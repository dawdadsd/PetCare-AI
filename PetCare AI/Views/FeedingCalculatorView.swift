//
//  FeedingCalculatorView.swift
//  PetCare AI
//
//  Created by 徐北游 on 2025/7/1.
//

import SwiftUI

/// 喂食量计算器视图
/// 职责：根据宠物信息实时计算个性化喂食建议
struct FeedingCalculatorView: View {
    // MARK: - 状态管理
    @State private var petName: String = ""
    @State private var selectedSpecies: String = "猫"
    @State private var petWeight: String = ""
    @State private var petAge: String = ""
    @State private var activityLevel: ActivityLevel = .normal
    @State private var calculation: FeedingCalculation?
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - 常量
    private let species = ["猫", "狗"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // 标题说明
                        headerSection
                        
                        // 输入表单
                        inputFormSection
                        
                        // 计算结果
                        if let calculation = calculation {
                            calculationResultSection(calculation)
                        }
                        
                        // 计算按钮
                        calculateButton
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.xl)
                }
            }
            .navigationTitle("喂食量计算器")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.primary)
                }
            }
        }
    }
    
    // MARK: - 视图组件
    
    /// 标题说明部分
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "calculator.fill")
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(DesignSystem.Colors.primary)
            
            Text("智能喂食量计算")
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Text("输入宠物基本信息，获得科学的个性化喂食建议")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.md)
        }
        .padding(.top, DesignSystem.Spacing.md)
    }
    
    /// 输入表单部分
    private var inputFormSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // 宠物名字
            inputField(
                title: "宠物名字",
                text: $petName,
                placeholder: "例如：小花",
                icon: "heart.fill"
            )
            
            // 物种选择
            speciesSelector
            
            // 体重输入
            inputField(
                title: "体重 (kg)",
                text: $petWeight,
                placeholder: "例如：5.2",
                icon: "scalemass.fill",
                keyboardType: .decimalPad
            )
            
            // 年龄输入
            inputField(
                title: "年龄 (月)",
                text: $petAge,
                placeholder: "例如：24",
                icon: "calendar",
                keyboardType: .numberPad
            )
            
            // 活动水平
            activityLevelSelector
        }
        .modernCard()
    }
    
    /// 计算结果部分
    private func calculationResultSection(_ calculation: FeedingCalculation) -> some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // 结果标题
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(DesignSystem.Colors.success)
                    .font(.system(size: 20, weight: .medium))
                
                Text("计算结果")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
            }
            
            Divider()
            
            // 主要指标
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: DesignSystem.Spacing.md) {
                resultCard(
                    title: "每日食量",
                    value: calculation.formattedDailyAmount,
                    icon: "fork.knife",
                    color: DesignSystem.Colors.primary
                )
                
                resultCard(
                    title: "每餐分量",
                    value: calculation.formattedMealSize,
                    icon: "bowl.fill",
                    color: DesignSystem.Colors.accent
                )
                
                resultCard(
                    title: "喂食次数",
                    value: "\(calculation.feedingTimes)次/天",
                    icon: "clock.fill",
                    color: DesignSystem.Colors.success
                )
                
                resultCard(
                    title: "热量需求",
                    value: "\(Int(calculation.dailyCalories))卡",
                    icon: "flame.fill",
                    color: DesignSystem.Colors.warning
                )
            }
            
            // 喂食时间建议
            if !calculation.feedingSchedule.isEmpty {
                feedingScheduleSection(calculation.feedingSchedule)
            }
            
            // 营养建议
            if !calculation.nutritionTips.isEmpty {
                nutritionTipsSection(calculation.nutritionTips)
            }
        }
        .modernCard()
        .transition(.opacity.combined(with: .scale))
        .animation(.easeInOut(duration: 0.3), value: calculation.id)
    }
    
    /// 物种选择器
    private var speciesSelector: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Label("宠物类型", systemImage: "pawprint.fill")
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(species, id: \.self) { species in
                    Button {
                        selectedSpecies = species
                        clearCalculation()
                    } label: {
                        HStack {
                            Image(systemName: species == "猫" ? "cat.fill" : "dog.fill")
                                .font(.system(size: 16, weight: .medium))
                            Text(species)
                                .font(DesignSystem.Typography.bodyMedium)
                        }
                        .foregroundColor(selectedSpecies == species ? .white : DesignSystem.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                        .background(
                            selectedSpecies == species ?
                            DesignSystem.Colors.primary :
                            DesignSystem.Colors.surface
                        )
                        .cornerRadius(DesignSystem.CornerRadius.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                .stroke(DesignSystem.Colors.border, lineWidth: selectedSpecies == species ? 0 : 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    /// 活动水平选择器
    private var activityLevelSelector: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Label("活动水平", systemImage: "figure.run")
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Picker("活动水平", selection: $activityLevel) {
                ForEach(ActivityLevel.allCases, id: \.self) { level in
                    Text(level.displayName).tag(level)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: activityLevel) { _, _ in
                clearCalculation()
            }
        }
    }
    
    /// 计算按钮
    private var calculateButton: some View {
        Button {
            calculateFeeding()
        } label: {
            HStack {
                Image(systemName: "function")
                Text("开始计算")
            }
        }
        .primaryButton(isEnabled: isFormValid)
        .disabled(!isFormValid)
    }
    
    /// 输入字段组件
    private func inputField(
        title: String,
        text: Binding<String>,
        placeholder: String,
        icon: String,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Label(title, systemImage: icon)
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            TextField(placeholder, text: text)
                .font(DesignSystem.Typography.body)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm + 2)
                .background(DesignSystem.Colors.surface)
                .cornerRadius(DesignSystem.CornerRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .stroke(DesignSystem.Colors.border, lineWidth: 1)
                )
                .keyboardType(keyboardType)
                .onChange(of: text.wrappedValue) { _, _ in
                    clearCalculation()
                }
        }
    }
    
    /// 结果卡片
    private func resultCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(color)
            
            Text(value)
                .font(DesignSystem.Typography.title3)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Text(title)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(color.opacity(0.1))
        .cornerRadius(DesignSystem.CornerRadius.md)
    }
    
    /// 喂食时间表部分
    private func feedingScheduleSection(_ schedule: [String]) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Image(systemName: "clock.badge.checkmark.fill")
                    .foregroundColor(DesignSystem.Colors.primary)
                Text("建议喂食时间")
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: schedule.count > 2 ? 2 : schedule.count), spacing: DesignSystem.Spacing.sm) {
                ForEach(schedule.indices, id: \.self) { index in
                    Text(schedule[index])
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .background(DesignSystem.Colors.primary.opacity(0.1))
                        .cornerRadius(DesignSystem.CornerRadius.sm)
                }
            }
        }
    }
    
    /// 营养建议部分
    private func nutritionTipsSection(_ tips: [String]) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(DesignSystem.Colors.accent)
                Text("营养建议")
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
            }
            
            ForEach(tips.indices, id: \.self) { index in
                HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                    Circle()
                        .fill(DesignSystem.Colors.accent)
                        .frame(width: 6, height: 6)
                        .padding(.top, 8)
                    
                    Text(tips[index])
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
    
    // MARK: - 计算属性
    
    /// 表单验证
    private var isFormValid: Bool {
        !petName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !petWeight.isEmpty && Float(petWeight) != nil && Float(petWeight)! > 0 &&
        !petAge.isEmpty && Int(petAge) != nil && Int(petAge)! > 0
    }
    
    // MARK: - 方法
    
    /// 执行喂食计算
    private func calculateFeeding() {
        guard let weight = Float(petWeight),
              let ageInMonths = Int(petAge) else { return }
        
        // 创建临时宠物对象用于计算
        let tempPet = TempPet(
            name: petName,
            species: selectedSpecies,
            weight: weight,
            ageInMonths: ageInMonths,
            activityLevel: activityLevel
        )
        
        // 使用喂食计算引擎
        let calculator = FeedingCalculationEngine()
        withAnimation(.easeInOut(duration: 0.5)) {
            calculation = calculator.calculate(for: tempPet)
        }
    }
    
    /// 清除计算结果
    private func clearCalculation() {
        withAnimation(.easeOut(duration: 0.2)) {
            calculation = nil
        }
    }
}

/// 活动水平枚举
enum ActivityLevel: String, CaseIterable {
    case low = "低"
    case normal = "正常"
    case high = "高"
    
    var displayName: String { rawValue }
    
    var multiplier: Double {
        switch self {
        case .low: return 0.8
        case .normal: return 1.0
        case .high: return 1.3
        }
    }
}

/// 临时宠物结构（用于计算）
struct TempPet {
    let name: String
    let species: String
    let weight: Float
    let ageInMonths: Int
    let activityLevel: ActivityLevel
}

/// 喂食计算结果
struct FeedingCalculation: Identifiable {
    let id = UUID()
    let petName: String
    let dailyCalories: Double
    let dailyFoodAmount: Double
    let feedingTimes: Int
    let mealSize: Double
    let feedingSchedule: [String]
    let nutritionTips: [String]
    
    var formattedDailyAmount: String {
        String(format: "%.0fg", dailyFoodAmount)
    }
    
    var formattedMealSize: String {
        String(format: "%.0fg", mealSize)
    }
}

/// 喂食计算引擎
class FeedingCalculationEngine {
    func calculate(for pet: TempPet) -> FeedingCalculation {
        let baseCalories = calculateBaseCalories(weight: pet.weight, species: pet.species)
        let ageMultiplier = getAgeMultiplier(ageInMonths: pet.ageInMonths, species: pet.species)
        let dailyCalories = baseCalories * ageMultiplier * pet.activityLevel.multiplier
        
        let dailyFoodAmount = (dailyCalories / 350) * 100 // 假设350卡/100g
        let feedingTimes = getFeedingTimes(ageInMonths: pet.ageInMonths)
        let mealSize = dailyFoodAmount / Double(feedingTimes)
        
        return FeedingCalculation(
            petName: pet.name,
            dailyCalories: dailyCalories,
            dailyFoodAmount: dailyFoodAmount,
            feedingTimes: feedingTimes,
            mealSize: mealSize,
            feedingSchedule: getFeedingSchedule(times: feedingTimes),
            nutritionTips: getNutritionTips(ageInMonths: pet.ageInMonths, species: pet.species)
        )
    }
    
    private func calculateBaseCalories(weight: Float, species: String) -> Double {
        if species == "猫" {
            return pow(Double(weight), 0.67) * 70
        } else {
            return pow(Double(weight), 0.75) * 70
        }
    }
    
    private func getAgeMultiplier(ageInMonths: Int, species: String) -> Double {
        if species == "猫" {
            if ageInMonths < 12 { return 2.5 }
            else if ageInMonths < 84 { return 1.4 }
            else { return 1.2 }
        } else {
            if ageInMonths < 12 { return 2.0 }
            else if ageInMonths < 84 { return 1.6 }
            else { return 1.3 }
        }
    }
    
    private func getFeedingTimes(ageInMonths: Int) -> Int {
        if ageInMonths < 6 { return 4 }
        else if ageInMonths < 12 { return 3 }
        else { return 2 }
    }
    
    private func getFeedingSchedule(times: Int) -> [String] {
        switch times {
        case 4: return ["7:00", "12:00", "17:00", "21:00"]
        case 3: return ["8:00", "14:00", "20:00"]
        default: return ["8:00", "18:00"]
        }
    }
    
    private func getNutritionTips(ageInMonths: Int, species: String) -> [String] {
        if species == "猫" {
            if ageInMonths < 12 {
                return ["选择高蛋白幼猫粮", "确保食物易消化", "逐渐过渡到固体食物"]
            } else if ageInMonths < 84 {
                return ["保持蛋白质含量在32%以上", "控制碳水化合物摄入", "确保牛磺酸充足"]
            } else {
                return ["选择易消化的老年猫粮", "增加水分摄入", "定期监测肾脏健康"]
            }
        } else {
            if ageInMonths < 12 {
                return ["选择适合体型的幼犬粮", "注意钙磷比例平衡", "避免过度喂食"]
            } else if ageInMonths < 84 {
                return ["根据活动量调整食量", "保持理想体重", "定期检查体态"]
            } else {
                return ["选择低钠老年犬粮", "添加关节保健成分", "少量多餐更易消化"]
            }
        }
    }
}

#Preview {
    FeedingCalculatorView()
}