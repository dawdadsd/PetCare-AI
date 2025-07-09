//
//  DesignSystem.swift
//  PetCare AI
//
//  Created by 徐北游 on 2025/7/1.
//

import SwiftUI

/// 设计系统 - 统一管理颜色、字体、间距等设计规范
/// 职责：提供2025年现代化的UI设计标准
struct DesignSystem {
    
    // MARK: - 颜色系统 (2025年现代化配色)
    struct Colors {
        // 主色调 - 温暖而现代的蓝绿色系
        static let primary = Color(red: 0.2, green: 0.6, blue: 0.8)        // #3399CC
        static let primaryLight = Color(red: 0.4, green: 0.7, blue: 0.9)   // #66B3E6
        static let primaryDark = Color(red: 0.1, green: 0.5, blue: 0.7)    // #1A80B3
        
        // 辅助色 - 温暖的橙色
        static let accent = Color(red: 1.0, green: 0.6, blue: 0.2)         // #FF9933
        static let accentLight = Color(red: 1.0, green: 0.7, blue: 0.4)    // #FFB366
        
        // 状态色
        static let success = Color(red: 0.3, green: 0.8, blue: 0.5)        // #4DCC80
        static let warning = Color(red: 1.0, green: 0.7, blue: 0.0)        // #FFB300
        static let error = Color(red: 0.9, green: 0.3, blue: 0.3)          // #E64D4D
        
        // 中性色 - 现代化灰色系
        static let background = Color(red: 0.98, green: 0.98, blue: 0.99)  // #FAFAFC
        static let backgroundSecondary = Color(red: 0.95, green: 0.95, blue: 0.97) // #F2F2F5
        static let surface = Color.white
        static let surfaceSecondary = Color(red: 0.97, green: 0.97, blue: 0.98) // #F7F7FA
        
        // 文字色
        static let textPrimary = Color(red: 0.1, green: 0.1, blue: 0.15)    // #1A1A26
        static let textSecondary = Color(red: 0.4, green: 0.4, blue: 0.5)   // #666680
        static let textTertiary = Color(red: 0.6, green: 0.6, blue: 0.65)   // #9999A6
        
        // 边框和分割线
        static let border = Color(red: 0.9, green: 0.9, blue: 0.92)        // #E6E6EB
        static let borderLight = Color(red: 0.95, green: 0.95, blue: 0.96) // #F2F2F5
    }
    
    // MARK: - 字体系统
    struct Typography {
        // 标题
        static let largeTitle = Font.system(size: 32, weight: .bold, design: .rounded)
        static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 24, weight: .semibold, design: .rounded)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let titleMedium = Font.system(size: 18, weight: .semibold, design: .rounded)
        
        // 正文
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let bodyMedium = Font.system(size: 17, weight: .medium, design: .default)
        static let bodySemibold = Font.system(size: 17, weight: .semibold, design: .default)
        
        // 小字
        static let caption = Font.system(size: 14, weight: .regular, design: .default)
        static let captionMedium = Font.system(size: 14, weight: .medium, design: .default)
        static let footnote = Font.system(size: 13, weight: .regular, design: .default)
        static let small = Font.system(size: 12, weight: .regular, design: .default)
    }
    
    // MARK: - 间距系统
    struct Spacing {
        static let xs: CGFloat = 4      // 最小间距
        static let sm: CGFloat = 8      // 小间距
        static let md: CGFloat = 16     // 中等间距
        static let lg: CGFloat = 24     // 大间距
        static let xl: CGFloat = 32     // 特大间距
        static let xxl: CGFloat = 48    // 超大间距
    }
    
    // MARK: - 圆角系统
    struct CornerRadius {
        static let sm: CGFloat = 8      // 小圆角
        static let md: CGFloat = 12     // 中等圆角
        static let lg: CGFloat = 16     // 大圆角
        static let xl: CGFloat = 20     // 特大圆角
        static let circle: CGFloat = 50 // 圆形
    }
    
    // MARK: - 阴影系统
    struct Shadow {
        static let soft = Color.black.opacity(0.05)
        static let medium = Color.black.opacity(0.1)
        static let strong = Color.black.opacity(0.15)
    }
}

// MARK: - 常用UI组件扩展

/// 现代化卡片样式
struct ModernCardStyle: ViewModifier {
    var backgroundColor: Color = DesignSystem.Colors.surface
    var cornerRadius: CGFloat = DesignSystem.CornerRadius.lg
    var shadowOpacity: Double = 0.08
    
    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: DesignSystem.Shadow.soft, radius: 8, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(DesignSystem.Colors.border, lineWidth: 0.5)
            )
    }
}

/// 主要按钮样式
struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.bodyMedium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                isEnabled ? 
                (configuration.isPressed ? DesignSystem.Colors.primaryDark : DesignSystem.Colors.primary) :
                DesignSystem.Colors.textTertiary
            )
            .cornerRadius(DesignSystem.CornerRadius.lg)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// 次要按钮样式
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.bodyMedium)
            .foregroundColor(DesignSystem.Colors.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(DesignSystem.Colors.primaryLight.opacity(0.1))
            .cornerRadius(DesignSystem.CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .stroke(DesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - View扩展
extension View {
    /// 应用现代化卡片样式
    func modernCard(backgroundColor: Color = DesignSystem.Colors.surface) -> some View {
        self.modifier(ModernCardStyle(backgroundColor: backgroundColor))
    }
    
    /// 主要按钮样式
    func primaryButton(isEnabled: Bool = true) -> some View {
        self.buttonStyle(PrimaryButtonStyle(isEnabled: isEnabled))
    }
    
    /// 次要按钮样式
    func secondaryButton() -> some View {
        self.buttonStyle(SecondaryButtonStyle())
    }
}