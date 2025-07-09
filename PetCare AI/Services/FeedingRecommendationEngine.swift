//
//  FeedingRecommendationEngine.swift
//  PetCare AI
//
//  Created by 徐北游 on 2025/7/1.
//

import Foundation

/// 喂食推荐错误类型
enum FeedingRecommendationError: Error, LocalizedError {
    case invalidPetName
    case invalidSpecies
    case invalidWeight
    case invalidAge
    
    var errorDescription: String? {
        switch self {
        case .invalidPetName:
            return "宠物名字不能为空"
        case .invalidSpecies:
            return "宠物物种信息无效"
        case .invalidWeight:
            return "宠物体重必须大于0"
        case .invalidAge:
            return "宠物年龄信息无效"
        }
    }
}

/// 喂食推荐引擎
/// 职责：根据宠物的具体信息计算个性化的喂食建议
class FeedingRecommendationEngine {
    static let shared = FeedingRecommendationEngine()
    
    private init() {}
    
    /// 计算宠物的个性化喂食建议
    func generateRecommendation(for pet: Pet) throws -> FeedingRecommendation {
        // 数据验证
        guard !pet.name.isEmpty else {
            throw FeedingRecommendationError.invalidPetName
        }
        
        guard !pet.species.isEmpty else {
            throw FeedingRecommendationError.invalidSpecies
        }
        
        guard pet.weight > 0 else {
            throw FeedingRecommendationError.invalidWeight
        }
        
        guard pet.ageInMonths >= 0 else {
            throw FeedingRecommendationError.invalidAge
        }
        
        let ageCategory = determineAgeCategory(pet: pet)
        let idealWeight = calculateIdealWeight(pet: pet)
        let dailyCalories = calculateDailyCalories(pet: pet, ageCategory: ageCategory)
        let feedingTimes = determineFeedingTimes(ageCategory: ageCategory)
        let dailyFoodAmount = calculateFoodAmount(calories: dailyCalories)
        
        return FeedingRecommendation(
            pet: pet,
            ageCategory: ageCategory,
            dailyCalories: dailyCalories,
            dailyFoodAmount: dailyFoodAmount,
            feedingTimes: feedingTimes,
            mealSize: calculateMealSize(dailyAmount: dailyFoodAmount, times: feedingTimes),
            idealWeightRange: idealWeight,
            nutritionTips: getNutritionTips(pet: pet, ageCategory: ageCategory),
            feedingSchedule: generateFeedingSchedule(times: feedingTimes)
        )
    }
    
    /// 确定年龄分类
    private func determineAgeCategory(pet: Pet) -> AgeCategory {
        let ageInMonths = pet.ageInMonths
        
        if pet.species == "猫" {
            if ageInMonths < 12 {
                return .kitten
            } else if ageInMonths < 84 { // 7年
                return .adult
            } else {
                return .senior
            }
        } else { // 狗
            // 根据体重判断犬种大小
            let size = pet.weight < 10 ? "小型犬" : (pet.weight < 25 ? "中型犬" : "大型犬")
            
            if ageInMonths < 12 {
                return .puppy
            } else if (size == "小型犬" && ageInMonths < 96) || // 小型犬8年
                      (size == "中型犬" && ageInMonths < 84) || // 中型犬7年
                      (size == "大型犬" && ageInMonths < 72) {  // 大型犬6年
                return .adult
            } else {
                return .senior
            }
        }
    }
    
    /// 计算理想体重范围
    private func calculateIdealWeight(pet: Pet) -> WeightRange {
        // 基于品种的理想体重（简化版本）
        let baseWeight = pet.weight
        return WeightRange(
            min: baseWeight * 0.9,
            max: baseWeight * 1.1,
            ideal: baseWeight
        )
    }
    
    /// 计算每日所需卡路里
    private func calculateDailyCalories(pet: Pet, ageCategory: AgeCategory) -> Double {
        let baseCalories: Double
        
        if pet.species == "猫" {
            // 猫的基础代谢率计算
            baseCalories = pow(Double(pet.weight), 0.67) * 70
            
            switch ageCategory {
            case .kitten:
                return baseCalories * 2.5 // 幼猫需要更多能量
            case .adult:
                return baseCalories * 1.4
            case .senior:
                return baseCalories * 1.2
            default:
                return baseCalories * 1.4
            }
        } else {
            // 狗的基础代谢率计算
            baseCalories = pow(Double(pet.weight), 0.75) * 70
            
            switch ageCategory {
            case .puppy:
                return baseCalories * 2.0
            case .adult:
                return baseCalories * 1.6
            case .senior:
                return baseCalories * 1.3
            default:
                return baseCalories * 1.6
            }
        }
    }
    
    /// 计算食物重量（假设平均食物为350卡路里/100g）
    private func calculateFoodAmount(calories: Double) -> Double {
        return (calories / 350) * 100 // 转换为克
    }
    
    /// 确定每日喂食次数
    private func determineFeedingTimes(ageCategory: AgeCategory) -> Int {
        switch ageCategory {
        case .kitten, .puppy:
            return 4
        case .adult:
            return 2
        case .senior:
            return 2
        }
    }
    
    /// 计算每餐分量
    private func calculateMealSize(dailyAmount: Double, times: Int) -> Double {
        return dailyAmount / Double(times)
    }
    
    /// 获取营养建议
    private func getNutritionTips(pet: Pet, ageCategory: AgeCategory) -> [String] {
        var tips: [String] = []
        
        if pet.species == "猫" {
            switch ageCategory {
            case .kitten:
                tips = [
                    "选择高蛋白幼猫粮",
                    "确保食物易消化",
                    "逐渐过渡到固体食物"
                ]
            case .adult:
                tips = [
                    "保持蛋白质含量在32%以上",
                    "控制碳水化合物摄入",
                    "确保牛磺酸充足"
                ]
            case .senior:
                tips = [
                    "选择易消化的老年猫粮",
                    "增加水分摄入",
                    "定期监测肾脏健康"
                ]
            default:
                tips = ["均衡营养很重要"]
            }
        } else {
            switch ageCategory {
            case .puppy:
                tips = [
                    "选择适合体型的幼犬粮",
                    "注意钙磷比例平衡",
                    "避免过度喂食"
                ]
            case .adult:
                tips = [
                    "根据活动量调整食量",
                    "保持理想体重",
                    "定期检查体态"
                ]
            case .senior:
                tips = [
                    "选择低钠老年犬粮",
                    "添加关节保健成分",
                    "少量多餐更易消化"
                ]
            default:
                tips = ["均衡营养很重要"]
            }
        }
        
        return tips
    }
    
    /// 生成喂食时间表
    private func generateFeedingSchedule(times: Int) -> [String] {
        switch times {
        case 4:
            return ["7:00", "12:00", "17:00", "21:00"]
        case 3:
            return ["8:00", "14:00", "20:00"]
        case 2:
            return ["8:00", "18:00"]
        default:
            return ["8:00", "18:00"]
        }
    }
}

/// 年龄分类枚举
enum AgeCategory {
    case kitten    // 幼猫
    case puppy     // 幼犬
    case adult     // 成年
    case senior    // 老年
    
    var displayName: String {
        switch self {
        case .kitten: return "幼猫期"
        case .puppy: return "幼犬期"
        case .adult: return "成年期"
        case .senior: return "老年期"
        }
    }
}

/// 体重范围结构
struct WeightRange {
    let min: Float
    let max: Float
    let ideal: Float
}

/// 个性化喂食建议结构
struct FeedingRecommendation {
    let pet: Pet
    let ageCategory: AgeCategory
    let dailyCalories: Double
    let dailyFoodAmount: Double  // 每日食物重量（克）
    let feedingTimes: Int        // 每日喂食次数
    let mealSize: Double         // 每餐分量（克）
    let idealWeightRange: WeightRange
    let nutritionTips: [String]
    let feedingSchedule: [String] // 建议喂食时间
    
    /// 格式化的每日食量显示
    var formattedDailyAmount: String {
        return String(format: "%.0fg", dailyFoodAmount)
    }
    
    /// 格式化的每餐分量显示
    var formattedMealSize: String {
        return String(format: "%.0fg", mealSize)
    }
    
    /// 体重状态评估
    var weightStatus: String {
        let currentWeight = pet.weight
        if currentWeight < idealWeightRange.min {
            return "偏瘦"
        } else if currentWeight > idealWeightRange.max {
            return "偏胖"
        } else {
            return "正常"
        }
    }
}