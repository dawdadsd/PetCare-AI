//
//  DiaryFiltersView.swift
//  PetCare AI
//
//  Created on 2025/7/1.
//

import SwiftUI

struct DiaryFiltersView: View {
    @ObservedObject var diaryViewModel: DiaryViewModel
    let pets: [Pet]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                // 宠物筛选
                Section("选择宠物") {
                    Button("所有宠物") {
                        diaryViewModel.selectedPet = nil
                    }
                    .foregroundColor(diaryViewModel.selectedPet == nil ? .blue : .primary)
                    
                    ForEach(pets) { pet in
                        Button(pet.name) {
                            diaryViewModel.selectedPet = pet
                        }
                        .foregroundColor(diaryViewModel.selectedPet?.id == pet.id ? .blue : .primary)
                    }
                }
                
                // 分类筛选
                Section("日记分类") {
                    Button("所有分类") {
                        diaryViewModel.selectedCategory = nil
                    }
                    .foregroundColor(diaryViewModel.selectedCategory == nil ? .blue : .primary)
                    
                    ForEach(DiaryCategory.allCases, id: \.self) { category in
                        HStack {
                            Image(systemName: category.iconName)
                                .foregroundColor(Color(category.colorName))
                            
                            Text(category.rawValue)
                            
                            Spacer()
                            
                            Text("\(diaryViewModel.getCategoryCount(category))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            diaryViewModel.selectedCategory = category
                        }
                        .foregroundColor(diaryViewModel.selectedCategory == category ? .blue : .primary)
                    }
                }
                
                // 时间范围筛选
                Section("时间范围") {
                    ForEach(DiaryViewModel.DateRange.allCases, id: \.self) { range in
                        Button(range.rawValue) {
                            diaryViewModel.selectedDateRange = range
                        }
                        .foregroundColor(diaryViewModel.selectedDateRange == range ? .blue : .primary)
                    }
                }
            }
            .navigationTitle("筛选条件")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("重置") {
                        diaryViewModel.clearFilters()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        diaryViewModel.loadDiaryEntries()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    DiaryFiltersView(diaryViewModel: DiaryViewModel(), pets: [])
}