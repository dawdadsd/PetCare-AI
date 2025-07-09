//
//  PetListView.swift
//  PetCare AI
//
//  Created by 徐北游 on 2025/7/1.
//

import SwiftUI
import SwiftData

/// 现代化宠物列表视图 - 符合2025年设计规范
/// 职责：展示宠物列表，提供搜索、排序、添加功能
struct PetListView: View {
    // MARK: - 数据和状态
    @Environment(\.modelContext) private var modelContext
    @Query private var pets: [Pet]
    
    @State private var viewModel = PetListViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景色
                DesignSystem.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 顶部搜索和排序区域
                    headerSection
                    
                    // 宠物列表内容
                    if filteredPets.isEmpty {
                        emptyStateView
                    } else {
                        petListContent
                    }
                }
            }
            .navigationTitle("我的宠物")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
            .sheet(isPresented: $viewModel.isShowingAddPet) {
                AddPetView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.setModelContext(modelContext)
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
    
    // MARK: - 计算属性
    
    /// 过滤后的宠物列表
    private var filteredPets: [Pet] {
        viewModel.filteredPets(pets)
    }
    
    // MARK: - 视图组件
    
    /// 顶部搜索和排序区域
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // 搜索框
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .font(.system(size: 16, weight: .medium))
                
                TextField("搜索宠物名字或品种", text: $viewModel.searchText)
                    .font(DesignSystem.Typography.body)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm + 2)
            .background(DesignSystem.Colors.surface)
            .cornerRadius(DesignSystem.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            )
            
            // 排序选择器
            HStack {
                Text("排序方式:")
                    .font(DesignSystem.Typography.captionMedium)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                Picker("排序", selection: $viewModel.selectedSortOption) {
                    ForEach(PetListViewModel.SortOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.top, DesignSystem.Spacing.sm)
        .padding(.bottom, DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.background)
    }
    
    /// 宠物列表内容
    private var petListContent: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.md) {
                ForEach(filteredPets, id: \.id) { pet in
                    NavigationLink(destination: PetDetailView(pet: pet)) {
                        PetCardView(pet: pet)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xl)
        }
        .refreshable {
            // 下拉刷新逻辑
        }
    }
    
    /// 空状态视图
    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Spacer()
            
            // 插图
            Image(systemName: "pawprint.fill")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(DesignSystem.Colors.textTertiary)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text(viewModel.searchText.isEmpty ? "还没有宠物" : "未找到匹配的宠物")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text(viewModel.searchText.isEmpty ? 
                     "点击右上角的 + 号添加你的第一只宠物吧！" : 
                     "试试修改搜索关键词或清空搜索")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.xl)
            }
            
            if viewModel.searchText.isEmpty {
                Button {
                    viewModel.isShowingAddPet = true
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("添加宠物")
                    }
                }
                .primaryButton()
                .padding(.horizontal, DesignSystem.Spacing.xl)
                .padding(.top, DesignSystem.Spacing.md)
            }
            
            Spacer()
        }
    }
    
    /// 添加按钮
    private var addButton: some View {
        Button {
            viewModel.isShowingAddPet = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.primary)
        }
    }
}

/// 宠物卡片视图 - 现代化设计
struct PetCardView: View {
    let pet: Pet
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // 宠物头像
            petAvatar
            
            // 宠物基本信息
            petBasicInfo
            
            Spacer()
            
            // 右侧箭头
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(DesignSystem.Colors.textTertiary)
        }
        .padding(DesignSystem.Spacing.md)
        .modernCard()
    }
    
    /// 宠物头像
    private var petAvatar: some View {
        AsyncImage(url: nil) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            // 默认头像
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [DesignSystem.Colors.primary.opacity(0.3), DesignSystem.Colors.accent.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Image(systemName: (pet.species == "猫") ? "cat.fill" : "dog.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.primary)
            }
        }
        .frame(width: 60, height: 60)
        .clipShape(Circle())
    }
    
    /// 宠物基本信息
    private var petBasicInfo: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(pet.name)
                .font(DesignSystem.Typography.title3)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .lineLimit(1)
            
            Text("\(pet.breed) • \(pet.gender)")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .lineLimit(1)
            
            HStack(spacing: DesignSystem.Spacing.sm) {
                Text(ageDescription)
                    .font(DesignSystem.Typography.footnote)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                
                if pet.weight > 0 {
                    Text("•")
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                    
                    Text("\(String(format: "%.1f", pet.weight))kg")
                        .font(DesignSystem.Typography.footnote)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
            }
        }
    }
    
    /// 年龄描述
    private var ageDescription: String {
        let age = pet.age
        return age == 0 ? "不满1岁" : "\(age)岁"
    }
}

#Preview {
    NavigationStack {
        PetListView()
    }
    .modelContainer(for: Pet.self, inMemory: true)
}