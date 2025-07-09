//
//  PetDetailViewModel.swift
//  PetCare AI
//
//  Created by 徐北游 on 2025/7/1.
//

import Foundation
import SwiftData
import SwiftUI
import UIKit

/// 宠物详情的ViewModel - 管理单个宠物的详细信息和操作
/// 职责：处理宠物信息编辑、数据验证、状态管理
@Observable
class PetDetailViewModel {
    // MARK: - 状态管理
    var isEditing = false               // 是否处于编辑模式
    var isShowingImagePicker = false    // 是否显示图片选择器
    var errorMessage: String?           // 错误信息
    var successMessage: String?         // 成功信息
    
    // MARK: - 编辑状态的数据
    var editingName: String = ""
    var editingBreed: String = ""
    var editingGender: String = "公"
    var editingBirthday: Date = Date()
    var editingWeight: String = ""
    var selectedImage: UIImage?
    
    // MARK: - 数据管理
    private var modelContext: ModelContext?
    private var currentPet: Pet?
    
    // MARK: - 初始化
    init() {
        // ViewModel初始化
    }
    
    // MARK: - 配置方法
    
    /// 设置数据上下文和当前宠物
    /// - Parameters:
    ///   - context: SwiftData上下文
    ///   - pet: 当前宠物对象
    func configure(with context: ModelContext, pet: Pet) {
        self.modelContext = context
        self.currentPet = pet
        loadPetData()
    }
    
    // MARK: - 数据操作
    
    /// 加载宠物数据到编辑状态
    private func loadPetData() {
        guard let pet = currentPet else { return }
        
        editingName = pet.name
        editingBreed = pet.breed
        editingGender = pet.gender
        editingBirthday = pet.birthday
        editingWeight = pet.weight > 0 ? String(pet.weight) : ""
        
        // 加载头像图片
        if let avatarData = pet.avatarData {
            selectedImage = UIImage(data: avatarData)
        }
    }
    
    /// 保存宠物信息
    func savePetChanges() {
        guard let context = modelContext,
              let pet = currentPet else { return }
        
        // 数据验证
        guard !editingName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "宠物名字不能为空"
            return
        }
        
        guard !editingBreed.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "品种不能为空"
            return
        }
        
        let weight = Float(editingWeight) ?? 0.0
        guard weight >= 0 else {
            errorMessage = "体重不能为负数"
            return
        }
        
        // 更新宠物信息
        pet.name = editingName.trimmingCharacters(in: .whitespacesAndNewlines)
        pet.breed = editingBreed.trimmingCharacters(in: .whitespacesAndNewlines)
        pet.gender = editingGender
        pet.birthday = editingBirthday
        pet.weight = weight
        pet.updatedAt = Date()
        
        // 更新头像
        if let image = selectedImage {
            pet.avatarData = image.jpegData(compressionQuality: 0.8)
        }
        
        // 保存到数据库
        do {
            try context.save()
            isEditing = false
            errorMessage = nil
            successMessage = "保存成功！"
            
            // 3秒后清除成功消息
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.successMessage = nil
            }
        } catch {
            errorMessage = "保存失败: \(error.localizedDescription)"
        }
    }
    
    /// 取消编辑，恢复原始数据
    func cancelEditing() {
        loadPetData()
        selectedImage = nil
        isEditing = false
        errorMessage = nil
    }
    
    /// 删除当前宠物
    func deletePet(completion: @escaping (Bool) -> Void) {
        guard let context = modelContext,
              let pet = currentPet else {
            completion(false)
            return
        }
        
        context.delete(pet)
        
        do {
            try context.save()
            completion(true)
        } catch {
            errorMessage = "删除失败: \(error.localizedDescription)"
            completion(false)
        }
    }
    
    // MARK: - 计算属性
    
    /// 当前宠物的年龄描述
    var ageDescription: String {
        guard let pet = currentPet else { return "未知" }
        let age = pet.age
        return age == 0 ? "不满1岁" : "\(age)岁"
    }
    
    /// 当前宠物的体重描述
    var weightDescription: String {
        guard let pet = currentPet else { return "未记录" }
        return pet.weight > 0 ? String(format: "%.1f kg", pet.weight) : "未记录"
    }
    
    /// 验证编辑数据是否有效
    var isValidData: Bool {
        !editingName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !editingBreed.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (Float(editingWeight) ?? 0.0) >= 0
    }
}