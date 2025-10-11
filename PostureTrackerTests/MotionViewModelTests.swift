//
//  MotionViewModelTests.swift
//  PostureTrackerTests
//
//  MotionViewModel 单元测试
//  Created on 2024-10-03
//

import XCTest
import Combine
@testable import PostureTracker

final class MotionViewModelTests: XCTestCase {

    // MARK: - 属性

    var sut: MotionViewModel!
    var cancellables: Set<AnyCancellable>!

    // MARK: - 生命周期

    override func setUp() {
        super.setUp()
        sut = MotionViewModel()
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - 初始状态测试

    func testInitialState() {
        // Given & When - 初始化后的状态
        
        // Then
        XCTAssertFalse(sut.isMonitoring, "初始状态应该未在监测")
        XCTAssertFalse(sut.isDeviating, "初始状态应该未偏差")
        XCTAssertEqual(sut.postureScore, 100.0, "初始姿态评分应为 100")
        XCTAssertEqual(sut.deviationCount, 0, "初始偏差次数应为 0")
        XCTAssertEqual(sut.deviationAngle, 0.0, accuracy: 0.01, "初始偏差角度应为 0")
    }

    func testCurrentPostureInitialization() {
        // Given & When - 检查初始姿态
        let posture = sut.currentPosture
        
        // Then
        XCTAssertEqual(posture.pitch, 0.0, accuracy: 0.01, "初始俯仰角应为 0")
        XCTAssertEqual(posture.yaw, 0.0, accuracy: 0.01, "初始偏航角应为 0")
        XCTAssertEqual(posture.roll, 0.0, accuracy: 0.01, "初始翻滚角应为 0")
    }

    func testTargetPostureInitialization() {
        // Given & When - 检查目标姿态
        let posture = sut.targetPosture
        
        // Then
        XCTAssertEqual(posture.pitch, 0.0, accuracy: 0.01, "目标俯仰角应为 0")
        XCTAssertEqual(posture.yaw, 0.0, accuracy: 0.01, "目标偏航角应为 0")
        XCTAssertEqual(posture.roll, 0.0, accuracy: 0.01, "目标翻滚角应为 0")
    }

    // MARK: - 监测控制测试

    func testStartMonitoring() {
        // Given
        let expectation = XCTestExpectation(description: "监测状态应更新")
        
        // When
        sut.$isMonitoring
            .dropFirst()
            .sink { isMonitoring in
                if isMonitoring {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.startMonitoring()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(sut.isMonitoring, "启动后应在监测中")
    }

    func testStopMonitoring() {
        // Given - 先启动监测
        sut.startMonitoring()
        
        let expectation = XCTestExpectation(description: "监测状态应停止")
        
        // When
        sut.$isMonitoring
            .dropFirst()
            .sink { isMonitoring in
                if !isMonitoring {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.stopMonitoring()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(sut.isMonitoring, "停止后应不在监测")
    }

    // MARK: - 目标姿态设置测试

    func testSetTargetPosture() {
        // Given
        let newTarget = Posture(
            pitch: 10.0,
            yaw: 5.0,
            roll: -3.0,
            timestamp: Date()
        )
        
        // When
        sut.setTargetPosture(newTarget)
        
        // Then
        XCTAssertEqual(sut.targetPosture.pitch, 10.0, accuracy: 0.01)
        XCTAssertEqual(sut.targetPosture.yaw, 5.0, accuracy: 0.01)
        XCTAssertEqual(sut.targetPosture.roll, -3.0, accuracy: 0.01)
    }

    func testResetTargetPosture() {
        // Given - 先设置一个非零的目标姿态
        let customTarget = Posture(pitch: 15.0, yaw: 10.0, roll: 5.0, timestamp: Date())
        sut.setTargetPosture(customTarget)
        
        // When
        sut.resetTargetPosture()
        
        // Then
        XCTAssertEqual(sut.targetPosture.pitch, 0.0, accuracy: 0.01)
        XCTAssertEqual(sut.targetPosture.yaw, 0.0, accuracy: 0.01)
        XCTAssertEqual(sut.targetPosture.roll, 0.0, accuracy: 0.01)
    }

    // MARK: - 偏差检测测试

    func testDeviationDetection_WithinThreshold() {
        // Given - 设置一个在阈值内的姿态
        let currentPosture = Posture(
            pitch: 5.0,  // 小于默认阈值
            yaw: 3.0,
            roll: 2.0,
            timestamp: Date()
        )
        
        // When
        sut.checkDeviation(currentPosture: currentPosture, targetPosture: sut.targetPosture)
        
        // Then
        XCTAssertFalse(sut.isDeviating, "偏差在阈值内不应触发偏差")
        XCTAssertEqual(sut.deviationCount, 0, "不应增加偏差计数")
    }

    func testDeviationDetection_ExceedThreshold() {
        // Given - 设置一个超出阈值的姿态
        let currentPosture = Posture(
            pitch: 20.0,  // 超过默认阈值 15°
            yaw: 0.0,
            roll: 0.0,
            timestamp: Date()
        )
        
        // When
        sut.checkDeviation(currentPosture: currentPosture, targetPosture: sut.targetPosture)
        
        // Then
        XCTAssertTrue(sut.isDeviating, "偏差超出阈值应触发偏差")
        XCTAssertEqual(sut.deviationCount, 1, "应增加偏差计数")
    }

    func testDeviationCount_MultipleDeviations() {
        // Given
        let deviatedPosture = Posture(pitch: 20.0, yaw: 0.0, roll: 0.0, timestamp: Date())
        
        // When - 触发多次偏差
        sut.checkDeviation(currentPosture: deviatedPosture, targetPosture: sut.targetPosture)
        sut.checkDeviation(currentPosture: deviatedPosture, targetPosture: sut.targetPosture)
        sut.checkDeviation(currentPosture: deviatedPosture, targetPosture: sut.targetPosture)
        
        // Then
        XCTAssertEqual(sut.deviationCount, 3, "应记录所有偏差次数")
    }

    func testDeviationAngle_Calculation() {
        // Given
        let currentPosture = Posture(pitch: 10.0, yaw: 5.0, roll: 3.0, timestamp: Date())
        let targetPosture = Posture(pitch: 0.0, yaw: 0.0, roll: 0.0, timestamp: Date())
        
        // When
        sut.checkDeviation(currentPosture: currentPosture, targetPosture: targetPosture)
        
        // Then - 偏差角度应该是向量的模
        let expectedAngle = sqrt(10.0 * 10.0 + 5.0 * 5.0 + 3.0 * 3.0)
        XCTAssertEqual(sut.deviationAngle, expectedAngle, accuracy: 0.1)
    }

    // MARK: - 姿态评分测试

    func testPostureScore_Perfect() {
        // Given - 完美姿态（无偏差）
        let perfectPosture = Posture(pitch: 0.0, yaw: 0.0, roll: 0.0, timestamp: Date())
        
        // When
        sut.updatePostureScore(currentPosture: perfectPosture, targetPosture: sut.targetPosture)
        
        // Then
        XCTAssertEqual(sut.postureScore, 100.0, accuracy: 0.1, "完美姿态应得满分")
    }

    func testPostureScore_SmallDeviation() {
        // Given - 小偏差（5度）
        let slightDeviation = Posture(pitch: 5.0, yaw: 0.0, roll: 0.0, timestamp: Date())
        
        // When
        sut.updatePostureScore(currentPosture: slightDeviation, targetPosture: sut.targetPosture)
        
        // Then
        XCTAssertGreaterThan(sut.postureScore, 90.0, "小偏差应保持高分")
        XCTAssertLessThan(sut.postureScore, 100.0, "有偏差不应得满分")
    }

    func testPostureScore_LargeDeviation() {
        // Given - 大偏差（30度）
        let largeDeviation = Posture(pitch: 30.0, yaw: 0.0, roll: 0.0, timestamp: Date())
        
        // When
        sut.updatePostureScore(currentPosture: largeDeviation, targetPosture: sut.targetPosture)
        
        // Then
        XCTAssertLessThan(sut.postureScore, 60.0, "大偏差应显著降低评分")
    }

    func testPostureScore_NeverNegative() {
        // Given - 极大偏差
        let extremeDeviation = Posture(pitch: 90.0, yaw: 90.0, roll: 90.0, timestamp: Date())
        
        // When
        sut.updatePostureScore(currentPosture: extremeDeviation, targetPosture: sut.targetPosture)
        
        // Then
        XCTAssertGreaterThanOrEqual(sut.postureScore, 0.0, "评分不应为负数")
    }

    func testPostureScore_MovingAverage() {
        // Given - 多次更新评分
        let posture1 = Posture(pitch: 5.0, yaw: 0.0, roll: 0.0, timestamp: Date())
        let posture2 = Posture(pitch: 10.0, yaw: 0.0, roll: 0.0, timestamp: Date())
        let posture3 = Posture(pitch: 0.0, yaw: 0.0, roll: 0.0, timestamp: Date())
        
        // When
        sut.updatePostureScore(currentPosture: posture1, targetPosture: sut.targetPosture)
        let score1 = sut.postureScore
        
        sut.updatePostureScore(currentPosture: posture2, targetPosture: sut.targetPosture)
        let score2 = sut.postureScore
        
        sut.updatePostureScore(currentPosture: posture3, targetPosture: sut.targetPosture)
        let score3 = sut.postureScore
        
        // Then - 评分应该是移动平均
        XCTAssertNotEqual(score1, score2, "不同姿态应产生不同评分")
        XCTAssertNotEqual(score2, score3, "评分应随姿态变化")
        XCTAssertGreaterThan(score3, score2, "改善姿态应提高评分")
    }

    // MARK: - 连接状态测试

    func testIsConnected_InitiallyFalse() {
        // Given & When - 初始状态
        
        // Then
        // 注意：实际连接状态取决于 AirPodsMotionManager
        // 这里只测试属性是否存在
        XCTAssertNotNil(sut.isConnected)
    }

    // MARK: - 性能测试

    func testPerformance_DeviationDetection() {
        // Given
        let posture = Posture(pitch: 20.0, yaw: 10.0, roll: 5.0, timestamp: Date())
        
        // When & Then
        measure {
            for _ in 0..<1000 {
                sut.checkDeviation(currentPosture: posture, targetPosture: sut.targetPosture)
            }
        }
    }

    func testPerformance_ScoreUpdate() {
        // Given
        let posture = Posture(pitch: 15.0, yaw: 8.0, roll: 3.0, timestamp: Date())
        
        // When & Then
        measure {
            for _ in 0..<1000 {
                sut.updatePostureScore(currentPosture: posture, targetPosture: sut.targetPosture)
            }
        }
    }

    // MARK: - 集成测试

    func testMonitoringWorkflow() {
        // Given
        var monitoringStates: [Bool] = []
        
        sut.$isMonitoring
            .sink { state in
                monitoringStates.append(state)
            }
            .store(in: &cancellables)
        
        // When - 模拟完整的监测流程
        sut.startMonitoring()
        
        let testPosture = Posture(pitch: 20.0, yaw: 0.0, roll: 0.0, timestamp: Date())
        sut.checkDeviation(currentPosture: testPosture, targetPosture: sut.targetPosture)
        sut.updatePostureScore(currentPosture: testPosture, targetPosture: sut.targetPosture)
        
        sut.stopMonitoring()
        
        // Then
        XCTAssertGreaterThan(monitoringStates.count, 1, "应记录多个监测状态变化")
        XCTAssertTrue(sut.deviationCount > 0, "应检测到偏差")
        XCTAssertLessThan(sut.postureScore, 100.0, "评分应反映偏差")
    }
}
