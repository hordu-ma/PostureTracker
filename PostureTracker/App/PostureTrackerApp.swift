//
//  PostureTrackerApp.swift
//  PostureTracker
//
//  应用程序入口
//  Created on 2024-09-30
//

import SwiftUI

@main
struct PostureTrackerApp: App {

    // MARK: - 属性

    /// 应用状态管理
    @StateObject private var appState = AppState()

    /// 场景生命周期管理
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - 初始化

    init() {
        configureApp()
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(appState.colorScheme)
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    handleScenePhaseChange(from: oldPhase, to: newPhase)
                }
        }
    }

    // MARK: - 私有方法

    /// 配置应用
    private func configureApp() {
        // 配置导航栏样式
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance

        // 配置 TabBar 样式
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground

        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }

    /// 处理场景生命周期变化
    private func handleScenePhaseChange(from oldPhase: ScenePhase, to newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            print("📱 应用进入前台")
            appState.onAppBecomeActive()

        case .inactive:
            print("📱 应用变为非活动状态")
            appState.onAppBecomeInactive()

        case .background:
            print("📱 应用进入后台")
            appState.onAppEnterBackground()

        @unknown default:
            break
        }
    }
}

// MARK: - 应用状态管理

/// 应用全局状态管理
class AppState: ObservableObject {

    // MARK: - Published 属性

    /// 配色方案
    @Published var colorScheme: ColorScheme?

    /// 是否处于前台
    @Published var isActive: Bool = true

    // MARK: - 初始化

    init() {
        loadSettings()
    }

    // MARK: - 生命周期方法

    /// 应用变为活动状态
    func onAppBecomeActive() {
        isActive = true

        // 恢复传感器采样率
        if AirPodsMotionManager.shared.isTracking {
            AirPodsMotionManager.shared.setSampleRate(50.0)
        }
    }

    /// 应用变为非活动状态
    func onAppBecomeInactive() {
        isActive = false
    }

    /// 应用进入后台
    func onAppEnterBackground() {
        isActive = false

        // 降低传感器采样率以节省电量
        if AirPodsMotionManager.shared.isTracking {
            AirPodsMotionManager.shared.setSampleRate(25.0)
        }

        // 保存数据
        saveData()
    }

    // MARK: - 私有方法

    /// 加载设置
    private func loadSettings() {
        // 从 UserDefaults 加载配色方案设置
        if let savedScheme = UserDefaults.standard.string(forKey: "colorScheme") {
            switch savedScheme {
            case "light":
                colorScheme = .light
            case "dark":
                colorScheme = .dark
            default:
                colorScheme = nil  // 跟随系统
            }
        }
    }

    /// 保存数据
    private func saveData() {
        // 触发数据保存逻辑
        print("💾 保存应用数据")
        // TODO: 实现数据持久化逻辑
    }
}
