//
//  SettingsManager.swift
//  PostureTracker
//
//  设置管理器 - 处理应用配置和用户偏好设置
//  Created on 2024-10-03
//

import Foundation
import SwiftUI
import AVFoundation
import Combine

/// 设置管理器 - 使用 UserDefaults 存储用户配置
class SettingsManager: ObservableObject {
    
    // MARK: - 单例
    
    static let shared = SettingsManager()
    
    // MARK: - 监测设置
    
    /// 传感器采样率 (Hz)
    @Published var sampleRate: Double {
        didSet {
            UserDefaults.standard.set(sampleRate, forKey: "sampleRate")
        }
    }
    
    /// 姿态检测灵敏度 (度)
    @Published var sensitivity: Double {
        didSet {
            UserDefaults.standard.set(sensitivity, forKey: "sensitivity")
        }
    }
    
    /// 提示延迟时间 (秒)
    @Published var alertDelay: Double {
        didSet {
            UserDefaults.standard.set(alertDelay, forKey: "alertDelay")
        }
    }
    
    // MARK: - 音频反馈设置
    
    /// 提示音音量 (0.0 - 1.0)
    @Published var alertVolume: Double {
        didSet {
            UserDefaults.standard.set(alertVolume, forKey: "alertVolume")
        }
    }
    
    /// 是否启用语音提示
    @Published var speechEnabled: Bool {
        didSet {
            UserDefaults.standard.set(speechEnabled, forKey: "speechEnabled")
        }
    }
    
    /// 选择的语音类型
    @Published var selectedVoice: String {
        didSet {
            UserDefaults.standard.set(selectedVoice, forKey: "selectedVoice")
        }
    }
    
    /// 是否启用勿扰模式
    @Published var doNotDisturbEnabled: Bool {
        didSet {
            UserDefaults.standard.set(doNotDisturbEnabled, forKey: "doNotDisturbEnabled")
        }
    }
    
    /// 勿扰模式开始时间
    @Published var dndStartTime: Date {
        didSet {
            UserDefaults.standard.set(dndStartTime, forKey: "dndStartTime")
        }
    }
    
    /// 勿扰模式结束时间
    @Published var dndEndTime: Date {
        didSet {
            UserDefaults.standard.set(dndEndTime, forKey: "dndEndTime")
        }
    }
    
    // MARK: - 外观设置
    
    /// 外观模式
    @Published var appearanceMode: AppearanceMode {
        didSet {
            UserDefaults.standard.set(appearanceMode.rawValue, forKey: "appearanceMode")
        }
    }
    
    /// 字体大小
    @Published var fontSize: FontSize {
        didSet {
            UserDefaults.standard.set(fontSize.rawValue, forKey: "fontSize")
        }
    }
    
    // MARK: - 数据设置
    
    /// 是否启用云端同步
    @Published var cloudSyncEnabled: Bool {
        didSet {
            UserDefaults.standard.set(cloudSyncEnabled, forKey: "cloudSyncEnabled")
        }
    }
    
    // MARK: - 私有属性
    
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    // MARK: - 初始化
    
    private init() {
        // 从 UserDefaults 加载设置，如果不存在则使用默认值
        self.sampleRate = UserDefaults.standard.object(forKey: "sampleRate") as? Double ?? 50.0
        self.sensitivity = UserDefaults.standard.object(forKey: "sensitivity") as? Double ?? 15.0
        self.alertDelay = UserDefaults.standard.object(forKey: "alertDelay") as? Double ?? 5.0
        
        self.alertVolume = UserDefaults.standard.object(forKey: "alertVolume") as? Double ?? 0.8
        self.speechEnabled = UserDefaults.standard.bool(forKey: "speechEnabled")
        self.selectedVoice = UserDefaults.standard.string(forKey: "selectedVoice") ?? "female"
        self.doNotDisturbEnabled = UserDefaults.standard.bool(forKey: "doNotDisturbEnabled")
        
        // 默认勿扰时间：22:00 - 08:00
        let calendar = Calendar.current
        let defaultStartTime = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date()
        let defaultEndTime = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
        
        self.dndStartTime = UserDefaults.standard.object(forKey: "dndStartTime") as? Date ?? defaultStartTime
        self.dndEndTime = UserDefaults.standard.object(forKey: "dndEndTime") as? Date ?? defaultEndTime
        
        // 外观设置
        let appearanceRawValue = UserDefaults.standard.string(forKey: "appearanceMode") ?? AppearanceMode.system.rawValue
        self.appearanceMode = AppearanceMode(rawValue: appearanceRawValue) ?? .system
        
        let fontSizeRawValue = UserDefaults.standard.string(forKey: "fontSize") ?? FontSize.medium.rawValue
        self.fontSize = FontSize(rawValue: fontSizeRawValue) ?? .medium
        
        self.cloudSyncEnabled = UserDefaults.standard.bool(forKey: "cloudSyncEnabled")
    }
    
    // MARK: - 公共方法
    
    /// 预览语音提示
    func previewVoice() {
        let utterance = AVSpeechUtterance(string: "您的姿态偏差过大，请调整坐姿")
        
        // 设置语音参数
        utterance.volume = Float(alertVolume)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.8
        
        // 根据选择的语音类型设置语音
        if let voice = getSelectedAVSpeechSynthesisVoice() {
            utterance.voice = voice
        }
        
        speechSynthesizer.speak(utterance)
    }
    
    /// 获取选择的 AVSpeechSynthesisVoice
    private func getSelectedAVSpeechSynthesisVoice() -> AVSpeechSynthesisVoice? {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        
        // 过滤中文语音
        let chineseVoices = voices.filter { $0.language.hasPrefix("zh") }
        
        switch selectedVoice {
        case "male":
            // 寻找男性中文语音
            return chineseVoices.first { voice in
                voice.gender == .male
            } ?? chineseVoices.first
        case "female":
            // 寻找女性中文语音
            return chineseVoices.first { voice in
                voice.gender == .female
            } ?? chineseVoices.first
        default:
            return chineseVoices.first
        }
    }
    
    /// 检查是否在勿扰时间内
    func isInDoNotDisturbTime() -> Bool {
        guard doNotDisturbEnabled else { return false }
        
        let calendar = Calendar.current
        let now = Date()
        
        let currentTime = calendar.dateComponents([.hour, .minute], from: now)
        let startTime = calendar.dateComponents([.hour, .minute], from: dndStartTime)
        let endTime = calendar.dateComponents([.hour, .minute], from: dndEndTime)
        
        guard let currentHour = currentTime.hour,
              let currentMinute = currentTime.minute,
              let startHour = startTime.hour,
              let startMinute = startTime.minute,
              let endHour = endTime.hour,
              let endMinute = endTime.minute else {
            return false
        }
        
        let currentMinutes = currentHour * 60 + currentMinute
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute
        
        // 处理跨天的情况
        if startMinutes > endMinutes {
            // 跨天：22:00 - 08:00
            return currentMinutes >= startMinutes || currentMinutes <= endMinutes
        } else {
            // 同一天：10:00 - 18:00
            return currentMinutes >= startMinutes && currentMinutes <= endMinutes
        }
    }
    
    /// 导出训练数据
    func exportTrainingData() -> Data? {
        // 这里应该实现实际的数据导出逻辑
        // 现在返回示例数据
        let exportData = [
            "exportDate": Date(),
            "settings": [
                "sampleRate": sampleRate,
                "sensitivity": sensitivity,
                "alertDelay": alertDelay
            ],
            "data": "training_data_placeholder"
        ] as [String : Any]
        
        return try? JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
    }
    
    /// 清除所有数据
    func clearAllData() {
        // 清除训练数据（这里应该调用实际的数据清理方法）
        // 现在只是占位
        print("清除所有训练数据")
        
        // 重置设置为默认值
        resetToDefaults()
    }
    
    /// 重置所有设置为默认值
    func resetToDefaults() {
        sampleRate = 50.0
        sensitivity = 15.0
        alertDelay = 5.0
        alertVolume = 0.8
        speechEnabled = false
        selectedVoice = "female"
        doNotDisturbEnabled = false
        appearanceMode = .system
        fontSize = .medium
        cloudSyncEnabled = false
        
        // 重置勿扰时间
        let calendar = Calendar.current
        dndStartTime = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date()
        dndEndTime = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    }
}

// MARK: - 枚举定义

/// 外观模式
enum AppearanceMode: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .light:
            return "浅色"
        case .dark:
            return "深色"
        case .system:
            return "跟随系统"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}

/// 字体大小
enum FontSize: String, CaseIterable {
    case small = "small"
    case medium = "medium"
    case large = "large"
    
    var displayName: String {
        switch self {
        case .small:
            return "小"
        case .medium:
            return "标准"
        case .large:
            return "大"
        }
    }
    
    var scaleFactor: CGFloat {
        switch self {
        case .small:
            return 0.9
        case .medium:
            return 1.0
        case .large:
            return 1.1
        }
    }
}

// MARK: - 预览

#Preview {
    struct SettingsManagerPreview: View {
        @StateObject private var settings = SettingsManager.shared
        
        var body: some View {
            VStack(spacing: 20) {
                Text("设置管理器预览")
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("采样率: \(Int(settings.sampleRate)) Hz")
                    Text("灵敏度: \(Int(settings.sensitivity))°")
                    Text("音量: \(Int(settings.alertVolume * 100))%")
                    Text("语音: \(settings.speechEnabled ? "开启" : "关闭")")
                }
                
                Button("预览语音") {
                    settings.previewVoice()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
    
    return SettingsManagerPreview()
}