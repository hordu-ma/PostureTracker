//
//  StatisticsViewModelTests.swift
//  PostureTrackerTests
//
//  StatisticsViewModel 单元测试
//  Created on 2024-10-03
//

import XCTest
import Combine
@testable import PostureTracker

final class StatisticsViewModelTests: XCTestCase {

    // MARK: - 属性

    var sut: StatisticsViewModel!
    var sessionViewModel: SessionViewModel!
    var cancellables: Set<AnyCancellable>!

    // MARK: - 生命周期

    override func setUp() {
        super.setUp()
        
        // 创建测试用的 SessionViewModel
        let userDefaults = UserDefaults(suiteName: "TestDefaults")
        userDefaults?.removePersistentDomain(forName: "TestDefaults")
        sessionViewModel = SessionViewModel(userDefaults: userDefaults!)
        
        sut = StatisticsViewModel(sessionViewModel: sessionViewModel)
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        sessionViewModel = nil
        super.tearDown()
    }

    // MARK: - 初始状态测试

    func testInitialState() {
        // Given & When - 初始化后的状态
        
        // Then
        XCTAssertEqual(sut.selectedTimeRange, .today, "默认时间范围应为今天")
        XCTAssertTrue(sut.postureData.isEmpty, "初始姿态数据应为空")
        XCTAssertTrue(sut.durationData.isEmpty, "初始时长数据应为空")
    }

    func testInitialSummary() {
        // Given & When - 检查初始统计汇总
        let summary = sut.summary
        
        // Then
        XCTAssertEqual(summary.totalSessions, 0, "总会话数应为 0")
        XCTAssertEqual(summary.averageScore, 0, "平均评分应为 0")
        XCTAssertEqual(summary.totalDuration, 0, "总时长应为 0")
        XCTAssertEqual(summary.bestScore, 0, "最佳评分应为 0")
    }

    // MARK: - 时间范围测试

    func testTimeRangeChange() {
        // Given
        var dataUpdateCount = 0
        
        sut.$postureData
            .dropFirst()
            .sink { _ in
                dataUpdateCount += 1
            }
            .store(in: &cancellables)
        
        // When
        sut.selectedTimeRange = .week
        
        // Then
        XCTAssertEqual(sut.selectedTimeRange, .week, "时间范围应更新")
        // 数据应该随时间范围更新
    }

    func testTimeRangeDisplayNames() {
        // Given & When & Then
        XCTAssertEqual(StatisticsViewModel.TimeRange.today.displayName, "今天")
        XCTAssertEqual(StatisticsViewModel.TimeRange.week.displayName, "本周")
        XCTAssertEqual(StatisticsViewModel.TimeRange.month.displayName, "本月")
    }

    // MARK: - 数据生成测试

    func testGenerateHourlyPostureData() {
        // Given - 设置今天的时间范围
        sut.selectedTimeRange = .today
        
        // When
        sut.refreshData()
        
        // Then
        XCTAssertFalse(sut.postureData.isEmpty, "应生成每小时姿态数据")
        // 今天应该有 24 小时的数据点
        XCTAssertLessThanOrEqual(sut.postureData.count, 24, "每小时数据点不应超过 24")
    }

    func testGenerateDailyPostureData() {
        // Given
        sut.selectedTimeRange = .week
        
        // When
        sut.refreshData()
        
        // Then
        XCTAssertFalse(sut.postureData.isEmpty, "应生成每日姿态数据")
        XCTAssertLessThanOrEqual(sut.postureData.count, 7, "本周数据点不应超过 7")
    }

    func testGenerateWeeklyPostureData() {
        // Given
        sut.selectedTimeRange = .month
        
        // When
        sut.refreshData()
        
        // Then
        XCTAssertFalse(sut.postureData.isEmpty, "应生成每周姿态数据")
        XCTAssertLessThanOrEqual(sut.postureData.count, 4, "本月数据点不应超过 4")
    }

    // MARK: - 时长数据测试

    func testGenerateDurationData_Today() {
        // Given
        sut.selectedTimeRange = .today
        
        // When
        sut.refreshData()
        
        // Then
        XCTAssertFalse(sut.durationData.isEmpty, "应生成时长数据")
        // 每个数据点的时长应该合理
        for dataPoint in sut.durationData {
            XCTAssertGreaterThanOrEqual(dataPoint.duration, 0, "时长不应为负")
        }
    }

    func testGenerateDurationData_Week() {
        // Given
        sut.selectedTimeRange = .week
        
        // When
        sut.refreshData()
        
        // Then
        XCTAssertFalse(sut.durationData.isEmpty, "应生成本周时长数据")
        XCTAssertLessThanOrEqual(sut.durationData.count, 7, "本周数据点不应超过 7")
    }

    func testGenerateDurationData_Month() {
        // Given
        sut.selectedTimeRange = .month
        
        // When
        sut.refreshData()
        
        // Then
        XCTAssertFalse(sut.durationData.isEmpty, "应生成本月时长数据")
    }

    // MARK: - 统计汇总测试

    func testCalculateSummary_WithSessions() {
        // Given - 添加一些测试会话
        let now = Date()
        for i in 0..<5 {
            let session = Session(
                id: UUID(),
                startTime: now.addingTimeInterval(Double(-i * 3600)),
                endTime: now.addingTimeInterval(Double(-i * 3600 + 1800)),
                averageScore: Double(80 + i * 2),
                deviationCount: i
            )
            sessionViewModel.sessionHistory.append(session)
        }
        
        // When
        sut.refreshData()
        let summary = sut.summary
        
        // Then
        XCTAssertEqual(summary.totalSessions, 5, "总会话数应正确")
        XCTAssertGreaterThan(summary.averageScore, 0, "平均评分应大于 0")
        XCTAssertGreaterThan(summary.totalDuration, 0, "总时长应大于 0")
        XCTAssertGreaterThanOrEqual(summary.bestScore, summary.averageScore, "最佳评分应不低于平均")
    }

    func testCalculateSummary_AverageScore() {
        // Given - 添加已知评分的会话
        let now = Date()
        let scores = [80.0, 85.0, 90.0]
        let expectedAverage = scores.reduce(0, +) / Double(scores.count)
        
        for score in scores {
            let session = Session(
                id: UUID(),
                startTime: now,
                endTime: now.addingTimeInterval(600),
                averageScore: score,
                deviationCount: 1
            )
            sessionViewModel.sessionHistory.append(session)
        }
        
        // When
        sut.refreshData()
        let summary = sut.summary
        
        // Then
        XCTAssertEqual(summary.averageScore, expectedAverage, accuracy: 0.1, "平均评分应正确计算")
    }

    func testCalculateSummary_BestScore() {
        // Given
        let now = Date()
        let scores = [75.0, 92.0, 88.0, 85.0]
        let expectedBest = scores.max() ?? 0
        
        for score in scores {
            let session = Session(
                id: UUID(),
                startTime: now,
                endTime: now.addingTimeInterval(600),
                averageScore: score,
                deviationCount: 1
            )
            sessionViewModel.sessionHistory.append(session)
        }
        
        // When
        sut.refreshData()
        let summary = sut.summary
        
        // Then
        XCTAssertEqual(summary.bestScore, expectedBest, accuracy: 0.1, "最佳评分应为最高分")
    }

    func testCalculateSummary_TotalDuration() {
        // Given
        let now = Date()
        let durations: [TimeInterval] = [600, 900, 1200] // 10分钟, 15分钟, 20分钟
        let expectedTotal = durations.reduce(0, +)
        
        for duration in durations {
            let session = Session(
                id: UUID(),
                startTime: now,
                endTime: now.addingTimeInterval(duration),
                averageScore: 85.0,
                deviationCount: 2
            )
            sessionViewModel.sessionHistory.append(session)
        }
        
        // When
        sut.refreshData()
        let summary = sut.summary
        
        // Then
        XCTAssertEqual(summary.totalDuration, expectedTotal, accuracy: 1, "总时长应正确累加")
    }

    func testCalculateSummary_EmptySessions() {
        // Given - 无会话数据
        sessionViewModel.sessionHistory.removeAll()
        
        // When
        sut.refreshData()
        let summary = sut.summary
        
        // Then
        XCTAssertEqual(summary.totalSessions, 0)
        XCTAssertEqual(summary.averageScore, 0)
        XCTAssertEqual(summary.totalDuration, 0)
        XCTAssertEqual(summary.bestScore, 0)
    }

    // MARK: - 数据刷新测试

    func testRefreshData() {
        // Given
        var refreshCount = 0
        
        sut.$postureData
            .dropFirst()
            .sink { _ in
                refreshCount += 1
            }
            .store(in: &cancellables)
        
        // When
        sut.refreshData()
        
        // Then
        XCTAssertGreaterThan(refreshCount, 0, "应触发数据更新")
        XCTAssertFalse(sut.postureData.isEmpty, "刷新后应有数据")
    }

    func testRefreshData_MultipleTimeRanges() {
        // Given & When - 测试不同时间范围的数据刷新
        sut.selectedTimeRange = .today
        sut.refreshData()
        let todayCount = sut.postureData.count
        
        sut.selectedTimeRange = .week
        sut.refreshData()
        let weekCount = sut.postureData.count
        
        sut.selectedTimeRange = .month
        sut.refreshData()
        let monthCount = sut.postureData.count
        
        // Then - 不同时间范围应有不同数量的数据点
        XCTAssertNotEqual(todayCount, weekCount, "不同时间范围数据点数应不同")
        XCTAssertNotEqual(weekCount, monthCount, "不同时间范围数据点数应不同")
    }

    // MARK: - 数据点结构测试

    func testPostureDataPoint_Structure() {
        // Given
        sut.selectedTimeRange = .today
        sut.refreshData()
        
        // When
        guard let firstDataPoint = sut.postureData.first else {
            XCTFail("应有数据点")
            return
        }
        
        // Then
        XCTAssertNotNil(firstDataPoint.id)
        XCTAssertNotNil(firstDataPoint.date)
        // 俯仰角应在合理范围内
        XCTAssertGreaterThan(firstDataPoint.avgPitch, -90)
        XCTAssertLessThan(firstDataPoint.avgPitch, 90)
    }

    func testDurationDataPoint_Structure() {
        // Given
        sut.selectedTimeRange = .week
        sut.refreshData()
        
        // When
        guard let firstDataPoint = sut.durationData.first else {
            XCTFail("应有时长数据点")
            return
        }
        
        // Then
        XCTAssertNotNil(firstDataPoint.id)
        XCTAssertNotNil(firstDataPoint.date)
        XCTAssertGreaterThanOrEqual(firstDataPoint.duration, 0, "时长应非负")
    }

    // MARK: - 边界条件测试

    func testPostureData_DateOrdering() {
        // Given
        sut.selectedTimeRange = .week
        sut.refreshData()
        
        // When & Then - 数据点应按时间排序
        for i in 0..<(sut.postureData.count - 1) {
            let current = sut.postureData[i].date
            let next = sut.postureData[i + 1].date
            XCTAssertLessThanOrEqual(current, next, "数据点应按时间升序排列")
        }
    }

    func testDurationData_DateOrdering() {
        // Given
        sut.selectedTimeRange = .week
        sut.refreshData()
        
        // When & Then
        for i in 0..<(sut.durationData.count - 1) {
            let current = sut.durationData[i].date
            let next = sut.durationData[i + 1].date
            XCTAssertLessThanOrEqual(current, next, "时长数据应按时间升序排列")
        }
    }

    // MARK: - 性能测试

    func testPerformance_RefreshData() {
        // Given
        sut.selectedTimeRange = .month
        
        // When & Then
        measure {
            sut.refreshData()
        }
    }

    func testPerformance_CalculateSummary() {
        // Given - 添加大量会话
        let now = Date()
        for i in 0..<100 {
            let session = Session(
                id: UUID(),
                startTime: now.addingTimeInterval(Double(-i * 3600)),
                endTime: now.addingTimeInterval(Double(-i * 3600 + 600)),
                averageScore: Double(70 + i % 30),
                deviationCount: i % 5
            )
            sessionViewModel.sessionHistory.append(session)
        }
        
        // When & Then
        measure {
            sut.refreshData()
            _ = sut.summary
        }
    }

    func testPerformance_GeneratePostureData() {
        // Given
        sut.selectedTimeRange = .month
        
        // When & Then
        measure {
            for _ in 0..<100 {
                sut.refreshData()
            }
        }
    }

    // MARK: - 集成测试

    func testDataFlow_SessionToStatistics() {
        // Given - 模拟完整的数据流
        let now = Date()
        
        // 添加会话数据
        for i in 0..<3 {
            let session = Session(
                id: UUID(),
                startTime: now.addingTimeInterval(Double(-i * 86400)),
                endTime: now.addingTimeInterval(Double(-i * 86400 + 1800)),
                averageScore: Double(85 + i),
                deviationCount: i
            )
            sessionViewModel.sessionHistory.append(session)
        }
        
        // When
        sut.selectedTimeRange = .week
        sut.refreshData()
        
        // Then - 统计数据应反映会话数据
        XCTAssertEqual(sut.summary.totalSessions, 3, "应统计所有会话")
        XCTAssertFalse(sut.postureData.isEmpty, "应生成姿态数据")
        XCTAssertFalse(sut.durationData.isEmpty, "应生成时长数据")
    }
}
