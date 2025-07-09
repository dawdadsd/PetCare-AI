//
//  PetDiary.swift
//  PetCare AI
//
//  Created on 2025/7/1.
//

import Foundation
import SwiftData

@Model
final class PetDiary {
    // 基本信息
    var title: String                    // 日记标题
    var content: String                  // 日记内容
    var category: DiaryCategory         // 日记分类
    var date: Date                      // 记录日期
    var imageData: Data?                // 照片数据
    
    // 关联信息
    var petID: UUID                     // 关联的宠物ID
    
    // 系统信息
    var id: UUID                        // 唯一标识符
    var createdAt: Date                 // 创建时间
    var updatedAt: Date                 // 更新时间
    
    init(title: String, content: String, category: DiaryCategory, date: Date = Date(), petID: UUID, imageData: Data? = nil) {
        self.title = title
        self.content = content
        self.category = category
        self.date = date
        self.petID = petID
        self.imageData = imageData
        
        // 自动生成的属性
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// 日记分类枚举 - 基于2025年现代宠物养护标准
enum DiaryCategory: String, CaseIterable, Codable {
    case custom = "自定义"              // 自定义记录
    case daily = "日常"                // 日常随手记
    case grooming = "美容护理"          // 洗澡、剪指甲、刷牙等
    case health = "健康管理"            // 体检、疫苗、生病记录
    case feeding = "饮食记录"           // 喂食、零食、特殊饮食
    case training = "训练教育"          // 行为训练、社会化训练
    case play = "运动娱乐"             // 散步、游戏、玩具
    case social = "社交活动"           // 与其他宠物或人的互动
    case travel = "外出旅行"           // 出门、旅游、寄养
    case medical = "医疗记录"          // 用药、治疗、康复
    case behavior = "行为观察"         // 情绪、行为变化记录
    case milestone = "成长里程碑"       // 重要时刻、纪念日
    
    // 分类图标
    var iconName: String {
        switch self {
        case .custom: return "star.fill"
        case .daily: return "text.bubble.fill"
        case .grooming: return "scissors"
        case .health: return "cross.fill"
        case .feeding: return "bowl.fill"
        case .training: return "brain.head.profile"
        case .play: return "tennisball.fill"
        case .social: return "person.2.fill"
        case .travel: return "car.fill"
        case .medical: return "pills.fill"
        case .behavior: return "eye.fill"
        case .milestone: return "gift.fill"
        }
    }
    
    // 分类颜色
    var colorName: String {
        switch self {
        case .custom: return "blue"
        case .daily: return "gray"
        case .grooming: return "mint"
        case .health: return "red"
        case .feeding: return "orange"
        case .training: return "purple"
        case .play: return "green"
        case .social: return "pink"
        case .travel: return "indigo"
        case .medical: return "red"
        case .behavior: return "teal"
        case .milestone: return "yellow"
        }
    }
    
    // 预设模板内容
    var templateContent: String {
        switch self {
        case .custom: return ""
        case .daily: return "今天和宝贝一起..."
        case .grooming: return "护理项目：\n状态：\n注意事项："
        case .health: return "检查项目：\n结果：\n医生建议："
        case .feeding: return "食物：\n分量：\n食欲状况："
        case .training: return "训练内容：\n表现：\n进步情况："
        case .play: return "活动内容：\n持续时间：\n宝贝状态："
        case .social: return "互动对象：\n互动情况：\n宝贝反应："
        case .travel: return "目的地：\n交通方式：\n宝贝适应情况："
        case .medical: return "用药/治疗：\n剂量/频次：\n反应情况："
        case .behavior: return "观察到的行为：\n可能原因：\n处理方式："
        case .milestone: return "重要时刻：\n值得纪念的原因：\n心情感受："
        }
    }
}

// 日记统计数据
struct DiaryStatistics {
    let totalEntries: Int
    let thisMonthEntries: Int
    let lastMonthEntries: Int
    let categoryCounts: [DiaryCategory: Int]
    let recentEntries: [PetDiary]
    
    static let empty = DiaryStatistics(
        totalEntries: 0,
        thisMonthEntries: 0,
        lastMonthEntries: 0,
        categoryCounts: [:],
        recentEntries: []
    )
}