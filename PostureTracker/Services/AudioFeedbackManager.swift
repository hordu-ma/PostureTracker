//
//  AudioFeedbackManager.swift
//  PostureTracker
//
//  音频反馈管理服务
//

import Foundation
import AVFoundation
import Combine
import os.log

/// 音频反馈管理器
/// 负责根据姿态偏差提供语音和音效反馈
public class AudioFeedbackManager: NSObject, ObservableObject {
    
    // MARK: - 单例
    
    public static let shared = AudioFeedbackManager()
    
    // MARK: - Published 属性
    
    /// 反馈开关
    @Published public var isEnabled: Bool = true
    
    /// 静音模式
    @Published public var isMuted: Bool = false
    
    /// 防打扰模式
    @Published public var isDoNotDisturb: Bool = false
    
    /// 音量（0.0 - 1.0）
    @Published public var volume: Float = 0.7
    
    /// 语速（0.0 - 1.0）
    @Published public var speechRate: Float = 0.5
    
    /// 反馈策略
    @Published public var feedbackStrategy: FeedbackStrategy = .adaptive
    
    /// 反馈语言
    @Published public var language: FeedbackLanguage = .chinese
    
    // MARK: - 私有属性
    
    private let synthesizer = AVSpeechSynthesizer()
    private let audioEngine = AVAudioEngine()
    private var audioPlayer: AVAudioPlayer?
    
    private var feedbackQueue: [FeedbackItem] = []
    private var isProcessingQueue = false
    
    private let logger = Logger(subsystem: "com.posturetracker", category: "AudioFeedback")
    
    private var lastFeedbackTime: Date?
    private let minFeedbackInterval: TimeInterval = 3.0 // 最小反馈间隔（秒）
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 初始化
    
    private override init() {
        super.init()
        setupAudioSession()
        synthesizer.delegate = self
    }
    
    // MARK: - 公开方法
    
    /// 提供姿态反馈
    public func provideFeedback(for currentPosture: Posture, target targetPosture: Posture) {
        guard isEnabled && !isMuted else { return }
        guard shouldProvideFeedback() else { return }
        
        let deviation = currentPosture.deviation(from: targetPosture)
        
        // 根据偏差程度决定反馈类型
        let feedbackLevel = determineFeedbackLevel(deviation: deviation)
        
        switch feedbackLevel {
        case .none:
            return
        case .gentle:
            provideGentleReminder(deviation: deviation, currentPosture: currentPosture)
        case .moderate:
            provideModerateWarning(deviation: deviation, currentPosture: currentPosture)
        case .strong:
            provideStrongCorrection(deviation: deviation, currentPosture: currentPosture)
        }
        
        lastFeedbackTime = Date()
    }
    
    /// 播放成功音效
    public func playSuccessSound() {
        guard isEnabled && !isMuted else { return }
        playSystemSound(.success)
    }
    
    /// 播放警告音效
    public func playWarningSound() {
        guard isEnabled && !isMuted else { return }
        playSystemSound(.warning)
    }
    
    /// 播放自定义语音
    public func speak(_ text: String, priority: FeedbackPriority = .normal) {
        guard isEnabled && !isMuted else { return }
        
        let item = FeedbackItem(
            type: .speech(text),
            priority: priority,
            timestamp: Date()
        )
        
        enqueueFeedback(item)
    }
    
    /// 停止所有反馈
    public func stopAllFeedback() {
        synthesizer.stopSpeaking(at: .immediate)
        audioPlayer?.stop()
        feedbackQueue.removeAll()
    }
    
    /// 暂停反馈
    public func pauseFeedback() {
        synthesizer.pauseSpeaking(at: .immediate)
        audioPlayer?.pause()
    }
    
    /// 恢复反馈
    public func resumeFeedback() {
        synthesizer.continueSpeaking()
        audioPlayer?.play()
    }
    
    // MARK: - 私有方法
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
            logger.info("音频会话配置成功")
        } catch {
            logger.error("音频会话配置失败: \(error.localizedDescription)")
        }
    }
    
    private func shouldProvideFeedback() -> Bool {
        // 防打扰模式检查
        if isDoNotDisturb {
            let hour = Calendar.current.component(.hour, from: Date())
            if hour >= 22 || hour < 8 { // 晚10点到早8点
                return false
            }
        }
        
        // 检查最小反馈间隔
        if let lastTime = lastFeedbackTime {
            return Date().timeIntervalSince(lastTime) >= minFeedbackInterval
        }
        
        return true
    }
    
    private func determineFeedbackLevel(deviation: PostureDeviation) -> FeedbackLevel {
        let magnitude = deviation.magnitude
        
        switch feedbackStrategy {
        case .gentle:
            return magnitude > 20 ? .gentle : .none
        case .moderate:
            if magnitude > 30 { return .strong }
            if magnitude > 20 { return .moderate }
            if magnitude > 10 { return .gentle }
            return .none
        case .strict:
            if magnitude > 20 { return .strong }
            if magnitude > 10 { return .moderate }
            if magnitude > 5 { return .gentle }
            return .none
        case .adaptive:
            // 自适应策略：根据用户历史表现调整
            if magnitude > 25 { return .strong }
            if magnitude > 15 { return .moderate }
            if magnitude > 8 { return .gentle }
            return .none
        }
    }
    
    private func provideGentleReminder(deviation: PostureDeviation, currentPosture: Posture) {
        playSystemSound(.gentle)
        
        let instruction = generateInstruction(
            for: deviation,
            level: .gentle,
            currentPosture: currentPosture
        )
        
        if !instruction.isEmpty {
            speak(instruction, priority: .low)
        }
    }
    
    private func provideModerateWarning(deviation: PostureDeviation, currentPosture: Posture) {
        playSystemSound(.warning)
        
        let instruction = generateInstruction(
            for: deviation,
            level: .moderate,
            currentPosture: currentPosture
        )
        
        speak(instruction, priority: .normal)
    }
    
    private func provideStrongCorrection(deviation: PostureDeviation, currentPosture: Posture) {
        playSystemSound(.alert)
        
        let instruction = generateInstruction(
            for: deviation,
            level: .strong,
            currentPosture: currentPosture
        )
        
        speak(instruction, priority: .high)
    }
    
    private func generateInstruction(for deviation: PostureDeviation, level: FeedbackLevel, currentPosture: Posture) -> String {
        let primaryAxis = currentPosture.primaryDeviationAxis(from: AirPodsMotionManager.shared.targetPosture)
        
        switch language {
        case .chinese:
            return generateChineseInstruction(axis: primaryAxis, deviation: deviation, level: level)
        case .english:
            return generateEnglishInstruction(axis: primaryAxis, deviation: deviation, level: level)
        }
    }
    
    private func generateChineseInstruction(axis: DeviationAxis, deviation: PostureDeviation, level: FeedbackLevel) -> String {
        switch axis {
        case .pitch:
            if deviation.pitchDelta > 0 {
                return level == .gentle ? "请稍微低一点头" : "头部太向后了，请低头"
            } else {
                return level == .gentle ? "请稍微抬一点头" : "头部太低了，请抬头"
            }
        case .yaw:
            if deviation.yawDelta > 0 {
                return level == .gentle ? "请稍微向左转" : "头部偏右，请向左转"
            } else {
                return level == .gentle ? "请稍微向右转" : "头部偏左，请向右转"
            }
        case .roll:
            if deviation.rollDelta > 0 {
                return level == .gentle ? "请稍微向左倾斜" : "头部右倾，请调整"
            } else {
                return level == .gentle ? "请稍微向右倾斜" : "头部左倾，请调整"
            }
        }
    }
    
    private func generateEnglishInstruction(axis: DeviationAxis, deviation: PostureDeviation, level: FeedbackLevel) -> String {
        switch axis {
        case .pitch:
            if deviation.pitchDelta > 0 {
                return level == .gentle ? "Lower your head slightly" : "Head too far back, please lower"
            } else {
                return level == .gentle ? "Raise your head slightly" : "Head too low, please raise"
            }
        case .yaw:
            if deviation.yawDelta > 0 {
                return level == .gentle ? "Turn left slightly" : "Head turned right, turn left"
            } else {
                return level == .gentle ? "Turn right slightly" : "Head turned left, turn right"
            }
        case .roll:
            if deviation.rollDelta > 0 {
                return level == .gentle ? "Tilt left slightly" : "Head tilted right, please adjust"
            } else {
                return level == .gentle ? "Tilt right slightly" : "Head tilted left, please adjust"
            }
        }
    }
    
    private func enqueueFeedback(_ item: FeedbackItem) {
        feedbackQueue.append(item)
        feedbackQueue.sort { $0.priority.rawValue > $1.priority.rawValue }
        
        if !isProcessingQueue {
            processFeedbackQueue()
        }
    }
    
    private func processFeedbackQueue() {
        guard !feedbackQueue.isEmpty else {
            isProcessingQueue = false
            return
        }
        
        isProcessingQueue = true
        let item = feedbackQueue.removeFirst()
        
        switch item.type {
        case .speech(let text):
            speakText(text)
        case .sound(let sound):
            playSystemSound(sound)
        }
    }
    
    private func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = speechRate
        utterance.volume = volume
        
        // 设置语言
        switch language {
        case .chinese:
            utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        case .english:
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        
        synthesizer.speak(utterance)
    }
    
    private func playSystemSound(_ sound: SystemSound) {
        // 这里应该加载实际的音频文件
        // 为了演示，使用系统声音
        switch sound {
        case .success:
            AudioServicesPlaySystemSound(1057)
        case .warning:
            AudioServicesPlaySystemSound(1073)
        case .alert:
            AudioServicesPlaySystemSound(1074)
        case .gentle:
            AudioServicesPlaySystemSound(1003)
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension AudioFeedbackManager: AVSpeechSynthesizerDelegate {
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // 继续处理队列
        DispatchQueue.main.async {
            self.processFeedbackQueue()
        }
    }
}

// MARK: - 辅助类型

/// 反馈级别
public enum FeedbackLevel {
    case none
    case gentle
    case moderate
    case strong
}

/// 反馈策略
public enum FeedbackStrategy: String, CaseIterable {
    case gentle = "温和"
    case moderate = "适中"
    case strict = "严格"
    case adaptive = "自适应"
}

/// 反馈语言
public enum FeedbackLanguage: String, CaseIterable {
    case chinese = "中文"
    case english = "English"
}

/// 反馈优先级
public enum FeedbackPriority: Int {
    case low = 0
    case normal = 1
    case high = 2
}

/// 系统声音
public enum SystemSound {
    case success
    case warning
    case alert
    case gentle
}

/// 反馈项
private struct FeedbackItem {
    enum FeedbackType {
        case speech(String)
        case sound(SystemSound)
    }
    
    let type: FeedbackType
    let priority: FeedbackPriority
    let timestamp: Date
}