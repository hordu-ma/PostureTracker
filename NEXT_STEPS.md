# PostureTracker 下一步行动指南

## 🎉 Sprint 2 完成！

恭喜！您已经成功完成了 **Sprint 2: 数据可视化界面开发**。

**当前进度**: 第二阶段 67% 完成 (2/3 Sprint)

---

## 📋 立即行动清单

### 第一步：在 Xcode 中测试 Sprint 2 成果

```bash
# 1. 在 Xcode 中打开项目
# 双击 PostureTracker.xcworkspace 或 PostureTracker.xcodeproj

# 2. 编译项目
# Cmd + B (Build)

# 3. 运行应用
# Cmd + R (Run)

# 4. 测试新功能
✅ 查看统计页面的折线图和柱状图
✅ 在监测页面查看 3D 姿态可视化（模拟器中）
✅ 切换时间范围（今天/本周/本月）
✅ 查看会话摘要列表
✅ 切换到暗色模式查看效果
```

### 第二步：验证 Sprint 2 功能

```bash
# 在模拟器中测试
✅ 统计页面显示图表正常
✅ 监测页面显示 3D 头部模型
✅ 角度数据和 3D 模型同步（使用模拟数据）
✅ 所有 Preview 能正常工作
```

### 第三步：准备 Sprint 3 开发环境

```bash
# 1. 查看当前设置页面
# - 所有设置项目前都是占位状态
# - 需要实现实际功能

# 2. 学习 UserDefaults 数据存储
# - Apple 官方文档：UserDefaults
# - SwiftUI @AppStorage 属性包装器

# 3. 准备音频测试环境
# - AVFoundation 基础知识
# - AVSpeechSynthesizer 使用
```

---

## 🚀 Sprint 3 详细开发计划

### 目标：设置和配置界面（预计 3-4 天）

### Task 3.1: 设置页面功能实现（2-3 天）

**优先级**: ⭐⭐⭐ 最高

#### 步骤 1: 监测参数配置（2-3 小时）

```swift
// 在 SettingsView.swift 中替换监测设置占位内容

Section("监测设置") {
    // 采样率选择器
    Picker("采样率", selection: $sampleRate) {
        Text("25 Hz").tag(25.0)
        Text("50 Hz").tag(50.0)
        Text("100 Hz").tag(100.0)
    }
    .pickerStyle(.segmented)

    // 灵敏度调节
    VStack(alignment: .leading) {
        Text("灵敏度: \(Int(sensitivity))°")
        Slider(value: $sensitivity, in: 5...30, step: 1)
    }

    // 提示延迟
    VStack(alignment: .leading) {
        Text("提示延迟: \(Int(alertDelay))秒")
        Slider(value: $alertDelay, in: 1...10, step: 1)
    }
}
```

**验收标准**:

- [ ] 设置能正常保存到 UserDefaults
- [ ] 重启应用后设置保持
- [ ] 滑块和选择器交互正常

#### 步骤 2: 音频反馈配置（2-3 小时）

```swift
Section("音频反馈") {
    // 音量调节
    VStack(alignment: .leading) {
        Text("提示音音量: \(Int(alertVolume * 100))%")
        Slider(value: $alertVolume, in: 0...1, step: 0.1)
    }

    // 语音开关
    Toggle("语音提示", isOn: $speechEnabled)

    if speechEnabled {
        // 语音选择
        Picker("语音类型", selection: $selectedVoice) {
            Text("男声").tag("male")
            Text("女声").tag("female")
        }
        .pickerStyle(.segmented)

        // 语音预览
        Button("试听语音") {
            previewVoice()
        }
    }

    // 勿扰模式
    Toggle("勿扰模式", isOn: $doNotDisturbEnabled)

    if doNotDisturbEnabled {
        DatePicker("开始时间", selection: $dndStartTime, displayedComponents: .hourAndMinute)
        DatePicker("结束时间", selection: $dndEndTime, displayedComponents: .hourAndMinute)
    }
}
```

**验收标准**:

- [ ] 语音预览功能工作
- [ ] 勿扰模式时间设置正常
- [ ] 音量调节立即生效

#### 步骤 3: 数据和隐私设置（1-2 小时）

```swift
Section("数据和隐私") {
    // 数据导出
    Button("导出训练数据") {
        exportTrainingData()
    }

    // 数据清理
    Button("清除所有数据", role: .destructive) {
        showingClearDataAlert = true
    }
    .confirmationDialog("确认清除", isPresented: $showingClearDataAlert) {
        Button("清除所有数据", role: .destructive) {
            clearAllData()
        }
    }

    // 隐私说明
    NavigationLink("隐私政策") {
        PrivacyPolicyView()
    }
}
```

**验收标准**:

- [ ] 数据导出功能准备就绪
- [ ] 清除数据确认正常
- [ ] 隐私政策页面可访问

---

### Task 3.2: 权限管理界面（1-2 天）

**优先级**: ⭐⭐ 中等

#### 创建 PermissionsView 组件（4-5 小时）

```swift
// 创建文件：PostureTracker/Views/PermissionsView.swift

struct PermissionsView: View {
    @State private var motionAuthStatus: CMAuthorizationStatus = .notDetermined
    @State private var microphoneAuthStatus: AVAudioSession.RecordPermission = .undetermined

    var body: some View {
        List {
            Section("所需权限") {
                PermissionRow(
                    icon: "gyroscope",
                    title: "运动传感器",
                    description: "监测 AirPods 头部运动",
                    status: motionAuthStatus
                )

                PermissionRow(
                    icon: "mic",
                    title: "麦克风",
                    description: "音频反馈功能",
                    status: microphoneAuthStatus
                )
            }

            Section("操作") {
                Button("重新检查权限") {
                    checkPermissions()
                }

                Button("打开系统设置") {
                    openSystemSettings()
                }
            }
        }
        .navigationTitle("权限管理")
        .onAppear {
            checkPermissions()
        }
    }
}
```

**验收标准**:

- [ ] 权限状态实时更新
- [ ] “打开系统设置”正常跳转
- [ ] 权限描述清晰明确

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
