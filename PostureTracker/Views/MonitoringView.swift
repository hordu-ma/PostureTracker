//
//  MonitoringView.swift
//  PostureTracker
//
//  主监测页面 - 实时姿态监测和控制
//  Created on 2024-09-30
//  Updated: 2024-10-03 - 集成 ViewModel 层
//

import SwiftUI

struct MonitoringView: View {

    // MARK: - ViewModels

    /// 姿态监测 ViewModel
    @StateObject private var motionViewModel = MotionViewModel()
    
    /// 会话管理 ViewModel
    @StateObject private var sessionViewModel = SessionViewModel()

    // MARK: - 状态属性

    /// 是否显示校准视图
    @State private var showingCalibration = false

    /// 是否显示设置
    @State private var showingSettings = false
    
    /// 是否显示会话保存确认
    @State private var showingSaveConfirmation = false

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 连接状态卡片
                    connectionStatusCard

                    // 当前姿态显示
                    currentPostureCard

                    // 控制按钮
                    controlButtons

                    // 会话统计
                    if motionViewModel.isMonitoring {
                        sessionStatisticsCard
                    }

                    // 提示信息
                    tipsCard

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("姿态监测")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCalibration = true
                    } label: {
                        Image(systemName: "scope")
                    }
                }
            }
            .sheet(isPresented: $showingCalibration) {
                CalibrationView()
            }
            .alert("保存会话", isPresented: $showingSaveConfirmation) {
                Button("保存", role: .destructive) {
                    saveCurrentSession()
                }
                Button("取消", role: .cancel) { }
            } message: {
                Text("是否保存本次训练会话？")
            }
        }
        .onAppear {
            checkDeviceAvailability()
        }
    }

    // MARK: - 子视图

    /// 连接状态卡片
    private var connectionStatusCard: some View {
        StatusCard(
            title: "AirPods 状态",
            isConnected: motionViewModel.isConnected,
            isTracking: motionViewModel.isMonitoring
        )
    }

    /// 当前姿态显示卡片
    private var currentPostureCard: some View {
        VStack(spacing: 16) {
            Text("当前姿态")
                .font(.headline)
                .foregroundColor(.secondary)

            if motionViewModel.isMonitoring {
                // 3D 姿态可视化
                PostureVisualization3D(
                    pitch: motionViewModel.currentPosture.pitch,
                    yaw: motionViewModel.currentPosture.yaw,
                    roll: motionViewModel.currentPosture.roll,
                    showAxes: true,
                    headColor: deviationColor
                )
                .frame(height: 200)
                .cornerRadius(12)
                .background(Color(.systemGray6))

                // 姿态角度显示
                HStack(spacing: 32) {
                    postureAngleView(
                        label: "俯仰",
                        angle: motionViewModel.currentPosture.pitch,
                        iconName: "arrow.up.and.down"
                    )

                    postureAngleView(
                        label: "偏航",
                        angle: motionViewModel.currentPosture.yaw,
                        iconName: "arrow.left.and.right"
                    )

                    postureAngleView(
                        label: "翻滚",
                        angle: motionViewModel.currentPosture.roll,
                        iconName: "arrow.clockwise"
                    )
                }

                // 偏差指示器
                deviationIndicator
                
                // 姿态评分
                postureScoreView

            } else {
                // 未监测状态
                VStack(spacing: 12) {
                    Image(systemName: "figure.stand.line.dotted.figure.stand")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))

                    Text("点击下方按钮开始监测")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(height: 150)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    /// 姿态角度视图
    private func postureAngleView(label: String, angle: Double, iconName: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(.blue)

            Text(String(format: "%.1f°", angle))
                .font(.title3)
                .fontWeight(.semibold)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    /// 偏差指示器
    private var deviationIndicator: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(motionViewModel.isDeviating ? Color.orange : Color.green)
                .frame(width: 12, height: 12)

            Text(motionViewModel.isDeviating ? "姿态偏差" : "姿态正常")
                .font(.subheadline)
                .foregroundColor(motionViewModel.isDeviating ? .orange : .green)

            Spacer()

            Text(String(format: "偏差: %.1f°", motionViewModel.deviationAngle))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            (motionViewModel.isDeviating ? Color.orange : Color.green)
                .opacity(0.1)
        )
        .cornerRadius(8)
    }
    
    /// 姿态评分视图
    private var postureScoreView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("姿态评分")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(String(format: "%.0f", motionViewModel.postureScore))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(scoreColor)
            }
            
            Spacer()
            
            // 评分等级指示
            Text(scoreGrade)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(scoreColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(scoreColor.opacity(0.15))
                .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    /// 评分颜色
    private var scoreColor: Color {
        if motionViewModel.postureScore >= 90 {
            return .green
        } else if motionViewModel.postureScore >= 70 {
            return .blue
        } else if motionViewModel.postureScore >= 50 {
            return .orange
        } else {
            return .red
        }
    }
    
    /// 评分等级
    private var scoreGrade: String {
        if motionViewModel.postureScore >= 90 {
            return "优秀"
        } else if motionViewModel.postureScore >= 70 {
            return "良好"
        } else if motionViewModel.postureScore >= 50 {
            return "一般"
        } else {
            return "较差"
        }
    }
    
    /// 根据偏差计算头部颜色
    private var deviationColor: UIColor {
        let magnitude = motionViewModel.deviationAngle
        
        if magnitude <= 5.0 {
            return .systemGreen // 姿态很好
        } else if magnitude <= 15.0 {
            return .systemBlue // 姿态正常
        } else if magnitude <= 25.0 {
            return .systemOrange // 有偏差
        } else {
            return .systemRed // 偏差很大
        }
    }

    /// 控制按钮
    private var controlButtons: some View {
        VStack(spacing: 16) {
            // 主控制按钮
            ActionButton(
                title: motionViewModel.isMonitoring ? "停止监测" : "开始监测",
                icon: motionViewModel.isMonitoring ? "stop.circle.fill" : "play.circle.fill",
                isEnabled: motionViewModel.isConnected,
                isPrimary: true
            ) {
                toggleTracking()
            }

            // 辅助按钮
            if motionViewModel.isMonitoring {
                HStack(spacing: 12) {
                    ActionButton(
                        title: "校准目标姿态",
                        icon: "target",
                        isEnabled: true,
                        isPrimary: false
                    ) {
                        calibrateTargetPosture()
                    }
                }
            }
        }
    }

    /// 会话统计卡片
    private var sessionStatisticsCard: some View {
        VStack(spacing: 16) {
            Text("当前会话")
                .font(.headline)
                .foregroundColor(.secondary)

            HStack(spacing: 32) {
                statisticView(
                    label: "时长",
                    value: formatDuration(sessionViewModel.currentSession?.duration ?? 0),
                    iconName: "clock"
                )

                statisticView(
                    label: "偏差次数",
                    value: "\(sessionViewModel.currentSession?.deviationCount ?? 0)",
                    iconName: "exclamationmark.triangle"
                )

                statisticView(
                    label: "当前评分",
                    value: String(format: "%.0f", motionViewModel.postureScore),
                    iconName: "star.fill"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    /// 统计项视图
    private func statisticView(label: String, value: String, iconName: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundColor(.blue)

            Text(value)
                .font(.title3)
                .fontWeight(.semibold)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    /// 提示信息卡片
    private var tipsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("使用提示")
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 8) {
                tipItem("佩戴 AirPods 并保持连接")
                tipItem("首次使用建议先进行校准")
                tipItem("保持自然坐姿，避免剧烈晃动")
                tipItem("建议每 30 分钟休息一次")
            }
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(16)
    }

    /// 提示项
    private func tipItem(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(.secondary)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - 私有方法

    /// 切换监测状态
    private func toggleTracking() {
        if motionViewModel.isMonitoring {
            stopTracking()
        } else {
            startTracking()
        }
    }

    /// 开始监测
    private func startTracking() {
        guard motionViewModel.isConnected else {
            // TODO: 显示错误提示
            print("❌ AirPods 未连接")
            return
        }

        // 启动姿态监测
        motionViewModel.startMonitoring()
        
        // 启动新会话
        sessionViewModel.startSession()

        // 触觉反馈
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// 停止监测
    private func stopTracking() {
        // 停止姿态监测
        motionViewModel.stopMonitoring()
        
        // 结束会话并提示保存
        sessionViewModel.endSession(
            averageScore: motionViewModel.postureScore,
            deviationCount: motionViewModel.deviationCount
        )
        
        // 显示保存确认
        if sessionViewModel.currentSession != nil {
            showingSaveConfirmation = true
        }

        // 触觉反馈
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// 校准目标姿态
    private func calibrateTargetPosture() {
        motionViewModel.setTargetPosture(motionViewModel.currentPosture)
        
        // 触觉反馈
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        print("✅ 目标姿态已校准")
    }
    
    /// 保存当前会话
    private func saveCurrentSession() {
        sessionViewModel.saveSession()
        
        // 触觉反馈
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// 检查设备可用性
    private func checkDeviceAvailability() {
        // 这里可以添加设备检测逻辑
        print("📱 检查 AirPods 连接状态")
    }

    /// 格式化时长
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

// MARK: - 校准视图占位

/// 校准视图（占位）
struct CalibrationView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "scope")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)

                Text("校准功能")
                    .font(.title)
                    .fontWeight(.bold)

                Text("即将推出...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("姿态校准")
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
}

// MARK: - 预览

#Preview("监测视图") {
    MonitoringView()
}

#Preview("暗色模式") {
    MonitoringView()
        .preferredColorScheme(.dark)
}
