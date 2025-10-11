//
//  SessionViewModel.swift
//  PostureTracker
//
//  会话管理视图模型 - 管理训练会话和历史记录
//  Created on 2025-10-11
//

import Foundation
import Combine
import SwiftUI

/// 会话管理视图模型
/// 负责管理训练会话的生命周期、统计数据和历史记录
class SessionViewModel: ObservableObject {
    
    // MARK: - Published 属性
    
    /// 当前会话
    @Published var currentSession: Session?
    
    /// 会话历史记录
    @Published var sessionHistory: [Session] = []
    
    /// 是否正在进行会话
    @Published var isSessionActive: Bool = false
    
    /// 会话持续时间（秒）
    @Published var sessionDuration: TimeInterval = 0
    
    /// 当前会话的偏差次数
    @Published var currentDeviationCount: Int = 0
    
    /// 当前会话的姿态评分
    @Published var currentSessionScore: Double = 100.0
    
    /// 今日总训练时长
    @Published var todayTotalDuration: TimeInterval = 0
    
    /// 今日会话数
    @Published var todaySessionCount: Int = 0
    
    // MARK: - 私有属性
    
    /// 会话开始时间
    private var sessionStartTime: Date?
    
    /// 会话姿态记录
    private var sessionPostures: [Posture] = []
    
    /// 计时器
    private var timer: Timer?
    
    /// Combine 订阅集合
    private var cancellables = Set<AnyCancellable>()
    
    /// UserDefaults 键
    private let historyKey = "session_history"
    
    // MARK: - 初始化
    
    init() {
        loadSessionHistory()
        calculateTodayStats()
    }
    
    deinit {
        endSession()
        cancellables.removeAll()
    }
    
    // MARK: - 公共方法
    
    /// 开始新会话
    func startSession() {
        guard !isSessionActive else {
            print("⚠️ 会话已经在进行中")
            return
        }
        
        print("▶️ 开始新的训练会话")
        
        // 重置会话数据
        sessionStartTime = Date()
        sessionDuration = 0
        currentDeviationCount = 0
        currentSessionScore = 100.0
        sessionPostures.removeAll()
        
        // 创建新会话
        currentSession = Session(
            id: UUID(),
            startTime: Date(),
            endTime: Date(),
            duration: 0,
            postureData: [],
            deviationCount: 0,
            averageScore: 100.0
        )
        
        // 启动计时器
        startTimer()
        
        isSessionActive = true
    }
    
    /// 结束当前会话
    func endSession() {
        guard isSessionActive, let session = currentSession else {
            print("⚠️ 没有活动的会话")
            return
        }
        
        print("⏹️ 结束训练会话")
        
        // 停止计时器
        stopTimer()
        
        // 更新会话数据
        let endTime = Date()
        let duration = endTime.timeIntervalSince(session.startTime)
        
        let completedSession = Session(
            id: session.id,
            startTime: session.startTime,
            endTime: endTime,
            duration: duration,
            postureData: sessionPostures,
            deviationCount: currentDeviationCount,
            averageScore: currentSessionScore
        )
        
        // 保存到历史记录
        saveSession(completedSession)
        
        // 重置状态
        currentSession = nil
        isSessionActive = false
        sessionDuration = 0
        
        // 更新今日统计
        calculateTodayStats()
        
        print("✅ 会话已保存: 时长 \(Int(duration))秒，得分 \(Int(currentSessionScore))分")
    }
    
    /// 暂停会话
    func pauseSession() {
        guard isSessionActive else { return }
        
        print("⏸️ 暂停会话")
        stopTimer()
    }
    
    /// 恢复会话
    func resumeSession() {
        guard isSessionActive else { return }
        
        print("▶️ 恢复会话")
        startTimer()
    }
    
    /// 记录姿态数据
    func recordPosture(_ posture: Posture) {
        guard isSessionActive else { return }
        
        sessionPostures.append(posture)
        
        // 限制姿态记录大小（每秒一个，最多保留1小时）
        let maxSize = 3600
        if sessionPostures.count > maxSize {
            sessionPostures.removeFirst()
        }
    }
    
    /// 记录偏差
    func recordDeviation() {
        guard isSessionActive else { return }
        currentDeviationCount += 1
    }
    
    /// 更新会话评分
    func updateSessionScore(_ score: Double) {
        guard isSessionActive else { return }
        currentSessionScore = score
    }
    
    /// 删除会话
    func deleteSession(_ session: Session) {
        sessionHistory.removeAll { $0.id == session.id }
        saveSessionHistory()
        calculateTodayStats()
        print("🗑️ 已删除会话: \(session.id)")
    }
    
    /// 清除所有历史记录
    func clearAllSessions() {
        sessionHistory.removeAll()
        saveSessionHistory()
        calculateTodayStats()
        print("🗑️ 已清除所有会话历史")
    }
    
    /// 获取本周会话
    func getWeeklySessions() -> [Session] {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        return sessionHistory.filter { session in
            session.startTime >= weekAgo
        }
    }
    
    /// 获取本月会话
    func getMonthlySessions() -> [Session] {
        let calendar = Calendar.current
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        
        return sessionHistory.filter { session in
            session.startTime >= monthAgo
        }
    }
    
    /// 获取指定日期的会话
    func getSessions(for date: Date) -> [Session] {
        let calendar = Calendar.current
        
        return sessionHistory.filter { session in
            calendar.isDate(session.startTime, inSameDayAs: date)
        }
    }
    
    // MARK: - 私有方法
    
    /// 启动计时器
    private func startTimer() {
        stopTimer() // 确保没有重复计时器
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.sessionStartTime else { return }
            
            self.sessionDuration = Date().timeIntervalSince(startTime)
        }
    }
    
    /// 停止计时器
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// 保存会话到历史记录
    private func saveSession(_ session: Session) {
        sessionHistory.append(session)
        
        // 按时间倒序排列
        sessionHistory.sort { $0.startTime > $1.startTime }
        
        // 限制历史记录大小（最多保留100个）
        let maxHistory = 100
        if sessionHistory.count > maxHistory {
            sessionHistory = Array(sessionHistory.prefix(maxHistory))
        }
        
        // 持久化
        saveSessionHistory()
    }
    
    /// 保存会话历史到 UserDefaults
    private func saveSessionHistory() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(sessionHistory)
            UserDefaults.standard.set(data, forKey: historyKey)
            print("💾 会话历史已保存: \(sessionHistory.count) 个会话")
        } catch {
            print("❌ 保存会话历史失败: \(error)")
        }
    }
    
    /// 从 UserDefaults 加载会话历史
    private func loadSessionHistory() {
        guard let data = UserDefaults.standard.data(forKey: historyKey) else {
            print("📂 无历史会话记录")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            sessionHistory = try decoder.decode([Session].self, from: data)
            print("📂 已加载会话历史: \(sessionHistory.count) 个会话")
        } catch {
            print("❌ 加载会话历史失败: \(error)")
            sessionHistory = []
        }
    }
    
    /// 计算今日统计
    private func calculateTodayStats() {
        let todaySessions = getSessions(for: Date())
        
        todaySessionCount = todaySessions.count
        todayTotalDuration = todaySessions.reduce(0) { $0 + $1.duration }
    }
}

// MARK: - 计算属性

extension SessionViewModel {
    
    /// 格式化的会话时长
    var formattedSessionDuration: String {
        let hours = Int(sessionDuration) / 3600
        let minutes = Int(sessionDuration) % 3600 / 60
        let seconds = Int(sessionDuration) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    /// 格式化的今日总时长
    var formattedTodayDuration: String {
        let hours = Int(todayTotalDuration) / 3600
        let minutes = Int(todayTotalDuration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)小时\(minutes)分钟"
        } else {
            return "\(minutes)分钟"
        }
    }
    
    /// 历史记录总数
    var totalSessionCount: Int {
        return sessionHistory.count
    }
    
    /// 历史记录总时长
    var totalTrainingDuration: TimeInterval {
        return sessionHistory.reduce(0) { $0 + $1.duration }
    }
    
    /// 平均会话时长
    var averageSessionDuration: TimeInterval {
        guard !sessionHistory.isEmpty else { return 0 }
        return totalTrainingDuration / Double(sessionHistory.count)
    }
    
    /// 平均会话评分
    var averageSessionScore: Double {
        guard !sessionHistory.isEmpty else { return 0 }
        
        let totalScore = sessionHistory.reduce(0.0) { $0 + $1.averageScore }
        return totalScore / Double(sessionHistory.count)
    }
    
    /// 最佳会话
    var bestSession: Session? {
        return sessionHistory.max { $0.averageScore < $1.averageScore }
    }
    
    /// 最长会话
    var longestSession: Session? {
        return sessionHistory.max { $0.duration < $1.duration }
    }
    
    /// 本周训练天数
    var weeklyTrainingDays: Int {
        let weeklySessions = getWeeklySessions()
        let calendar = Calendar.current
        
        let uniqueDays = Set(weeklySessions.map { session in
            calendar.startOfDay(for: session.startTime)
        })
        
        return uniqueDays.count
    }
    
    /// 连续训练天数
    var consecutiveTrainingDays: Int {
        guard !sessionHistory.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        var days = 0
        var currentDate = Date()
        
        while true {
            let daySessions = getSessions(for: currentDate)
            if daySessions.isEmpty {
                break
            }
            
            days += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                break
            }
            currentDate = previousDay
        }
        
        return days
    }
}

// MARK: - 统计辅助类型

extension SessionViewModel {
    
    /// 会话统计数据
    struct SessionStats {
        let totalCount: Int
        let totalDuration: TimeInterval
        let averageDuration: TimeInterval
        let averageScore: Double
        let bestScore: Double
        let trainingDays: Int
        let consecutiveDays: Int
    }
    
    /// 获取统计数据
    func getStats() -> SessionStats {
        return SessionStats(
            totalCount: totalSessionCount,
            totalDuration: totalTrainingDuration,
            averageDuration: averageSessionDuration,
            averageScore: averageSessionScore,
            bestScore: bestSession?.averageScore ?? 0,
            trainingDays: weeklyTrainingDays,
            consecutiveDays: consecutiveTrainingDays
        )
    }
}
