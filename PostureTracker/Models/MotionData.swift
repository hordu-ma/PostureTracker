//
//  MotionData.swift
//  PostureTracker
//
//  运动数据模型，包含加速度、陀螺仪和四元数数据
//

import Foundation
import CoreMotion

/// 运动数据模型
/// 封装传感器原始数据和处理后的运动信息
public struct MotionData: Codable {
    
    /// 数据唯一标识
    public let id: UUID
    
    /// 时间戳
    public let timestamp: TimeInterval
    
    /// 加速度数据（单位：g）
    public let acceleration: Vector3D
    
    /// 陀螺仪数据（单位：rad/s）
    public let rotationRate: Vector3D
    
    /// 四元数（用于姿态表示）
    public let quaternion: Quaternion
    
    /// 姿态数据
    public let posture: Posture
    
    /// 角速度（单位：degrees/s）
    public let angularVelocity: AngularVelocity
    
    /// 数据来源
    public let source: DataSource
    
    /// 采样率（Hz）
    public let sampleRate: Double
    
    // MARK: - 初始化
    
    public init(
        id: UUID = UUID(),
        timestamp: TimeInterval = Date().timeIntervalSince1970,
        acceleration: Vector3D,
        rotationRate: Vector3D,
        quaternion: Quaternion,
        posture: Posture,
        angularVelocity: AngularVelocity,
        source: DataSource = .airpods,
        sampleRate: Double = 50.0
    ) {
        self.id = id
        self.timestamp = timestamp
        self.acceleration = acceleration
        self.rotationRate = rotationRate
        self.quaternion = quaternion
        self.posture = posture
        self.angularVelocity = angularVelocity
        self.source = source
        self.sampleRate = sampleRate
    }
    
    /// 从 CMHeadphoneMotionManager 数据初始化
    public init?(from headphoneMotion: CMDeviceMotion, source: DataSource = .airpods) {
        self.id = UUID()
        self.timestamp = Date().timeIntervalSince1970
        
        // 加速度数据
        self.acceleration = Vector3D(
            x: headphoneMotion.userAcceleration.x,
            y: headphoneMotion.userAcceleration.y,
            z: headphoneMotion.userAcceleration.z
        )
        
        // 陀螺仪数据
        self.rotationRate = Vector3D(
            x: headphoneMotion.rotationRate.x,
            y: headphoneMotion.rotationRate.y,
            z: headphoneMotion.rotationRate.z
        )
        
        // 四元数
        self.quaternion = Quaternion(
            w: headphoneMotion.attitude.quaternion.w,
            x: headphoneMotion.attitude.quaternion.x,
            y: headphoneMotion.attitude.quaternion.y,
            z: headphoneMotion.attitude.quaternion.z
        )
        
        // 姿态
        self.posture = Posture(from: headphoneMotion.attitude)
        
        // 角速度
        self.angularVelocity = AngularVelocity(
            pitch: headphoneMotion.rotationRate.x.toDegrees(),
            yaw: headphoneMotion.rotationRate.y.toDegrees(),
            roll: headphoneMotion.rotationRate.z.toDegrees()
        )
        
        self.source = source
        self.sampleRate = 50.0 // 默认采样率
    }
}

/// 三维向量
public struct Vector3D: Codable, Equatable {
    public let x: Double
    public let y: Double
    public let z: Double
    
    /// 向量模长
    public var magnitude: Double {
        return sqrt(x * x + y * y + z * z)
    }
    
    /// 归一化向量
    public var normalized: Vector3D {
        let mag = magnitude
        guard mag > 0 else { return Vector3D(x: 0, y: 0, z: 0) }
        return Vector3D(x: x/mag, y: y/mag, z: z/mag)
    }
    
    /// 点积
    public func dot(_ other: Vector3D) -> Double {
        return x * other.x + y * other.y + z * other.z
    }
    
    /// 叉积
    public func cross(_ other: Vector3D) -> Vector3D {
        return Vector3D(
            x: y * other.z - z * other.y,
            y: z * other.x - x * other.z,
            z: x * other.y - y * other.x
        )
    }
}

/// 四元数
public struct Quaternion: Codable, Equatable {
    public let w: Double
    public let x: Double
    public let y: Double
    public let z: Double
    
    /// 获取共轭四元数
    public var conjugate: Quaternion {
        return Quaternion(w: w, x: -x, y: -y, z: -z)
    }
    
    /// 获取四元数模长
    public var magnitude: Double {
        return sqrt(w * w + x * x + y * y + z * z)
    }
    
    /// 归一化四元数
    public var normalized: Quaternion {
        let mag = magnitude
        guard mag > 0 else { return Quaternion(w: 1, x: 0, y: 0, z: 0) }
        return Quaternion(w: w/mag, x: x/mag, y: y/mag, z: z/mag)
    }
    
    /// 转换为欧拉角
    public func toEulerAngles() -> (pitch: Double, yaw: Double, roll: Double) {
        let pitch = atan2(2 * (w * x + y * z), 1 - 2 * (x * x + y * y))
        let yaw = asin(2 * (w * y - z * x))
        let roll = atan2(2 * (w * z + x * y), 1 - 2 * (y * y + z * z))
        
        return (pitch: pitch.toDegrees(), yaw: yaw.toDegrees(), roll: roll.toDegrees())
    }
}

/// 角速度
public struct AngularVelocity: Codable, Equatable {
    /// 俯仰角速度（degrees/s）
    public let pitch: Double
    
    /// 偏航角速度（degrees/s）
    public let yaw: Double
    
    /// 翻滚角速度（degrees/s）
    public let roll: Double
    
    /// 总角速度
    public var magnitude: Double {
        return sqrt(pitch * pitch + yaw * yaw + roll * roll)
    }
    
    /// 是否处于静止状态（角速度小于阈值）
    public func isStationary(threshold: Double = 5.0) -> Bool {
        return magnitude < threshold
    }
}

/// 数据来源
public enum DataSource: String, Codable {
    case airpods = "AirPods"
    case iPhone = "iPhone"
    case appleWatch = "Apple Watch"
    case simulator = "Simulator"
    case mock = "Mock"
}

/// 运动状态
public enum MotionState: String, Codable {
    case stationary = "静止"
    case moving = "运动中"
    case rotating = "旋转中"
    case accelerating = "加速中"
    case unknown = "未知"
    
    /// 根据运动数据判断状态
    public static func detect(from data: MotionData) -> MotionState {
        let accThreshold = 0.1 // g
        let rotThreshold = 5.0 // degrees/s
        
        let isAccelerating = data.acceleration.magnitude > accThreshold
        let isRotating = data.angularVelocity.magnitude > rotThreshold
        
        if !isAccelerating && !isRotating {
            return .stationary
        } else if isRotating && !isAccelerating {
            return .rotating
        } else if isAccelerating && !isRotating {
            return .accelerating
        } else {
            return .moving
        }
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