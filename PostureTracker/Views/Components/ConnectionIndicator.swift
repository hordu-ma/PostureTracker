//
//  ConnectionIndicator.swift
//  PostureTracker
//
//  连接指示器组件 - 显示设备连接和监测状态
//  Created on 2024-09-30
//

import SwiftUI

/// 连接状态指示器
struct ConnectionIndicator: View {

    // MARK: - 属性

    /// 是否已连接
    let isConnected: Bool

    /// 是否正在监测
    let isTracking: Bool

    /// 指示器大小
    var size: CGFloat = 12

    /// 是否显示动画
    @State private var isAnimating = false

    // MARK: - Body

    var body: some View {
        HStack(spacing: 8) {
            // 状态指示灯
            Circle()
                .fill(statusColor)
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(statusColor.opacity(0.3), lineWidth: 2)
                        .scaleEffect(isAnimating ? 1.5 : 1.0)
                        .opacity(isAnimating ? 0 : 1)
                )
                .animation(
                    isTracking
                        ? Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: false) : .default,
                    value: isAnimating
                )

            // 状态文本
            Text(statusText)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(statusColor.opacity(0.1))
        .cornerRadius(12)
        .onAppear {
            if isTracking {
                isAnimating = true
            }
        }
        .onChange(of: isTracking) { oldValue, newValue in
            isAnimating = newValue
        }
    }

    // MARK: - 计算属性

    /// 状态颜色
    private var statusColor: Color {
        if !isConnected {
            return .red
        } else if isTracking {
            return .green
        } else {
            return .orange
        }
    }

    /// 状态文本
    private var statusText: String {
        if !isConnected {
            return "未连接"
        } else if isTracking {
            return "监测中"
        } else {
            return "已连接"
        }
    }
}

// MARK: - 预览

#Preview("未连接") {
    ConnectionIndicator(
        isConnected: false,
        isTracking: false
    )
    .padding()
}

#Preview("已连接") {
    ConnectionIndicator(
        isConnected: true,
        isTracking: false
    )
    .padding()
}

#Preview("监测中") {
    ConnectionIndicator(
        isConnected: true,
        isTracking: true
    )
    .padding()
}

#Preview("大尺寸") {
    ConnectionIndicator(
        isConnected: true,
        isTracking: true,
        size: 16
    )
    .padding()
}

#Preview("暗色模式") {
    VStack(spacing: 20) {
        ConnectionIndicator(
            isConnected: false,
            isTracking: false
        )

        ConnectionIndicator(
            isConnected: true,
            isTracking: false
        )

        ConnectionIndicator(
            isConnected: true,
            isTracking: true
        )
    }
    .padding()
    .preferredColorScheme(.dark)
}
