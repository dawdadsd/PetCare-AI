//
//  FeedingGuide.swift
//  PetCare AI
//
//  Created by 徐北游 on 2025/7/1.
//

import Foundation

/// 宠物类型枚举
enum PetType: String, CaseIterable {
    case cat = "猫咪"
    case dog = "狗狗"
    
    var icon: String {
        switch self {
        case .cat: return "cat.fill"
        case .dog: return "dog.fill"
        }
    }
}

/// 年龄阶段枚举
enum AgeStage: String, CaseIterable {
    case kitten = "幼猫/幼犬"
    case adult = "成年"
    case senior = "老年"
    
    var description: String {
        switch self {
        case .kitten: return "0-12个月"
        case .adult: return "1-7岁"
        case .senior: return "7岁以上"
        }
    }
}

/// 喂食指南数据结构
struct FeedingGuide {
    let petType: PetType
    let ageStage: AgeStage
    let dailyMeals: String
    let mealTiming: String
    let nutritionFocus: [String]
    let importantNotes: [String]
    let calories: String
}

/// 喂食指南数据管理器
class FeedingGuideManager {
    static let shared = FeedingGuideManager()
    
    private init() {}
    
    /// 获取所有喂食指南
    func getAllGuides() -> [FeedingGuide] {
        return catGuides + dogGuides
    }
    
    /// 获取特定宠物类型的指南
    func getGuides(for petType: PetType) -> [FeedingGuide] {
        switch petType {
        case .cat:
            return catGuides
        case .dog:
            return dogGuides
        }
    }
    
    /// 猫咪喂食指南
    private let catGuides: [FeedingGuide] = [
        FeedingGuide(
            petType: .cat,
            ageStage: .kitten,
            dailyMeals: "4-6次",
            mealTiming: "每3-4小时喂食一次",
            nutritionFocus: [
                "高蛋白质含量（50-60%）",
                "高脂肪提供能量",
                "易消化的优质蛋白",
                "充足的牛磺酸",
                "适量的钙磷比例"
            ],
            importantNotes: [
                "幼猫生长迅速，需要充足营养",
                "6个月前每天需要约60-65卡路里/磅体重",
                "逐渐从母乳或奶粉过渡到固体食物",
                "确保食物温度适宜",
                "随时提供清洁饮水"
            ],
            calories: "60-65卡路里/磅体重/天"
        ),
        FeedingGuide(
            petType: .cat,
            ageStage: .adult,
            dailyMeals: "2-3次",
            mealTiming: "早晚固定时间喂食",
            nutritionFocus: [
                "优质动物蛋白（猫是严格肉食动物）",
                "适量脂肪维持体重",
                "必需脂肪酸维护皮毛健康",
                "牛磺酸支持心脏和眼部健康",
                "控制碳水化合物摄入"
            ],
            importantNotes: [
                "成年猫新陈代谢稳定",
                "避免过度喂食导致肥胖",
                "定时定量喂食有助消化",
                "监控体重变化",
                "提供充足新鲜水源"
            ],
            calories: "20-30卡路里/磅体重/天"
        ),
        FeedingGuide(
            petType: .cat,
            ageStage: .senior,
            dailyMeals: "2-3次",
            mealTiming: "少量多餐，减轻消化负担",
            nutritionFocus: [
                "易消化的优质蛋白",
                "增加蛋白质含量维护肌肉",
                "降低磷含量保护肾脏",
                "抗氧化剂延缓衰老",
                "适量纤维促进肠道健康"
            ],
            importantNotes: [
                "老年猫蛋白质代谢能力下降",
                "注意肾脏和心脏健康",
                "可能需要软化食物",
                "定期体检调整饮食",
                "保持适当体重避免关节负担"
            ],
            calories: "根据活动量调整，通常较成年期略少"
        )
    ]
    
    /// 狗狗喂食指南
    private let dogGuides: [FeedingGuide] = [
        FeedingGuide(
            petType: .dog,
            ageStage: .kitten,
            dailyMeals: "3-4次",
            mealTiming: "每4-6小时喂食一次",
            nutritionFocus: [
                "高蛋白质支持生长发育",
                "适量脂肪提供能量",
                "钙磷平衡促进骨骼发育",
                "DHA支持大脑发育",
                "易消化的营养成分"
            ],
            importantNotes: [
                "幼犬生长期营养需求高",
                "8-10个月基本完成生长",
                "大型犬与小型犬需求有差异",
                "避免过度喂食影响骨骼发育",
                "12个月后可转换成犬粮"
            ],
            calories: "根据品种大小调整，小型犬更高"
        ),
        FeedingGuide(
            petType: .dog,
            ageStage: .adult,
            dailyMeals: "1-2次",
            mealTiming: "早晚各一次或每天一次",
            nutritionFocus: [
                "均衡的蛋白质、脂肪、碳水化合物",
                "优质动物蛋白为主",
                "适量纤维促进消化",
                "必需脂肪酸维护皮毛",
                "维生素和矿物质平衡"
            ],
            importantNotes: [
                "成犬新陈代谢稳定",
                "根据活动量调整食量",
                "避免餐后剧烈运动",
                "定期监控体重和体态",
                "选择适合体型的狗粮"
            ],
            calories: "根据体重、年龄、活动量计算"
        ),
        FeedingGuide(
            petType: .dog,
            ageStage: .senior,
            dailyMeals: "2-3次",
            mealTiming: "少量多餐，便于消化",
            nutritionFocus: [
                "易消化的优质蛋白",
                "降低热量控制体重",
                "降低钠含量保护心脏",
                "葡萄糖胺支持关节健康",
                "抗氧化剂延缓衰老"
            ],
            importantNotes: [
                "老年犬新陈代谢减慢",
                "可能需要特殊老年犬粮",
                "注意牙齿健康，必要时软化食物",
                "定期体检调整饮食方案",
                "保持适度运动配合饮食"
            ],
            calories: "较成年期减少10-20%"
        )
    ]
}