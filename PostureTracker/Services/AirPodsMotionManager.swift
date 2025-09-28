//
//  AirPodsMotionManager.swift
//  PostureTracker
//
//  AirPods 运动传感器数据管理服务
//

import Foundation
import CoreMotion
import Combine
import os.log

/// AirPods 运动管理器
/// 负责管理传感器数据采集、处理和分发
public class AirPodsMotionManager: NSObject, ObservableObject {
    
    // MARK: - 单例
    
    public static let shared = AirPodsMotionManager()
    
    // MARK: - Published 属性
    
    /// 当前姿态
    @Published public var currentPosture: Posture = .zero
    
    /// 目标姿态
    @Published public var targetPosture: Posture = .standardSitting
    
    /// 当前运动数据
    @Published public var currentMotionData: MotionData?
    
    /// 连接状态
    @Published public var isConnected: Bool = false
    
    /// 采集状态
    @Published public var isTracking: Bool = false
    
    /// 错误信息
    @Published public var error: MotionError?
    
    /// 采样率
    @Published public var sampleRate: Double = 50.0
    
    // MARK: - 私有属性
    
    private let motionManager = CMHeadphoneMotionManager()
    private var motionUpdateTimer: Timer?
    private var dataBuffer: [MotionData] = []
    private let bufferSize = 100
    private let logger = Logger(subsystem: "com.posturetracker", category: "MotionManager")
    
    // MARK: - Combine
    
    /// 运动数据流
    public let motionDataPublisher = PassthroughSubject<MotionData, Never>()
    
    /// 姿态变化流
    public let postureChangePublisher = PassthroughSubject<Posture, Never>()
    
    /// 校准完成流
    public let calibrationCompletePublisher = PassthroughSubject<CalibrationResult, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 初始化
    
    private override init() {
        super.init()
        setupMotionManager()
        checkDeviceAvailability()
    }
    
    // MARK: - 公开方法
    
    /// 开始追踪
    public func startTracking() {
        guard motionManager.isDeviceMotionAvailable else {
            self.error = .deviceNotAvailable
            logger.error("设备不支持运动检测")
            return
        }
        
        guard !isTracking else {
            logger.warning("已经在追踪中")
            return
        }
        
        logger.info("开始追踪运动数据")
        
        // 配置更新间隔
        motionManager.deviceMotionUpdateInterval = 1.0 / sampleRate
        
        // 开始设备运动更新
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self else { return }
            
            if let error = error {
                self.handleMotionError(error)
                return
            }
            
            guard let motion = motion else { return }
            self.processMotionUpdate(motion)
        }
        
        isTracking = true
    }
    
    /// 停止追踪
    public func stopTracking() {
        guard isTracking else { return }
        
        logger.info("停止追踪运动数据")
        motionManager.stopDeviceMotionUpdates()
        isTracking = false
        
        // 清理缓冲区
        dataBuffer.removeAll()
    }
    
    /// 暂停追踪
    public func pauseTracking() {
        guard isTracking else { return }
        
        logger.info("暂停追踪")
        motionManager.stopDeviceMotionUpdates()
        isTracking = false
    }
    
    /// 恢复追踪
    public func resumeTracking() {
        guard !isTracking else { return }
        
        logger.info("恢复追踪")
        startTracking()
    }
    
    /// 设置目标姿态
    public func setTargetPosture(_ posture: Posture) {
        logger.info("设置目标姿态: pitch=\(posture.pitch), yaw=\(posture.yaw), roll=\(posture.roll)")
        targetPosture = posture
    }
    
    /// 设置采样率
    public func setSampleRate(_ rate: Double) {
        guard rate > 0 && rate <= 100 else {
            logger.warning("无效的采样率: \(rate)")
            return
        }
        
        sampleRate = rate
        
        if isTracking {
            // 重新配置更新间隔
            motionManager.deviceMotionUpdateInterval = 1.0 / sampleRate
        }
    }
    
    // MARK: - 校准功能
    
    /// 开始校准
    public func startCalibration(duration: TimeInterval = 5.0) {
        logger.info("开始校准，持续时间: \(duration)秒")
        
        var calibrationData: [Posture] = []
        let startTime = Date()
        
        // 临时提高采样率
        let originalSampleRate = sampleRate
        setSampleRate(100.0)
        
        // 收集校准数据
        motionDataPublisher
            .sink { [weak self] data in
                calibrationData.append(data.posture)
                
                // 检查是否达到校准时间
                if Date().timeIntervalSince(startTime) >= duration {
                    self?.completeCalibration(with: calibrationData, originalSampleRate: originalSampleRate)
                }
            }
            .store(in: &cancellables)
        
        startTracking()
    }
    
    /// 完成校准
    private func completeCalibration(with data: [Posture], originalSampleRate: Double) {
        stopTracking()
        setSampleRate(originalSampleRate)
        
        guard !data.isEmpty else {
            logger.error("校准失败：无数据")
            calibrationCompletePublisher.send(.failure("无校准数据"))
            return
        }
        
        // 计算平均姿态作为基准
        let avgPitch = data.map { $0.pitch }.reduce(0, +) / Double(data.count)
        let avgYaw = data.map { $0.yaw }.reduce(0, +) / Double(data.count)
        let avgRoll = data.map { $0.roll }.reduce(0, +) / Double(data.count)
        
        let calibratedPosture = Posture(pitch: avgPitch, yaw: avgYaw, roll: avgRoll)
        
        logger.info("校准完成: pitch=\(avgPitch), yaw=\(avgYaw), roll=\(avgRoll)")
        
        // 设置为目标姿态
        setTargetPosture(calibratedPosture)
        
        // 发送校准结果
        let result = CalibrationResult(
            success: true,
            referencePosture: calibratedPosture,
            dataPointCount: data.count,
            message: "校准成功"
        )
        
        calibrationCompletePublisher.send(result)
    }
    
    // MARK: - 私有方法
    
    private func setupMotionManager() {
        // 检查权限和可用性
        guard CMHeadphoneMotionManager.authorizationStatus() == .authorized else {
            logger.warning("未授权使用运动数据")
            requestMotionAuthorization()
            return
        }
    }
    
    private func checkDeviceAvailability() {
        isConnected = motionManager.isDeviceMotionAvailable
        
        if !isConnected {
            logger.warning("AirPods 未连接或不支持运动检测")
            error = .deviceNotAvailable
        }
    }
    
    private func requestMotionAuthorization() {
        // 注意：实际的权限请求需要在 Info.plist 中配置
        logger.info("请求运动数据权限")
    }
    
    private func processMotionUpdate(_ motion: CMDeviceMotion) {
        // 创建运动数据
        guard let motionData = MotionData(from: motion) else {
            logger.error("无法创建运动数据")
            return
        }
        
        // 更新当前数据
        currentMotionData = motionData
        currentPosture = motionData.posture
        
        // 添加到缓冲区
        dataBuffer.append(motionData)
        if dataBuffer.count > bufferSize {
            dataBuffer.removeFirst()
        }
        
        // 发布数据
        motionDataPublisher.send(motionData)
        postureChangePublisher.send(motionData.posture)
        
        // 检查姿态偏差
        checkPostureDeviation(motionData.posture)
    }
    
    private func checkPostureDeviation(_ posture: Posture) {
        let deviation = posture.deviation(from: targetPosture)
        
        if deviation.exceedsThreshold(15.0) {
            logger.debug("姿态偏差过大: \(deviation.magnitude)")
        }
    }
    
    private func handleMotionError(_ error: Error) {
        logger.error("运动数据错误: \(error.localizedDescription)")
        self.error = .dataUpdateFailed(error.localizedDescription)
        stopTracking()
    }
    
    // MARK: - 数据导出
    
    /// 获取缓冲区数据
    public func getBufferedData() -> [MotionData] {
        return dataBuffer
    }
    
    /// 清空缓冲区
    public func clearBuffer() {
        dataBuffer.removeAll()
    }
}

// MARK: - 错误定义

/// 运动管理错误
public enum MotionError: LocalizedError {
    case deviceNotAvailable
    case authorizationDenied
    case dataUpdateFailed(String)
    case calibrationFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .deviceNotAvailable:
            return "AirPods 未连接或不支持运动检测"
        case .authorizationDenied:
            return "未授权使用运动数据"
        case .dataUpdateFailed(let reason):
            return "数据更新失败: \(reason)"
        case .calibrationFailed(let reason):
            return "校准失败: \(reason)"
        }
    }
}

// MARK: - 校准结果

/// 校准结果
public struct CalibrationResult {
    public let success: Bool
    public let referencePosture: Posture?
    public let dataPointCount: Int
    public let message: String
    
    public static func failure(_ message: String) -> CalibrationResult {
        return CalibrationResult(
            success: false,
            referencePosture: nil,
            dataPointCount: 0,
            message: message
        )
    }
}