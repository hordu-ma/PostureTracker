//
//  FileExportManager.swift
//  PostureTracker
//
//  文件导出管理器 - 处理数据导出和文件分享功能
//  Created on 2024-10-03
//

import Foundation
import UIKit
import SwiftUI

/// 导出格式枚举
enum ExportFormat: String, CaseIterable {
    case json = "json"
    case csv = "csv"
    
    var displayName: String {
        switch self {
        case .json:
            return "JSON 格式"
        case .csv:
            return "CSV 格式"
        }
    }
    
    var fileExtension: String {
        return rawValue
    }
    
    var mimeType: String {
        switch self {
        case .json:
            return "application/json"
        case .csv:
            return "text/csv"
        }
    }
}

/// 导出数据模型
struct ExportData: Codable {
    let exportDate: Date
    let appVersion: String
    let deviceInfo: DeviceInfo
    let settings: ExportSettings
    let postureData: [PostureDataPoint]
    let sessionSummaries: [SessionSummary]
    let statistics: ExportStatistics
    
    struct DeviceInfo: Codable {
        let model: String
        let systemVersion: String
        let appBuild: String
        
        init() {
            self.model = UIDevice.current.model
            self.systemVersion = UIDevice.current.systemVersion
            self.appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        }
    }
    
    struct ExportSettings: Codable {
        let sampleRate: Double
        let sensitivity: Double
        let alertDelay: Double
        let alertVolume: Double
        let speechEnabled: Bool
        let selectedVoice: String
        let doNotDisturbEnabled: Bool
        let appearanceMode: String
        let fontSize: String
        
        init(from settingsManager: SettingsManager) {
            self.sampleRate = settingsManager.sampleRate
            self.sensitivity = settingsManager.sensitivity
            self.alertDelay = settingsManager.alertDelay
            self.alertVolume = settingsManager.alertVolume
            self.speechEnabled = settingsManager.speechEnabled
            self.selectedVoice = settingsManager.selectedVoice
            self.doNotDisturbEnabled = settingsManager.doNotDisturbEnabled
            self.appearanceMode = settingsManager.appearanceMode.rawValue
            self.fontSize = settingsManager.fontSize.rawValue
        }
    }
    
    struct ExportStatistics: Codable {
        let totalSessions: Int
        let totalTrainingTime: TimeInterval
        let averagePostureScore: Double
        let mostActiveDay: String
        let dataPointsCount: Int
        
        init(sessionSummaries: [SessionSummary], postureData: [PostureDataPoint]) {
            self.totalSessions = sessionSummaries.count
            self.totalTrainingTime = sessionSummaries.reduce(0) { $0 + $1.duration }
            self.averagePostureScore = sessionSummaries.isEmpty ? 0 : 
                sessionSummaries.reduce(0) { $0 + $1.averageScore } / Double(sessionSummaries.count)
            
            // 计算最活跃的一天
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dayGroups = Dictionary(grouping: sessionSummaries) { 
                formatter.string(from: $0.date) 
            }
            self.mostActiveDay = dayGroups.max { $0.value.count < $1.value.count }?.key ?? "无数据"
            
            self.dataPointsCount = postureData.count
        }
    }
}

/// 文件导出管理器
class FileExportManager: ObservableObject {
    
    // MARK: - 单例
    
    static let shared = FileExportManager()
    
    // MARK: - 属性
    
    @Published var isExporting = false
    @Published var exportProgress: Double = 0.0
    @Published var lastExportError: String?
    @Published var exportSuccess = false
    @Published var lastExportedFileName: String?
    
    private init() {}
    
    // MARK: - 公共方法
    
    /// 导出所有数据
    /// - Parameter format: 导出格式
    /// - Returns: 导出的数据
    func exportAllData(format: ExportFormat) -> Data? {
        isExporting = true
        exportProgress = 0.0
        lastExportError = nil
        exportSuccess = false
        
        defer {
            isExporting = false
            exportProgress = 1.0
        }
        
        do {
            // 准备数据
            exportProgress = 0.2
            let postureData = MockDataGenerator.generateTodayPostureData()
            
            exportProgress = 0.4
            let sessionSummaries = MockDataGenerator.generateSessionSummaries()
            
            exportProgress = 0.6
            let settings = SettingsManager.shared
            
            // 创建导出数据
            exportProgress = 0.8
            let exportData = ExportData(
                exportDate: Date(),
                appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0",
                deviceInfo: ExportData.DeviceInfo(),
                settings: ExportData.ExportSettings(from: settings),
                postureData: postureData,
                sessionSummaries: sessionSummaries,
                statistics: ExportData.ExportStatistics(sessionSummaries: sessionSummaries, postureData: postureData)
            )
            
            // 根据格式导出
            let data: Data
            switch format {
            case .json:
                data = try exportToJSON(exportData)
            case .csv:
                guard let csvData = exportToCSV(exportData) else {
                    throw ExportError.csvGenerationFailed
                }
                data = csvData
            }
            
            exportSuccess = true
            return data
        } catch {
            lastExportError = "导出失败：\(error.localizedDescription)"
            exportSuccess = false
            return nil
        }
    }
    
    /// 导出为JSON格式
    private func exportToJSON(_ exportData: ExportData) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        return try encoder.encode(exportData)
    }
    
    /// 导出为CSV格式
    private func exportToCSV(_ exportData: ExportData) -> Data? {
        var csvContent = ""
        
        // 添加元数据
        csvContent += "PostureTracker 数据导出\n"
        csvContent += "导出时间,\(formatDate(exportData.exportDate))\n"
        csvContent += "应用版本,\(exportData.appVersion)\n"
        csvContent += "设备型号,\(exportData.deviceInfo.model)\n"
        csvContent += "系统版本,\(exportData.deviceInfo.systemVersion)\n"
        csvContent += "\n"
        
        // 设置数据
        csvContent += "设置项,值\n"
        csvContent += "采样率,\(exportData.settings.sampleRate) Hz\n"
        csvContent += "灵敏度,\(exportData.settings.sensitivity)°\n"
        csvContent += "提示延迟,\(exportData.settings.alertDelay)秒\n"
        csvContent += "音量,\(Int(exportData.settings.alertVolume * 100))%\n"
        csvContent += "语音提示,\(exportData.settings.speechEnabled ? "开启" : "关闭")\n"
        csvContent += "勿扰模式,\(exportData.settings.doNotDisturbEnabled ? "开启" : "关闭")\n"
        csvContent += "\n"
        
        // 统计数据
        csvContent += "统计项,值\n"
        csvContent += "总会话数,\(exportData.statistics.totalSessions)\n"
        csvContent += "总训练时长,\(formatDuration(exportData.statistics.totalTrainingTime))\n"
        csvContent += "平均姿态得分,\(String(format: "%.1f", exportData.statistics.averagePostureScore))\n"
        csvContent += "最活跃日期,\(exportData.statistics.mostActiveDay)\n"
        csvContent += "数据点数量,\(exportData.statistics.dataPointsCount)\n"
        csvContent += "\n"
        
        // 姿态数据
        csvContent += "姿态数据\n"
        csvContent += "日期时间,俯仰角,偏航角,翻滚角\n"
        
        for dataPoint in exportData.postureData {
            csvContent += "\(formatDateTime(dataPoint.date)),\(dataPoint.avgPitch),\(dataPoint.avgYaw),\(dataPoint.avgRoll)\n"
        }
        
        csvContent += "\n"
        
        // 会话摘要
        csvContent += "会话摘要\n"
        csvContent += "日期时间,持续时间(分钟),平均得分,偏差次数,训练质量\n"
        
        for session in exportData.sessionSummaries {
            csvContent += "\(formatDateTime(session.date)),\(Int(session.duration/60)),\(String(format: "%.1f", session.averageScore)),\(session.deviationCount),\(session.quality.rawValue)\n"
        }
        
        return csvContent.data(using: .utf8)
    }
    
    /// 分享导出的文件
    /// - Parameters:
    ///   - data: 要分享的数据
    ///   - format: 文件格式
    ///   - sourceView: 源视图（用于iPad的popover）
    func shareExportedFile(data: Data, format: ExportFormat, sourceView: UIView? = nil) {
        let fileName = generateFileName(format: format)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: tempURL)
            lastExportedFileName = fileName
            
            DispatchQueue.main.async {
                self.presentActivityViewController(for: tempURL, sourceView: sourceView)
            }
        } catch {
            lastExportError = "文件保存失败：\(error.localizedDescription)"
            exportSuccess = false
        }
    }
    
    /// 生成文件名
    private func generateFileName(format: ExportFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = formatter.string(from: Date())
        
        return "PostureTracker_数据导出_\(timestamp).\(format.fileExtension)"
    }
    
    /// 展示活动视图控制器
    private func presentActivityViewController(for url: URL, sourceView: UIView?) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            lastExportError = "无法找到根视图控制器"
            return
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        // iPad 支持
        if let popover = activityVC.popoverPresentationController {
            if let sourceView = sourceView {
                popover.sourceView = sourceView
                popover.sourceRect = sourceView.bounds
            } else {
                popover.sourceView = rootViewController.view
                popover.sourceRect = CGRect(x: rootViewController.view.bounds.midX,
                                          y: rootViewController.view.bounds.midY,
                                          width: 0, height: 0)
            }
            popover.permittedArrowDirections = []
        }
        
        rootViewController.present(activityVC, animated: true)
    }
    
    // MARK: - 辅助方法
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)小时\(minutes)分钟"
        } else {
            return "\(minutes)分钟"
        }
    }
    
    /// 清理临时文件
    func cleanupTempFiles() {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileManager = FileManager.default
        
        do {
            let tempFiles = try fileManager.contentsOfDirectory(atPath: tempDirectory.path)
            for fileName in tempFiles {
                if fileName.hasPrefix("PostureTracker_数据导出_") {
                    let fileURL = tempDirectory.appendingPathComponent(fileName)
                    try fileManager.removeItem(at: fileURL)
                }
            }
        } catch {
            print("清理临时文件失败：\(error)")
        }
    }
}

// MARK: - 导出错误

/// 导出错误类型
enum ExportError: LocalizedError {
    case csvGenerationFailed
    case noDataAvailable
    case fileWriteFailed
    
    var errorDescription: String? {
        switch self {
        case .csvGenerationFailed:
            return "CSV 格式生成失败"
        case .noDataAvailable:
            return "没有可导出的数据"
        case .fileWriteFailed:
            return "文件写入失败"
        }
    }
}

// MARK: - SwiftUI 支持

/// SwiftUI 文件导出修饰符
struct FileExportModifier: ViewModifier {
    @StateObject private var exportManager = FileExportManager.shared
    @State private var showingExportOptions = false
    
    func body(content: Content) -> some View {
        content
            .actionSheet(isPresented: $showingExportOptions) {
                ActionSheet(
                    title: Text("导出数据"),
                    message: Text("选择导出格式"),
                    buttons: [
                        .default(Text("JSON 格式")) {
                            exportData(format: .json)
                        },
                        .default(Text("CSV 格式")) {
                            exportData(format: .csv)
                        },
                        .cancel(Text("取消"))
                    ]
                )
            }
            .overlay(
                Group {
                    if exportManager.isExporting {
                        ProgressView("导出中...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.3))
                    }
                }
            )
    }
    
    private func exportData(format: ExportFormat) {
        guard let data = exportManager.exportAllData(format: format) else {
            return
        }
        
        exportManager.shareExportedFile(data: data, format: format)
    }
}

extension View {
    /// 添加文件导出功能
    func fileExportSupport() -> some View {
        modifier(FileExportModifier())
    }
}

// MARK: - 预览

#Preview("文件导出管理器") {
    struct FileExportPreview: View {
        @StateObject private var exportManager = FileExportManager.shared
        
        var body: some View {
            VStack(spacing: 20) {
                Text("文件导出管理器")
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("导出状态: \(exportManager.isExporting ? "导出中" : "就绪")")
                    
                    if exportManager.isExporting {
                        ProgressView(value: exportManager.exportProgress)
                        Text("进度: \(Int(exportManager.exportProgress * 100))%")
                    }
                    
                    if let error = exportManager.lastExportError {
                        Text("错误: \(error)")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                HStack {
                    Button("导出 JSON") {
                        exportData(format: .json)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("导出 CSV") {
                        exportData(format: .csv)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        
        private func exportData(format: ExportFormat) {
            guard let data = exportManager.exportAllData(format: format) else {
                return
            }
            
            exportManager.shareExportedFile(data: data, format: format)
        }
    }
    
    return FileExportPreview()
}