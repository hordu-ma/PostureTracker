//
//  MotionViewModel.swift
//  PostureTracker
//
//  运动数据视图模型 - 处理实时姿态监测和数据流
//  Created on 2025-10-11
//

import Foundation
import Combine
import SwiftUI

/// 运动数据视图模型
/// 负责管理实时姿态数据、偏差检测和音频反馈
class MotionViewModel: ObservableObject {
    
    // MARK: - Published 属性
    
    /// 当前姿态
    @Published var currentPosture: Posture = .zero
    
    /// 目标姿态
    @Published var targetPosture: Posture = .standardSitting
    
    /// 当前偏差
    @Published var currentDeviation: PostureDeviation?
    
    /// 是否处于监测状态
    @Published var isMonitoring: Bool = false
    
    /// AirPods 连接状态
    @Published var isConnected: Bool = false
    
    /// 偏差状态（是否超出容差范围）
    @Published var isDeviating: Bool = false
    
    /// 偏差次数
    @Published var deviationCount: Int = 0
    
    /// 监测时长（秒）
    @Published var monitoringDuration: TimeInterval = 0
    
    /// 姿态质量评分（0-100）
    @Published var postureScore: Double = 100.0
    
    /// 错误信息
    @Published var errorMessage: String?
    
    // MARK: - 私有属性
    
    /// 运动管理器
    private let motionManager = AirPodsMotionManager.shared
    
    /// 音频反馈管理器
    private let audioManager = AudioFeedbackManager.shared
    
    /// 设置管理器
    private let settingsManager = SettingsManager.shared
    
    /// Combine 订阅集合
    private var cancellables = Set<AnyCancellable>()
    
    /// 监测开始时间
    private var monitoringStartTime: Date?
    
    /// 计时器
    private var timer: Timer?
    
    /// 姿态历史记录（用于计算评分）
    private var postureHistory: [Posture] = []
    private let maxHistorySize = 100
    
    /// 上次偏差检测时间
    private var lastDeviationCheckTime: Date = Date()
    
    // MARK: - 初始化
    
    init() {
        setupBindings()
        setupMotionManager()
    }
    
    deinit {
        stopMonitoring()
        cancellables.removeAll()
    }
    
    // MARK: - 公共方法
    
    /// 开始监测
    func startMonitoring() {
        guard !isMonitoring else {
            print("⚠️ 已经在监测中")
            return
        }
        
        print("🎯 开始姿态监测")
        
        // 重置状态
        resetStats()
        
        // 应用设置
        applySensitivitySettings()
        
        // 启动运动管理器
        motionManager.startTracking()
        
        // 启动计时器
        startTimer()
        
        // 更新状态
        isMonitoring = true
        monitoringStartTime = Date()
    }
    
    /// 停止监测
    func stopMonitoring() {
        guard isMonitoring else { return }
        
        print("🛑 停止姿态监测")
        
        // 停止运动管理器
        motionManager.stopTracking()
        
        // 停止计时器
        stopTimer()
        
        // 停止音频反馈
        audioManager.stopAllFeedback()
        
        // 更新状态
        isMonitoring = false
    }
    
    /// 暂停监测
    func pauseMonitoring() {
        guard isMonitoring else { return }
        
        print("⏸️ 暂停姿态监测")
        
        motionManager.pauseTracking()
        stopTimer()
        audioManager.pauseFeedback()
    }
    
    /// 恢复监测
    func resumeMonitoring() {
        guard !isMonitoring else { return }
        
        print("▶️ 恢复姿态监测")
        
        motionManager.resumeTracking()
        startTimer()
        audioManager.resumeFeedback()
        
        isMonitoring = true
    }
    
    /// 重置统计数据
    func resetStats() {
        deviationCount = 0
        monitoringDuration = 0
        postureScore = 100.0
        postureHistory.removeAll()
        errorMessage = nil
    }
    
    /// 设置目标姿态
    func setTargetPosture(_ posture: Posture) {
        targetPosture = posture
        motionManager.setTargetPosture(posture)
        print("🎯 目标姿态已设置: pitch=\(posture.pitch)°, yaw=\(posture.yaw)°, roll=\(posture.roll)°")
    }
    
    /// 开始校准
    func startCalibration(duration: TimeInterval = 5.0, completion: @escaping (Result<Posture, Error>) -> Void) {
        print("🔧 开始校准，持续时间: \(duration)秒")
        
        motionManager.calibrationCompletePublisher
            .sink { [weak self] result in
                switch result {
                case .success(let posture):
                    self?.setTargetPosture(posture)
                    completion(.success(posture))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            .store(in: &cancellables)
        
        motionManager.startCalibration(duration: duration)
    }
    
    // MARK: - 私有方法
    
    /// 设置数据绑定
    private func setupBindings() {
        // 订阅姿态变化
        motionManager.$currentPosture
            .receive(on: DispatchQueue.main)
            .sink { [weak self] posture in
                self?.handlePostureUpdate(posture)
            }
            .store(in: &cancellables)
        
        // 订阅连接状态
        motionManager.$isConnected
            .receive(on: DispatchQueue.main)
            .assign(to: \.isConnected, on: self)
            .store(in: &cancellables)
        
        // 订阅错误信息
        motionManager.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                }
            }
            .store(in: &cancellables)
    }
    
    /// 设置运动管理器
    private func setupMotionManager() {
        // 设置采样率
        motionManager.setSampleRate(settingsManager.sampleRate)
    }
    
    /// 应用灵敏度设置
    private func applySensitivitySettings() {
        motionManager.setSampleRate(settingsManager.sampleRate)
        // 灵敏度会影响偏差阈值，在偏差检测中使用
    }
    
    /// 处理姿态更新
    private func handlePostureUpdate(_ posture: Posture) {
        currentPosture = posture
        
        // 添加到历史记录
        addToHistory(posture)
        
        // 检测偏差
        checkDeviation()
        
        // 更新评分
        updatePostureScore()
    }
    
    /// 添加姿态到历史记录
    private func addToHistory(_ posture: Posture) {
        postureHistory.append(posture)
        
        // 限制历史记录大小
        if postureHistory.count > maxHistorySize {
            postureHistory.removeFirst()
        }
    }
    
    /// 检测姿态偏差
    private func checkDeviation() {
        guard isMonitoring else { return }
        
        // 计算偏差
        let deviation = currentPosture.deviation(from: targetPosture)
        currentDeviation = deviation
        
        // 获取灵敏度设置（作为容差）
        let tolerance = settingsManager.sensitivity
        
        // 检查是否超出容差
        let wasDeviating = isDeviating
        isDeviating = deviation.magnitude > tolerance
        
        // 如果从正常变为偏差，增加计数
        if !wasDeviating && isDeviating {
            deviationCount += 1
            
            // 检查是否应该提供音频反馈
            let timeSinceLastCheck = Date().timeIntervalSince(lastDeviationCheckTime)
            if timeSinceLastCheck >= settingsManager.alertDelay {
                provideAudioFeedback(for: deviation)
                lastDeviationCheckTime = Date()
            }
        }
    }
    
    /// 提供音频反馈
    private func provideAudioFeedback(for deviation: PostureDeviation) {
        audioManager.provideFeedback(for: currentPosture, target: targetPosture)
    }
    
    /// 更新姿态评分
    private func updatePostureScore() {
        guard !postureHistory.isEmpty else {
            postureScore = 100.0
            return
        }
        
        // 计算历史记录中符合标准的姿态比例
        let tolerance = settingsManager.sensitivity
        let goodPostureCount = postureHistory.filter { posture in
            posture.isWithinTolerance(of: targetPosture, tolerance: tolerance)
        }.count
        
        postureScore = (Double(goodPostureCount) / Double(postureHistory.count)) * 100.0
    }
    
    /// 启动计时器
    private func startTimer() {
        stopTimer() // 确保没有重复计时器
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if let startTime = self.monitoringStartTime {
                self.monitoringDuration = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    /// 停止计时器
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - 计算属性

extension MotionViewModel {
    
    /// 格式化的监测时长
    var formattedDuration: String {
        let hours = Int(monitoringDuration) / 3600
        let minutes = Int(monitoringDuration) % 3600 / 60
        let seconds = Int(monitoringDuration) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    /// 偏差状态文本
    var deviationStatusText: String {
        if !isMonitoring {
            return "未监测"
        } else if isDeviating {
            return "姿态偏差"
        } else {
            return "姿态良好"
        }
    }
    
    /// 偏差状态颜色
    var deviationStatusColor: Color {
        if !isMonitoring {
            return .gray
        } else if isDeviating {
            return .red
        } else {
            return .green
        }
    }
    
    /// 评分等级
    var scoreGrade: String {
        switch postureScore {
        case 90...100:
            return "优秀"
        case 75..<90:
            return "良好"
        case 60..<75:
            return "中等"
        case 40..<60:
            return "较差"
        default:
            return "需改善"
        }
    }
    
    /// 评分颜色
    var scoreColor: Color {
        switch postureScore {
        case 90...100:
            return .green
        case 75..<90:
            return .blue
        case 60..<75:
            return .orange
        default:
            return .red
        }
    }
}

// MARK: - CalibrationResult

/// 校准结果
enum CalibrationResult {
    case success(Posture)
    case failure(String)
}
