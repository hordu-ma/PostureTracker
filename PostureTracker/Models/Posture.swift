//
//  Posture.swift
//  PostureTracker
//
//  姿态数据模型，表示头部的三维空间姿态
//

import Foundation
import CoreMotion

/// 姿态数据模型
/// 使用欧拉角表示头部在三维空间中的姿态
public struct Posture: Codable, Equatable {
    
    /// 俯仰角（Pitch）- 绕 X 轴旋转，范围 [-90, 90]
    /// 正值表示抬头，负值表示低头
    public let pitch: Double
    
    /// 偏航角（Yaw）- 绕 Y 轴旋转，范围 [-180, 180]
    /// 正值表示向右转，负值表示向左转
    public let yaw: Double
    
    /// 翻滚角（Roll）- 绕 Z 轴旋转，范围 [-180, 180]
    /// 正值表示向右倾斜，负值表示向左倾斜
    public let roll: Double
    
    /// 时间戳
    public let timestamp: TimeInterval
    
    /// 数据质量评分（0-1）
    public let quality: Double
    
    // MARK: - 初始化
    
    public init(pitch: Double, yaw: Double, roll: Double, timestamp: TimeInterval = Date().timeIntervalSince1970, quality: Double = 1.0) {
        self.pitch = pitch
        self.yaw = yaw
        self.roll = roll
        self.timestamp = timestamp
        self.quality = quality
    }
    
    /// 从 CMAttitude 初始化
    public init(from attitude: CMAttitude, quality: Double = 1.0) {
        self.pitch = attitude.pitch.toDegrees()
        self.yaw = attitude.yaw.toDegrees()
        self.roll = attitude.roll.toDegrees()
        self.timestamp = Date().timeIntervalSince1970
        self.quality = quality
    }
    
    // MARK: - 静态属性
    
    /// 零姿态（中立位置）
    public static var zero: Posture {
        return Posture(pitch: 0, yaw: 0, roll: 0)
    }
    
    /// 标准坐姿姿态
    public static var standardSitting: Posture {
        return Posture(pitch: -5, yaw: 0, roll: 0)
    }
    
    // MARK: - 计算属性
    
    /// 计算与目标姿态的欧几里得距离
    public func distance(to target: Posture) -> Double {
        let deltaPitch = pitch - target.pitch
        let deltaYaw = yaw - target.yaw
        let deltaRoll = roll - target.roll
        return sqrt(deltaPitch * deltaPitch + deltaYaw * deltaYaw + deltaRoll * deltaRoll)
    }
    
    /// 计算与目标姿态的偏差
    public func deviation(from target: Posture) -> PostureDeviation {
        return PostureDeviation(
            pitchDelta: pitch - target.pitch,
            yawDelta: yaw - target.yaw,
            rollDelta: roll - target.roll
        )
    }
    
    /// 判断是否在目标姿态的容差范围内
    public func isWithinTolerance(of target: Posture, tolerance: Double = 10.0) -> Bool {
        return abs(pitch - target.pitch) <= tolerance &&
               abs(yaw - target.yaw) <= tolerance &&
               abs(roll - target.roll) <= tolerance
    }
    
    /// 获取主要偏离轴
    public func primaryDeviationAxis(from target: Posture) -> DeviationAxis {
        let deviation = self.deviation(from: target)
        let absPitch = abs(deviation.pitchDelta)
        let absYaw = abs(deviation.yawDelta)
        let absRoll = abs(deviation.rollDelta)
        
        if absPitch >= absYaw && absPitch >= absRoll {
            return .pitch
        } else if absYaw >= absRoll {
            return .yaw
        } else {
            return .roll
        }
    }
}

/// 姿态偏差
public struct PostureDeviation: Codable, Equatable {
    public let pitchDelta: Double
    public let yawDelta: Double
    public let rollDelta: Double
    
    /// 偏差幅度
    public var magnitude: Double {
        return sqrt(pitchDelta * pitchDelta + yawDelta * yawDelta + rollDelta * rollDelta)
    }
    
    /// 是否超过阈值
    public func exceedsThreshold(_ threshold: Double) -> Bool {
        return magnitude > threshold
    }
    
    /// 获取最大偏差值
    public var maxDeviation: Double {
        return max(abs(pitchDelta), max(abs(yawDelta), abs(rollDelta)))
    }
}

/// 偏离轴枚举
public enum DeviationAxis: String, Codable {
    case pitch = "pitch"
    case yaw = "yaw"
    case roll = "roll"
    
    /// 获取中文描述
    public var chineseDescription: String {
        switch self {
        case .pitch:
            return "俯仰"
        case .yaw:
            return "偏航"
        case .roll:
            return "翻滚"
        }
    }
}

/// 姿态类型
public enum PostureType: String, Codable, CaseIterable {
    case good = "良好"
    case forward = "前倾"
    case backward = "后仰"
    case leftTilt = "左倾"
    case rightTilt = "右倾"
    case unknown = "未知"
    
    /// 根据姿态判断类型
    public static func classify(_ posture: Posture, relativeTo reference: Posture = .standardSitting) -> PostureType {
        let deviation = posture.deviation(from: reference)
        
        // 设定阈值
        let threshold: Double = 15.0
        
        // 判断姿态类型
        if deviation.magnitude < threshold {
            return .good
        }
        
        // 根据主要偏离方向判断
        if abs(deviation.pitchDelta) > threshold {
            return deviation.pitchDelta > 0 ? .backward : .forward
        }
        
        if abs(deviation.rollDelta) > threshold {
            return deviation.rollDelta > 0 ? .rightTilt : .leftTilt
        }
        
        return .unknown
    }
}

// MARK: - Extensions

fileprivate extension Double {
    /// 将弧度转换为角度
    func toDegrees() -> Double {
        return self * 180.0 / .pi
    }
    
    /// 将角度转换为弧度
    func toRadians() -> Double {
        return self * .pi / 180.0
    }
}