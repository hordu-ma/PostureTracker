//
//  StatisticsView.swift
//  PostureTracker
//
//  统计页面 - 显示姿态数据统计和分析
//  Created on 2024-09-30
//

import SwiftUI

struct StatisticsView: View {

    // MARK: - 属性

    /// 选中的时间范围
    @State private var selectedTimeRange: TimeRange = .today

    /// 是否显示详细信息
    @State private var showingDetails = false

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 时间范围选择器
                    timeRangePicker

                    // 占位内容
                    placeholderContent

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("统计分析")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingDetails.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
            }
        }
    }

    // MARK: - 子视图

    /// 时间范围选择器
    private var timeRangePicker: some View {
        Picker("时间范围", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }

    /// 占位内容
    private var placeholderContent: some View {
        VStack(spacing: 24) {
            // 图标
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))

            // 文字说明
            VStack(spacing: 12) {
                Text("统计功能开发中")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("即将推出以下功能：")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // 功能列表
            VStack(alignment: .leading, spacing: 16) {
                featureItem(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "姿态趋势图表",
                    description: "查看每日姿态变化趋势"
                )

                featureItem(
                    icon: "chart.bar.fill",
                    title: "训练时长统计",
                    description: "每日、每周训练时长对比"
                )

                featureItem(
                    icon: "exclamationmark.triangle.fill",
                    title: "偏差分析",
                    description: "姿态偏差次数和频率分析"
                )

                featureItem(
                    icon: "star.fill",
                    title: "训练成就",
                    description: "完成目标获得成就徽章"
                )
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
        .padding(.vertical, 40)
    }

    /// 功能项
    private func featureItem(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

// MARK: - 时间范围枚举

/// 时间范围
enum TimeRange: String, CaseIterable {
    case today = "今天"
    case week = "本周"
    case month = "本月"
}

// MARK: - 预览

#Preview("统计视图") {
    StatisticsView()
}

#Preview("暗色模式") {
    StatisticsView()
        .preferredColorScheme(.dark)
}
