# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

---

## 项目概述

**PostureTracker** 是一个基于 AirPods 运动传感器的 iOS 姿态追踪应用，使用 SwiftUI 和 MVVM + Combine 架构。

### 核心技术栈
- **语言**: Swift 5.9+
- **UI**: SwiftUI (iOS 14.0+)
- **架构**: MVVM + Combine (响应式数据流)
- **传感器**: CoreMotion (CMHeadphoneMotionManager)
- **依赖管理**: CocoaPods
- **代码规范**: SwiftLint

### 当前开发状态
- **阶段**: Sprint 3 (第二阶段 - 视图层开发)
- **完成度**: ~50% 整体进度
- **最后更新**: 2024-10-03

---

## 常用构建和开发命令

### 依赖管理
```bash
# 安装项目依赖 (首次运行或 Podfile 变更后)
make install
# 或
pod install --repo-update

# 重置项目 (清理并重新安装依赖)
make reset
```

### 构建和运行
```bash
# 在模拟器中构建和运行应用
make build && make run

# 仅构建 Debug 版本
make build

# 构建 Release 版本
make build-release

# 清理构建产物
make clean
```

### 测试
```bash
# 运行单元测试
make test

# 运行 UI 测试
make ui-test

# 生成测试覆盖率报告
make coverage
```

### 代码质量
```bash
# 运行 SwiftLint 代码检查
make lint

# 自动修复代码格式问题
make format
```

### 项目导航
```bash
# 查看当前 Sprint 状态
make sprint-status

# 打开项目文档
make docs-open

# 查看下一步计划
make docs-next
```

### 环境检查
```bash
# 检查开发环境配置
make check-env
```

---

## 架构和代码结构

### MVVM + Combine 架构

项目采用严格的 MVVM 架构，配合 Combine 实现响应式数据流：

```
User Action → View → ViewModel → Service → Model
                ↑                              ↓
                └──────── Update ←─────────────┘
```

### 目录结构
```
PostureTracker/
├── App/                          # 应用入口和生命周期管理
│   └── PostureTrackerApp.swift  # @main 入口，AppState 全局状态
│
├── Models/                        # 数据模型层
│   ├── Posture.swift              # 姿态数据 (欧拉角: pitch/yaw/roll)
│   ├── MotionData.swift           # 运动传感器数据
│   └── Session.swift              # 训练会话记录
│
├── Services/                      # 业务服务层 (核心逻辑)
│   ├── AirPodsMotionManager.swift # 传感器数据管理 (单例)
│   └── AudioFeedbackManager.swift # 音频反馈系统 (单例)
│
├── Views/                         # SwiftUI 视图层
│   ├── ContentView.swift          # 主导航 (TabView: 监测/统计/设置)
│   ├── MonitoringView.swift       # 实时监测页面 (核心功能)
│   ├── StatisticsView.swift       # 统计分析页面
│   ├── SettingsView.swift         # 设置配置页面
│   ├── PermissionsView.swift      # 权限管理页面
│   ├── PrivacyPolicyView.swift    # 隐私政策页面
│   └── Components/                # 可复用组件
│       ├── StatusCard.swift           # 状态卡片
│       ├── ConnectionIndicator.swift  # 连接指示器
│       ├── ActionButton.swift         # 主操作按钮
│       ├── PostureVisualization3D.swift  # 3D 姿态可视化
│       └── SessionSummaryCard.swift      # 会话摘要卡片
│
├── Managers/                      # 管理器层
│   └── SettingsManager.swift      # 设置持久化管理 (UserDefaults)
│
└── Utils/                         # 工具类
    ├── FileExportManager.swift    # 文件导出管理
    └── MockDataGenerator.swift    # 测试数据生成器
```

### 关键架构模式

#### 1. 单例服务管理
传感器和音频管理器使用单例模式，全局访问：
```swift
AirPodsMotionManager.shared.startTracking()
AudioFeedbackManager.shared.provideFeedback(for: posture, target: targetPosture)
```

#### 2. Combine 数据流
使用 Publishers 和 Subscribers 实现响应式更新：
```swift
// 在 AirPodsMotionManager 中
public let motionDataPublisher = PassthroughSubject<MotionData, Never>()
public let postureChangePublisher = PassthroughSubject<Posture, Never>()

// 在 ViewModel 中订阅
motionManager.motionDataPublisher
    .sink { motionData in
        // 处理数据
    }
    .store(in: &cancellables)
```

#### 3. 应用生命周期管理
`AppState` 类管理全局状态，响应场景生命周期变化：
- **前台激活**: 恢复传感器采样率 (50Hz)
- **后台切换**: 降低采样率 (25Hz) 节省电量
- **数据保存**: 自动触发持久化逻辑

#### 4. SwiftUI 组件化
所有 UI 组件独立且可复用，使用 Preview 支持快速开发

---

## 关键技术细节

### 1. AirPods 传感器数据采集

**使用框架**: `CMHeadphoneMotionManager` (CoreMotion)

**采样率配置**:
- 前台活跃: 50Hz (高精度监测)
- 后台模式: 25Hz (节省电量)
- 校准模式: 100Hz (高精度校准)

**数据处理流程**:
```swift
// 启动追踪
motionManager.deviceMotionUpdateInterval = 1.0 / 50.0  // 50Hz
motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
    // 处理 CMDeviceMotion 数据
    let posture = Posture(from: motion.attitude)
    postureChangePublisher.send(posture)
}
```

**循环缓冲区**: 限制 100 个数据点，防止内存溢出

### 2. 姿态数据模型

**欧拉角表示** (Posture.swift):
- `pitch`: 俯仰角 [-90°, 90°] (抬头为正，低头为负)
- `yaw`: 偏航角 [-180°, 180°] (右转为正，左转为负)
- `roll`: 翻滚角 [-180°, 180°] (右倾为正，左倾为负)

**偏差计算**:
```swift
let deviation = currentPosture.deviation(from: targetPosture)
if deviation.magnitude > 15.0 {
    // 触发音频反馈
}
```

**标准姿态**:
- 零姿态: `Posture.zero` (pitch: 0, yaw: 0, roll: 0)
- 标准坐姿: `Posture.standardSitting` (pitch: -5, yaw: 0, roll: 0)

### 3. 音频反馈系统

**反馈策略**:
- 温和模式 (mild): 3 秒最小间隔
- 适中模式 (moderate): 2 秒最小间隔
- 严格模式 (strict): 1 秒最小间隔

**语音合成**: 使用 `AVSpeechSynthesizer` 提供中英双语反馈

**勿扰模式**: 支持自定义时间段禁用音频反馈

### 4. 设置持久化

**存储方案**: `UserDefaults` (SettingsManager)

**配置项**:
- 监测参数: 采样率、灵敏度、提示延迟
- 音频配置: 音量、语速、语音类型、勿扰模式
- 外观设置: 主题模式、字体大小

### 5. 性能优化

**目标指标**:
- UI 帧率: 60fps
- CPU 使用率: < 15%
- 电量消耗: < 5%/小时

**优化策略**:
- 后台自动降低采样率
- 循环缓冲区限制内存使用
- `weak self` 避免循环引用
- SwiftUI 视图优化 (避免过度重绘)

---

## 开发工作流

### 新功能开发流程
1. 查看 `NEXT_STEPS.md` 了解当前 Sprint 任务
2. 在 Xcode 中创建新文件或修改现有文件
3. 遵循 MVVM 架构分层原则
4. 使用 SwiftUI Preview 进行快速迭代
5. 添加单元测试 (目标覆盖率 > 80%)
6. 运行 `make lint` 检查代码规范
7. 提交符合规范的 Git commit

### Git 提交规范
```bash
类型(范围): 简洁描述

详细说明 (可选)

关联: #issue-number
```

**提交类型**:
- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建/工具变动

### 测试策略
- **单元测试**: 核心业务逻辑 (Services, Models)
- **集成测试**: 数据流和服务交互
- **UI 测试**: 关键用户流程 (Sprint 6)
- **真机测试**: AirPods 连接和传感器功能

---

## 重要项目文件

### 核心文档 (优先阅读)
- `README.md` - 项目说明和快速开始
- `NEXT_STEPS.md` - 下一步行动指南 (当前 Sprint 详情) ⭐
- `PROJECT_STATUS.md` - 项目状态快速概览
- `DEVELOPMENT_GUIDE.md` - 完整开发指南 (23KB)

### Sprint 文档
- `Docs/SPRINT_TRACKER.md` - Sprint 详细进度跟踪
- `Docs/SPRINT1_SUMMARY.md` - Sprint 1 完成总结
- `Docs/SPRINT1_QUICKSTART.md` - 快速开始和测试指南
- `Docs/PROJECT_SETUP_CHECKLIST.md` - Xcode 项目配置清单

### 配置文件
- `Podfile` - CocoaPods 依赖定义
- `Package.swift` - Swift Package Manager 配置
- `.swiftlint.yml` - SwiftLint 规则配置
- `Makefile` - 自动化构建脚本

---

## 注意事项

### SensorKit vs CMHeadphoneMotionManager
- ✅ **当前方案**: `CMHeadphoneMotionManager` (无需特殊权限，立即可用)
- ⏳ **备选方案**: `SensorKit` (需 Apple 批准，仅研究用途，审批周期 3-5 个月)

### 权限配置
项目需要在 `Info.plist` 中配置以下权限：
```xml
<key>NSMotionUsageDescription</key>
<string>需要访问运动数据来监测头部姿态</string>
```

### 设备兼容性
- ✅ 支持: AirPods Pro (1st/2nd gen), AirPods (3rd gen), AirPods Max
- ❌ 不支持: AirPods (1st/2nd gen) - 无运动传感器

### Firebase 集成
Firebase 配置在第五阶段 (Sprint 9-10) 实现，当前阶段可跳过。

---

## 快速参考

### 常用类和方法
```swift
// 传感器管理
AirPodsMotionManager.shared.startTracking()
AirPodsMotionManager.shared.stopTracking()
AirPodsMotionManager.shared.setSampleRate(50.0)

// 音频反馈
AudioFeedbackManager.shared.provideFeedback(for: posture, target: targetPosture)
AudioFeedbackManager.shared.speak("提示文本", priority: .high)

// 设置管理
SettingsManager.shared.monitoringSettings  // 监测设置
SettingsManager.shared.audioSettings       // 音频设置
SettingsManager.shared.saveSettings()      // 保存设置

// 姿态计算
let deviation = currentPosture.deviation(from: targetPosture)
let isGood = posture.isWithinTolerance(of: target, tolerance: 10.0)
```

### 快速问题排查
- **构建失败**: 运行 `make clean && make install && make build`
- **CocoaPods 问题**: 运行 `make reset`
- **代码规范错误**: 运行 `make format` 自动修复
- **查看 Sprint 进度**: 运行 `make sprint-status`

---

**最后更新**: 2024-10-03
**项目版本**: Sprint 3 (50% 完成)
