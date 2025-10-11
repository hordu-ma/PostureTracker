//
//  SessionViewModelTests.swift
//  PostureTrackerTests
//
//  SessionViewModel 单元测试
//  Created on 2024-10-03
//

import XCTest
import Combine
@testable import PostureTracker

final class SessionViewModelTests: XCTestCase {

    // MARK: - 属性

    var sut: SessionViewModel!
    var cancellables: Set<AnyCancellable>!
    var userDefaults: UserDefaults!

    // MARK: - 生命周期

    override func setUp() {
        super.setUp()
        
        // 使用测试专用的 UserDefaults
        userDefaults = UserDefaults(suiteName: "TestDefaults")
        userDefaults.removePersistentDomain(forName: "TestDefaults")
        
        sut = SessionViewModel(userDefaults: userDefaults)
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        userDefaults.removePersistentDomain(forName: "TestDefaults")
        userDefaults = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - 初始状态测试

    func testInitialState() {
        // Given & When - 初始化后的状态
        
        // Then
        XCTAssertNil(sut.currentSession, "初始状态应无当前会话")
        XCTAssertTrue(sut.sessionHistory.isEmpty, "初始历史记录应为空")
        XCTAssertEqual(sut.totalSessions, 0, "总会话数应为 0")
    }

    func testInitialStatistics() {
        // Given & When - 检查初始统计数据
        
        // Then
        XCTAssertEqual(sut.todayTotalDuration, 0, "今日总时长应为 0")
        XCTAssertEqual(sut.weeklyTrainingDays, 0, "本周训练天数应为 0")
        XCTAssertEqual(sut.consecutiveTrainingDays, 0, "连续训练天数应为 0")
    }

    // MARK: - 会话创建测试

    func testStartSession() {
        // Given
        let expectation = XCTestExpectation(description: "会话应创建")
        
        // When
        sut.$currentSession
            .dropFirst()
            .sink { session in
                if session != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.startSession()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(sut.currentSession, "应创建新会话")
        XCTAssertEqual(sut.currentSession?.duration, 0, accuracy: 0.1, "初始时长应为 0")
    }

    func testStartSession_DuplicateCall() {
        // Given - 已有一个进行中的会话
        sut.startSession()
        let firstSession = sut.currentSession
        
        // When - 尝试再次启动会话
        sut.startSession()
        
        // Then - 不应创建新会话
        XCTAssertEqual(sut.currentSession?.id, firstSession?.id, "不应创建重复会话")
    }

    // MARK: - 会话结束测试

    func testEndSession() {
        // Given - 启动一个会话
        sut.startSession()
        
        // When - 等待一小段时间后结束
        let expectation = XCTestExpectation(description: "等待会话时长累积")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        sut.endSession(averageScore: 85.0, deviationCount: 3)
        
        // Then
        XCTAssertNotNil(sut.currentSession, "结束后会话应仍存在（待保存）")
        XCTAssertNotNil(sut.currentSession?.endTime, "应设置结束时间")
        XCTAssertEqual(sut.currentSession?.averageScore, 85.0, "应设置平均评分")
        XCTAssertEqual(sut.currentSession?.deviationCount, 3, "应设置偏差次数")
        XCTAssertGreaterThan(sut.currentSession?.duration ?? 0, 0, "应有持续时间")
    }

    func testEndSession_WithoutActiveSession() {
        // Given - 没有活动会话
        
        // When
        sut.endSession(averageScore: 90.0, deviationCount: 1)
        
        // Then - 不应崩溃，应保持 nil
        XCTAssertNil(sut.currentSession)
    }

    // MARK: - 会话保存测试

    func testSaveSession() {
        // Given - 创建并结束一个会话
        sut.startSession()
        
        let expectation = XCTestExpectation(description: "等待时间累积")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        sut.endSession(averageScore: 88.0, deviationCount: 2)
        
        // When
        sut.saveSession()
        
        // Then
        XCTAssertNil(sut.currentSession, "保存后当前会话应清空")
        XCTAssertEqual(sut.sessionHistory.count, 1, "历史记录应增加")
        XCTAssertEqual(sut.totalSessions, 1, "总会话数应增加")
    }

    func testSaveSession_WithoutEndingSession() {
        // Given - 启动但未结束会话
        sut.startSession()
        
        // When
        sut.saveSession()
        
        // Then - 不应保存未结束的会话
        XCTAssertNil(sut.currentSession, "应清空当前会话")
        XCTAssertEqual(sut.sessionHistory.count, 0, "不应保存未完成的会话")
    }

    func testSaveSession_MultipleSessions() {
        // Given & When - 保存多个会话
        for i in 0..<3 {
            sut.startSession()
            
            let expectation = XCTestExpectation(description: "等待会话 \(i)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 1.0)
            
            sut.endSession(averageScore: Double(80 + i * 5), deviationCount: i)
            sut.saveSession()
        }
        
        // Then
        XCTAssertEqual(sut.sessionHistory.count, 3, "应保存所有会话")
        XCTAssertEqual(sut.totalSessions, 3, "总会话数应正确")
    }

    // MARK: - 持久化测试

    func testSessionPersistence_SaveAndLoad() {
        // Given - 创建并保存会话
        sut.startSession()
        
        let expectation = XCTestExpectation(description: "等待时间")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        sut.endSession(averageScore: 92.0, deviationCount: 1)
        sut.saveSession()
        
        let savedCount = sut.sessionHistory.count
        
        // When - 创建新的 ViewModel（模拟应用重启）
        let newViewModel = SessionViewModel(userDefaults: userDefaults)
        
        // Then
        XCTAssertEqual(newViewModel.sessionHistory.count, savedCount, "应加载保存的会话")
        XCTAssertEqual(newViewModel.totalSessions, savedCount, "总会话数应一致")
    }

    func testClearHistory() {
        // Given - 保存一些会话
        for _ in 0..<5 {
            sut.startSession()
            sut.endSession(averageScore: 85.0, deviationCount: 2)
            sut.saveSession()
        }
        
        // When
        sut.clearHistory()
        
        // Then
        XCTAssertTrue(sut.sessionHistory.isEmpty, "历史记录应清空")
        XCTAssertEqual(sut.totalSessions, 0, "总会话数应重置")
    }

    // MARK: - 统计数据测试

    func testTodayTotalDuration() {
        // Given - 今天的多个会话
        let calendar = Calendar.current
        let now = Date()
        
        for _ in 0..<3 {
            let session = Session(
                id: UUID(),
                startTime: now,
                endTime: now.addingTimeInterval(600), // 10分钟
                averageScore: 85.0,
                deviationCount: 2
            )
            sut.sessionHistory.append(session)
        }
        
        // When
        let todayDuration = sut.todayTotalDuration
        
        // Then
        XCTAssertEqual(todayDuration, 1800, accuracy: 1, "今日总时长应为 30 分钟")
    }

    func testTodayTotalDuration_WithOldSessions() {
        // Given - 包含昨天的会话
        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        
        // 昨天的会话
        let oldSession = Session(
            id: UUID(),
            startTime: yesterday,
            endTime: yesterday.addingTimeInterval(600),
            averageScore: 85.0,
            deviationCount: 2
        )
        sut.sessionHistory.append(oldSession)
        
        // 今天的会话
        let todaySession = Session(
            id: UUID(),
            startTime: now,
            endTime: now.addingTimeInterval(300),
            averageScore: 90.0,
            deviationCount: 1
        )
        sut.sessionHistory.append(todaySession)
        
        // When
        let todayDuration = sut.todayTotalDuration
        
        // Then
        XCTAssertEqual(todayDuration, 300, accuracy: 1, "应只计算今日会话")
    }

    func testWeeklyTrainingDays() {
        // Given - 本周的不同天数有训练
        let calendar = Calendar.current
        let now = Date()
        
        // 今天
        let todaySession = Session(
            id: UUID(),
            startTime: now,
            endTime: now.addingTimeInterval(600),
            averageScore: 85.0,
            deviationCount: 2
        )
        sut.sessionHistory.append(todaySession)
        
        // 3天前
        if let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now) {
            let pastSession = Session(
                id: UUID(),
                startTime: threeDaysAgo,
                endTime: threeDaysAgo.addingTimeInterval(600),
                averageScore: 80.0,
                deviationCount: 3
            )
            sut.sessionHistory.append(pastSession)
        }
        
        // When
        let weeklyDays = sut.weeklyTrainingDays
        
        // Then
        XCTAssertEqual(weeklyDays, 2, "本周应有 2 个训练日")
    }

    func testConsecutiveTrainingDays() {
        // Given - 连续3天的训练
        let calendar = Calendar.current
        let now = Date()
        
        for i in 0..<3 {
            if let date = calendar.date(byAdding: .day, value: -i, to: now) {
                let session = Session(
                    id: UUID(),
                    startTime: date,
                    endTime: date.addingTimeInterval(600),
                    averageScore: 85.0,
                    deviationCount: 2
                )
                sut.sessionHistory.append(session)
            }
        }
        
        // When
        let consecutive = sut.consecutiveTrainingDays
        
        // Then
        XCTAssertEqual(consecutive, 3, "应有 3 天连续训练")
    }

    func testConsecutiveTrainingDays_WithGap() {
        // Given - 有间隔的训练
        let calendar = Calendar.current
        let now = Date()
        
        // 今天
        let todaySession = Session(
            id: UUID(),
            startTime: now,
            endTime: now.addingTimeInterval(600),
            averageScore: 85.0,
            deviationCount: 2
        )
        sut.sessionHistory.append(todaySession)
        
        // 3天前（中间有间隔）
        if let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now) {
            let pastSession = Session(
                id: UUID(),
                startTime: threeDaysAgo,
                endTime: threeDaysAgo.addingTimeInterval(600),
                averageScore: 80.0,
                deviationCount: 3
            )
            sut.sessionHistory.append(pastSession)
        }
        
        // When
        let consecutive = sut.consecutiveTrainingDays
        
        // Then
        XCTAssertEqual(consecutive, 1, "间隔后应重新计数，只有今天")
    }

    // MARK: - 边界条件测试

    func testSessionDuration_Zero() {
        // Given - 立即结束的会话
        sut.startSession()
        
        // When
        sut.endSession(averageScore: 100.0, deviationCount: 0)
        
        // Then
        XCTAssertGreaterThanOrEqual(sut.currentSession?.duration ?? -1, 0, "时长不应为负")
    }

    func testSessionScore_Boundaries() {
        // Given
        sut.startSession()
        
        // When & Then - 测试极端评分值
        sut.endSession(averageScore: 0.0, deviationCount: 100)
        XCTAssertEqual(sut.currentSession?.averageScore, 0.0, "应接受最低评分")
        
        sut.saveSession()
        sut.startSession()
        
        sut.endSession(averageScore: 100.0, deviationCount: 0)
        XCTAssertEqual(sut.currentSession?.averageScore, 100.0, "应接受最高评分")
    }

    // MARK: - 性能测试

    func testPerformance_SaveMultipleSessions() {
        // Given & When & Then
        measure {
            for _ in 0..<100 {
                sut.startSession()
                sut.endSession(averageScore: 85.0, deviationCount: 2)
                sut.saveSession()
            }
            sut.clearHistory()
        }
    }

    func testPerformance_LoadLargeHistory() {
        // Given - 创建大量会话
        for _ in 0..<100 {
            sut.startSession()
            sut.endSession(averageScore: 85.0, deviationCount: 2)
            sut.saveSession()
        }
        
        // When & Then
        measure {
            _ = SessionViewModel(userDefaults: userDefaults)
        }
    }
}
