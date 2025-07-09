//
//  PetDetailView.swift
//  PetCare AI
//
//  Created by 徐北游 on 2025/7/1.
//

import SwiftUI
import SwiftData
import UIKit

/// 宠物详情视图 - 现代化设计，支持查看和编辑
/// 职责：展示宠物详细信息，提供编辑和删除功能
struct PetDetailView: View {
    let pet: Pet
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel = PetDetailViewModel()
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // 头部信息卡片
                    headerCard
                    
                    // 基本信息卡片
                    basicInfoCard
                    
                    // 喂食建议卡片
                    if !viewModel.isEditing {
                        feedingRecommendationCard
                    }
                    
                    // 操作按钮区域
                    if !viewModel.isEditing {
                        actionButtons
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.xl)
            }
        }
        .navigationTitle(viewModel.isEditing ? "编辑宠物" : pet.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.isEditing {
                    saveButton
                } else {
                    editButton
                }
            }
            
            if viewModel.isEditing {
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelButton
                }
            }
        }
        .onAppear {
            viewModel.configure(with: modelContext, pet: pet)
        }
        .alert("删除宠物", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                deletePet()
            }
        } message: {
            Text("确定要删除 \(pet.name) 吗？此操作无法撤销。")
        }
        .alert("错误", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("确定") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .overlay(
            // 成功消息提示
            Group {
                if let successMessage = viewModel.successMessage {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(DesignSystem.Colors.success)
                            Text(successMessage)
                                .font(DesignSystem.Typography.captionMedium)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                        }
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                        .background(DesignSystem.Colors.surface)
                        .cornerRadius(DesignSystem.CornerRadius.md)
                        .shadow(color: DesignSystem.Shadow.medium, radius: 8, x: 0, y: 2)
                        .padding(.bottom, 100)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut, value: viewModel.successMessage)
        )
    }
    
    // MARK: - 视图组件
    
    /// 头部信息卡片
    private var headerCard: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // 宠物头像
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.primary.opacity(0.2),
                                DesignSystem.Colors.accent.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                if let avatarData = pet.avatarData,
                   let avatarImage = UIImage(data: avatarData) {
                    Image(uiImage: avatarImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }
            .overlay(
                Circle()
                    .stroke(DesignSystem.Colors.surface, lineWidth: 4)
                    .shadow(color: DesignSystem.Shadow.soft, radius: 8, x: 0, y: 2)
            )
            
            // 宠物基本信息
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text(pet.name)
                    .font(DesignSystem.Typography.title1)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .fontWeight(.bold)
                
                Text("\(pet.breed) • \(pet.gender)")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            // 年龄和体重信息
            HStack(spacing: DesignSystem.Spacing.lg) {
                InfoBadge(
                    icon: "calendar",
                    title: "年龄",
                    value: viewModel.ageDescription
                )
                
                InfoBadge(
                    icon: "scalemass",
                    title: "体重",
                    value: viewModel.weightDescription
                )
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .modernCard()
    }
    
    /// 基本信息卡片
    private var basicInfoCard: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("基本信息")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                Spacer()
            }
            
            if viewModel.isEditing {
                editingForm
            } else {
                infoDisplay
            }
        }
        .padding(DesignSystem.Spacing.md)
        .modernCard()
    }
    
    /// 编辑表单
    private var editingForm: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            EditableField(title: "名字", text: $viewModel.editingName)
            EditableField(title: "品种", text: $viewModel.editingBreed)
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("性别")
                    .font(DesignSystem.Typography.captionMedium)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Picker("性别", selection: $viewModel.editingGender) {
                    Text("公").tag("公")
                    Text("母").tag("母")
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("生日")
                    .font(DesignSystem.Typography.captionMedium)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                DatePicker("生日", selection: $viewModel.editingBirthday, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .labelsHidden()
            }
            
            EditableField(title: "体重 (kg)", text: $viewModel.editingWeight, keyboardType: .decimalPad)
        }
    }
    
    /// 信息展示
    private var infoDisplay: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            InfoRow(title: "名字", value: pet.name)
            InfoRow(title: "品种", value: pet.breed)
            InfoRow(title: "性别", value: pet.gender)
            InfoRow(title: "生日", value: DateFormatter.displayDate.string(from: pet.birthday))
            InfoRow(title: "体重", value: pet.weight > 0 ? String(format: "%.1f kg", pet.weight) : "未记录")
            InfoRow(title: "添加时间", value: DateFormatter.displayDateTime.string(from: pet.createdAt))
            
            if pet.updatedAt != pet.createdAt {
                InfoRow(title: "更新时间", value: DateFormatter.displayDateTime.string(from: pet.updatedAt))
            }
        }
    }
    
    /// 喂食建议卡片
    private var feedingRecommendationCard: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(DesignSystem.Colors.primary)
                    .font(.system(size: 16, weight: .medium))
                
                Text("喂食建议")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                NavigationLink(destination: FeedingCalculatorView()) {
                    Text("详细计算")
                        .font(DesignSystem.Typography.small)
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }
            
            // 显示喂食建议内容
            if pet.weight > 0 && !pet.species.isEmpty {
                feedingRecommendationContent
            } else {
                missingInfoPrompt
            }
        }
        .padding(DesignSystem.Spacing.md)
        .modernCard()
    }
    
    /// 喂食建议内容
    @ViewBuilder
    private var feedingRecommendationContent: some View {
        if let recommendation = try? FeedingRecommendationEngine.shared.generateRecommendation(for: pet) {
            VStack(spacing: DesignSystem.Spacing.sm) {
                // 基本推荐信息
                HStack {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("每日食量")
                            .font(DesignSystem.Typography.small)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        Text(recommendation.formattedDailyAmount)
                            .font(DesignSystem.Typography.title3)
                            .foregroundColor(DesignSystem.Colors.primary)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xs) {
                        Text("每餐分量")
                            .font(DesignSystem.Typography.small)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        Text(recommendation.formattedMealSize)
                            .font(DesignSystem.Typography.title3)
                            .foregroundColor(DesignSystem.Colors.accent)
                            .fontWeight(.semibold)
                    }
                }
                
                // 喂食次数和时间
                HStack {
                    Text("建议每日\(recommendation.feedingTimes)次")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    
                    Spacer()
                    
                    Text("年龄段: \(recommendation.ageCategory.displayName)")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                // 营养建议
                if !recommendation.nutritionTips.isEmpty {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text("营养建议")
                            .font(DesignSystem.Typography.captionMedium)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        
                        ForEach(recommendation.nutritionTips.prefix(2), id: \.self) { tip in
                            HStack(alignment: .top, spacing: DesignSystem.Spacing.xs) {
                                Text("•")
                                    .font(DesignSystem.Typography.small)
                                    .foregroundColor(DesignSystem.Colors.primary)
                                
                                Text(tip)
                                    .font(DesignSystem.Typography.small)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                    .lineLimit(2)
                            }
                        }
                    }
                }
            }
        } else {
            // 错误状态显示
            VStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(DesignSystem.Colors.warning)
                Text("无法计算喂食建议")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                Text("请检查宠物信息是否完整")
                    .font(DesignSystem.Typography.small)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    /// 缺失信息提示
    private var missingInfoPrompt: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "info.circle")
                .font(.system(size: 24))
                .foregroundColor(DesignSystem.Colors.textTertiary)
            
            Text("需要完善宠物信息")
                .font(DesignSystem.Typography.captionMedium)
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            Text("请添加宠物的体重和物种信息以获取个性化喂食建议")
                .font(DesignSystem.Typography.small)
                .foregroundColor(DesignSystem.Colors.textTertiary)
                .multilineTextAlignment(.center)
            
            Button {
                viewModel.isEditing = true
            } label: {
                Text("完善信息")
                    .font(DesignSystem.Typography.captionMedium)
                    .foregroundColor(DesignSystem.Colors.primary)
            }
            .padding(.top, DesignSystem.Spacing.xs)
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
    
    /// 操作按钮
    private var actionButtons: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Button {
                viewModel.isEditing = true
            } label: {
                HStack {
                    Image(systemName: "pencil")
                    Text("编辑信息")
                }
            }
            .primaryButton()
            
            Button {
                showingDeleteAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("删除宠物")
                }
            }
            .foregroundColor(DesignSystem.Colors.error)
            .font(DesignSystem.Typography.bodyMedium)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(DesignSystem.Colors.error.opacity(0.1))
            .cornerRadius(DesignSystem.CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .stroke(DesignSystem.Colors.error.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Toolbar按钮
    
    private var editButton: some View {
        Button("编辑") {
            viewModel.isEditing = true
        }
        .foregroundColor(DesignSystem.Colors.primary)
    }
    
    private var saveButton: some View {
        Button("保存") {
            viewModel.savePetChanges()
        }
        .foregroundColor(DesignSystem.Colors.primary)
        .disabled(!viewModel.isValidData)
    }
    
    private var cancelButton: some View {
        Button("取消") {
            viewModel.cancelEditing()
        }
        .foregroundColor(DesignSystem.Colors.textSecondary)
    }
    
    // MARK: - 方法
    
    private func deletePet() {
        viewModel.deletePet { success in
            if success {
                dismiss()
            }
        }
    }
}

// MARK: - 辅助视图组件

/// 信息标签
struct InfoBadge: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(DesignSystem.Colors.primary)
            
            Text(title)
                .font(DesignSystem.Typography.small)
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            Text(value)
                .font(DesignSystem.Typography.captionMedium)
                .foregroundColor(DesignSystem.Colors.textPrimary)
        }
        .frame(minWidth: 80)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.backgroundSecondary)
        .cornerRadius(DesignSystem.CornerRadius.md)
    }
}

/// 信息行
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(DesignSystem.Typography.captionMedium)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Spacer()
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
    }
}

/// 可编辑字段
struct EditableField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(title)
                .font(DesignSystem.Typography.captionMedium)
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            TextField("请输入\(title)", text: $text)
                .textFieldStyle(ModernTextFieldStyle())
                .keyboardType(keyboardType)
        }
    }
}

// MARK: - 日期格式器扩展
extension DateFormatter {
    static let displayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()
    
    static let displayDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()
}

#Preview {
    NavigationStack {
        PetDetailView(pet: Pet(name: "旺财", breed: "金毛寻回犬", species: "狗", gender: "公", birthday: Date()))
    }
    .modelContainer(for: Pet.self, inMemory: true)
}