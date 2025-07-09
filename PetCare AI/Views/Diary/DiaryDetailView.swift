//
//  DiaryDetailView.swift
//  PetCare AI
//
//  Created on 2025/7/1.
//

import SwiftUI
import PhotosUI

struct DiaryDetailView: View {
    let diary: PetDiary
    @ObservedObject var diaryViewModel: DiaryViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isEditing = false
    @State private var editedTitle: String = ""
    @State private var editedContent: String = ""
    @State private var editedCategory: DiaryCategory = .daily
    @State private var editedDate = Date()
    @State private var selectedImage: PhotosPickerItem?
    @State private var newImageData: Data?
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 头部信息
                headerSection
                
                // 照片显示
                if let imageData = newImageData ?? diary.imageData,
                   let uiImage = UIImage(data: imageData) {
                    imageSection(uiImage: uiImage)
                }
                
                // 内容部分
                contentSection
                
                // 元数据
                metadataSection
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if isEditing {
                        Button("取消") {
                            cancelEditing()
                        }
                        
                        Button("保存") {
                            saveChanges()
                        }
                        .fontWeight(.semibold)
                    } else {
                        Menu {
                            Button("编辑", systemImage: "pencil") {
                                startEditing()
                            }
                            
                            Button("删除", systemImage: "trash", role: .destructive) {
                                showingDeleteAlert = true
                            }
                            
                            Button("分享", systemImage: "square.and.arrow.up") {
                                // TODO: 实现分享功能
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
        }
        .alert("删除日记", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                deleteDiary()
            }
        } message: {
            Text("确定要删除这条日记吗？此操作无法撤销。")
        }
        .onChange(of: selectedImage) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    newImageData = data
                }
            }
        }
    }
    
    // 头部信息
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // 分类图标
                Image(systemName: (isEditing ? editedCategory : diary.category).iconName)
                    .font(.title)
                    .foregroundColor(Color((isEditing ? editedCategory : diary.category).colorName))
                    .frame(width: 40, height: 40)
                    .background(Color((isEditing ? editedCategory : diary.category).colorName).opacity(0.1))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    if isEditing {
                        TextField("日记标题", text: $editedTitle)
                            .font(.title2)
                            .fontWeight(.bold)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(diary.title)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    if isEditing {
                        DatePicker("记录日期", selection: $editedDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                    } else {
                        Text(diary.date, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            // 分类选择（编辑模式）
            if isEditing {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(DiaryCategory.allCases, id: \.self) { category in
                            CategoryChip(
                                category: category,
                                isSelected: editedCategory == category
                            ) {
                                editedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                HStack {
                    Text(diary.category.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(diary.category.colorName).opacity(0.1))
                        .foregroundColor(Color(diary.category.colorName))
                        .cornerRadius(12)
                    
                    Spacer()
                }
            }
        }
    }
    
    // 图片部分
    private func imageSection(uiImage: UIImage) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if isEditing {
                HStack {
                    Text("照片")
                        .font(.headline)
                    
                    Spacer()
                    
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        Text("更换照片")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    Button("移除", role: .destructive) {
                        newImageData = nil
                        if diary.imageData != nil {
                            diary.imageData = nil
                        }
                    }
                    .font(.caption)
                }
            }
            
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(12)
        }
    }
    
    // 内容部分
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("日记内容")
                .font(.headline)
            
            if isEditing {
                TextEditor(text: $editedContent)
                    .frame(minHeight: 150)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            } else {
                Text(diary.content)
                    .font(.body)
                    .lineSpacing(4)
            }
        }
    }
    
    // 元数据部分
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Label("创建时间", systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(diary.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                + Text(" ")
                + Text(diary.createdAt, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if diary.updatedAt != diary.createdAt {
                VStack(alignment: .leading, spacing: 8) {
                    Label("最后修改", systemImage: "pencil")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(diary.updatedAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    + Text(" ")
                    + Text(diary.updatedAt, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // 开始编辑
    private func startEditing() {
        editedTitle = diary.title
        editedContent = diary.content
        editedCategory = diary.category
        editedDate = diary.date
        newImageData = diary.imageData
        isEditing = true
    }
    
    // 取消编辑
    private func cancelEditing() {
        isEditing = false
        newImageData = nil
        selectedImage = nil
    }
    
    // 保存更改
    private func saveChanges() {
        // Create a copy with updated values
        let updatedDiary = diary
        updatedDiary.title = editedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedDiary.content = editedContent.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedDiary.category = editedCategory
        updatedDiary.date = editedDate
        
        if let newImageData = newImageData {
            updatedDiary.imageData = newImageData
        }
        
        diaryViewModel.updateDiary(updatedDiary)
        isEditing = false
        newImageData = nil
        selectedImage = nil
    }
    
    // 删除日记
    private func deleteDiary() {
        diaryViewModel.deleteDiary(diary)
        dismiss()
    }
}

// 分类标签组件
struct CategoryChip: View {
    let category: DiaryCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: category.iconName)
                    .font(.caption)
                
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? Color(category.colorName) : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
    }
}

#Preview {
    NavigationView {
        DiaryDetailView(
            diary: PetDiary(
                title: "小七的快乐时光",
                content: "今天带小七去公园玩，它特别兴奋，一直在草地上跑来跑去。看到其他小狗也很友好，社交能力很棒！",
                category: .play,
                petID: UUID()
            ),
            diaryViewModel: DiaryViewModel()
        )
    }
}