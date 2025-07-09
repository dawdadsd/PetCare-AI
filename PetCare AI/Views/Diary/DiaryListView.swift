//
//  DiaryListView.swift
//  PetCare AI
//
//  Created on 2025/7/1.
//

import SwiftUI
import SwiftData

struct DiaryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var pets: [Pet]
    @State private var diaryViewModel = DiaryViewModel()
    @State private var showingAddDiary = false
    @State private var showingFilters = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏和筛选按钮
                searchAndFilterSection
                
                if diaryViewModel.diaryEntries.isEmpty {
                    emptyStateView
                } else {
                    // 日记条目列表
                    diaryEntriesList
                }
            }
            .navigationTitle("宠物日常记录")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddDiary = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddDiary) {
                AddDiaryEntryView(diaryViewModel: diaryViewModel, pets: pets)
            }
            .sheet(isPresented: $showingFilters) {
                DiaryFiltersView(diaryViewModel: diaryViewModel, pets: pets)
            }
            .onAppear {
                diaryViewModel.setup(modelContext: modelContext)
            }
        }
    }
    
    // 搜索和筛选部分
    private var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            // 搜索栏
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("搜索日记内容...", text: $diaryViewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: diaryViewModel.searchText) { _, _ in
                        diaryViewModel.loadDiaryEntries()
                    }
                
                Button(action: { showingFilters = true }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // 快速筛选标签
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // 所有宠物
                    FilterChip(
                        title: "所有宠物", 
                        isSelected: diaryViewModel.selectedPet == nil
                    ) {
                        diaryViewModel.selectedPet = nil
                        diaryViewModel.loadDiaryEntries()
                    }
                    
                    // 宠物筛选
                    ForEach(pets) { pet in
                        FilterChip(
                            title: pet.name,
                            isSelected: diaryViewModel.selectedPet?.id == pet.id
                        ) {
                            diaryViewModel.selectedPet = pet
                            diaryViewModel.loadDiaryEntries()
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // 统计信息
            statsSection
        }
        .background(Color(.systemGray6))
    }
    
    // 统计信息部分
    private var statsSection: some View {
        HStack(spacing: 16) {
            StatCard(title: "日记总数", value: "\(diaryViewModel.statistics.totalEntries)")
            StatCard(title: "本月日记", value: "\(diaryViewModel.statistics.thisMonthEntries)")
            StatCard(title: "上月日记", value: "\(diaryViewModel.statistics.lastMonthEntries)")
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    // 日记条目列表
    private var diaryEntriesList: some View {
        List {
            ForEach(diaryViewModel.diaryEntries) { diary in
                NavigationLink(destination: DiaryDetailView(diary: diary, diaryViewModel: diaryViewModel)) {
                    DiaryRowView(diary: diary, pets: pets)
                }
            }
            .onDelete(perform: deleteDiaries)
        }
        .listStyle(PlainListStyle())
        .refreshable {
            diaryViewModel.loadDiaryEntries()
            diaryViewModel.updateStatistics()
        }
    }
    
    // 空状态视图
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("还没有日记记录")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("记录你和宠物的每一个美好时刻")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: { showingAddDiary = true }) {
                Label("添加第一条日记", systemImage: "plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // 删除日记条目
    private func deleteDiaries(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                diaryViewModel.deleteDiary(diaryViewModel.diaryEntries[index])
            }
        }
    }
}

// 筛选标签组件
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

// 统计卡片组件
struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(8)
    }
}

// 日记行视图
struct DiaryRowView: View {
    let diary: PetDiary
    let pets: [Pet]
    
    private var pet: Pet? {
        pets.first { $0.id == diary.petID }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 分类图标
            Image(systemName: diary.category.iconName)
                .font(.title2)
                .foregroundColor(Color(diary.category.colorName))
                .frame(width: 30, height: 30)
                .background(Color(diary.category.colorName).opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                // 标题和宠物名
                HStack {
                    Text(diary.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if let pet = pet {
                        Text(pet.name)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                }
                
                // 内容预览
                Text(diary.content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                // 分类和日期
                HStack {
                    Text(diary.category.rawValue)
                        .font(.caption)
                        .foregroundColor(Color(diary.category.colorName))
                    
                    Spacer()
                    
                    Text(diary.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // 图片指示器
            if diary.imageData != nil {
                Image(systemName: "photo")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    DiaryListView()
        .modelContainer(for: [Pet.self, PetDiary.self], inMemory: true)
}