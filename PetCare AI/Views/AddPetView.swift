//
//  AddPetView.swift
//  PetCare AI
//
//  Created by 徐北游 on 2025/7/1.
//

import SwiftUI
import PhotosUI
import UIKit

/// 添加宠物视图 - 现代化表单设计
/// 职责：提供宠物信息输入界面，数据验证和保存
struct AddPetView: View {
    @Bindable var viewModel: PetListViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - 表单状态
    @State private var name = ""
    @State private var species = "猫"
    @State private var breed = ""
    @State private var gender = "公"
    @State private var birthday = Date()
    @State private var weight = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var avatarImage: UIImage?
    @State private var isShowingImagePicker = false
    
    // 预定义选项
    private let speciesOptions = ["猫", "狗"]
    private let genderOptions = ["公", "母"]
    
    // 根据物种动态生成品种选项
    private var availableBreeds: [String] {
        if species == "猫" {
            return ["布偶猫", "英短", "美短", "波斯猫", "暹罗猫", "橘猫", "田园猫", "其他"]
        } else {
            return ["金毛寻回犬", "拉布拉多", "柴犬", "边境牧羊犬", "泰迪", "比熊", "田园犬", "其他"]
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // 头像选择区域
                        avatarSection
                        
                        // 基本信息表单
                        formSection
                        
                        // 保存按钮
                        saveButton
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.top, DesignSystem.Spacing.md)
                }
            }
            .navigationTitle("添加宠物")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelButton
                }
            }
            .alert("错误", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("确定") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    // MARK: - 视图组件
    
    /// 头像选择区域
    private var avatarSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // 头像显示
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.primary.opacity(0.1),
                                DesignSystem.Colors.accent.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                if let avatarImage = avatarImage {
                    Image(uiImage: avatarImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else {
                    VStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.primary)
                        
                        Text("添加照片")
                            .font(DesignSystem.Typography.captionMedium)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
            }
            .overlay(
                Circle()
                    .stroke(DesignSystem.Colors.border, lineWidth: 2)
            )
            .onTapGesture {
                isShowingImagePicker = true
            }
            
            // 头像选择按钮
            PhotosPicker(selection: $selectedImage,
                        matching: .images,
                        photoLibrary: .shared()) {
                Text("选择照片")
                    .font(DesignSystem.Typography.captionMedium)
                    .foregroundColor(DesignSystem.Colors.primary)
            }
            .onChange(of: selectedImage) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        avatarImage = UIImage(data: data)
                    }
                }
            }
        }
        .padding(.top, DesignSystem.Spacing.md)
    }
    
    /// 表单区域
    private var formSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // 宠物名字
            FormFieldView(title: "宠物名字 *", isRequired: true) {
                TextField("给你的宠物起个名字", text: $name)
                    .textFieldStyle(ModernTextFieldStyle())
            }
            
            // 物种选择
            FormFieldView(title: "宠物类型 *", isRequired: true) {
                Picker("物种", selection: $species) {
                    ForEach(speciesOptions, id: \.self) { option in
                        HStack {
                            Image(systemName: option == "猫" ? "cat.fill" : "dog.fill")
                            Text(option)
                        }.tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: species) { _, _ in
                    // 物种改变时重置品种选择
                    breed = ""
                }
            }
            
            // 品种选择
            FormFieldView(title: "品种 *", isRequired: true) {
                Menu {
                    ForEach(availableBreeds, id: \.self) { breedOption in
                        Button(breedOption) {
                            breed = breedOption
                        }
                    }
                } label: {
                    HStack {
                        Text(breed.isEmpty ? "选择品种" : breed)
                            .foregroundColor(breed.isEmpty ? DesignSystem.Colors.textTertiary : DesignSystem.Colors.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.sm + 2)
                    .background(DesignSystem.Colors.surface)
                    .cornerRadius(DesignSystem.CornerRadius.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .stroke(DesignSystem.Colors.border, lineWidth: 1)
                    )
                }
            }
            
            // 性别选择
            FormFieldView(title: "性别") {
                Picker("性别", selection: $gender) {
                    ForEach(genderOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            // 生日选择
            FormFieldView(title: "生日") {
                DatePicker("生日", selection: $birthday, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .labelsHidden()
            }
            
            // 体重输入
            FormFieldView(title: "体重 (kg)") {
                TextField("例如: 5.2", text: $weight)
                    .textFieldStyle(ModernTextFieldStyle())
                    .keyboardType(.decimalPad)
            }
        }
        .modernCard()
        .padding(.horizontal, DesignSystem.Spacing.xs)
    }
    
    /// 保存按钮
    private var saveButton: some View {
        Button {
            savePet()
        } label: {
            HStack {
                Image(systemName: "checkmark")
                Text("保存宠物")
            }
        }
        .primaryButton(isEnabled: isValidForm)
        .padding(.top, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.xl)
    }
    
    /// 取消按钮
    private var cancelButton: some View {
        Button("取消") {
            dismiss()
        }
        .foregroundColor(DesignSystem.Colors.textSecondary)
    }
    
    // MARK: - 计算属性
    
    /// 表单验证
    private var isValidForm: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !breed.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - 方法
    
    /// 保存宠物
    private func savePet() {
        let weightValue = Float(weight) ?? 0.0
        
        viewModel.addPet(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            breed: breed.trimmingCharacters(in: .whitespacesAndNewlines),
            species: species,
            gender: gender,
            birthday: birthday,
            weight: weightValue
        )
        
        if viewModel.errorMessage == nil {
            dismiss()
        }
    }
}

/// 表单字段视图
struct FormFieldView<Content: View>: View {
    let title: String
    let isRequired: Bool
    let content: () -> Content
    
    init(title: String, isRequired: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.isRequired = isRequired
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            HStack {
                Text(title)
                    .font(DesignSystem.Typography.captionMedium)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                if isRequired {
                    Text("*")
                        .font(DesignSystem.Typography.captionMedium)
                        .foregroundColor(DesignSystem.Colors.error)
                }
                
                Spacer()
            }
            
            content()
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

/// 现代化文本框样式
struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(DesignSystem.Typography.body)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm + 2)
            .background(DesignSystem.Colors.surface)
            .cornerRadius(DesignSystem.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            )
    }
}

#Preview {
    AddPetView(viewModel: PetListViewModel())
}