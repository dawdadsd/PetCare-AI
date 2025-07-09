//
//  FeedingGuideView.swift
//  PetCare AI
//
//  Created by 徐北游 on 2025/7/1.
//

import SwiftUI

/// 科学喂食指南视图
/// 职责：提供简洁的喂食指南和智能计算功能
struct FeedingGuideView: View {
    // MARK: - 状态管理
    @State private var selectedPetType: PetType = .cat
    @State private var showingCalculator = false
    
    // MARK: - 数据源
    private let feedingGuideManager = FeedingGuideManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景色
                DesignSystem.Colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // 快速功能区
                        quickActionsSection
                        
                        // 宠物类型切换器
                        petTypeSelector
                        
                        // 简化的喂食指南内容
                        simplifiedGuideContent
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.xl)
                }
            }
            .navigationTitle("喂食指南")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingCalculator) {
                FeedingCalculatorView()
            }
        }
    }
    
    // MARK: - 计算属性
    
    /// 当前选中宠物类型的指南数据
    private var currentGuides: [FeedingGuide] {
        feedingGuideManager.getGuides(for: selectedPetType)
    }
    
    // MARK: - 视图组件
    
    /// 快速功能区
    private var quickActionsSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // 标题
            HStack {
                Text("智能喂食助手")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                Spacer()
            }
            
            // 功能按钮
            HStack(spacing: DesignSystem.Spacing.md) {
                // 喂食量计算器
                quickActionButton(
                    title: "智能计算",
                    subtitle: "个性化喂食量",
                    icon: "calculator.fill",
                    color: DesignSystem.Colors.primary
                ) {
                    showingCalculator = true
                }
                
                // 通用指南
                quickActionButton(
                    title: "科学指南",
                    subtitle: "年龄段建议",
                    icon: "book.fill",
                    color: DesignSystem.Colors.accent
                ) {
                    // 滚动到指南内容
                }
            }
        }
        .modernCard()
    }
    
    /// 宠物类型选择器（简化版）
    private var petTypeSelector: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(PetType.allCases, id: \.self) { petType in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedPetType = petType
                    }
                } label: {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Image(systemName: petType.icon)
                            .font(.system(size: 16, weight: .medium))
                        
                        Text(petType.rawValue)
                            .font(DesignSystem.Typography.bodyMedium)
                    }
                    .foregroundColor(selectedPetType == petType ? .white : DesignSystem.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(
                        selectedPetType == petType ?
                        DesignSystem.Colors.primary :
                        DesignSystem.Colors.surface
                    )
                    .cornerRadius(DesignSystem.CornerRadius.sm)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(3)
        .background(DesignSystem.Colors.backgroundSecondary)
        .cornerRadius(DesignSystem.CornerRadius.sm + 3)
    }
    
    /// 简化的指南内容
    private var simplifiedGuideContent: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // 标题
            HStack {
                Text("\(selectedPetType.rawValue)喂食指南")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                Spacer()
            }
            
            // 年龄段卡片（横向滚动）
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    ForEach(currentGuides.indices, id: \.self) { index in
                        let guide = currentGuides[index]
                        CompactGuideCard(guide: guide)
                            .frame(width: 280)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
            }
            .padding(.horizontal, -DesignSystem.Spacing.md)
        }
    }
    
    /// 快速功能按钮
    private func quickActionButton(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(color)
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text(subtitle)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.lg)
            .background(color.opacity(0.1))
            .cornerRadius(DesignSystem.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// 简化的喂食指南卡片
struct CompactGuideCard: View {
    let guide: FeedingGuide
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // 年龄段标题
            HStack {
                Image(systemName: guide.petType.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.primary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(guide.ageStage.rawValue)
                        .font(DesignSystem.Typography.titleMedium)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text(guide.ageStage.description)
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
            }
            
            Divider()
            
            // 关键信息
            VStack(spacing: DesignSystem.Spacing.sm) {
                compactInfoRow("每日餐数", guide.dailyMeals, "clock.fill")
                compactInfoRow("喂食时间", guide.mealTiming, "calendar")
                compactInfoRow("热量需求", guide.calories, "flame.fill")
            }
            
            // 主要营养要点（显示前3个）
            if !guide.nutritionFocus.isEmpty {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("营养重点")
                        .font(DesignSystem.Typography.captionMedium)
                        .foregroundColor(DesignSystem.Colors.primary)
                    
                    ForEach(guide.nutritionFocus.prefix(3).indices, id: \.self) { index in
                        HStack(alignment: .top, spacing: DesignSystem.Spacing.xs) {
                            Circle()
                                .fill(DesignSystem.Colors.primary)
                                .frame(width: 4, height: 4)
                                .padding(.top, 6)
                            
                            Text(guide.nutritionFocus[index])
                                .font(DesignSystem.Typography.footnote)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    if guide.nutritionFocus.count > 3 {
                        Text("还有\(guide.nutritionFocus.count - 3)项建议...")
                            .font(DesignSystem.Typography.small)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                            .padding(.top, 2)
                    }
                }
                .padding(.top, DesignSystem.Spacing.sm)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.surface)
        .cornerRadius(DesignSystem.CornerRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .stroke(DesignSystem.Colors.primary.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: DesignSystem.Shadow.soft, radius: 4, x: 0, y: 2)
    }
    
    /// 简化的信息行
    private func compactInfoRow(_ title: String, _ value: String, _ icon: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(DesignSystem.Colors.primary)
                .frame(width: 16)
            
            Text(title)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .frame(width: 60, alignment: .leading)
            
            Text(value)
                .font(DesignSystem.Typography.captionMedium)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    NavigationStack {
        FeedingGuideView()
    }
}