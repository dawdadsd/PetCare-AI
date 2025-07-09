//
//  Pet.swift
//  PetCare AI
//
//  Created by 徐北游 on 2025/7/1.
//
import Foundation
import SwiftData

@Model
final class Pet: Identifiable {
    // 基本信息
    var name: String           // 宠物名字
    var breed: String          // 品种
    var species: String        // 物种：猫/狗
    var gender: String         // 性别：公/母
    var birthday: Date         // 生日
    var weight: Float          // 体重（公斤）
    var avatarData: Data?      // 宠物头像图片数据

    // 系统信息
    var id: UUID               // 唯一标识符
    var createdAt: Date        // 创建时间
    var updatedAt: Date        // 更新时间

    // 初始化方法 - Swift中的构造函数
    init(name: String, breed: String, species: String, gender: String, birthday: Date, weight: Float = 0.0) {
        self.name = name
        self.breed = breed
        self.species = species
        self.gender = gender
        self.birthday = birthday
        self.weight = weight
        self.avatarData = nil

        // 自动生成的属性
        self.id = UUID()           // 生成唯一ID
        self.createdAt = Date()    // 当前时间
        self.updatedAt = Date()    // 当前时间
    }

    // 计算属性 - 根据生日计算年龄
    var age: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: Date())
        return ageComponents.year ?? 0
    }
    
    // 计算属性 - 根据生日计算月龄（用于精确的喂食推荐）
    var ageInMonths: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.month], from: birthday, to: Date())
        return ageComponents.month ?? 0
    }
}
