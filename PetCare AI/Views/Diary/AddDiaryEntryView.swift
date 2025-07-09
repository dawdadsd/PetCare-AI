//
//  AddDiaryEntryView.swift
//  PetCare AI
//
//  Created on 2025/7/1.
//

import SwiftUI
import PhotosUI

struct AddDiaryEntryView: View {
    @ObservedObject var diaryViewModel: DiaryViewModel
    let pets: [Pet]
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedCategory: DiaryCategory = .daily
    @State private var selectedPet: Pet?
    @State private var selectedDate = Date()
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var showingImagePicker = false
    
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedPet != nil
    }
    
    var body: some View {
        NavigationView {
            Form {
                // 基本信息
                Section("基本信息") {
                    TextField("日记标题", text: $title)
                        .textInputAutocapitalization(.sentences)
                    
                    DatePicker("记录日期", selection: $selectedDate, displayedComponents: .date)
                    
                    Picker("选择宠物", selection: $selectedPet) {
                        Text("请选择宠物").tag(nil as Pet?)
                        ForEach(pets) { pet in
                            Text(pet.name).tag(pet as Pet?)
                        }
                    }
                }
                
                // 分类选择
                Section("日记分类") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(DiaryCategory.allCases, id: \.self) { category in
                                CategoryCard(
                                    category: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                    // 如果选择了模板分类，自动填充模板内容
                                    if content.isEmpty {
                                        content = category.templateContent
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // 内容编辑
                Section("日记内容") {
                    TextEditor(text: $content)
                        .frame(minHeight: 100)
                        .textInputAutocapitalization(.sentences)
                }
                
                // 照片添加
                Section("添加照片") {
                    if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                        HStack {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 100)
                                .cornerRadius(8)
                            
                            Spacer()
                            
                            Button("移除照片", role: .destructive) {
                                self.imageData = nil
                                selectedImage = nil
                            }
                        }
                    } else {
                        PhotosPicker(selection: $selectedImage, matching: .images) {
                            Label("选择照片", systemImage: "photo")
                        }
                    }
                }
            }
            .navigationTitle("添加日记")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveDiary()
                    }
                    .disabled(!isFormValid)
                    .fontWeight(.semibold)
                }
            }
            .onChange(of: selectedImage) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }
            .onAppear {
                // 如果只有一个宠物，自动选择
                if pets.count == 1 {
                    selectedPet = pets.first
                }
            }
        }
    }
    
    private func saveDiary() {
        guard let selectedPet = selectedPet else { return }
        
        let diary = PetDiary(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedCategory,
            date: selectedDate,
            petID: selectedPet.id,
            imageData: imageData
        )
        
        diaryViewModel.addDiary(diary)
        dismiss()
    }
}

// 分类卡片组件
struct CategoryCard: View {
    let category: DiaryCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: category.iconName)
                .font(.title2)
                .foregroundColor(isSelected ? .white : Color(category.colorName))
            
            Text(category.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
        }
        .frame(width: 80, height: 70)
        .background(isSelected ? Color(category.colorName) : Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(category.colorName), lineWidth: isSelected ? 2 : 0)
        )
        .onTapGesture {
            action()
        }
    }
}

#Preview {
    AddDiaryEntryView(diaryViewModel: DiaryViewModel(), pets: [])
}