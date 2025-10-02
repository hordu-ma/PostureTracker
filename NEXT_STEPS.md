# PostureTracker 下一步行动指南

## 🎉 Sprint 1 完成！

恭喜！您已经成功完成了 **Sprint 1: 核心界面框架开发**。

**当前进度**: 第二阶段 33% 完成 (1/3 Sprint)

---

## 📋 立即行动清单

### 第一步：创建 Xcode 项目（如果尚未创建）

```bash
# 1. 在 Xcode 中创建新项目
# File > New > Project...
# iOS > App
# Product Name: PostureTracker
# Interface: SwiftUI
# Language: Swift

# 2. 将现有代码添加到项目
# - 删除自动生成的 ContentView.swift 和 PostureTrackerApp.swift
# - 右键项目 > Add Files to "PostureTracker"...
# - 选择 PostureTracker 文件夹下的所有子目录
# - 勾选 "Copy items if needed" 和 "Create groups"

# 3. 配置 Info.plist
# 添加运动数据使用说明：
# NSMotionUsageDescription: "需要访问运动数据来监测头部姿态"

# 4. 测试编译
# Cmd + B (Build)
# Cmd + R (Run)
```

### 第二步：验证 Sprint 1 功能

```bash
# 在模拟器中测试
✅ 应用能正常启动
✅ 三个标签页可以切换
✅ 监测页面显示正常
✅ 按钮可以点击（连接状态会显示错误，这是正常的）
✅ 统计和设置页面显示占位内容
✅ 切换到暗色模式查看效果
```

### 第三步：准备 Sprint 2 开发环境

```bash
# 1. 学习 SceneKit 基础
# - Apple 官方文档：SceneKit Overview
# - WWDC Session：Building Apps with SceneKit
# - 示例项目：Apple Sample Code

# 2. 学习 Swift Charts
# - Apple 官方文档：Swift Charts
# - WWDC Session：Hello Swift Charts
# - 示例项目：Charts Tutorials

# 3. 准备测试数据
# - 创建模拟姿态数据生成器
# - 准备不同时间段的测试数据
```

---

## 🚀 Sprint 2 详细开发计划

### 目标：数据可视化界面（预计 4-5 天）

### Task 2.2.1: 3D 姿态展示组件（2-3 天）

**优先级**: ⭐⭐⭐ 最高

#### 步骤 1: 集成 SceneKit（2-3 小时）

```swift
// 创建文件：PostureTracker/Views/Components/PostureVisualization3D.swift

import SwiftUI
import SceneKit

struct PostureVisualization3D: UIViewRepresentable {
    var pitch: Double
    var yaw: Double
    var roll: Double

    func makeUIView(context: Context) -> SCNView {
        // 创建 SceneKit 视图
        let sceneView = SCNView()
        sceneView.scene = SCNScene()
        sceneView.backgroundColor = .clear
        sceneView.allowsCameraControl = false

        // TODO: 设置相机和光照
        // TODO: 添加头部模型

        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        // TODO: 更新模型旋转角度
    }
}
```

**验收标准**:
- [ ] SceneKit 场景能正常渲染
- [ ] 场景中有基础几何体（立方体或球体代表头部）
- [ ] 背景透明，融入应用风格

#### 步骤 2: 实现头部模型（3-4 小时）

```swift
// 在 makeUIView 中添加模型
private func setupHeadModel(in scene: SCNScene) {
    // 创建简单的头部模型（椭球体）
    let headGeometry = SCNSphere(radius: 1.0)
    headGeometry.segmentCount = 32

    // 设置材质
    headGeometry.firstMaterial?.diffuse.contents = UIColor.systemBlue
    headGeometry.firstMaterial?.specular.contents = UIColor.white

    // 创建节点
    let headNode = SCNNode(geometry: headGeometry)
    scene.rootNode.addChildNode(headNode)

    // TODO: 添加参考坐标系（可选）
}
```

**验收标准**:
- [ ] 头部模型渲染正常
- [ ] 材质和光照效果良好
- [ ] 大小和位置合适

#### 步骤 3: 实时旋转更新（2-3 小时）

```swift
func updateUIView(_ uiView: SCNView, context: Context) {
    guard let headNode = uiView.scene?.rootNode.childNodes.first else { return }

    // 将欧拉角转换为 SceneKit 旋转
    let pitchRotation = SCNMatrix4MakeRotation(Float(pitch.degreesToRadians), 1, 0, 0)
    let yawRotation = SCNMatrix4MakeRotation(Float(yaw.degreesToRadians), 0, 1, 0)
    let rollRotation = SCNMatrix4MakeRotation(Float(roll.degreesToRadians), 0, 0, 1)

    // 组合旋转
    var transform = SCNMatrix4Identity
    transform = SCNMatrix4Mult(transform, yawRotation)
    transform = SCNMatrix4Mult(transform, pitchRotation)
    transform = SCNMatrix4Mult(transform, rollRotation)

    headNode.transform = transform
}
```

**验收标准**:
- [ ] 模型能根据角度实时旋转
- [ ] 旋转方向正确
- [ ] 性能流畅（60fps）

#### 步骤 4: 集成到监测页面（1-2 小时）

```swift
// 在 MonitoringView.swift 的 currentPostureCard 中添加
if motionManager.isTracking {
    // 3D 可视化
    PostureVisualization3D(
        pitch: motionManager.currentPosture.pitch,
        yaw: motionManager.currentPosture.yaw,
        roll: motionManager.currentPosture.roll
    )
    .frame(height: 200)
    .cornerRadius(12)

    // 原有的角度显示
    HStack(spacing: 32) {
        // ...
    }
}
```

**验收标准**:
- [ ] 3D 视图集成到页面
- [ ] 与其他元素布局协调
- [ ] 交互不冲突

---

### Task 2.2.2: 统计图表页面（1-2 天）

**优先级**: ⭐⭐⭐ 高

#### 步骤 1: 准备测试数据（1-2 小时）

```swift
// 创建文件：PostureTracker/Utils/MockDataGenerator.swift

struct MockDataGenerator {
    /// 生成今日姿态趋势数据
    static func generateTodayPostureData() -> [PostureDataPoint] {
        var data: [PostureDataPoint] = []
        let now = Date()

        for hour in 0..<24 {
            let date = Calendar.current.date(byAdding: .hour, value: -hour, to: now)!
            let avgPitch = Double.random(in: -15...15)
            data.append(PostureDataPoint(date: date, avgPitch: avgPitch))
        }

        return data.reversed()
    }

    /// 生成每日训练时长数据
    static func generateWeeklyDuration() -> [DurationDataPoint] {
        // TODO: 实现
    }
}

struct PostureDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let avgPitch: Double
}
```

**验收标准**:
- [ ] 能生成合理的测试数据
- [ ] 数据格式符合图表要求

#### 步骤 2: 实现折线图（2-3 小时）

```swift
// 在 StatisticsView.swift 中替换占位内容
import Charts

private var postureChart: some View {
    VStack(alignment: .leading, spacing: 12) {
        Text("姿态趋势")
            .font(.headline)

        Chart(mockData) { dataPoint in
            LineMark(
                x: .value("时间", dataPoint.date),
                y: .value("俯仰角", dataPoint.avgPitch)
            )
            .foregroundStyle(.blue)
            .interpolationMethod(.catmullRom)
        }
        .frame(height: 200)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour, count: 3))
        }
    }
    .padding()
    .background(Color(.systemBackground))
    .cornerRadius(16)
}
```

**验收标准**:
- [ ] 折线图正常显示
- [ ] 坐标轴标签清晰
- [ ] 支持暗色模式

#### 步骤 3: 实现柱状图（2-3 小时）

```swift
private var durationChart: some View {
    VStack(alignment: .leading, spacing: 12) {
        Text("每日训练时长")
            .font(.headline)

        Chart(weeklyData) { dataPoint in
            BarMark(
                x: .value("日期", dataPoint.date, unit: .day),
                y: .value("时长", dataPoint.duration)
            )
            .foregroundStyle(.green)
        }
        .frame(height: 200)
    }
    .padding()
    .background(Color(.systemBackground))
    .cornerRadius(16)
}
```

**验收标准**:
- [ ] 柱状图正常显示
- [ ] 数据标签清晰
- [ ] 交互体验良好

---

### Task 2.2.3: 会话统计卡片（1 天）

**优先级**: ⭐⭐ 中等

#### 创建独立组件（3-4 小时）

```swift
// 创建文件：PostureTracker/Views/Components/SessionSummaryCard.swift

struct SessionSummaryCard: View {
    let sessionData: SessionStatistics

    var body: some View {
        VStack(spacing: 16) {
            // 标题
            HStack {
                Text("会话总结")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: shareSession) {
                    Image(systemName: "square.and.arrow.up")
                }
            }

            // 统计数据网格
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                statItem(icon: "clock", label: "总时长", value: formatDuration(sessionData.duration))
                statItem(icon: "figure.stand", label: "姿态评分", value: "\(sessionData.score)")
                statItem(icon: "exclamationmark.triangle", label: "偏差次数", value: "\(sessionData.deviationCount)")
                statItem(icon: "chart.line.uptrend.xyaxis", label: "改善率", value: "\(sessionData.improvement)%")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8)
    }
}
```

**验收标准**:
- [ ] 卡片布局美观
- [ ] 数据显示完整
- [ ] 分享功能 UI 就绪

---

## 📚 学习资源推荐

### SceneKit 学习路径

```
1. 基础概念（1-2 小时）
   - 场景（Scene）
   - 节点（Node）
   - 几何体（Geometry）
   - 材质（Material）
   - 光照（Light）
   - 相机（Camera）

2. 实践项目（2-3 小时）
   - 创建简单 3D 场景
   - 添加几何体
   - 应用材质和光照
   - 实现旋转动画

3. 性能优化（1 小时）
   - LOD（细节层次）
   - 批量渲染
   - 纹理优化
```

**推荐资源**:
- Apple 官方文档：https://developer.apple.com/documentation/scenekit
- WWDC 2017: Advances in SceneKit
- Ray Wenderlich SceneKit 教程

### Swift Charts 学习路径

```
1. Charts 基础（1 小时）
   - Chart 类型概览
   - 数据绑定
   - Mark 标记

2. 图表类型（2-3 小时）
   - LineMark（折线图）
   - BarMark（柱状图）
   - AreaMark（面积图）
   - PointMark（散点图）

3. 自定义样式（1-2 小时）
   - 坐标轴定制
   - 颜色和样式
   - 图例配置
```

**推荐资源**:
- Apple 官方文档：https://developer.apple.com/documentation/charts
- WWDC 2022: Hello Swift Charts
- Swift Charts 示例代码集

---

## ⚠️ 注意事项

### 性能考虑

1. **3D 渲染性能**
   - 目标：60fps
   - 优化策略：
     - 使用低多边形模型
     - 关闭不必要的特效
     - 限制更新频率
     - 使用 Instruments 监控

2. **图表渲染性能**
   - 数据点限制：< 1000 个点
   - 使用数据采样
   - 异步加载数据

### 真机测试

```
优先测试场景：
1. 3D 模型在真机上的性能
2. 图表滚动流畅度
3. 内存使用情况
4. 电池消耗
```

### 备选方案

```
如果 3D 渲染性能不佳：
- 方案 A：简化模型（球体替代复杂模型）
- 方案 B：使用 2D 图示替代 3D
- 方案 C：降低刷新率到 30fps
```

---

## 🎯 成功标准

### Sprint 2 完成标准

- [ ] 3D 姿态可视化正常工作
- [ ] 至少实现一种统计图表
- [ ] 会话统计卡片完成
- [ ] 性能达标（60fps）
- [ ] 支持暗色模式
- [ ] 代码有完整注释
- [ ] 添加 Preview

### 质量要求

- [ ] 无编译错误和警告
- [ ] 代码通过 SwiftLint 检查
- [ ] 所有新组件有 Preview
- [ ] 更新文档（SPRINT_TRACKER.md）

---

## 📞 遇到问题？

### 调试技巧

1. **3D 场景不显示**
   - 检查场景是否创建
   - 检查相机位置
   - 检查光照设置
   - 使用 SceneKit Scene Editor 调试

2. **图表不显示数据**
   - 打印数据验证
   - 检查数据格式
   - 确认坐标轴范围
   - 查看控制台错误

3. **性能问题**
   - 使用 Instruments Time Profiler
   - 检查 GPU 使用率
   - 分析内存分配
   - 优化渲染循环

### 获取帮助

- 查看项目文档：`Docs/` 目录
- 搜索 Apple 开发者论坛
- Stack Overflow 标签：swiftui, scenekit, swift-charts
- GitHub Issues 搜索类似问题

---

## 🎊 激励自己

你已经完成了第二阶段的 **33%**！

```
Progress: ██████░░░░░░░░░░░░ 33%
```

**继续保持这个节奏，你很快就能完成整个项目！**

接下来的 Sprint 2 会更有趣，因为：
- 🎨 你将创建炫酷的 3D 可视化
- 📊 你将实现漂亮的数据图表
- 🚀 功能将变得更加完整

**加油！让我们开始 Sprint 2 的开发吧！**

---

**文档更新**: 2024-09-30
**下次更新**: Sprint 2 完成时
**当前任务**: 开始学习 SceneKit 和 Swift Charts

---

## 快速命令参考

```bash
# 启动开发
cd ~/my-devs/swift/PostureTracker\ 2
open PostureTracker.xcodeproj  # 或 .xcworkspace

# 编译
Cmd + B

# 运行
Cmd + R

# 清理
Cmd + Shift + K

# 查看文档
open Docs/SPRINT_TRACKER.md
open Docs/SPRINT1_QUICKSTART.md

# Git 提交
git add .
git commit -m "feat: 完成 Sprint 1 核心界面框架"
git push
```

**祝开发顺利！🚀**
