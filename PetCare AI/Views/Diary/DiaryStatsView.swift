//
//  DiaryStatsView.swift
//  PetCare AI
//
//  Created on 2025/7/1.
//

import SwiftUI
import Charts

struct DiaryStatsView: View {
    @ObservedObject var diaryViewModel: DiaryViewModel
    let pets: [Pet]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 总体统计
                overallStatsSection
                
                // 分类统计
                categoryStatsSection
                
                // 时间趋势（如果有足够数据）
                if diaryViewModel.statistics.totalEntries > 5 {
                    timelineStatsSection
                }
                
                // 最近记录
                recentEntriesSection
            }
            .padding()
        }
        .navigationTitle("日记统计")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // 总体统计部分
    private var overallStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("总体概览")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                StatsCard(
                    title: "总日记数",
                    value: "\(diaryViewModel.statistics.totalEntries)",
                    subtitle: "累计记录",
                    color: .blue,
                    icon: "book.fill"
                )
                
                StatsCard(
                    title: "本月记录",
                    value: "\(diaryViewModel.statistics.thisMonthEntries)",
                    subtitle: "本月新增",
                    color: .green,
                    icon: "calendar"
                )
                
                StatsCard(
                    title: "平均频率",
                    value: calculateAverageFrequency(),
                    subtitle: "每周记录",
                    color: .orange,
                    icon: "chart.line.uptrend.xyaxis"
                )
                
                StatsCard(
                    title: "最爱分类",
                    value: getMostUsedCategory(),
                    subtitle: "使用最多",
                    color: .purple,
                    icon: "heart.fill"
                )
            }
        }
    }
    
    // 分类统计部分
    private var categoryStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("分类统计")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(DiaryCategory.allCases, id: \.self) { category in
                    let count = diaryViewModel.getCategoryCount(category)
                    if count > 0 {
                        CategoryStatsCard(category: category, count: count)
                    }
                }
            }
        }
    }
    
    // 时间趋势部分
    private var timelineStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("记录趋势")
                .font(.title2)
                .fontWeight(.bold)
            
            // 这里可以添加图表显示时间趋势
            // 由于Charts框架可能需要额外配置，先使用简单的月度对比
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("本月")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(diaryViewModel.statistics.thisMonthEntries)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("条记录")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                VStack(alignment: .leading) {
                    Text("上月")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(diaryViewModel.statistics.lastMonthEntries)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    
                    Text("条记录")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            
            // 趋势分析
            let trend = getTrendAnalysis()
            HStack {
                Image(systemName: trend.isPositive ? "arrow.up.right" : "arrow.down.right")
                    .foregroundColor(trend.isPositive ? .green : .red)
                
                Text(trend.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // 最近记录部分
    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("最近记录")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(diaryViewModel.statistics.recentEntries) { diary in
                RecentEntryRow(diary: diary, pets: pets)
            }
        }
    }
    
    // 计算平均记录频率
    private func calculateAverageFrequency() -> String {
        let totalEntries = diaryViewModel.statistics.totalEntries
        guard totalEntries > 0 else { return "0" }
        
        // 假设第一条记录是30天前（这里可以从实际数据中获取）
        let daysAgo = 30
        let weeks = max(1, daysAgo / 7)
        
        let averagePerWeek = Double(totalEntries) / Double(weeks)
        return String(format: "%.1f", averagePerWeek)
    }
    
    // 获取最常用的分类
    private func getMostUsedCategory() -> String {
        let categoryCounts = diaryViewModel.statistics.categoryCounts
        guard let mostUsed = categoryCounts.max(by: { $0.value < $1.value }) else {
            return "无"
        }
        return mostUsed.key.rawValue
    }
    
    // 获取趋势分析
    private func getTrendAnalysis() -> (isPositive: Bool, description: String) {
        let thisMonth = diaryViewModel.statistics.thisMonthEntries
        let lastMonth = diaryViewModel.statistics.lastMonthEntries
        
        if thisMonth > lastMonth {
            let increase = thisMonth - lastMonth
            return (true, "比上月增加 \(increase) 条记录")
        } else if thisMonth < lastMonth {
            let decrease = lastMonth - thisMonth
            return (false, "比上月减少 \(decrease) 条记录")
        } else {
            return (true, "与上月持平")
        }
    }
}

// 统计卡片组件
struct StatsCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// 分类统计卡片
struct CategoryStatsCard: View {
    let category: DiaryCategory
    let count: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: category.iconName)
                .font(.title2)
                .foregroundColor(Color(category.colorName))
            
            Text("\(count)")
                .font(.title3)
                .fontWeight(.bold)
            
            Text(category.rawValue)
                .font(.caption)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color(category.colorName).opacity(0.1))
        .cornerRadius(10)
    }
}

// 最近条目行
struct RecentEntryRow: View {
    let diary: PetDiary
    let pets: [Pet]
    
    private var pet: Pet? {
        pets.first { $0.id == diary.petID }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: diary.category.iconName)
                .font(.caption)
                .foregroundColor(Color(diary.category.colorName))
                .frame(width: 24, height: 24)
                .background(Color(diary.category.colorName).opacity(0.1))
                .cornerRadius(6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(diary.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                HStack {
                    if let pet = pet {
                        Text(pet.name)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    Text("·")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(diary.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        DiaryStatsView(diaryViewModel: DiaryViewModel(), pets: [])
    }
}