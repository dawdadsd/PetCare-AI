//
//  ContentView.swift
//  PetCare AI
//
//  Created by 徐北游 on 2025/7/1.
//

import SwiftUI
import SwiftData

/// 主内容视图 - 应用的入口视图
/// 职责：作为应用的根视图，展示完整的标签页导航
struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Pet.self, PetDiary.self], inMemory: true)
}
