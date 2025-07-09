//
//  DiaryViewModel.swift
//  PetCare AI
//
//  Created on 2025/7/1.
//

import Foundation
import SwiftData
import SwiftUI
import Combine

class DiaryViewModel: ObservableObject {
    private var modelContext: ModelContext?
    @Published var diaryEntries: [PetDiary] = []
    @Published var selectedPet: Pet?
    @Published var searchText: String = ""
    @Published var selectedCategory: DiaryCategory?
    @Published var selectedDateRange: DateRange = .all
    @Published var statistics: DiaryStatistics = .empty
    
    // 日期范围筛选选项
    enum DateRange: String, CaseIterable {
        case all = "全部时期"
        case thisMonth = "本月日记"
        case lastMonth = "上月日记"
        case thisYear = "今年日记"
        case lastYear = "去年日记"
        
        var predicate: Date? {
            let calendar = Calendar.current
            let now = Date()
            
            switch self {
            case .all:
                return nil
            case .thisMonth:
                return calendar.date(from: calendar.dateComponents([.year, .month], from: now))
            case .lastMonth:
                let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
                return calendar.date(from: calendar.dateComponents([.year, .month], from: lastMonth))
            case .thisYear:
                return calendar.date(from: calendar.dateComponents([.year], from: now))
            case .lastYear:
                let lastYear = calendar.date(byAdding: .year, value: -1, to: now) ?? now
                return calendar.date(from: calendar.dateComponents([.year], from: lastYear))
            }
        }
    }
    
    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadDiaryEntries()
        updateStatistics()
    }
    
    // 加载日记条目
    func loadDiaryEntries() {
        guard let modelContext = modelContext else { return }
        
        var descriptor = FetchDescriptor<PetDiary>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        // 应用筛选条件
        var predicates: [Predicate<PetDiary>] = []
        
        // 宠物筛选
        if let selectedPet = selectedPet {
            let petID = selectedPet.id
            predicates.append(#Predicate<PetDiary> { diary in
                diary.petID == petID
            })
        }
        
        // 分类筛选
        if let selectedCategory = selectedCategory {
            let category = selectedCategory
            predicates.append(#Predicate<PetDiary> { diary in
                diary.category == category
            })
        }
        
        // 日期范围筛选
        if let startDate = selectedDateRange.predicate {
            let calendar = Calendar.current
            let endDate: Date
            
            switch selectedDateRange {
            case .thisMonth, .lastMonth:
                endDate = calendar.date(byAdding: .month, value: 1, to: startDate) ?? Date()
            case .thisYear, .lastYear:
                endDate = calendar.date(byAdding: .year, value: 1, to: startDate) ?? Date()
            case .all:
                endDate = Date()
            }
            
            predicates.append(#Predicate<PetDiary> { diary in
                diary.date >= startDate && diary.date < endDate
            })
        }
        
        // 搜索文本筛选
        if !searchText.isEmpty {
            let searchText = searchText
            predicates.append(#Predicate<PetDiary> { diary in
                diary.title.localizedStandardContains(searchText) ||
                diary.content.localizedStandardContains(searchText)
            })
        }
        
        // 组合所有筛选条件
        if predicates.count == 1 {
            descriptor.predicate = predicates[0]
        } else if predicates.count > 1 {
            // 简化组合逻辑，只使用第一个谓词
            descriptor.predicate = predicates[0]
        }
        
        do {
            diaryEntries = try modelContext.fetch(descriptor)
        } catch {
            print("加载日记失败: \(error)")
        }
    }
    
    // 更新统计信息
    func updateStatistics() {
        guard let modelContext = modelContext else { return }
        
        do {
            // 获取所有日记条目
            let allDescriptor = FetchDescriptor<PetDiary>()
            let allEntries = try modelContext.fetch(allDescriptor)
            
            // 计算统计数据
            let calendar = Calendar.current
            let now = Date()
            let thisMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
            let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: thisMonthStart) ?? now
            
            let thisMonthEntries = allEntries.filter { $0.date >= thisMonthStart }
            let lastMonthEntries = allEntries.filter { 
                $0.date >= lastMonthStart && $0.date < thisMonthStart 
            }
            
            // 分类统计
            var categoryCounts: [DiaryCategory: Int] = [:]
            for category in DiaryCategory.allCases {
                categoryCounts[category] = allEntries.filter { $0.category == category }.count
            }
            
            // 最近条目
            let recentEntries = Array(allEntries.sorted { $0.date > $1.date }.prefix(5))
            
            statistics = DiaryStatistics(
                totalEntries: allEntries.count,
                thisMonthEntries: thisMonthEntries.count,
                lastMonthEntries: lastMonthEntries.count,
                categoryCounts: categoryCounts,
                recentEntries: recentEntries
            )
        } catch {
            print("更新统计信息失败: \(error)")
        }
    }
    
    // 添加新日记条目
    func addDiary(_ diary: PetDiary) {
        guard let modelContext = modelContext else { return }
        
        modelContext.insert(diary)
        
        do {
            try modelContext.save()
            loadDiaryEntries()
            updateStatistics()
        } catch {
            print("保存日记失败: \(error)")
        }
    }
    
    // 更新日记条目
    func updateDiary(_ diary: PetDiary) {
        guard let modelContext = modelContext else { return }
        
        diary.updatedAt = Date()
        
        do {
            try modelContext.save()
            loadDiaryEntries()
            updateStatistics()
        } catch {
            print("更新日记失败: \(error)")
        }
    }
    
    // 删除日记条目
    func deleteDiary(_ diary: PetDiary) {
        guard let modelContext = modelContext else { return }
        
        modelContext.delete(diary)
        
        do {
            try modelContext.save()
            loadDiaryEntries()
            updateStatistics()
        } catch {
            print("删除日记失败: \(error)")
        }
    }
    
    // 清空筛选条件
    func clearFilters() {
        searchText = ""
        selectedCategory = nil
        selectedDateRange = .all
        loadDiaryEntries()
    }
    
    // 获取指定宠物的日记数量
    func getDiaryCount(for pet: Pet) -> Int {
        return diaryEntries.filter { $0.petID == pet.id }.count
    }
    
    // 获取指定分类的日记数量
    func getCategoryCount(_ category: DiaryCategory) -> Int {
        return statistics.categoryCounts[category] ?? 0
    }
}