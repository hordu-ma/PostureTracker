//
//  ContentView.swift
//  PostureTracker
//
//  主内容视图 - TabView 导航结构
//  Created on 2024-09-30
//

import SwiftUI

struct ContentView: View {

    // MARK: - 属性

    /// 当前选中的标签页
    @State private var selectedTab: TabItem = .monitoring

    /// 应用状态
    @EnvironmentObject var appState: AppState

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            // 监测页面
            MonitoringView()
                .tabItem {
                    Label {
                        Text("监测")
                    } icon: {
                        Image(
                            systemName: selectedTab == .monitoring ? "figure.stand" : "figure.stand"
                        )
                    }
                }
                .tag(TabItem.monitoring)

            // 统计页面
            StatisticsView()
                .tabItem {
                    Label {
                        Text("统计")
                    } icon: {
                        Image(
                            systemName: selectedTab == .statistics ? "chart.bar.fill" : "chart.bar")
                    }
                }
                .tag(TabItem.statistics)

            // 设置页面
            SettingsView()
                .tabItem {
                    Label {
                        Text("设置")
                    } icon: {
                        Image(systemName: selectedTab == .settings ? "gear" : "gear")
                    }
                }
                .tag(TabItem.settings)
        }
        .accentColor(.blue)
        .onAppear {
            configureTabBar()
        }
    }

    // MARK: - 私有方法

    /// 配置 TabBar 样式
    private func configureTabBar() {
        // 确保 TabBar 样式正确应用
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        // 设置选中和未选中的颜色
        appearance.stackedLayoutAppearance.selected.iconColor = .systemBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue
        ]

        appearance.stackedLayoutAppearance.normal.iconColor = .systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray
        ]

        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - TabItem 枚举

/// 标签页枚举
enum TabItem: String, CaseIterable {
    case monitoring = "监测"
    case statistics = "统计"
    case settings = "设置"

    /// 图标名称
    var iconName: String {
        switch self {
        case .monitoring:
            return "figure.stand"
        case .statistics:
            return "chart.bar"
        case .settings:
            return "gear"
        }
    }

    /// 选中时的图标名称
    var selectedIconName: String {
        switch self {
        case .monitoring:
            return "figure.stand"
        case .statistics:
            return "chart.bar.fill"
        case .settings:
            return "gear"
        }
    }
}

// MARK: - 预览

#Preview("内容视图") {
    ContentView()
        .environmentObject(AppState())
}

#Preview("暗色模式") {
    ContentView()
        .environmentObject(AppState())
        .preferredColorScheme(.dark)
}
