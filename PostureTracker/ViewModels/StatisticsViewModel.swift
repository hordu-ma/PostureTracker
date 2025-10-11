//
//  StatisticsViewModel.swift
//  PostureTracker
//
//  统计数据视图模型 - 提供图表数据和统计分析
//  Created on 2025-10-11
//

import Foundation
import Combine
import SwiftUI

/// 时间范围枚举
enum TimeRange: String, CaseIterable {
    case today = "今天"
    case week = "本周"
    case month = "本月"
    
    var days: Int {
        switch self {
        case .today: return 1
        case .week: return 7
        case .month: return 30
        }
    }
}

/// 统计数据视图模型
/// 负责准备图表数据、过滤和统计分析
class StatisticsViewModel: ObservableObject {
    
    // MARK: - Published 属性
    
    /// 选择的时间范围
    @Published var selectedTimeRange: TimeRange = .today
    
    /// 姿态趋势数据
    @Published var postureData: [PostureDataPoint] = []
    
    /// 训练时长数据
    @Published var durationData: [DurationDataPoint] = []
    
    /// 会话摘要列表
    @Published var sessionSummaries: [SessionSummary] = []
    
    /// 是否正在加载数据
    @Published var isLoading: Bool = false
    
    /// 统计摘要
    @Published var summary: StatisticsSummary?
    
    // MARK: - 私有属性
    
    /// 会话视图模型（用于获取历史数据）
    private let sessionViewModel: SessionViewModel
    
    /// Combine 订阅集合
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 初始化
    
    init(sessionViewModel: SessionViewModel = SessionViewModel()) {
        self.sessionViewModel = sessionViewModel
        setupBindings()
        loadData()
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    // MARK: - 公共方法
    
    /// 加载数据
    func loadData() {
        isLoading = true
        
        // 异步加载数据
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // 加载姿态趋势数据
            let postureData = self.loadPostureData()
            
            // 加载训练时长数据
            let durationData = self.loadDurationData()
            
            // 加载会话摘要
            let summaries = self.loadSessionSummaries()
            
            // 计算统计摘要
            let summary = self.calculateSummary(from: summaries)
            
            // 在主线程更新 UI
            DispatchQueue.main.async {
                self.postureData = postureData
                self.durationData = durationData
                self.sessionSummaries = summaries
                self.summary = summary
                self.isLoading = false
            }
        }
    }
    
    /// 刷新数据
    func refresh() {
        print("🔄 刷新统计数据")
        loadData()
    }
    
    /// 导出统计数据
    func exportStatistics() -> StatisticsExport {
        return StatisticsExport(
            timeRange: selectedTimeRange,
            postureData: postureData,
            durationData: durationData,
            summaries: sessionSummaries,
            summary: summary ?? StatisticsSummary()
        )
    }
    
    // MARK: - 私有方法
    
    /// 设置数据绑定
    private func setupBindings() {
        // 监听时间范围变化
        $selectedTimeRange
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.loadData()
            }
            .store(in: &cancellables)
    }
    
    /// 加载姿态趋势数据
    private func loadPostureData() -> [PostureDataPoint] {
        // 获取时间范围内的会话
        let sessions = getSessionsInRange()
        
        // 根据时间范围生成数据点
        switch selectedTimeRange {
        case .today:
            return generateHourlyPostureData(from: sessions)
        case .week:
            return generateDailyPostureData(from: sessions, days: 7)
        case .month:
            return generateDailyPostureData(from: sessions, days: 30)
        }
    }
    
    /// 加载训练时长数据
    private func loadDurationData() -> [DurationDataPoint] {
        let sessions = getSessionsInRange()
        
        switch selectedTimeRange {
        case .today:
            return generateHourlyDurationData(from: sessions)
        case .week:
            return generateDailyDurationData(from: sessions, days: 7)
        case .month:
            return generateDailyDurationData(from: sessions, days: 30)
        }
    }
    
    /// 加载会话摘要
    private func loadSessionSummaries() -> [SessionSummary] {
        let sessions = getSessionsInRange()
        
        return sessions.map { session in
            SessionSummary(
                id: UUID(),
                date: session.startTime,
                duration: session.duration,
                deviationCount: session.deviationCount,
                averageScore: session.averageScore,
                quality: evaluateQuality(score: session.averageScore)
            )
        }
    }
    
    /// 获取时间范围内的会话
    private func getSessionsInRange() -> [Session] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeRange {
        case .today:
            return sessionViewModel.getSessions(for: now)
        case .week:
            return sessionViewModel.getWeeklySessions()
        case .month:
            return sessionViewModel.getMonthlySessions()
        }
    }
    
    /// 生成按小时的姿态数据（今天）
    private func generateHourlyPostureData(from sessions: [Session]) -> [PostureDataPoint] {
        var dataPoints: [PostureDataPoint] = []
        let calendar = Calendar.current
        let now = Date()
        
        // 生成过去24小时的数据点
        for hourOffset in (0..<24).reversed() {
            guard let hourDate = calendar.date(byAdding: .hour, value: -hourOffset, to: now) else {
                continue
            }
            
            // 获取该小时的姿态数据
            let hourPostures = sessions.flatMap { $0.postureData }.filter { posture in
                let postureDate = Date(timeIntervalSince1970: posture.timestamp)
                return calendar.isDate(postureDate, equalTo: hourDate, toGranularity: .hour)
            }
            
            if !hourPostures.isEmpty {
                let avgPitch = hourPostures.map { $0.pitch }.reduce(0, +) / Double(hourPostures.count)
                let avgYaw = hourPostures.map { $0.yaw }.reduce(0, +) / Double(hourPostures.count)
                let avgRoll = hourPostures.map { $0.roll }.reduce(0, +) / Double(hourPostures.count)
                
                dataPoints.append(PostureDataPoint(
                    id: UUID(),
                    date: hourDate,
                    avgPitch: avgPitch,
                    avgYaw: avgYaw,
                    avgRoll: avgRoll
                ))
            } else {
                // 使用模拟数据填充
                dataPoints.append(MockDataGenerator.generatePostureDataPoint(for: hourDate))
            }
        }
        
        return dataPoints
    }
    
    /// 生成按天的姿态数据
    private func generateDailyPostureData(from sessions: [Session], days: Int) -> [PostureDataPoint] {
        var dataPoints: [PostureDataPoint] = []
        let calendar = Calendar.current
        let now = Date()
        
        for dayOffset in (0..<days).reversed() {
            guard let dayDate = calendar.date(byAdding: .day, value: -dayOffset, to: now) else {
                continue
            }
            
            // 获取该天的姿态数据
            let daySessions = sessions.filter { session in
                calendar.isDate(session.startTime, inSameDayAs: dayDate)
            }
            
            let dayPostures = daySessions.flatMap { $0.postureData }
            
            if !dayPostures.isEmpty {
                let avgPitch = dayPostures.map { $0.pitch }.reduce(0, +) / Double(dayPostures.count)
                let avgYaw = dayPostures.map { $0.yaw }.reduce(0, +) / Double(dayPostures.count)
                let avgRoll = dayPostures.map { $0.roll }.reduce(0, +) / Double(dayPostures.count)
                
                dataPoints.append(PostureDataPoint(
                    id: UUID(),
                    date: dayDate,
                    avgPitch: avgPitch,
                    avgYaw: avgYaw,
                    avgRoll: avgRoll
                ))
            } else {
                // 使用模拟数据填充
                dataPoints.append(MockDataGenerator.generatePostureDataPoint(for: dayDate))
            }
        }
        
        return dataPoints
    }
    
    /// 生成按小时的时长数据
    private func generateHourlyDurationData(from sessions: [Session]) -> [DurationDataPoint] {
        var dataPoints: [DurationDataPoint] = []
        let calendar = Calendar.current
        let now = Date()
        
        for hourOffset in (0..<24).reversed() {
            guard let hourDate = calendar.date(byAdding: .hour, value: -hourOffset, to: now) else {
                continue
            }
            
            // 获取该小时的会话
            let hourSessions = sessions.filter { session in
                calendar.isDate(session.startTime, equalTo: hourDate, toGranularity: .hour)
            }
            
            let totalDuration = hourSessions.reduce(0.0) { $0 + $1.duration }
            
            dataPoints.append(DurationDataPoint(
                id: UUID(),
                date: hourDate,
                duration: totalDuration / 60.0 // 转换为分钟
            ))
        }
        
        return dataPoints
    }
    
    /// 生成按天的时长数据
    private func generateDailyDurationData(from sessions: [Session], days: Int) -> [DurationDataPoint] {
        var dataPoints: [DurationDataPoint] = []
        let calendar = Calendar.current
        let now = Date()
        
        for dayOffset in (0..<days).reversed() {
            guard let dayDate = calendar.date(byAdding: .day, value: -dayOffset, to: now) else {
                continue
            }
            
            // 获取该天的会话
            let daySessions = sessions.filter { session in
                calendar.isDate(session.startTime, inSameDayAs: dayDate)
            }
            
            let totalDuration = daySessions.reduce(0.0) { $0 + $1.duration }
            
            dataPoints.append(DurationDataPoint(
                id: UUID(),
                date: dayDate,
                duration: totalDuration / 60.0 // 转换为分钟
            ))
        }
        
        return dataPoints
    }
    
    /// 计算统计摘要
    private func calculateSummary(from summaries: [SessionSummary]) -> StatisticsSummary {
        guard !summaries.isEmpty else {
            return StatisticsSummary()
        }
        
        let totalSessions = summaries.count
        let totalDuration = summaries.reduce(0.0) { $0 + $1.duration }
        let totalDeviations = summaries.reduce(0) { $0 + $1.deviationCount }
        let averageScore = summaries.reduce(0.0) { $0 + $1.averageScore } / Double(summaries.count)
        
        let bestSession = summaries.max { $0.averageScore < $1.averageScore }
        let longestSession = summaries.max { $0.duration < $1.duration }
        
        return StatisticsSummary(
            totalSessions: totalSessions,
            totalDuration: totalDuration,
            averageDuration: totalDuration / Double(totalSessions),
            totalDeviations: totalDeviations,
            averageScore: averageScore,
            bestScore: bestSession?.averageScore ?? 0,
            longestDuration: longestSession?.duration ?? 0
        )
    }
    
    /// 评估训练质量
    private func evaluateQuality(score: Double) -> SessionQuality {
        switch score {
        case 90...100:
            return .excellent
        case 75..<90:
            return .good
        case 60..<75:
            return .fair
        default:
            return .poor
        }
    }
}

// MARK: - 计算属性

extension StatisticsViewModel {
    
    /// 是否有数据
    var hasData: Bool {
        return !sessionSummaries.isEmpty
    }
    
    /// 格式化的总时长
    var formattedTotalDuration: String {
        guard let summary = summary else { return "0分钟" }
        
        let hours = Int(summary.totalDuration) / 3600
        let minutes = Int(summary.totalDuration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)小时\(minutes)分钟"
        } else {
            return "\(minutes)分钟"
        }
    }
    
    /// 平均会话时长（格式化）
    var formattedAverageDuration: String {
        guard let summary = summary else { return "0分钟" }
        
        let minutes = Int(summary.averageDuration) / 60
        return "\(minutes)分钟"
    }
    
    /// 评分等级
    var scoreGrade: String {
        guard let summary = summary else { return "无数据" }
        
        switch summary.averageScore {
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
        guard let summary = summary else { return .gray }
        
        switch summary.averageScore {
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

// MARK: - 数据模型

/// 统计摘要
struct StatisticsSummary: Codable {
    let totalSessions: Int
    let totalDuration: TimeInterval
    let averageDuration: TimeInterval
    let totalDeviations: Int
    let averageScore: Double
    let bestScore: Double
    let longestDuration: TimeInterval
    
    init() {
        self.totalSessions = 0
        self.totalDuration = 0
        self.averageDuration = 0
        self.totalDeviations = 0
        self.averageScore = 0
        self.bestScore = 0
        self.longestDuration = 0
    }
    
    init(totalSessions: Int, totalDuration: TimeInterval, averageDuration: TimeInterval,
         totalDeviations: Int, averageScore: Double, bestScore: Double, longestDuration: TimeInterval) {
        self.totalSessions = totalSessions
        self.totalDuration = totalDuration
        self.averageDuration = averageDuration
        self.totalDeviations = totalDeviations
        self.averageScore = averageScore
        self.bestScore = bestScore
        self.longestDuration = longestDuration
    }
}

/// 统计数据导出
struct StatisticsExport: Codable {
    let timeRange: TimeRange
    let postureData: [PostureDataPoint]
    let durationData: [DurationDataPoint]
    let summaries: [SessionSummary]
    let summary: StatisticsSummary
    let exportDate: Date = Date()
}
