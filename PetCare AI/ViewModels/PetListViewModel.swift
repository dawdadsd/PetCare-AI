//
//  PetListViewModel.swift
//  PetCare AI
//
//  Created by 徐北游 on 2025/7/1.
//

import Foundation
import SwiftData

/// 宠物列表的ViewModel - 遵循MVVM架构
/// 职责：管理宠物列表的业务逻辑、数据操作和状态管理
@Observable
class PetListViewModel {
    // MARK: - 状态管理
    var isShowingAddPet = false          // 是否显示添加宠物页面
    var searchText = ""                  // 搜索文本
    var selectedSortOption = SortOption.name  // 排序选项
    var isLoading = false                // 加载状态
    var errorMessage: String?            // 错误信息
    
    // MARK: - 数据管理
    private var modelContext: ModelContext?
    
    /// 排序选项枚举
    enum SortOption: String, CaseIterable {
        case name = "名字"
        case age = "年龄"
        case breed = "品种"
        case recent = "最近添加"
    }
    
    // MARK: - 初始化
    init() {
        // ViewModel初始化
    }
    
    // MARK: - 公共方法
    
    /// 设置数据上下文 - 用于数据库操作
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    /// 添加新宠物
    /// - Parameters:
    ///   - name: 宠物名字
    ///   - breed: 品种
    ///   - species: 物种
    ///   - gender: 性别
    ///   - birthday: 生日
    ///   - weight: 体重
    func addPet(name: String, breed: String, species: String, gender: String, birthday: Date, weight: Float = 0.0) {
        guard let context = modelContext else { return }
        
        let newPet = Pet(
            name: name,
            breed: breed,
            species: species,
            gender: gender,
            birthday: birthday,
            weight: weight
        )
        
        context.insert(newPet)
        
        do {
            try context.save()
            isShowingAddPet = false
            errorMessage = nil
        } catch {
            errorMessage = "保存失败: \(error.localizedDescription)"
        }
    }
    
    /// 删除宠物
    /// - Parameter pets: 要删除的宠物数组
    func deletePets(_ pets: [Pet]) {
        guard let context = modelContext else { return }
        
        for pet in pets {
            context.delete(pet)
        }
        
        do {
            try context.save()
            errorMessage = nil
        } catch {
            errorMessage = "删除失败: \(error.localizedDescription)"
        }
    }
    
    /// 过滤宠物列表
    /// - Parameter pets: 原始宠物列表
    /// - Returns: 过滤后的宠物列表
    func filteredPets(_ pets: [Pet]) -> [Pet] {
        let filtered = pets.filter { pet in
            searchText.isEmpty || 
            pet.name.localizedCaseInsensitiveContains(searchText) ||
            pet.breed.localizedCaseInsensitiveContains(searchText)
        }
        
        return sortedPets(filtered)
    }
    
    /// 排序宠物列表
    /// - Parameter pets: 宠物列表
    /// - Returns: 排序后的宠物列表
    private func sortedPets(_ pets: [Pet]) -> [Pet] {
        switch selectedSortOption {
        case .name:
            return pets.sorted { $0.name < $1.name }
        case .age:
            return pets.sorted { $0.age > $1.age }
        case .breed:
            return pets.sorted { $0.breed < $1.breed }
        case .recent:
            return pets.sorted { $0.createdAt > $1.createdAt }
        }
    }
}