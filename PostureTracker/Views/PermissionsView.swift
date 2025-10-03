//
//  PermissionsView.swift
//  PostureTracker
//
//  权限管理页面 - 显示和管理应用权限状态
//  Created on 2024-10-03
//

import SwiftUI
import CoreMotion
import AVFoundation

struct PermissionsView: View {
    
    // MARK: - 属性
    
    /// 运动传感器权限状态
    @State private var motionAuthStatus: CMAuthorizationStatus = .notDetermined
    
    /// 麦克风权限状态
    @State private var microphoneAuthStatus: AVAudioSession.RecordPermission = .undetermined
    
    /// 是否正在检查权限
    @State private var isCheckingPermissions = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            List {
                // 权限说明
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("权限说明")
                                .font(.headline)
                        }
                        
                        Text("PostureTracker 需要以下权限来提供完整的功能体验：")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                
                // 所需权限
                Section("所需权限") {
                    PermissionRow(
                        icon: "gyroscope",
                        iconColor: .blue,
                        title: "运动传感器",
                        description: "监测 AirPods 头部运动数据",
                        status: motionAuthStatus,
                        onRequest: {
                            requestMotionPermission()
                        }
                    )
                    
                    PermissionRow(
                        icon: "mic",
                        iconColor: .red,
                        title: "麦克风",
                        description: "用于音频反馈功能",
                        status: microphoneAuthStatus,
                        onRequest: {
                            requestMicrophonePermission()
                        }
                    )
                }
                
                // 操作
                Section("操作") {
                    Button {
                        checkPermissions()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.blue)
                            Text("重新检查权限")
                            Spacer()
                            if isCheckingPermissions {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    .disabled(isCheckingPermissions)
                    
                    Button {
                        openSystemSettings()
                    } label: {
                        HStack {
                            Image(systemName: \"gear\")
                                .foregroundColor(.gray)
                            Text(\"打开系统设置\")
                            Spacer()
                            Image(systemName: \"arrow.up.right\")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // 帮助信息
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(\"💡 小贴士\")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(\"• 运动传感器权限是必需的，用于检测头部姿态\")
                            Text(\"• 麦克风权限是可选的，用于语音提示功能\")
                            Text(\"• 您可以随时在系统设置中修改这些权限\")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle(\"权限管理\")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                checkPermissions()
            }
        }
    }
    
    // MARK: - 私有方法
    
    /// 检查所有权限状态
    private func checkPermissions() {
        isCheckingPermissions = true
        
        // 检查运动传感器权限
        motionAuthStatus = CMMotionActivityManager.authorizationStatus()
        
        // 检查麦克风权限
        microphoneAuthStatus = AVAudioSession.sharedInstance().recordPermission
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isCheckingPermissions = false
        }
    }
    
    /// 请求运动传感器权限
    private func requestMotionPermission() {
        let manager = CMMotionActivityManager()
        let now = Date()
        
        manager.queryActivityStarting(from: now, to: now, to: .main) { _, error in
            DispatchQueue.main.async {
                self.checkPermissions()
            }
        }
    }
    
    /// 请求麦克风权限
    private func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                self.checkPermissions()
            }
        }
    }
    
    /// 打开系统设置
    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        UIApplication.shared.open(url)
    }
}

// MARK: - 权限行组件

struct PermissionRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let status: Any // CMAuthorizationStatus 或 AVAudioSession.RecordPermission
    let onRequest: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // 图标
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 状态指示器
                statusIndicator
            }
            
            // 操作按钮（如果需要）
            if needsAction {
                Button(\"授予权限\") {
                    onRequest()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 4)
    }
    
    /// 状态指示器
    private var statusIndicator: some View {
        HStack(spacing: 4) {
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)
            Text(statusText)
                .font(.caption)
                .foregroundColor(statusColor)
        }
    }
    
    /// 是否需要操作按钮
    private var needsAction: Bool {
        if let motionStatus = status as? CMAuthorizationStatus {
            return motionStatus == .notDetermined || motionStatus == .denied
        }
        if let micStatus = status as? AVAudioSession.RecordPermission {
            return micStatus == .undetermined || micStatus == .denied
        }
        return false
    }
    
    /// 状态图标
    private var statusIcon: String {
        if let motionStatus = status as? CMAuthorizationStatus {
            switch motionStatus {
            case .authorized:
                return \"checkmark.circle.fill\"
            case .denied, .restricted:
                return \"xmark.circle.fill\"
            case .notDetermined:
                return \"questionmark.circle.fill\"
            @unknown default:
                return \"questionmark.circle.fill\"
            }
        }
        
        if let micStatus = status as? AVAudioSession.RecordPermission {
            switch micStatus {
            case .granted:
                return \"checkmark.circle.fill\"
            case .denied:
                return \"xmark.circle.fill\"
            case .undetermined:
                return \"questionmark.circle.fill\"
            @unknown default:
                return \"questionmark.circle.fill\"
            }
        }
        
        return \"questionmark.circle.fill\"
    }
    
    /// 状态颜色
    private var statusColor: Color {
        if let motionStatus = status as? CMAuthorizationStatus {
            switch motionStatus {
            case .authorized:
                return .green
            case .denied, .restricted:
                return .red
            case .notDetermined:
                return .orange
            @unknown default:
                return .gray
            }
        }
        
        if let micStatus = status as? AVAudioSession.RecordPermission {
            switch micStatus {
            case .granted:
                return .green
            case .denied:
                return .red
            case .undetermined:
                return .orange
            @unknown default:
                return .gray
            }
        }
        
        return .gray
    }
    
    /// 状态文本
    private var statusText: String {
        if let motionStatus = status as? CMAuthorizationStatus {
            switch motionStatus {
            case .authorized:
                return \"已授权\"
            case .denied:
                return \"已拒绝\"
            case .restricted:
                return \"受限制\"
            case .notDetermined:
                return \"未决定\"
            @unknown default:
                return \"未知\"
            }
        }
        
        if let micStatus = status as? AVAudioSession.RecordPermission {
            switch micStatus {
            case .granted:
                return \"已授权\"
            case .denied:
                return \"已拒绝\"
            case .undetermined:
                return \"未决定\"
            @unknown default:
                return \"未知\"
            }
        }
        
        return \"未知\"
    }
}

// MARK: - 扩展

/// 为 CMAuthorizationStatus 添加协议支持
extension CMAuthorizationStatus {
    var description: String {
        switch self {
        case .authorized:
            return \"已授权\"
        case .denied:
            return \"已拒绝\"
        case .restricted:
            return \"受限制\"
        case .notDetermined:
            return \"未决定\"
        @unknown default:
            return \"未知\"
        }
    }
}

/// 为 AVAudioSession.RecordPermission 添加协议支持
extension AVAudioSession.RecordPermission {
    var description: String {
        switch self {
        case .granted:
            return \"已授权\"
        case .denied:
            return \"已拒绝\"
        case .undetermined:
            return \"未决定\"
        @unknown default:
            return \"未知\"
        }
    }
}

// MARK: - 预览

#Preview(\"权限管理\") {
    PermissionsView()
}

#Preview(\"权限行 - 已授权\") {
    List {
        PermissionRow(
            icon: \"gyroscope\",
            iconColor: .blue,
            title: \"运动传感器\",
            description: \"监测 AirPods 头部运动\",
            status: CMAuthorizationStatus.authorized,
            onRequest: { }
        )
    }
}

#Preview(\"权限行 - 未授权\") {
    List {
        PermissionRow(
            icon: \"mic\",
            iconColor: .red,
            title: \"麦克风\",
            description: \"音频反馈功能\",
            status: AVAudioSession.RecordPermission.denied,
            onRequest: { }
        )
    }
}