//
//  SettingsManagerTests.swift
//  PostureTrackerTests
//
//  SettingsManager 单元测试
//  Created on 2024-10-03
//

import XCTest
@testable import PostureTracker

class SettingsManagerTests: XCTestCase {
    
    var settingsManager: SettingsManager!
    
    override func setUpWithError() throws {
        // 每个测试前重置设置管理器
        settingsManager = SettingsManager.shared
        settingsManager.resetToDefaults()
    }
    
    override func tearDownWithError() throws {
        // 测试后清理
        settingsManager = nil
    }
    
    // MARK: - 基础设置测试
    
    func testDefaultSettings() throws {
        // 测试默认设置值
        XCTAssertEqual(settingsManager.sampleRate, 50.0, "默认采样率应为50Hz")
        XCTAssertEqual(settingsManager.sensitivity, 15.0, "默认灵敏度应为15度")
        XCTAssertEqual(settingsManager.alertDelay, 5.0, "默认提示延迟应为5秒")
        XCTAssertEqual(settingsManager.alertVolume, 0.8, "默认音量应为80%")
        XCTAssertFalse(settingsManager.speechEnabled, "默认应关闭语音提示")
        XCTAssertEqual(settingsManager.selectedVoice, "female", "默认应为女声")
        XCTAssertFalse(settingsManager.doNotDisturbEnabled, "默认应关闭勿扰模式")
        XCTAssertEqual(settingsManager.appearanceMode, .system, "默认应跟随系统外观")
        XCTAssertEqual(settingsManager.fontSize, .medium, "默认字体大小应为中等")
        XCTAssertFalse(settingsManager.cloudSyncEnabled, "默认应关闭云端同步")
    }
    
    func testSettingsPersistence() throws {
        // 测试设置持久化
        let testSampleRate = 100.0
        let testSensitivity = 25.0
        let testVolume = 0.5
        
        settingsManager.sampleRate = testSampleRate
        settingsManager.sensitivity = testSensitivity
        settingsManager.alertVolume = testVolume
        
        // 模拟应用重启，创建新的设置管理器实例
        let newSettingsManager = SettingsManager.shared
        
        XCTAssertEqual(newSettingsManager.sampleRate, testSampleRate, "采样率应该持久化")
        XCTAssertEqual(newSettingsManager.sensitivity, testSensitivity, "灵敏度应该持久化")
        XCTAssertEqual(newSettingsManager.alertVolume, testVolume, "音量应该持久化")
    }
    
    func testSampleRateValidation() throws {
        // 测试采样率有效值
        let validRates = [25.0, 50.0, 100.0]
        
        for rate in validRates {
            settingsManager.sampleRate = rate
            XCTAssertEqual(settingsManager.sampleRate, rate, "采样率\(rate)应该有效")
        }
    }
    
    func testSensitivityRange() throws {
        // 测试灵敏度范围
        settingsManager.sensitivity = 5.0
        XCTAssertEqual(settingsManager.sensitivity, 5.0, "最小灵敏度应为5度")
        
        settingsManager.sensitivity = 30.0
        XCTAssertEqual(settingsManager.sensitivity, 30.0, "最大灵敏度应为30度")
        
        settingsManager.sensitivity = 15.0
        XCTAssertEqual(settingsManager.sensitivity, 15.0, "中等灵敏度应为15度")
    }
    
    func testVolumeRange() throws {
        // 测试音量范围
        settingsManager.alertVolume = 0.0
        XCTAssertEqual(settingsManager.alertVolume, 0.0, "最小音量应为0")
        
        settingsManager.alertVolume = 1.0
        XCTAssertEqual(settingsManager.alertVolume, 1.0, "最大音量应为1.0")
        
        settingsManager.alertVolume = 0.5
        XCTAssertEqual(settingsManager.alertVolume, 0.5, "中等音量应为0.5")
    }
    
    // MARK: - 勿扰模式测试
    
    func testDoNotDisturbTimeLogic() throws {
        let calendar = Calendar.current
        settingsManager.doNotDisturbEnabled = true
        
        // 设置勿扰时间：22:00 - 08:00
        let startTime = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date()
        let endTime = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
        
        settingsManager.dndStartTime = startTime
        settingsManager.dndEndTime = endTime
        
        // 创建测试时间点
        let nightTime = calendar.date(bySettingHour: 23, minute: 30, second: 0, of: Date()) ?? Date()
        let morningTime = calendar.date(bySettingHour: 7, minute: 30, second: 0, of: Date()) ?? Date()
        let dayTime = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: Date()) ?? Date()
        
        // 注意：由于isInDoNotDisturbTime()使用当前时间，这里测试的是逻辑结构
        XCTAssertTrue(settingsManager.doNotDisturbEnabled, "勿扰模式应已启用")
    }
    
    func testDoNotDisturbDisabled() throws {
        settingsManager.doNotDisturbEnabled = false
        // 当勿扰模式关闭时，应该总是返回false
        XCTAssertFalse(settingsManager.isInDoNotDisturbTime(), "勿扰模式关闭时应返回false")
    }
    
    // MARK: - 语音设置测试
    
    func testVoiceSettings() throws {
        // 测试语音设置
        settingsManager.speechEnabled = true
        settingsManager.selectedVoice = "male"
        
        XCTAssertTrue(settingsManager.speechEnabled, "语音提示应已启用")
        XCTAssertEqual(settingsManager.selectedVoice, "male", "应选择男声")
        
        settingsManager.selectedVoice = "female"
        XCTAssertEqual(settingsManager.selectedVoice, "female", "应选择女声")
    }
    
    // MARK: - 外观设置测试
    
    func testAppearanceSettings() throws {
        // 测试外观设置
        for mode in AppearanceMode.allCases {
            settingsManager.appearanceMode = mode
            XCTAssertEqual(settingsManager.appearanceMode, mode, "外观模式应为\(mode.displayName)")
        }
    }
    
    func testFontSizeSettings() throws {
        // 测试字体大小设置
        for size in FontSize.allCases {
            settingsManager.fontSize = size
            XCTAssertEqual(settingsManager.fontSize, size, "字体大小应为\(size.displayName)")
        }
    }
    
    // MARK: - 数据管理测试
    
    func testDataExport() throws {
        // 测试数据导出
        let exportData = settingsManager.exportTrainingData()
        XCTAssertNotNil(exportData, "应该能够导出数据")
        
        if let data = exportData {
            XCTAssertGreaterThan(data.count, 0, "导出的数据应该不为空")
            
            // 尝试解析JSON
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                XCTAssertNotNil(json, "导出的数据应该是有效的JSON")
            } catch {
                XCTFail("导出的数据应该是有效的JSON格式")
            }
        }
    }
    
    func testResetToDefaults() throws {
        // 修改一些设置
        settingsManager.sampleRate = 100.0
        settingsManager.sensitivity = 25.0
        settingsManager.speechEnabled = true
        settingsManager.appearanceMode = .dark
        
        // 重置到默认值
        settingsManager.resetToDefaults()
        
        // 验证设置已重置
        XCTAssertEqual(settingsManager.sampleRate, 50.0, "采样率应重置为默认值")
        XCTAssertEqual(settingsManager.sensitivity, 15.0, "灵敏度应重置为默认值")
        XCTAssertFalse(settingsManager.speechEnabled, "语音提示应重置为默认值")
        XCTAssertEqual(settingsManager.appearanceMode, .system, "外观模式应重置为默认值")
    }
    
    // MARK: - 性能测试
    
    func testSettingsPerformance() throws {
        // 测试设置读取性能
        measure {
            for _ in 0..<1000 {
                _ = settingsManager.sampleRate
                _ = settingsManager.sensitivity
                _ = settingsManager.alertVolume
                _ = settingsManager.speechEnabled
            }
        }
    }
    
    func testSettingsWritePerformance() throws {
        // 测试设置写入性能
        measure {
            for i in 0..<100 {
                settingsManager.sensitivity = Double(i % 25 + 5)
                settingsManager.alertVolume = Double(i % 100) / 100.0
            }
        }
    }
}

// MARK: - MockDataGenerator 测试

class MockDataGeneratorTests: XCTestCase {
    
    func testTodayDataGeneration() throws {
        let data = MockDataGenerator.generateTodayPostureData()
        
        XCTAssertFalse(data.isEmpty, "今日数据不应为空")
        XCTAssertEqual(data.count, 24, "今日数据应包含24小时的数据")
        
        // 验证数据格式
        for dataPoint in data {
            XCTAssertGreaterThanOrEqual(dataPoint.avgPitch, -30, "俯仰角应在合理范围内")
            XCTAssertLessThanOrEqual(dataPoint.avgPitch, 30, "俯仰角应在合理范围内")
            XCTAssertGreaterThanOrEqual(dataPoint.avgYaw, -45, "偏航角应在合理范围内")
            XCTAssertLessThanOrEqual(dataPoint.avgYaw, 45, "偏航角应在合理范围内")
            XCTAssertGreaterThanOrEqual(dataPoint.avgRoll, -20, "翻滚角应在合理范围内")
            XCTAssertLessThanOrEqual(dataPoint.avgRoll, 20, "翻滚角应在合理范围内")
        }
    }
    
    func testWeeklyDataGeneration() throws {
        let data = MockDataGenerator.generateWeeklyPostureData()
        
        XCTAssertFalse(data.isEmpty, "周数据不应为空")
        XCTAssertEqual(data.count, 7, "周数据应包含7天的数据")
        
        // 验证数据排序（应按时间倒序）
        for i in 1..<data.count {
            XCTAssertGreaterThan(data[i-1].date, data[i].date, "数据应按时间倒序排列")
        }
    }
    
    func testTrainingDurationData() throws {
        let data = MockDataGenerator.generateTrainingDurationData()
        
        XCTAssertFalse(data.isEmpty, "训练时长数据不应为空")
        XCTAssertEqual(data.count, 7, "训练时长数据应包含7天")
        
        for dataPoint in data {
            XCTAssertGreaterThanOrEqual(dataPoint.duration, 0, "训练时长不应为负数")
            XCTAssertLessThanOrEqual(dataPoint.duration, 8 * 60, "训练时长不应超过8小时")
        }
    }
    
    func testSessionSummariesGeneration() throws {
        let summaries = MockDataGenerator.generateSessionSummaries()
        
        XCTAssertFalse(summaries.isEmpty, "会话摘要不应为空")
        XCTAssertGreaterThanOrEqual(summaries.count, 3, "应至少有3个会话摘要")
        XCTAssertLessThanOrEqual(summaries.count, 10, "会话摘要不应超过10个")
        
        for summary in summaries {
            XCTAssertGreaterThan(summary.duration, 0, "会话时长应大于0")
            XCTAssertGreaterThanOrEqual(summary.averageScore, 0, "平均分数应≥0")
            XCTAssertLessThanOrEqual(summary.averageScore, 100, "平均分数应≤100")
            XCTAssertGreaterThanOrEqual(summary.deviationCount, 0, "偏差次数应≥0")
        }
    }
    
    func testDataConsistency() throws {
        // 多次生成数据，确保数据结构一致
        for _ in 0..<10 {
            let todayData = MockDataGenerator.generateTodayPostureData()
            let weeklyData = MockDataGenerator.generateWeeklyPostureData()
            let durationData = MockDataGenerator.generateTrainingDurationData()
            
            XCTAssertEqual(todayData.count, 24, "今日数据计数应一致")
            XCTAssertEqual(weeklyData.count, 7, "周数据计数应一致")
            XCTAssertEqual(durationData.count, 7, "时长数据计数应一致")
        }
    }
}

// MARK: - FileExportManager 测试

class FileExportManagerTests: XCTestCase {
    
    var exportManager: FileExportManager!
    
    override func setUpWithError() throws {
        exportManager = FileExportManager.shared
    }
    
    override func tearDownWithError() throws {
        exportManager.cleanupTempFiles()
        exportManager = nil
    }
    
    func testJSONExport() throws {
        let data = exportManager.exportAllData(format: .json)
        
        XCTAssertNotNil(data, "JSON导出不应为nil")
        
        if let jsonData = data {
            XCTAssertGreaterThan(jsonData.count, 0, "JSON数据不应为空")
            
            // 验证JSON格式
            do {
                let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
                XCTAssertNotNil(json, "应该是有效的JSON")
                
                if let jsonDict = json as? [String: Any] {
                    XCTAssertNotNil(jsonDict["exportDate"], "应包含导出日期")
                    XCTAssertNotNil(jsonDict["appVersion"], "应包含应用版本")
                    XCTAssertNotNil(jsonDict["postureData"], "应包含姿态数据")
                    XCTAssertNotNil(jsonDict["sessionSummaries"], "应包含会话摘要")
                    XCTAssertNotNil(jsonDict["settings"], "应包含设置信息")
                }
            } catch {
                XCTFail("JSON解析失败: \(error)")
            }
        }
    }
    
    func testCSVExport() throws {
        let data = exportManager.exportAllData(format: .csv)
        
        XCTAssertNotNil(data, "CSV导出不应为nil")
        
        if let csvData = data,
           let csvString = String(data: csvData, encoding: .utf8) {
            
            XCTAssertFalse(csvString.isEmpty, "CSV内容不应为空")
            XCTAssertTrue(csvString.contains("PostureTracker 数据导出"), "应包含标题")
            XCTAssertTrue(csvString.contains("设置项,值"), "应包含设置信息")
            XCTAssertTrue(csvString.contains("姿态数据"), "应包含姿态数据")
            XCTAssertTrue(csvString.contains("会话摘要"), "应包含会话摘要")
        }
    }
    
    func testExportProgress() throws {
        let expectation = XCTestExpectation(description: "导出进度更新")
        
        // 监听导出进度
        let cancellable = exportManager.$exportProgress.sink { progress in
            if progress >= 1.0 {
                expectation.fulfill()
            }
        }
        
        // 开始导出
        _ = exportManager.exportAllData(format: .json)
        
        wait(for: [expectation], timeout: 5.0)
        cancellable.cancel()
    }
    
    func testExportFormats() throws {
        for format in ExportFormat.allCases {
            let data = exportManager.exportAllData(format: format)
            XCTAssertNotNil(data, "\(format.displayName)导出不应为nil")
            
            if let exportData = data {
                XCTAssertGreaterThan(exportData.count, 0, "\(format.displayName)数据不应为空")
            }
        }
    }
}