//
//  StatisticsView.swift
//  PostureTracker
//
//  统计页面 - 显示姿态数据统计和分析
//  Created on 2024-09-30
//  Updated: 2024-10-03 - 集成 StatisticsViewModel
//

import SwiftUI
import Charts

struct StatisticsView: View {

    // MARK: - ViewModels

    /// 统计数据 ViewModel
    @StateObject private var viewModel: StatisticsViewModel
    
    /// 会话管理 ViewModel
    @ObservedObject var sessionViewModel: SessionViewModel

    // MARK: - 状态属性

    /// 是否显示详细信息
    @State private var showingDetails = false
    
    // MARK: - 初始化
    
    init(sessionViewModel: SessionViewModel = SessionViewModel()) {
        self.sessionViewModel = sessionViewModel
        _viewModel = StateObject(wrappedValue: StatisticsViewModel(sessionViewModel: sessionViewModel))
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 汇总统计卡片
                    summaryStatsCard
                    
                    // 时间范围选择器
                    timeRangePicker

                    // 图表区域
                    chartsSection
                    
                    // 会话统计区域
                    sessionStatsSection

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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.refreshData()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                viewModel.refreshData()
            }
        }
    }

    // MARK: - 子视图
    
    /// 汇总统计卡片
    private var summaryStatsCard: some View {
        VStack(spacing: 16) {
            Text("总体统计")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 24) {
                summaryStatItem(
                    label: "总会话数",
                    value: "\(viewModel.summary.totalSessions)",
                    iconName: "square.grid.2x2"
                )
                
                summaryStatItem(
                    label: "平均评分",
                    value: String(format: "%.0f", viewModel.summary.averageScore),
                    iconName: "star.fill"
                )
                
                summaryStatItem(
                    label: "总时长",
                    value: formatMinutes(viewModel.summary.totalDuration),
                    iconName: "clock"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    /// 汇总统计项
    private func summaryStatItem(label: String, value: String, iconName: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    /// 时间范围选择器
    private var timeRangePicker: some View {
        Picker("时间范围", selection: $viewModel.selectedTimeRange) {
            ForEach([StatisticsViewModel.TimeRange.today, .week, .month], id: \.self) { range in
                Text(range.displayName).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }

    /// 图表区域
    private var chartsSection: some View {
        VStack(spacing: 20) {
            // 姿态趋势图表
            postureChart
            
            // 训练时长图表
            durationChart
        }
    }
    
    /// 姿态趋势图表
    private var postureChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("姿态趋势")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("俯仰角度 (°)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Chart(viewModel.postureData) { dataPoint in
                LineMark(
                    x: .value("时间", dataPoint.date),
                    y: .value("俯仰角", dataPoint.avgPitch)
                )
                .foregroundStyle(.blue)
                .interpolationMethod(.catmullRom)
                .symbol(.circle)
                .symbolSize(30)
                
                // 添加理想范围区域
                RectangleMark(
                    xStart: .value("开始", viewModel.postureData.first?.date ?? Date()),
                    xEnd: .value("结束", viewModel.postureData.last?.date ?? Date()),
                    yStart: .value("下限", -5),
                    yEnd: .value("上限", 5)
                )
                .foregroundStyle(.green.opacity(0.1))
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let intValue = value.as(Double.self) {
                            Text("\(Int(intValue))°")
                                .font(.caption)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: xAxisValues) { value in
                    AxisGridLine()
                    AxisValueLabel(format: xAxisFormat)
                }
            }
            .chartYScale(domain: -25...15)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8)
    }
    
    /// 训练时长图表
    private var durationChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("训练时长")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("分钟")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Chart(viewModel.durationData) { dataPoint in
                BarMark(
                    x: .value("日期", dataPoint.date, unit: chartTimeUnit),
                    y: .value("时长", dataPoint.duration)
                )
                .foregroundStyle(.green.gradient)
                .cornerRadius(4)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let intValue = value.as(Double.self) {
                            Text("\(Int(intValue))m")
                                .font(.caption)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: xAxisValues) { value in
                    AxisGridLine()
                    AxisValueLabel(format: xAxisFormat)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8)
    }
    
    /// 会话统计区域
    private var sessionStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("近期会话")
                .font(.headline)
                .fontWeight(.semibold)
            
            if sessionViewModel.sessionHistory.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("暂无训练记录")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(sessionViewModel.sessionHistory.prefix(5)) { session in
                        SessionHistoryRow(session: session)
                    }
                }
                
                if sessionViewModel.sessionHistory.count > 5 {
                    Button("查看全部 \(sessionViewModel.sessionHistory.count) 条记录") {
                        // TODO: 导航到详细会话列表
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8)
    }
    
    // MARK: - 计算属性
    
    /// X轴刻度值
    private var xAxisValues: [Date] {
        switch viewModel.selectedTimeRange {
        case .today:
            // 每3小时一个刻度
            return stride(from: 0, to: 24, by: 3).compactMap { hour in
                Calendar.current.date(byAdding: .hour, value: -hour, to: Date())
            }.reversed()
        case .week:
            // 每天一个刻度
            return (0..<7).compactMap { day in
                Calendar.current.date(byAdding: .day, value: -day, to: Date())
            }.reversed()
        case .month:
            // 每周一个刻度
            return (0..<4).compactMap { week in
                Calendar.current.date(byAdding: .weekOfYear, value: -week, to: Date())
            }.reversed()
        }
    }
    
    /// X轴格式
    private var xAxisFormat: Date.FormatStyle {
        switch viewModel.selectedTimeRange {
        case .today:
            return .dateTime.hour()
        case .week:
            return .dateTime.weekday(.abbreviated)
        case .month:
            return .dateTime.month(.abbreviated).day()
        }
    }
    
    /// 图表时间单位
    private var chartTimeUnit: Calendar.Component {
        switch viewModel.selectedTimeRange {
        case .today:
            return .hour
        case .week:
            return .day
        case .month:
            return .weekOfYear
        }
    }
    
    // MARK: - 辅助方法
    
    /// 格式化分钟数
    private func formatMinutes(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds / 60)
        if minutes < 60 {
            return "\(minutes)分"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours):\(String(format: "%02d", remainingMinutes))时"
        }
    }
}

// MARK: - 会话历史行视图

/// 会话历史行视图
struct SessionHistoryRow: View {
    let session: Session
    
    var body: some View {
        HStack(spacing: 12) {
            // 会话图标
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.title2)
                .foregroundColor(gradeColor)
                .frame(width: 32, height: 32)
                .background(gradeColor.opacity(0.1))
                .cornerRadius(8)
            
            // 会话信息
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("训练会话")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(formatDate(session.startTime))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(formatDuration(session.duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(session.averageScore))分")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(gradeColor)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private var gradeColor: Color {
        if session.averageScore >= 90 {
            return .green
        } else if session.averageScore >= 70 {
            return .blue
        } else if session.averageScore >= 50 {
            return .orange
        } else {
            return .red
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        let seconds = Int(duration) % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}

// MARK: - 预览

#Preview("统计视图") {
    StatisticsView()
}

#Preview("暗色模式") {
    StatisticsView()
        .preferredColorScheme(.dark)
}

#Preview("会话历史行") {
    let session = Session(
        startTime: Date(),
        endTime: Date().addingTimeInterval(1800),
        averageScore: 85,
        deviationCount: 3
    )
    return SessionHistoryRow(session: session)
        .padding()
}
