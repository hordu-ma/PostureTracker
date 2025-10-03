//
//  SessionSummaryCard.swift
//  PostureTracker
//
//  会话统计卡片组件 - 显示训练会话的详细统计信息
//  Created on 2024-09-30
//

import SwiftUI

struct SessionSummaryCard: View {
    
    // MARK: - 属性
    
    /// 会话统计数据
    let sessionData: SessionStatistics
    
    /// 是否显示分享按钮
    var showShareButton: Bool = true
    
    /// 分享操作回调
    var onShare: (() -> Void)?
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            // 头部
            headerSection
            
            // 统计数据网格
            statisticsGrid
            
            // 姿态分布图表
            postureDistributionSection
            
            // 建议和评价
            suggestionSection
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
    
    // MARK: - 子视图
    
    /// 头部区域
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("会话总结")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("训练评价：\(sessionData.grade.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(gradeColor)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            if showShareButton {
                Button(action: {
                    onShare?()
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    /// 统计数据网格
    private var statisticsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            
            // 总时长
            StatisticItem(
                icon: "clock.fill",
                iconColor: .blue,
                label: "总时长",
                value: formatDuration(sessionData.duration),
                subtitle: "有效训练时间"
            )
            
            // 姿态评分
            StatisticItem(
                icon: "star.fill",
                iconColor: gradeColor,
                label: "姿态评分",
                value: "\(sessionData.score)",
                subtitle: "满分100分"
            )
            
            // 数据采样
            StatisticItem(
                icon: "waveform.path.ecg",
                iconColor: .green,
                label: "数据采样",
                value: "\(sessionData.dataPointCount)",
                subtitle: "个数据点"
            )
            
            // 平均准确率
            StatisticItem(
                icon: "target",
                iconColor: .orange,
                label: "准确率",
                value: "\(Int(sessionData.accuracy * 100))%",
                subtitle: "姿态符合率"
            )
        }
    }
    
    /// 姿态分布区域
    private var postureDistributionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("姿态分布")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(Array(sessionData.postureDistribution.keys.sorted(by: { 
                    sessionData.postureDistribution[$0] ?? 0 > sessionData.postureDistribution[$1] ?? 0 
                })), id: \.self) { postureType in
                    PostureDistributionRow(
                        postureType: postureType,
                        percentage: sessionData.postureDistribution[postureType] ?? 0
                    )
                }
            }
        }
    }
    
    /// 建议区域
    private var suggestionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                
                Text("训练建议")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text(sessionData.grade.suggestion)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(nil)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - 计算属性
    
    /// 等级颜色
    private var gradeColor: Color {
        switch sessionData.grade {
        case .excellent:
            return .green
        case .good:
            return .blue
        case .average:
            return .yellow
        case .belowAverage:
            return .orange
        case .poor:
            return .red
        }
    }
    
    // MARK: - 辅助方法
    
    /// 格式化时长
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

// MARK: - 统计项视图

struct StatisticItem: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            // 图标
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.1))
                .cornerRadius(8)
            
            // 数值
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // 标签
            VStack(spacing: 2) {
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - 姿态分布行视图  

struct PostureDistributionRow: View {
    let postureType: PostureType
    let percentage: Double
    
    var body: some View {
        HStack {
            // 姿态类型
            HStack(spacing: 8) {
                Circle()
                    .fill(postureColor)
                    .frame(width: 12, height: 12)
                
                Text(postureType.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // 百分比进度条
            HStack(spacing: 8) {
                ProgressView(value: percentage, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: postureColor))
                    .frame(width: 60)
                
                Text("\(Int(percentage * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var postureColor: Color {
        switch postureType {
        case .neutral:
            return .green
        case .forwardHead:
            return .red
        case .backwardHead:
            return .orange
        case .leftTilt:
            return .purple
        case .rightTilt:
            return .pink
        }
    }
}

// MARK: - 预览

#Preview("会话统计卡片") {
    SessionSummaryCard(
        sessionData: MockDataGenerator.generateCurrentSessionStats(),
        onShare: {
            print("分享会话数据")
        }
    )
    .padding()
}

#Preview("会话统计卡片 - 暗色模式") {
    SessionSummaryCard(
        sessionData: MockDataGenerator.generateCurrentSessionStats(),
        showShareButton: false
    )
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("统计项") {
    StatisticItem(
        icon: "clock.fill",
        iconColor: .blue,
        label: "总时长",
        value: "25:30",
        subtitle: "有效训练时间"
    )
    .padding()
}

#Preview("姿态分布行") {
    VStack {
        PostureDistributionRow(postureType: .neutral, percentage: 0.65)
        PostureDistributionRow(postureType: .forwardHead, percentage: 0.25)
        PostureDistributionRow(postureType: .leftTilt, percentage: 0.10)
    }
    .padding()
}