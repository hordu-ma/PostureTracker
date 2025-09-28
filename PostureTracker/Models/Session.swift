//
//  Session.swift
//  PostureTracker
//
//  训练会话数据模型
//

import Foundation

/// 训练会话
public struct Session: Codable, Identifiable {
    
    /// 会话唯一标识
    public let id: UUID
    
    /// 用户ID
    public let userId: String
    
    /// 会话类型
    public let type: SessionType
    
    /// 开始时间
    public let startTime: Date
    
    /// 结束时间
    public var endTime: Date?
    
    /// 目标姿态
    public let targetPosture: Posture
    
    /// 运动数据点集合
    public var motionDataPoints: [MotionData]
    
    /// 会话统计
    public var statistics: SessionStatistics?
    
    /// 会话状态
    public var status: SessionStatus
    
    /// 会话标签
    public let tags: [String]
    
    /// 备注
    public var notes: String?
    
    // MARK: - 初始化
    
    public init(
        id: UUID = UUID(),
        userId: String,
        type: SessionType = .training,
        targetPosture: Posture = .standardSitting,
        tags: [String] = []
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.startTime = Date()
        self.endTime = nil
        self.targetPosture = targetPosture
        self.motionDataPoints = []
        self.statistics = nil
        self.status = .active
        self.tags = tags
        self.notes = nil
    }
    
    // MARK: - 计算属性
    
    /// 会话时长（秒）
    public var duration: TimeInterval {
        guard let endTime = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return endTime.timeIntervalSince(startTime)
    }
    
    /// 数据点数量
    public var dataPointCount: Int {
        return motionDataPoints.count
    }
    
    /// 平均采样率
    public var averageSampleRate: Double {
        guard dataPointCount > 1 else { return 0 }
        return Double(dataPointCount) / duration
    }
    
    /// 是否已完成
    public var isCompleted: Bool {
        return status == .completed
    }
    
    // MARK: - 方法
    
    /// 添加运动数据点
    public mutating func addMotionData(_ data: MotionData) {
        motionDataPoints.append(data)
    }
    
    /// 结束会话
    public mutating func end() {
        endTime = Date()
        status = .completed
        calculateStatistics()
    }
    
    /// 暂停会话
    public mutating func pause() {
        status = .paused
    }
    
    /// 恢复会话
    public mutating func resume() {
        status = .active
    }
    
    /// 计算会话统计
    private mutating func calculateStatistics() {
        guard !motionDataPoints.isEmpty else { return }
        
        // 计算各种统计指标
        let postures = motionDataPoints.map { $0.posture }
        let deviations = postures.map { $0.deviation(from: targetPosture) }
        
        // 平均偏差
        let averageDeviation = PostureDeviation(
            pitchDelta: deviations.map { $0.pitchDelta }.reduce(0, +) / Double(deviations.count),
            yawDelta: deviations.map { $0.yawDelta }.reduce(0, +) / Double(deviations.count),
            rollDelta: deviations.map { $0.rollDelta }.reduce(0, +) / Double(deviations.count)
        )
        
        // 最大偏差
        let maxDeviation = deviations.map { $0.magnitude }.max() ?? 0
        
        // 准确率（在容差范围内的百分比）
        let accurateCount = postures.filter { $0.isWithinTolerance(of: targetPosture) }.count
        let accuracy = Double(accurateCount) / Double(postures.count)
        
        // 姿态分布
        let postureDistribution = Dictionary(grouping: postures) { posture in
            PostureType.classify(posture, relativeTo: targetPosture)
        }.mapValues { Double($0.count) / Double(postures.count) }
        
        statistics = SessionStatistics(
            duration: duration,
            dataPointCount: dataPointCount,
            averageDeviation: averageDeviation,
            maxDeviation: maxDeviation,
            accuracy: accuracy,
            postureDistribution: postureDistribution,
            averageSampleRate: averageSampleRate
        )
    }
}

/// 会话类型
public enum SessionType: String, Codable, CaseIterable {
    case training = "训练"
    case calibration = "校准"
    case assessment = "评估"
    case freeMode = "自由模式"
}

/// 会话状态
public enum SessionStatus: String, Codable {
    case active = "进行中"
    case paused = "已暂停"
    case completed = "已完成"
    case cancelled = "已取消"
}

/// 会话统计
public struct SessionStatistics: Codable {
    /// 持续时间（秒）
    public let duration: TimeInterval
    
    /// 数据点数量
    public let dataPointCount: Int
    
    /// 平均偏差
    public let averageDeviation: PostureDeviation
    
    /// 最大偏差
    public let maxDeviation: Double
    
    /// 准确率（0-1）
    public let accuracy: Double
    
    /// 姿态类型分布
    public let postureDistribution: [PostureType: Double]
    
    /// 平均采样率（Hz）
    public let averageSampleRate: Double
    
    /// 获取评分（0-100）
    public var score: Int {
        return Int(accuracy * 100)
    }
    
    /// 获取等级
    public var grade: PerformanceGrade {
        switch score {
        case 90...100:
            return .excellent
        case 75..<90:
            return .good
        case 60..<75:
            return .average
        case 40..<60:
            return .belowAverage
        default:
            return .poor
        }
    }
}

/// 表现等级
public enum PerformanceGrade: String, Codable {
    case excellent = "优秀"
    case good = "良好"
    case average = "一般"
    case belowAverage = "较差"
    case poor = "差"
    
    /// 获取等级颜色（用于UI显示）
    public var colorName: String {
        switch self {
        case .excellent:
            return "green"
        case .good:
            return "blue"
        case .average:
            return "yellow"
        case .belowAverage:
            return "orange"
        case .poor:
            return "red"
        }
    }
    
    /// 获取建议
    public var suggestion: String {
        switch self {
        case .excellent:
            return "非常棒！继续保持良好的姿势。"
        case .good:
            return "做得不错！稍微注意一下细节会更好。"
        case .average:
            return "还有进步空间，多加练习。"
        case .belowAverage:
            return "需要更多练习，注意保持正确姿势。"
        case .poor:
            return "建议重新校准并从基础练习开始。"
        }
    }
}

/// 会话摘要（用于列表显示）
public struct SessionSummary: Codable, Identifiable {
    public let id: UUID
    public let date: Date
    public let type: SessionType
    public let duration: TimeInterval
    public let score: Int
    public let grade: PerformanceGrade
    
    public init(from session: Session) {
        self.id = session.id
        self.date = session.startTime
        self.type = session.type
        self.duration = session.duration
        self.score = session.statistics?.score ?? 0
        self.grade = session.statistics?.grade ?? .poor
    }
}