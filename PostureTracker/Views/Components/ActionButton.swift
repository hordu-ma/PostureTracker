//
//  ActionButton.swift
//  PostureTracker
//
//  主操作按钮组件 - 用于监测控制等主要操作
//  Created on 2024-09-30
//

import SwiftUI

/// 主操作按钮组件
struct ActionButton: View {

    // MARK: - 属性

    /// 按钮标题
    let title: String

    /// 图标名称
    let icon: String?

    /// 是否可用
    let isEnabled: Bool

    /// 是否为主要按钮
    let isPrimary: Bool

    /// 点击回调
    let action: () -> Void

    /// 按钮按压状态
    @State private var isPressed = false

    // MARK: - 初始化

    init(
        title: String,
        icon: String? = nil,
        isEnabled: Bool = true,
        isPrimary: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isEnabled = isEnabled
        self.isPrimary = isPrimary
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button {
            // 触觉反馈
            if isEnabled {
                let generator = UIImpactFeedbackGenerator(style: isPrimary ? .medium : .light)
                generator.impactOccurred()
                action()
            }
        } label: {
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: isPrimary ? 20 : 16))
                }

                Text(title)
                    .font(
                        .system(size: isPrimary ? 18 : 16, weight: isPrimary ? .semibold : .medium))
            }
            .frame(maxWidth: .infinity)
            .frame(height: isPrimary ? 56 : 48)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .cornerRadius(isPrimary ? 16 : 12)
            .shadow(
                color: isEnabled ? shadowColor : .clear,
                radius: isPressed ? 4 : 8,
                x: 0,
                y: isPressed ? 2 : 4
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if isEnabled {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }

    // MARK: - 计算属性

    /// 前景色
    private var foregroundColor: Color {
        if !isEnabled {
            return .gray
        }

        if isPrimary {
            return .white
        } else {
            return .blue
        }
    }

    /// 背景色
    private var backgroundColor: Color {
        if !isEnabled {
            return Color.gray.opacity(0.2)
        }

        if isPrimary {
            return .blue
        } else {
            return Color.blue.opacity(0.1)
        }
    }

    /// 阴影颜色
    private var shadowColor: Color {
        if isPrimary {
            return .blue.opacity(0.3)
        } else {
            return .black.opacity(0.05)
        }
    }
}

// MARK: - 预览

#Preview("主要按钮") {
    VStack(spacing: 20) {
        ActionButton(
            title: "开始监测",
            icon: "play.circle.fill",
            isEnabled: true,
            isPrimary: true
        ) {
            print("开始监测")
        }

        ActionButton(
            title: "停止监测",
            icon: "stop.circle.fill",
            isEnabled: true,
            isPrimary: true
        ) {
            print("停止监测")
        }
    }
    .padding()
}

#Preview("次要按钮") {
    VStack(spacing: 20) {
        ActionButton(
            title: "暂停",
            icon: "pause.circle",
            isEnabled: true,
            isPrimary: false
        ) {
            print("暂停")
        }

        ActionButton(
            title: "重置",
            icon: "arrow.counterclockwise",
            isEnabled: true,
            isPrimary: false
        ) {
            print("重置")
        }
    }
    .padding()
}

#Preview("禁用状态") {
    VStack(spacing: 20) {
        ActionButton(
            title: "开始监测",
            icon: "play.circle.fill",
            isEnabled: false,
            isPrimary: true
        ) {
            print("不会执行")
        }

        ActionButton(
            title: "暂停",
            icon: "pause.circle",
            isEnabled: false,
            isPrimary: false
        ) {
            print("不会执行")
        }
    }
    .padding()
}

#Preview("无图标") {
    VStack(spacing: 20) {
        ActionButton(
            title: "继续",
            isEnabled: true,
            isPrimary: true
        ) {
            print("继续")
        }

        ActionButton(
            title: "取消",
            isEnabled: true,
            isPrimary: false
        ) {
            print("取消")
        }
    }
    .padding()
}

#Preview("暗色模式") {
    VStack(spacing: 20) {
        ActionButton(
            title: "开始监测",
            icon: "play.circle.fill",
            isEnabled: true,
            isPrimary: true
        ) {
            print("开始监测")
        }

        ActionButton(
            title: "暂停",
            icon: "pause.circle",
            isEnabled: true,
            isPrimary: false
        ) {
            print("暂停")
        }

        ActionButton(
            title: "禁用按钮",
            icon: "xmark.circle",
            isEnabled: false,
            isPrimary: true
        ) {
            print("不会执行")
        }
    }
    .padding()
    .preferredColorScheme(.dark)
}
