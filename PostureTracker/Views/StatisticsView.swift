//
//  StatisticsView.swift
//  PostureTracker
//
//  统计页面 - 显示姿态数据统计和分析
//  Created on 2024-09-30
//

import SwiftUI
import Charts

struct StatisticsView: View {

    // MARK: - 属性

    /// 选中的时间范围
    @State private var selectedTimeRange: TimeRange = .today

    /// 是否显示详细信息
    @State private var showingDetails = false

    /// 姿态数据
    @State private var postureData: [PostureDataPoint] = []
    
    /// 训练时长数据
    @State private var durationData: [DurationDataPoint] = []
    
    /// 会话摘要数据
    @State private var sessionSummaries: [SessionSummary] = []

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
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
            }
            .onAppear {
                loadData()
            }
            .onChange(of: selectedTimeRange) { _ in
                loadData()
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

            Chart(postureData) { dataPoint in
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
                    xStart: .value("开始", postureData.first?.date ?? Date()),
                    xEnd: .value("结束", postureData.last?.date ?? Date()),
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

            Chart(durationData) { dataPoint in
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
            
            LazyVStack(spacing: 12) {
                ForEach(sessionSummaries.prefix(5)) { session in
                    SessionSummaryRow(session: session)
                }
            }
            
            if sessionSummaries.count > 5 {
                Button("查看更多") {
                    // TODO: 导航到详细会话列表
                }
                .font(.subheadline)
                .foregroundColor(.blue)
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
        switch selectedTimeRange {
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
        switch selectedTimeRange {
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
        switch selectedTimeRange {
        case .today:
            return .hour
        case .week:
            return .day
        case .month:
            return .weekOfYear
        }
    }
    
    // MARK: - 方法
    
    /// 加载数据
    private func loadData() {
        switch selectedTimeRange {
        case .today:
            postureData = MockDataGenerator.generateTodayPostureData()
            durationData = MockDataGenerator.generateWeeklyDurationData().suffix(1).map { $0 }
        case .week:
            postureData = MockDataGenerator.generateWeeklyPostureData()
            durationData = MockDataGenerator.generateWeeklyDurationData()
        case .month:
            postureData = MockDataGenerator.generateMonthlyPostureData()
            durationData = MockDataGenerator.generateMonthlyDurationData()
        }
        
        sessionSummaries = MockDataGenerator.generateSessionSummaries()
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

/// 会话摘要行视图
struct SessionSummaryRow: View {
    let session: SessionSummary
    
    var body: some View {
        HStack(spacing: 12) {
            // 会话类型图标
            Image(systemName: sessionTypeIcon)
                .font(.title2)
                .foregroundColor(gradeColor)
                .frame(width: 32, height: 32)
                .background(gradeColor.opacity(0.1))
                .cornerRadius(8)
            
            // 会话信息
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(session.type.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(formatDate(session.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(formatDuration(session.duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(session.score)分")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(gradeColor)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private var sessionTypeIcon: String {
        switch session.type {
        case .training:
            return "figure.strengthtraining.traditional"
        case .calibration:
            return "scope"
        case .assessment:
            return "chart.bar.doc.horizontal"
        case .freeMode:
            return "person.crop.circle"
        }
    }
    
    private var gradeColor: Color {
        switch session.grade {
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration / 60)
        let seconds = Int(duration) % 60
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}

#Preview("会话摘要行") {
    SessionSummaryRow(session: SessionSummary(
        id: UUID(),
        date: Date(),
        type: .training,
        duration: 1800,
        score: 85,
        grade: .good
    ))
    .padding()
}
