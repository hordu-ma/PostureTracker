//
//  SettingsView.swift
//  PostureTracker
//
//  设置页面 - 应用配置和个性化设置
//  Created on 2024-09-30
//

import SwiftUI
import AVFoundation

struct SettingsView: View {

    // MARK: - 属性

    /// 设置管理器
    @StateObject private var settings = SettingsManager.shared
    
    /// 文件导出管理器
    @StateObject private var exportManager = FileExportManager.shared

    /// 应用版本号
    private let appVersion =
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"

    /// 构建版本号
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    /// 是否显示关于页面
    @State private var showingAbout = false
    
    /// 是否显示清除数据确认对话框
    @State private var showingClearDataAlert = false
    
    /// 是否显示数据导出选项
    @State private var showingExportOptions = false
    
    /// 是否显示权限管理页面
    @State private var showingPermissions = false

    // MARK: - Body

    var body: some View {
        NavigationView {
            Form {
                // 监测设置
                Section {
                    // 采样率选择器
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            settingIcon("waveform", .blue)
                            Text("采样率")
                            Spacer()
                            Text("\(Int(settings.sampleRate)) Hz")
                                .foregroundColor(.secondary)
                        }
                        
                        Picker("采样率", selection: $settings.sampleRate) {
                            Text("25 Hz").tag(25.0)
                            Text("50 Hz").tag(50.0)
                            Text("100 Hz").tag(100.0)
                        }
                        .pickerStyle(.segmented)
                    }

                    // 灵敏度调节
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            settingIcon("gauge.medium", .orange)
                            Text("灵敏度")
                            Spacer()
                            Text("\(Int(settings.sensitivity))°")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $settings.sensitivity, in: 5...30, step: 1) {
                            Text("灵敏度")
                        } minimumValueLabel: {
                            Text("5°")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } maximumValueLabel: {
                            Text("30°")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    // 提示延迟
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            settingIcon("clock", .green)
                            Text("提示延迟")
                            Spacer()
                            Text("\(Int(settings.alertDelay))秒")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $settings.alertDelay, in: 1...10, step: 1) {
                            Text("提示延迟")
                        } minimumValueLabel: {
                            Text("1s")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } maximumValueLabel: {
                            Text("10s")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("监测设置")
                } footer: {
                    Text("调整传感器采样率和姿态检测灵敏度")
                }

                // 音频反馈
                Section {
                    // 音量调节
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            settingIcon("speaker.wave.2.fill", .purple)
                            Text("提示音音量")
                            Spacer()
                            Text("\(Int(settings.alertVolume * 100))%")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $settings.alertVolume, in: 0...1, step: 0.1) {
                            Text("音量")
                        } minimumValueLabel: {
                            Image(systemName: "speaker")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } maximumValueLabel: {
                            Image(systemName: "speaker.wave.3")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    // 语音开关
                    HStack {
                        settingIcon("text.bubble.fill", .blue)
                        Text("语音提示")
                        Spacer()
                        Toggle("", isOn: $settings.speechEnabled)
                    }

                    if settings.speechEnabled {
                        // 语音选择
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                settingIcon("person.wave.2", .cyan)
                                Text("语音类型")
                                Spacer()
                                Text(settings.selectedVoice == "male" ? "男声" : "女声")
                                    .foregroundColor(.secondary)
                            }
                            
                            Picker("语音类型", selection: $settings.selectedVoice) {
                                Text("男声").tag("male")
                                Text("女声").tag("female")
                            }
                            .pickerStyle(.segmented)
                        }

                        // 语音预览
                        Button {
                            settings.previewVoice()
                        } label: {
                            HStack {
                                settingIcon("play.fill", .green)
                                Text("试听语音")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .foregroundColor(.primary)
                    }

                    // 勿扰模式
                    HStack {
                        settingIcon("moon.fill", .indigo)
                        Text("勿扰模式")
                        Spacer()
                        Toggle("", isOn: $settings.doNotDisturbEnabled)
                    }

                    if settings.doNotDisturbEnabled {
                        VStack(spacing: 12) {
                            DatePicker("开始时间", selection: $settings.dndStartTime, displayedComponents: .hourAndMinute)
                            DatePicker("结束时间", selection: $settings.dndEndTime, displayedComponents: .hourAndMinute)
                        }
                        .padding(.leading, 40)
                    }
                } header: {
                    Text("音频反馈")
                } footer: {
                    Text("配置姿态偏差时的提示音和语音反馈")
                }

                // 数据和隐私
                Section {
                    // 云端同步
                    HStack {
                        settingIcon("icloud.fill", .blue)
                        Text("云端同步")
                        Spacer()
                        Toggle("", isOn: $settings.cloudSyncEnabled)
                    }

                    // 数据导出
                    Button {
                        showingExportOptions = true
                    } label: {
                        HStack {
                            settingIcon("externaldrive.fill", .gray)
                            Text("导出训练数据")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.primary)
                    }

                    // 清除数据
                    Button {
                        showingClearDataAlert = true
                    } label: {
                        HStack {
                            settingIcon("trash.fill", .red)
                            Text("清除所有数据")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.red)
                    }
                    
                    // 权限管理
                    Button {
                        showingPermissions = true
                    } label: {
                        HStack {
                            settingIcon("lock.shield.fill", .orange)
                            Text("权限管理")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.primary)
                    }
                } header: {
                    Text("数据和隐私")
                } footer: {
                    Text("管理您的训练数据和隐私设置")
                }

                // 外观
                Section {
                    // 外观模式
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            settingIcon("paintbrush.fill", .pink)
                            Text("外观")
                            Spacer()
                            Text(settings.appearanceMode.displayName)
                                .foregroundColor(.secondary)
                        }
                        
                        Picker("外观", selection: $settings.appearanceMode) {
                            ForEach(AppearanceMode.allCases, id: \.self) { mode in
                                Text(mode.displayName).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // 字体大小
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            settingIcon("textformat.size", .orange)
                            Text("字体大小")
                            Spacer()
                            Text(settings.fontSize.displayName)
                                .foregroundColor(.secondary)
                        }
                        
                        Picker("字体大小", selection: $settings.fontSize) {
                            ForEach(FontSize.allCases, id: \.self) { size in
                                Text(size.displayName).tag(size)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
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
                        HStack {
                            settingIcon("info.circle.fill", .blue)
                            Text("关于")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.primary)
                    }

                    Button {
                        // TODO: 实现评分功能
                    } label: {
                        HStack {
                            settingIcon("star.fill", .yellow)
                            Text("给我们评分")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.primary)
                    }

                    Button {
                        // TODO: 实现反馈功能
                    } label: {
                        HStack {
                            settingIcon("envelope.fill", .green)
                            Text("反馈与建议")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.primary)
                    }
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
            .preferredColorScheme(settings.appearanceMode.colorScheme)
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .sheet(isPresented: $showingPermissions) {
                PermissionsView()
            }
            .confirmationDialog("确认清除", isPresented: $showingClearDataAlert, titleVisibility: .visible) {
                Button("清除所有数据", role: .destructive) {
                    settings.clearAllData()
                }
                Button("取消", role: .cancel) { }
            } message: {
                Text("此操作将永久删除所有训练数据，无法恢复。请确认是否继续？")
            }
            .actionSheet(isPresented: $showingExportOptions) {
                ActionSheet(
                    title: Text("导出数据"),
                    message: Text("选择导出格式"),
                    buttons: [
                        .default(Text("JSON 格式")) {
                            exportData(format: .json)
                        },
                        .default(Text("CSV 格式")) {
                            exportData(format: .csv)
                        },
                        .cancel(Text("取消"))
                    ]
                )
            }
            .overlay(
                Group {
                    if exportManager.isExporting {
                        VStack(spacing: 16) {
                            ProgressView("导出中...")
                                .progressViewStyle(CircularProgressViewStyle())
                            
                            ProgressView(value: exportManager.exportProgress)
                                .frame(width: 200)
                            
                            Text("进度: \(Int(exportManager.exportProgress * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                    }
                    
                    if let error = exportManager.lastExportError {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.title)
                            
                            Text("导出失败")
                                .font(.headline)
                            
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("确定") {
                                exportManager.lastExportError = nil
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                    }
                }
            )
        }
    }

    // MARK: - 子视图

    /// 设置图标组件
    private func settingIcon(_ systemName: String, _ color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(color)
                .frame(width: 28, height: 28)

            Image(systemName: systemName)
                .font(.system(size: 14))
                .foregroundColor(.white)
        }
    }
    
    /// 数据导出格式
    enum ExportFormat {
        case json, csv
    }
    
    /// 导出数据
    private func exportData(format: ExportFormat) {
        guard let data = exportManager.exportAllData(format: format) else {
            return
        }
        
        exportManager.shareExportedFile(data: data, format: format)
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
                    VStack(spacing: 12) {
                        NavigationLink {
                            PrivacyPolicyView()
                        } label: {
                            HStack {
                                Text("隐私政策")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .foregroundColor(.blue)
                        }
                        
                        Divider()
                        
                        VStack(spacing: 8) {
                            Text("© 2024 PostureTracker")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text("MIT License")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
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
