//
//  MonitoringView.swift
//  PostureTracker
//
//  主监测页面 - 实时姿态监测和控制
//  Created on 2024-09-30
//

import SwiftUI

struct MonitoringView: View {

    // MARK: - 属性

    /// AirPods 运动管理器
    @ObservedObject private var motionManager = AirPodsMotionManager.shared

    /// 是否显示校准视图
    @State private var showingCalibration = false

    /// 是否显示设置
    @State private var showingSettings = false

    /// 当前会话统计
    @State private var sessionDuration: TimeInterval = 0
    @State private var deviationCount: Int = 0

    /// 计时器
    @State private var timer: Timer?

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
                    if motionManager.isTracking {
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
        }
        .onAppear {
            checkDeviceAvailability()
        }
        .onDisappear {
            stopTimer()
        }
    }

    // MARK: - 子视图

    /// 连接状态卡片
    private var connectionStatusCard: some View {
        StatusCard(
            title: "AirPods 状态",
            isConnected: motionManager.isConnected,
            isTracking: motionManager.isTracking
        )
    }

    /// 当前姿态显示卡片
    private var currentPostureCard: some View {
        VStack(spacing: 16) {
            Text("当前姿态")
                .font(.headline)
                .foregroundColor(.secondary)

            if motionManager.isTracking {
                // 3D 姿态可视化
                PostureVisualization3D(
                    pitch: motionManager.currentPosture.pitch,
                    yaw: motionManager.currentPosture.yaw,
                    roll: motionManager.currentPosture.roll,
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
                        angle: motionManager.currentPosture.pitch,
                        iconName: "arrow.up.and.down"
                    )

                    postureAngleView(
                        label: "偏航",
                        angle: motionManager.currentPosture.yaw,
                        iconName: "arrow.left.and.right"
                    )

                    postureAngleView(
                        label: "翻滚",
                        angle: motionManager.currentPosture.roll,
                        iconName: "arrow.clockwise"
                    )
                }

                // 偏差指示器
                deviationIndicator

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
        let deviation = motionManager.currentPosture.deviation(from: motionManager.targetPosture)
        let isNormal = !deviation.exceedsThreshold(15.0)

        return HStack(spacing: 12) {
            Circle()
                .fill(isNormal ? Color.green : Color.orange)
                .frame(width: 12, height: 12)

            Text(isNormal ? "姿态正常" : "姿态偏差")
                .font(.subheadline)
                .foregroundColor(isNormal ? .green : .orange)

            Spacer()

            Text(String(format: "偏差: %.1f°", deviation.magnitude))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            (isNormal ? Color.green : Color.orange)
                .opacity(0.1)
        )
        .cornerRadius(8)
    }
    
    /// 根据偏差计算头部颜色
    private var deviationColor: UIColor {
        let deviation = motionManager.currentPosture.deviation(from: motionManager.targetPosture)
        let magnitude = deviation.magnitude
        
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
                title: motionManager.isTracking ? "停止监测" : "开始监测",
                icon: motionManager.isTracking ? "stop.circle.fill" : "play.circle.fill",
                isEnabled: motionManager.isConnected,
                isPrimary: true
            ) {
                toggleTracking()
            }

            // 辅助按钮
            if motionManager.isTracking {
                HStack(spacing: 12) {
                    ActionButton(
                        title: "暂停",
                        icon: "pause.circle",
                        isEnabled: true,
                        isPrimary: false
                    ) {
                        pauseTracking()
                    }

                    ActionButton(
                        title: "重置",
                        icon: "arrow.counterclockwise",
                        isEnabled: true,
                        isPrimary: false
                    ) {
                        resetSession()
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
                    value: formatDuration(sessionDuration),
                    iconName: "clock"
                )

                statisticView(
                    label: "偏差次数",
                    value: "\(deviationCount)",
                    iconName: "exclamationmark.triangle"
                )

                statisticView(
                    label: "采样率",
                    value: String(format: "%.0f Hz", motionManager.sampleRate),
                    iconName: "waveform"
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
        if motionManager.isTracking {
            stopTracking()
        } else {
            startTracking()
        }
    }

    /// 开始监测
    private func startTracking() {
        guard motionManager.isConnected else {
            // TODO: 显示错误提示
            print("❌ AirPods 未连接")
            return
        }

        motionManager.startTracking()
        startTimer()

        // 重置统计
        sessionDuration = 0
        deviationCount = 0

        // 触觉反馈
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// 停止监测
    private func stopTracking() {
        motionManager.stopTracking()
        stopTimer()

        // 触觉反馈
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// 暂停监测
    private func pauseTracking() {
        motionManager.pauseTracking()
        stopTimer()
    }

    /// 重置会话
    private func resetSession() {
        sessionDuration = 0
        deviationCount = 0

        // 触觉反馈
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// 检查设备可用性
    private func checkDeviceAvailability() {
        // 这里可以添加设备检测逻辑
        print("📱 检查 AirPods 连接状态")
    }

    /// 启动计时器
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            sessionDuration += 1
        }
    }

    /// 停止计时器
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
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
