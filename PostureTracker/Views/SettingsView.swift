//
//  SettingsView.swift
//  PostureTracker
//
//  设置页面 - 应用配置和个性化设置
//  Created on 2024-09-30
//

import SwiftUI

struct SettingsView: View {

    // MARK: - 属性

    /// 应用版本号
    private let appVersion =
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"

    /// 构建版本号
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    /// 是否显示关于页面
    @State private var showingAbout = false

    // MARK: - Body

    var body: some View {
        NavigationView {
            Form {
                // 监测设置
                Section {
                    settingRow(
                        icon: "waveform",
                        iconColor: .blue,
                        title: "采样率",
                        value: "50 Hz"
                    )

                    settingRow(
                        icon: "gauge.medium",
                        iconColor: .orange,
                        title: "灵敏度",
                        value: "中等"
                    )

                    settingRow(
                        icon: "clock",
                        iconColor: .green,
                        title: "提示延迟",
                        value: "5 秒"
                    )
                } header: {
                    Text("监测设置")
                } footer: {
                    Text("调整传感器采样率和姿态检测灵敏度")
                }

                // 音频反馈
                Section {
                    settingRow(
                        icon: "speaker.wave.2.fill",
                        iconColor: .purple,
                        title: "提示音音量",
                        value: "80%"
                    )

                    settingRow(
                        icon: "text.bubble.fill",
                        iconColor: .blue,
                        title: "语音提示",
                        value: "开启"
                    )

                    settingRow(
                        icon: "moon.fill",
                        iconColor: .indigo,
                        title: "勿扰模式",
                        value: "未设置"
                    )
                } header: {
                    Text("音频反馈")
                } footer: {
                    Text("配置姿态偏差时的提示音和语音反馈")
                }

                // 数据和隐私
                Section {
                    settingRow(
                        icon: "icloud.fill",
                        iconColor: .blue,
                        title: "云端同步",
                        value: "未登录"
                    )

                    settingRow(
                        icon: "externaldrive.fill",
                        iconColor: .gray,
                        title: "数据导出",
                        value: ""
                    )

                    settingRow(
                        icon: "trash.fill",
                        iconColor: .red,
                        title: "清除数据",
                        value: ""
                    )
                } header: {
                    Text("数据和隐私")
                } footer: {
                    Text("管理您的训练数据和隐私设置")
                }

                // 外观
                Section {
                    settingRow(
                        icon: "paintbrush.fill",
                        iconColor: .pink,
                        title: "外观",
                        value: "跟随系统"
                    )

                    settingRow(
                        icon: "textformat.size",
                        iconColor: .orange,
                        title: "字体大小",
                        value: "标准"
                    )
                } header: {
                    Text("外观")
                } footer: {
                    Text("自定义应用界面外观")
                }

                // 关于
                Section {
                    Button {
                        showingAbout = true
                    } label: {
                        settingRow(
                            icon: "info.circle.fill",
                            iconColor: .blue,
                            title: "关于",
                            value: ""
                        )
                    }

                    settingRow(
                        icon: "star.fill",
                        iconColor: .yellow,
                        title: "给我们评分",
                        value: ""
                    )

                    settingRow(
                        icon: "envelope.fill",
                        iconColor: .green,
                        title: "反馈与建议",
                        value: ""
                    )
                } header: {
                    Text("关于")
                }

                // 版本信息
                Section {
                    HStack {
                        Text("版本")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(appVersion) (\(buildNumber))")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
    }

    // MARK: - 子视图

    /// 设置行组件
    private func settingRow(
        icon: String,
        iconColor: Color,
        title: String,
        value: String
    ) -> some View {
        HStack(spacing: 12) {
            // 图标
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(iconColor)
                    .frame(width: 28, height: 28)

                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }

            // 标题
            Text(title)
                .font(.body)

            Spacer()

            // 值
            if !value.isEmpty {
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // 箭头
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - 关于视图

/// 关于视图
struct AboutView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 应用图标
                    Image(systemName: "figure.stand")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .padding(.top, 40)

                    // 应用名称
                    Text("PostureTracker")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("基于 AirPods 的智能姿态追踪")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Divider()
                        .padding(.vertical)

                    // 功能介绍
                    VStack(alignment: .leading, spacing: 16) {
                        Text("核心功能")
                            .font(.headline)
                            .padding(.bottom, 8)

                        featureItem(icon: "figure.stand", text: "实时姿态监测")
                        featureItem(icon: "speaker.wave.2", text: "智能音频反馈")
                        featureItem(icon: "chart.bar", text: "数据统计分析")
                        featureItem(icon: "icloud", text: "云端数据同步")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // 技术栈
                    VStack(alignment: .leading, spacing: 12) {
                        Text("技术栈")
                            .font(.headline)
                            .padding(.bottom, 8)

                        Text("• Swift 5.9+ & SwiftUI")
                        Text("• MVVM + Combine")
                        Text("• CMHeadphoneMotionManager")
                        Text("• AVFoundation")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // 版权信息
                    VStack(spacing: 8) {
                        Text("© 2024 PostureTracker")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("MIT License")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 24)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("关于")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }

    /// 功能项
    private func featureItem(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
        }
    }
}

// MARK: - 预览

#Preview("设置视图") {
    SettingsView()
}

#Preview("关于视图") {
    AboutView()
}

#Preview("暗色模式") {
    SettingsView()
        .preferredColorScheme(.dark)
}
