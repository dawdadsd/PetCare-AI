//
//  MainTabView.swift
//  PetCare AI
//
//  Created by 徐北游 on 2025/7/1.
//

import SwiftUI

/// 主标签页视图
/// 职责：提供应用的主要导航结构，包含宠物管理和喂食指南功能
struct MainTabView: View {
    var body: some View {
        TabView {
            // 宠物列表标签页
            PetListView()
                .tabItem {
                    Image(systemName: "pawprint.fill")
                    Text("我的宠物")
                }
                .tag(0)
            
            // 日记记录标签页
            DiaryListView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("日记")
                }
                .tag(1)
            
            // 喂食指南标签页
            FeedingGuideView()
                .tabItem {
                    Image(systemName: "leaf.fill")
                    Text("喂食指南")
                }
                .tag(2)
        }
        .accentColor(DesignSystem.Colors.primary)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Pet.self, PetDiary.self], inMemory: true)
}