//
//  MockDataGenerator.swift
//  PostureTracker
//
//  测试数据生成器 - 为图表和统计功能提供模拟数据
//  Created on 2024-09-30
//

import Foundation

/// 模拟数据生成器
struct MockDataGenerator {
    
    // MARK: - 姿态数据
    
    /// 生成今日姿态趋势数据
    static func generateTodayPostureData() -> [PostureDataPoint] {
        var data: [PostureDataPoint] = []
        let now = Date()
        let calendar = Calendar.current
        
        // 生成过去24小时的数据，每小时一个数据点
        for hour in 0..<24 {
            guard let date = calendar.date(byAdding: .hour, value: -hour, to: now) else { continue }
            
            // 模拟真实的姿态变化模式
            let timeOfDay = 24 - hour
            let avgPitch = generateRealisticPitchValue(for: timeOfDay)
            let avgYaw = Double.random(in: -8...8)
            let avgRoll = Double.random(in: -5...5)
            
            data.append(PostureDataPoint(
                id: UUID(),
                date: date,
                avgPitch: avgPitch,
                avgYaw: avgYaw,
                avgRoll: avgRoll
            ))
        }
        
        return data.reversed() // 按时间正序排列
    }
    
    /// 生成本周姿态数据
    static func generateWeeklyPostureData() -> [PostureDataPoint] {
        var data: [PostureDataPoint] = []
        let now = Date()
        let calendar = Calendar.current
        
        // 生成过去7天的数据
        for day in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -day, to: now) else { continue }
            
            let avgPitch = generateDailyAveragePitch()
            let avgYaw = Double.random(in: -6...6)
            let avgRoll = Double.random(in: -4...4)
            
            data.append(PostureDataPoint(
                id: UUID(),
                date: date,
                avgPitch: avgPitch,
                avgYaw: avgYaw,
                avgRoll: avgRoll
            ))
        }
        
        return data.reversed()
    }
    
    /// 生成本月姿态数据
    static func generateMonthlyPostureData() -> [PostureDataPoint] {
        var data: [PostureDataPoint] = []
        let now = Date()
        let calendar = Calendar.current
        
        // 生成过去30天的数据
        for day in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -day, to: now) else { continue }
            
            let avgPitch = generateDailyAveragePitch()
            let avgYaw = Double.random(in: -5...5)
            let avgRoll = Double.random(in: -3...3)
            
            data.append(PostureDataPoint(
                id: UUID(),
                date: date,
                avgPitch: avgPitch,
                avgYaw: avgYaw,
                avgRoll: avgRoll
            ))
        }
        
        return data.reversed()
    }
    
    // MARK: - 训练时长数据
    
    /// 生成每日训练时长数据
    static func generateWeeklyDurationData() -> [DurationDataPoint] {
        var data: [DurationDataPoint] = []
        let now = Date()
        let calendar = Calendar.current
        
        for day in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -day, to: now) else { continue }
            
            // 工作日vs周末的不同模式
            let isWeekend = calendar.isDateInWeekend(date)
            let baseDuration = isWeekend ? 45.0 : 30.0 // 分钟
            let variation = Double.random(in: -15...25)
            let duration = max(0, baseDuration + variation)
            
            data.append(DurationDataPoint(
                id: UUID(),
                date: date,
                duration: duration
            ))
        }
        
        return data.reversed()
    }
    
    /// 生成月度训练时长数据
    static func generateMonthlyDurationData() -> [DurationDataPoint] {
        var data: [DurationDataPoint] = []
        let now = Date()
        let calendar = Calendar.current
        
        // 按周聚合显示
        for week in 0..<4 {
            guard let date = calendar.date(byAdding: .weekOfYear, value: -week, to: now) else { continue }
            
            // 每周总训练时长
            let weeklyTotal = Double.random(in: 150...400) // 分钟
            
            data.append(DurationDataPoint(
                id: UUID(),
                date: date,
                duration: weeklyTotal
            ))
        }
        
        return data.reversed()
    }
    
    // MARK: - 会话统计数据
    
    /// 生成会话摘要数据
    static func generateSessionSummaries(count: Int = 10) -> [SessionSummary] {
        var summaries: [SessionSummary] = []
        let now = Date()
        let calendar = Calendar.current
        
        for i in 0..<count {
            guard let date = calendar.date(byAdding: .day, value: -i, to: now) else { continue }
            
            let sessionId = UUID()
            let sessionType = SessionType.allCases.randomElement() ?? .training
            let duration = TimeInterval.random(in: 900...5400) // 15分钟到1.5小时
            let score = Int.random(in: 40...95)
            let grade = determineGrade(for: score)
            
            summaries.append(SessionSummary(
                id: sessionId,
                date: date,
                type: sessionType,
                duration: duration,
                score: score,
                grade: grade
            ))
        }
        
        return summaries
    }
    
    /// 生成实时会话统计
    static func generateCurrentSessionStats() -> SessionStatistics {
        let accuracy = Double.random(in: 0.6...0.9)
        
        return SessionStatistics(
            duration: TimeInterval.random(in: 300...3600), // 5分钟到1小时
            dataPointCount: Int.random(in: 150...1800),
            averageDeviation: PostureDeviation(
                pitchDelta: Double.random(in: -10...10),
                yawDelta: Double.random(in: -8...8),
                rollDelta: Double.random(in: -5...5)
            ),
            maxDeviation: Double.random(in: 15...35),
            accuracy: accuracy,
            postureDistribution: [
                .neutral: Double.random(in: 0.6...0.8),
                .forwardHead: Double.random(in: 0.1...0.2),
                .backwardHead: Double.random(in: 0.05...0.1),
                .leftTilt: Double.random(in: 0.02...0.08),
                .rightTilt: Double.random(in: 0.02...0.08)
            ],
            averageSampleRate: Double.random(in: 45...55)
        )
    }
    
    // MARK: - 私有辅助方法
    
    /// 生成真实的俯仰角值（基于一天中的时间）
    private static func generateRealisticPitchValue(for hour: Int) -> Double {
        switch hour {
        case 6...8: // 早晨，较好的姿势
            return Double.random(in: -5...2)
        case 9...11: // 上午工作，逐渐变差
            return Double.random(in: -8...5)
        case 12...13: // 午餐时间，稍微改善
            return Double.random(in: -6...3)
        case 14...17: // 下午工作，姿势较差
            return Double.random(in: -15...8)
        case 18...19: // 下班时间，略有改善
            return Double.random(in: -10...5)
        case 20...22: // 晚上放松，中等姿势
            return Double.random(in: -8...6)
        default: // 夜间和深夜，数据较少
            return Double.random(in: -12...10)
        }
    }
    
    /// 生成每日平均俯仰角
    private static func generateDailyAveragePitch() -> Double {
        return Double.random(in: -12...8)
    }
    
    /// 根据分数确定等级
    private static func determineGrade(for score: Int) -> PerformanceGrade {
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

// MARK: - 数据模型

/// 姿态数据点（用于图表显示）
struct PostureDataPoint: Identifiable {
    let id: UUID
    let date: Date
    let avgPitch: Double
    let avgYaw: Double
    let avgRoll: Double
    
    /// 姿态偏差量级
    var magnitude: Double {
        return sqrt(avgPitch * avgPitch + avgYaw * avgYaw + avgRoll * avgRoll)
    }
}

/// 训练时长数据点
struct DurationDataPoint: Identifiable {
    let id: UUID
    let date: Date
    let duration: Double // 分钟
    
    /// 格式化时长显示
    var formattedDuration: String {
        let hours = Int(duration) / 60
        let minutes = Int(duration) % 60
        
        if hours > 0 {
            return "\(hours)h\(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

/// 会话统计数据点
struct SessionDataPoint: Identifiable {
    let id: UUID
    let date: Date
    let sessionCount: Int
    let averageScore: Double
    let totalDuration: Double
}

// MARK: - 预览支持

#if DEBUG
extension MockDataGenerator {
    /// 预览用的快速数据生成
    static var previewPostureData: [PostureDataPoint] {
        return generateTodayPostureData().suffix(12).map { $0 }
    }
    
    static var previewDurationData: [DurationDataPoint] {
        return generateWeeklyDurationData()
    }
    
    static var previewSessionStats: SessionStatistics {
        return generateCurrentSessionStats()
    }
}
#endif