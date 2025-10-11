//
//  FileExportManagerTests.swift
//  PostureTrackerTests
//
//  FileExportManager 单元测试
//  Created on 2025-10-11
//

import XCTest
@testable import PostureTracker

class FileExportManagerTests: XCTestCase {
    
    var exportManager: FileExportManager!
    
    override func setUpWithError() throws {
        exportManager = FileExportManager.shared
        // 清理之前的状态
        exportManager.lastExportError = nil
        exportManager.exportSuccess = false
    }
    
    override func tearDownWithError() throws {
        exportManager = nil
        // 清理临时文件
        FileExportManager.shared.cleanupTempFiles()
    }
    
    // MARK: - 导出格式测试
    
    func testExportFormatProperties() throws {
        // 测试 JSON 格式
        XCTAssertEqual(ExportFormat.json.displayName, "JSON 格式")
        XCTAssertEqual(ExportFormat.json.fileExtension, "json")
        XCTAssertEqual(ExportFormat.json.mimeType, "application/json")
        
        // 测试 CSV 格式
        XCTAssertEqual(ExportFormat.csv.displayName, "CSV 格式")
        XCTAssertEqual(ExportFormat.csv.fileExtension, "csv")
        XCTAssertEqual(ExportFormat.csv.mimeType, "text/csv")
    }
    
    func testAllExportFormats() throws {
        let formats = ExportFormat.allCases
        XCTAssertEqual(formats.count, 2, "应该有两种导出格式")
        XCTAssertTrue(formats.contains(.json), "应该包含 JSON 格式")
        XCTAssertTrue(formats.contains(.csv), "应该包含 CSV 格式")
    }
    
    // MARK: - JSON 导出测试
    
    func testExportToJSON() throws {
        // 执行 JSON 导出
        let jsonData = exportManager.exportAllData(format: .json)
        
        // 验证导出结果
        XCTAssertNotNil(jsonData, "JSON 导出数据不应为空")
        XCTAssertTrue(exportManager.exportSuccess, "导出应该成功")
        XCTAssertNil(exportManager.lastExportError, "不应有错误")
        
        // 验证 JSON 数据可以解析
        guard let data = jsonData else {
            XCTFail("JSON 数据为空")
            return
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        XCTAssertNoThrow(try decoder.decode(ExportData.self, from: data), "JSON 应该可以解析为 ExportData")
    }
    
    func testJSONDataStructure() throws {
        let jsonData = exportManager.exportAllData(format: .json)
        XCTAssertNotNil(jsonData)
        
        guard let data = jsonData else { return }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let exportData = try decoder.decode(ExportData.self, from: data)
        
        // 验证数据结构
        XCTAssertNotNil(exportData.exportDate, "导出日期不应为空")
        XCTAssertFalse(exportData.appVersion.isEmpty, "应用版本不应为空")
        XCTAssertFalse(exportData.deviceInfo.model.isEmpty, "设备型号不应为空")
        XCTAssertGreaterThan(exportData.postureData.count, 0, "应该有姿态数据")
        XCTAssertGreaterThan(exportData.sessionSummaries.count, 0, "应该有会话摘要")
    }
    
    // MARK: - CSV 导出测试
    
    func testExportToCSV() throws {
        // 执行 CSV 导出
        let csvData = exportManager.exportAllData(format: .csv)
        
        // 验证导出结果
        XCTAssertNotNil(csvData, "CSV 导出数据不应为空")
        XCTAssertTrue(exportManager.exportSuccess, "导出应该成功")
        XCTAssertNil(exportManager.lastExportError, "不应有错误")
        
        // 验证 CSV 数据可以转换为字符串
        guard let data = csvData else {
            XCTFail("CSV 数据为空")
            return
        }
        
        let csvString = String(data: data, encoding: .utf8)
        XCTAssertNotNil(csvString, "CSV 应该可以转换为字符串")
    }
    
    func testCSVContentStructure() throws {
        let csvData = exportManager.exportAllData(format: .csv)
        XCTAssertNotNil(csvData)
        
        guard let data = csvData,
              let csvString = String(data: data, encoding: .utf8) else {
            XCTFail("无法转换 CSV 数据")
            return
        }
        
        // 验证 CSV 包含必要的章节
        XCTAssertTrue(csvString.contains("PostureTracker 数据导出"), "应包含标题")
        XCTAssertTrue(csvString.contains("设置项"), "应包含设置信息")
        XCTAssertTrue(csvString.contains("统计项"), "应包含统计信息")
        XCTAssertTrue(csvString.contains("姿态数据"), "应包含姿态数据")
        XCTAssertTrue(csvString.contains("会话摘要"), "应包含会话摘要")
        
        // 验证包含列标题
        XCTAssertTrue(csvString.contains("日期时间,俯仰角,偏航角,翻滚角"), "应包含姿态数据列标题")
        XCTAssertTrue(csvString.contains("日期时间,持续时间(分钟),平均得分,偏差次数,训练质量"), "应包含会话摘要列标题")
    }
    
    // MARK: - 导出进度测试
    
    func testExportProgress() throws {
        // 开始导出前
        XCTAssertEqual(exportManager.exportProgress, 0.0, "初始进度应为 0")
        
        // 执行导出
        _ = exportManager.exportAllData(format: .json)
        
        // 导出完成后
        XCTAssertEqual(exportManager.exportProgress, 1.0, "完成后进度应为 1.0")
    }
    
    func testExportingState() throws {
        // 开始导出前
        XCTAssertFalse(exportManager.isExporting, "初始状态不应在导出中")
        
        // 执行导出
        _ = exportManager.exportAllData(format: .json)
        
        // 导出完成后
        XCTAssertFalse(exportManager.isExporting, "完成后不应在导出中")
    }
    
    // MARK: - 文件名生成测试
    
    func testFileNameGeneration() throws {
        // 通过导出来触发文件名生成
        let jsonData = exportManager.exportAllData(format: .json)
        XCTAssertNotNil(jsonData)
        
        // 模拟文件分享
        exportManager.shareExportedFile(data: jsonData!, format: .json)
        
        // 等待异步操作
        let expectation = XCTestExpectation(description: "等待文件名生成")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // 验证文件名
        if let fileName = exportManager.lastExportedFileName {
            XCTAssertTrue(fileName.hasPrefix("PostureTracker_数据导出_"), "文件名应有正确前缀")
            XCTAssertTrue(fileName.hasSuffix(".json"), "JSON 文件应有 .json 扩展名")
        }
    }
    
    // MARK: - 临时文件清理测试
    
    func testCleanupTempFiles() throws {
        // 创建一些临时文件
        let tempDirectory = FileManager.default.temporaryDirectory
        let testFileName = "PostureTracker_数据导出_test.json"
        let testFileURL = tempDirectory.appendingPathComponent(testFileName)
        
        let testData = "test data".data(using: .utf8)!
        try testData.write(to: testFileURL)
        
        // 验证文件存在
        XCTAssertTrue(FileManager.default.fileExists(atPath: testFileURL.path), "测试文件应该存在")
        
        // 清理
        exportManager.cleanupTempFiles()
        
        // 验证文件被删除
        XCTAssertFalse(FileManager.default.fileExists(atPath: testFileURL.path), "测试文件应该被删除")
    }
    
    // MARK: - 导出数据内容测试
    
    func testExportDataDeviceInfo() throws {
        let deviceInfo = ExportData.DeviceInfo()
        
        XCTAssertFalse(deviceInfo.model.isEmpty, "设备型号不应为空")
        XCTAssertFalse(deviceInfo.systemVersion.isEmpty, "系统版本不应为空")
        XCTAssertFalse(deviceInfo.appBuild.isEmpty, "应用构建号不应为空")
    }
    
    func testExportDataSettings() throws {
        let settings = SettingsManager.shared
        let exportSettings = ExportData.ExportSettings(from: settings)
        
        XCTAssertEqual(exportSettings.sampleRate, settings.sampleRate, "采样率应匹配")
        XCTAssertEqual(exportSettings.sensitivity, settings.sensitivity, "灵敏度应匹配")
        XCTAssertEqual(exportSettings.alertVolume, settings.alertVolume, "音量应匹配")
        XCTAssertEqual(exportSettings.speechEnabled, settings.speechEnabled, "语音开关应匹配")
    }
    
    func testExportDataStatistics() throws {
        let postureData = MockDataGenerator.generateTodayPostureData()
        let sessionSummaries = MockDataGenerator.generateSessionSummaries()
        
        let statistics = ExportData.ExportStatistics(
            sessionSummaries: sessionSummaries,
            postureData: postureData
        )
        
        XCTAssertEqual(statistics.totalSessions, sessionSummaries.count, "总会话数应匹配")
        XCTAssertEqual(statistics.dataPointsCount, postureData.count, "数据点数量应匹配")
        XCTAssertGreaterThanOrEqual(statistics.averagePostureScore, 0, "平均得分应 >= 0")
        XCTAssertLessThanOrEqual(statistics.averagePostureScore, 100, "平均得分应 <= 100")
    }
    
    // MARK: - 性能测试
    
    func testExportPerformance() throws {
        // 测试导出性能
        measure {
            _ = exportManager.exportAllData(format: .json)
        }
    }
    
    func testCSVExportPerformance() throws {
        // 测试 CSV 导出性能
        measure {
            _ = exportManager.exportAllData(format: .csv)
        }
    }
}
