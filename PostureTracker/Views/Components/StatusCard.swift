//
//  StatusCard.swift
//  PostureTracker
//
//  状态卡片组件 - 显示 AirPods 连接和监测状态
//  Created on 2024-09-30
//

import SwiftUI

/// 状态卡片组件
struct StatusCard: View {

    // MARK: - 属性

    /// 标题
    let title: String

    /// 是否已连接
    let isConnected: Bool

    /// 是否正在监测
    let isTracking: Bool

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            // 标题
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                // 状态指示器
                ConnectionIndicator(
                    isConnected: isConnected,
                    isTracking: isTracking
                )
            }

            // 设备信息
            deviceInfoSection

            // 状态描述
            statusDescription
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - 子视图

    /// 设备信息区域
    private var deviceInfoSection: some View {
        HStack(spacing: 16) {
            // AirPods 图标
            Image(systemName: "airpodspro")
                .font(.system(size: 40))
                .foregroundColor(isConnected ? .blue : .gray)

            VStack(alignment: .leading, spacing: 4) {
                Text(isConnected ? "AirPods Pro" : "未连接")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(deviceStatusText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }

    /// 状态描述
    private var statusDescription: some View {
        HStack {
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)

            Text(statusText)
                .font(.subheadline)
                .foregroundColor(statusColor)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(statusColor.opacity(0.1))
        .cornerRadius(8)
    }

    // MARK: - 计算属性

    /// 设备状态文本
    private var deviceStatusText: String {
        if !isConnected {
            return "请佩戴并连接 AirPods"
        } else if isTracking {
            return "正在监测中"
        } else {
            return "已连接，准备就绪"
        }
    }

    /// 状态图标
    private var statusIcon: String {
        if !isConnected {
            return "antenna.radiowaves.left.and.right.slash"
        } else if isTracking {
            return "checkmark.circle.fill"
        } else {
            return "checkmark.circle"
        }
    }

    /// 状态文本
    private var statusText: String {
        if !isConnected {
            return "设备未连接"
        } else if isTracking {
            return "监测进行中"
        } else {
            return "已就绪"
        }
    }

    /// 状态颜色
    private var statusColor: Color {
        if !isConnected {
            return .red
        } else if isTracking {
            return .green
        } else {
            return .blue
        }
    }
}

// MARK: - 预览

#Preview("已连接-未监测") {
    StatusCard(
        title: "AirPods 状态",
        isConnected: true,
        isTracking: false
    )
    .padding()
}

#Preview("已连接-监测中") {
    StatusCard(
        title: "AirPods 状态",
        isConnected: true,
        isTracking: true
    )
    .padding()
}

#Preview("未连接") {
    StatusCard(
        title: "AirPods 状态",
        isConnected: false,
        isTracking: false
    )
    .padding()
}

#Preview("暗色模式") {
    StatusCard(
        title: "AirPods 状态",
        isConnected: true,
        isTracking: true
    )
    .padding()
    .preferredColorScheme(.dark)
}
