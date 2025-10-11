# PostureTracker 开发指南

> 基于 AirPods 传感器的智能姿态追踪 iOS 应用开发指南
>
> 创建日期：2025-09-28
> 版本：1.0.0

## 📋 目录

1. [项目概述](#项目概述)
2. [已完成工作](#已完成工作)
3. [技术架构](#技术架构)
4. [核心模块说明](#核心模块说明)
5. [开发环境配置](#开发环境配置)
6. [快速开始](#快速开始)
7. [重要提醒](#重要提醒)
8. [开发路线图](#开发路线图)
9. [常见问题](#常见问题)
10. [参考资源](#参考资源)

## 项目概述

PostureTracker 是一个创新的 iOS 应用，利用 AirPods 内置的陀螺仪和加速度计传感器，实时监测用户头部姿态，通过智能音频反馈系统帮助用户改善姿势。

### 核心功能

- 🎯 **实时姿态监测**：通过 AirPods 传感器采集头部运动数据（50Hz 采样率）
- 🔊 **智能音频反馈**：基于姿态偏差的多级别语音指导（中英双语）
- 📊 **数据分析可视化**：3D 姿态展示和统计分析
- ☁️ **云端同步**：Firebase 实现数据备份和多设备同步
- 🎮 **个性化设置**：可调节反馈策略、音量、语速等

### 技术栈

- **开发语言**: Swift 5.9+
- **UI 框架**: SwiftUI
- **架构模式**: MVVM + Combine
- **传感器**: SensorKit / CMHeadphoneMotionManager
- **音频**: AVFoundation
- **云服务**: Firebase (Firestore + Storage)
- **依赖管理**: CocoaPods / SPM

## 已完成工作

### ✅ 第一阶段成果（2024-09-28）

#### 1. 项目基础架构

- [x] 创建标准 iOS 项目目录结构（MVVM 架构）
- [x] 配置文件生成（README、.gitignore、Podfile、Makefile）
- [x] 自动化构建系统（Makefile）
- [x] 项目初始化脚本（setup.sh）

#### 2. 核心数据模型

- [x] **Posture.swift** - 姿态数据模型
    - 欧拉角表示（pitch、yaw、roll）
    - 姿态偏差计算
    - 姿态类型分类
    - 数据质量评分

- [x] **MotionData.swift** - 运动数据模型
    - 三维向量（Vector3D）
    - 四元数（Quaternion）
    - 角速度（AngularVelocity）
    - 运动状态检测

- [x] **Session.swift** - 会话管理模型
    - 训练会话记录
    - 统计分析（准确率、偏差、评分）
    - 表现等级评估
    - 会话摘要生成

#### 3. 服务层实现

- [x] **AirPodsMotionManager.swift** - 传感器数据管理
    - SensorKit/CMHeadphoneMotionManager 封装
    - 实时数据流（Combine Publisher）
    - 数据采集控制（开始、暂停、停止）
    - 校准功能
    - 循环缓冲区

- [x] **AudioFeedbackManager.swift** - 音频反馈系统
    - AVSpeechSynthesizer 语音合成
    - 多级别反馈（温和、适中、严格）
    - 中英双语支持
    - 反馈队列管理
    - 防打扰模式

#### 4. 项目文档

- [x] **README.md** - 项目说明和快速开始
- [x] **ARCHITECTURE.md** - 详细架构设计
- [x] **DEVELOPMENT_GUIDE.md** - 本开发指南

---

### ✅ 第二阶段 Sprint 1 成果（2024-09-30）

#### 1. 应用架构层

- [x] **PostureTrackerApp.swift** - 应用入口和生命周期管理
    - AppState 全局状态管理
    - 场景生命周期处理（active/inactive/background）
    - 后台电量优化（自动降低采样率）
    - 配色方案支持（浅色/暗色/跟随系统）
    - 数据自动保存机制

#### 2. 核心视图层（7个视图文件）

- [x] **ContentView.swift** - 主导航结构
    - TabView 三标签布局（监测/统计/设置）
    - 自定义 TabBar 样式和主题
    - 标签切换动画和状态保持

- [x] **MonitoringView.swift** - 监测页面（核心功能，444行代码）
    - 实时姿态数据显示（俯仰/偏航/翻滚）
    - AirPods 连接状态检测和显示
    - 监测控制（开始/停止/暂停/重置）
    - 会话统计（时长计时/偏差次数/采样率）
    - 偏差可视化指示器（正常/偏差状态）
    - 校准功能入口（占位）
    - 使用提示卡片
    - 触觉反馈集成

- [x] **StatisticsView.swift** - 统计页面（占位，155行代码）
    - 时间范围选择器（今天/本周/本月）
    - 功能预告和规划展示
    - 即将推出功能列表

- [x] **SettingsView.swift** - 设置页面（占位，343行代码）
    - 完整设置分组结构
    - 监测设置项占位
    - 音频反馈配置占位
    - 数据和隐私设置占位
    - 外观设置占位
    - 关于页面集成
    - 版本信息显示

#### 3. 可复用组件库（3个组件）

- [x] **StatusCard.swift** - 状态卡片组件（182行，4个Preview）
    - AirPods 连接状态展示
    - 设备信息显示
    - 三种状态模式（未连接/已连接/监测中）
    - 响应式布局和暗色模式支持

- [x] **ConnectionIndicator.swift** - 连接指示器（148行，5个Preview）
    - 三色状态指示（红/橙/绿）
    - 呼吸灯动画效果
    - 可自定义大小
    - 状态文本标签

- [x] **ActionButton.swift** - 主操作按钮（261行，5个Preview）
    - 主要/次要样式支持
    - 禁用状态处理
    - 按压缩放动画（0.98倍）
    - 触觉反馈集成（Medium/Light）
    - 自适应阴影效果

#### 4. 完整文档体系（6个文档）

- [x] **NEXT_STEPS.md** - 下一步行动指南（553行）
- [x] **PROJECT_STATUS.md** - 项目状态快速概览
- [x] **Docs/SPRINT_TRACKER.md** - Sprint 详细进度跟踪（287行）
- [x] **Docs/SPRINT1_QUICKSTART.md** - 快速开始和测试指南（485行）
- [x] **Docs/SPRINT1_SUMMARY.md** - Sprint 1 完成总结报告（462行）
- [x] **Docs/PROJECT_SETUP_CHECKLIST.md** - Xcode 项目配置检查清单（429行）

#### 5. Sprint 1 成果统计

- **视图文件**: 8 个
- **可复用组件**: 3 个
- **总代码行数**: 1,830 行
- **注释行数**: 440 行（注释覆盖率 24%）
- **Preview 数量**: 22 个
- **文档文件**: 6 个（约 2,716 行文档）

#### 6. 技术特性

- [x] MVVM 架构基础实现
- [x] Combine 响应式数据流
- [x] 组件化设计模式
- [x] 全面暗色模式支持
- [x] 触觉反馈系统
- [x] 流畅动画效果（60fps 目标）
- [x] 响应式布局设计
- [x] 后台电量优化策略

## 技术架构

### 架构模式：MVVM + Combine

```
┌──────────────────────────────────────────┐
│                  Views                    │  ← SwiftUI 视图层
├──────────────────────────────────────────┤
│               ViewModels                  │  ← 视图模型层 (业务逻辑)
├──────────────────────────────────────────┤
│                Services                   │  ← 服务层 (核心功能)
├──────────────────────────────────────────┤
│                 Models                    │  ← 数据模型层
├──────────────────────────────────────────┤
│            Utils & Extensions             │  ← 工具层
└──────────────────────────────────────────┘
```

### 数据流设计

```swift
// 单向数据流
User Action → View → ViewModel → Service → Model
                ↑                              ↓
                └──────── Update ←─────────────┘

// Combine 响应式流
AirPodsMotionManager.motionDataPublisher
    .map(DataProcessor.process)         // 数据处理
    .filter { $0.quality > 0.8 }       // 质量过滤
    .sink { motionData in               // 更新UI
        updateView(with: motionData)
    }
```

### 目录结构

```
PostureTracker/
├── PostureTracker/
│   ├── App/                    # 应用入口和生命周期
│   ├── Models/                  # 数据模型层 ✅
│   │   ├── Posture.swift
│   │   ├── MotionData.swift
│   │   └── Session.swift
│   ├── ViewModels/              # 视图模型层 🚧
│   ├── Views/                   # SwiftUI 视图层 🚧
│   │   └── Components/          # 可重用组件
│   ├── Services/                # 业务服务层 ✅
│   │   ├── AirPodsMotionManager.swift
│   │   └── AudioFeedbackManager.swift
│   ├── Utils/                   # 工具类 🚧
│   │   └── Extensions/          # Swift 扩展
│   ├── Resources/               # 资源文件
│   └── Configuration/           # 配置文件
├── PostureTrackerTests/         # 单元测试和UI测试 🚧
├── Docs/                        # 项目文档 ✅
│   └── ARCHITECTURE.md
├── README.md                    # 项目说明 ✅
├── DEVELOPMENT_GUIDE.md         # 开发指南 ✅
├── Makefile                     # 构建脚本 ✅
├── Podfile                      # 依赖配置 ✅
└── setup.sh                     # 初始化脚本 ✅

图例: ✅ 已完成  🚧 待开发
```

## 核心模块说明

### 1. 姿态数据处理（Posture.swift）

```swift
// 姿态表示
struct Posture {
    let pitch: Double  // 俯仰角 [-90, 90]
    let yaw: Double    // 偏航角 [-180, 180]
    let roll: Double   // 翻滚角 [-180, 180]
}

// 使用示例
let currentPosture = Posture(pitch: -10, yaw: 5, roll: 0)
let deviation = currentPosture.deviation(from: .standardSitting)
if deviation.exceedsThreshold(15.0) {
    // 触发音频反馈
}
```

### 2. 传感器数据管理（AirPodsMotionManager）

```swift
// 单例模式访问
let motionManager = AirPodsMotionManager.shared

// 订阅数据流
motionManager.motionDataPublisher
    .sink { motionData in
        // 处理运动数据
    }
    .store(in: &cancellables)

// 控制数据采集
motionManager.startTracking()
motionManager.pauseTracking()
motionManager.stopTracking()

// 校准
motionManager.startCalibration(duration: 5.0)
```

### 3. 音频反馈系统（AudioFeedbackManager）

```swift
// 配置反馈策略
AudioFeedbackManager.shared.feedbackStrategy = .adaptive
AudioFeedbackManager.shared.language = .chinese

// 提供姿态反馈
AudioFeedbackManager.shared.provideFeedback(
    for: currentPosture,
    target: targetPosture
)

// 自定义语音
AudioFeedbackManager.shared.speak("请保持正确姿势", priority: .high)
```

## 开发环境配置

### 系统要求

- macOS 13.0+ (Ventura) 或更高版本
- Xcode 15.0+
- iOS 14.0+ (部署目标)

### 硬件要求

- AirPods Pro 或 AirPods (第3代) - 用于传感器数据
- iPhone (iOS 14+) - 测试设备
- Apple Developer 账号 - 用于真机调试

### 依赖工具

```bash
# 1. 安装 Homebrew（如未安装）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. 安装 CocoaPods
sudo gem install cocoapods

# 3. 安装 SwiftLint（可选）
brew install swiftlint

# 4. 安装 Firebase CLI（可选）
npm install -g firebase-tools

# 5. 安装 XcodeGen（可选）
brew install xcodegen
```

## 快速开始

### 1. 克隆或创建项目

```bash
cd ~/my-devs/swift/PostureTracker
```

### 2. 运行初始化脚本

```bash
chmod +x setup.sh
./setup.sh
```

### 3. 安装依赖

```bash
make install
# 或
pod install --repo-update
```

### 4. 配置项目

- 打开 `PostureTracker.xcworkspace`
- 配置开发团队和证书
- 添加 Firebase 配置文件 `GoogleService-Info.plist`

### 5. 构建运行

```bash
make build  # 构建项目
make run    # 在模拟器运行
make test   # 运行测试
```

### Makefile 常用命令

```bash
make help          # 显示所有可用命令
make clean         # 清理构建产物
make build         # 构建 Debug 版本
make build-release # 构建 Release 版本
make test          # 运行单元测试
make ui-test       # 运行 UI 测试
make coverage      # 生成测试覆盖率报告
make lint          # 代码检查
make format        # 代码格式化
make reset         # 重置项目
```

## ⚠️ 重要提醒

### 1. SensorKit 权限申请（关键挑战）

#### 问题说明

- SensorKit **仅限研究用途**，不能用于商业应用
- 需要向 Apple 提交专门的研究申请
- 审批周期约 **3-5 个月**
- 必须是学术研究机构或医疗研究组织

#### 申请要求

1. **研究项目文档**
    - 研究目标和科学价值
    - 数据使用计划
    - 伦理审查批准

2. **机构资质**
    - 研究机构认证
    - IRB 批准文件
    - 研究负责人资历

3. **技术方案**
    - 架构设计
    - 隐私保护措施
    - 数据安全方案

#### 备选方案

```swift
// 使用 CMHeadphoneMotionManager（iOS 14+）
import CoreMotion

let headphoneMotionManager = CMHeadphoneMotionManager()
if headphoneMotionManager.isDeviceMotionAvailable {
    headphoneMotionManager.startDeviceMotionUpdates(to: .main) { motion, error in
        // 处理运动数据
    }
}
```

### 2. 权限配置

在 `Info.plist` 中添加：

```xml
<!-- 运动数据权限 -->
<key>NSMotionUsageDescription</key>
<string>此应用需要访问运动传感器以追踪您的头部姿态</string>

<!-- SensorKit 权限（需特殊批准）-->
<key>com.apple.developer.sensorkit.reader</key>
<true/>

<!-- 音频权限 -->
<key>NSSpeechRecognitionUsageDescription</key>
<string>此应用需要语音识别权限以提供语音反馈</string>
```

### 3. AirPods 兼容性

#### 支持的设备

- ✅ AirPods Pro (第1代、第2代)
- ✅ AirPods (第3代)
- ❌ AirPods (第1代、第2代) - 无运动传感器
- ✅ AirPods Max

#### 检测代码

```swift
// 检查 AirPods 连接状态
CMHeadphoneMotionManager.authorizationStatus() == .authorized
motionManager.isDeviceMotionAvailable
```

### 4. 性能优化建议

#### 采样率设置

```swift
// 推荐采样率
let optimalSampleRate = 50.0  // Hz
// 后台模式降低到 10Hz 以节省电量
let backgroundSampleRate = 10.0
```

#### 内存管理

- 使用循环缓冲区，限制 100 个数据点
- 定期清理过期会话数据
- 使用 `weak self` 避免循环引用

### 5. 隐私和安全

#### 数据保护

- 本地数据使用 Core Data 加密存储
- 敏感信息存储在 Keychain
- 网络传输使用 HTTPS
- 实现用户数据删除功能

#### 合规要求

- 遵循 GDPR 和 CCPA 规范
- 提供清晰的隐私政策
- 用户数据匿名化处理

## 开发路线图

### 第二阶段：视图层开发（进行中 - 33% 完成）

#### Sprint 1: 核心界面框架 ✅ 已完成（2024-09-30）

- [x] 创建 SwiftUI 主界面（TabView 导航）
- [x] 实现监测页面核心功能
- [x] 开发控制面板（开始/停止/暂停/重置）
- [x] 设置界面框架（占位）
- [x] 基础组件库（StatusCard/ConnectionIndicator/ActionButton）
- [x] 完整文档体系

#### Sprint 2: 数据可视化界面 ⏳ 待开始（预计 4-5 天）

- [ ] 实现 3D 姿态可视化（SceneKit）
- [ ] 开发统计图表（Swift Charts - 折线图/柱状图）
- [ ] 创建会话统计卡片
- [ ] 图表交互和数据筛选

#### Sprint 3: 设置和配置界面 ⏳ 待开始（预计 3-4 天）

- [ ] 完善设置页面功能实现
- [ ] 监测参数配置（采样率/灵敏度/延迟）
- [ ] 音频反馈配置（音量/语音/勿扰模式）
- [ ] 权限管理界面
- [ ] 校准向导完整实现

### 第三阶段：ViewModel 层（待完成 - 预计 2 周）

#### Sprint 4: 核心 ViewModel ⏳ 待开始（预计 5-6 天）

- [ ] MonitoringViewModel - 监测页面数据处理
- [ ] 数据流绑定和转换（Combine Pipeline）
- [ ] 生命周期管理（onAppear/onDisappear）
- [ ] 音频反馈集成和触发逻辑

#### Sprint 5: 统计和设置 ViewModel ⏳ 待开始（预计 4-5 天）

- [ ] StatisticsViewModel - 统计数据聚合
- [ ] SettingsViewModel - 设置项管理
- [ ] PermissionsViewModel - 权限状态管理
- [ ] UserDefaults 持久化集成

#### Sprint 6: 业务逻辑整合 ⏳ 待开始（预计 3-4 天）

- [ ] 音频反馈业务逻辑
- [ ] 数据持久化集成（Core Data）
- [ ] 后台保存任务
- [ ] 单元测试（目标覆盖率 > 80%）

### 第四阶段：数据处理优化（待完成 - 预计 1.5 周）

#### Sprint 7: 算法优化 ⏳ 待开始（预计 4-5 天）

- [ ] 实现卡尔曼滤波算法
- [ ] 传感器数据平滑处理
- [ ] 自适应阈值算法
- [ ] 性能优化（目标 CPU < 15%）

#### Sprint 8: 数据存储优化 ⏳ 待开始（预计 3-4 天）

- [ ] Core Data 模型完善
- [ ] 数据导出功能（CSV/JSON）
- [ ] 数据清理策略
- [ ] 查询性能优化

### 第五阶段：云端集成（待完成 - 预计 2 周）

#### Sprint 9: Firebase 基础集成 ⏳ 待开始（预计 5-6 天）

- [ ] Firebase SDK 集成（SPM）
- [ ] 用户认证（匿名/Apple Sign In）
- [ ] 数据同步服务实现
- [ ] Firestore 安全规则配置

#### Sprint 10: 云端功能完善 ⏳ 待开始（预计 4-5 天）

- [ ] 数据下载和恢复
- [ ] 离线队列机制
- [ ] Firebase Storage 集成
- [ ] 推送通知（APNs/FCM）

### 第六阶段：测试和优化（待完成 - 预计 1.5 周）

#### Sprint 11: 全面测试 ⏳ 待开始（预计 5-6 天）

- [ ] 单元测试补全（目标覆盖率 > 80%）
- [ ] UI 测试（关键流程）
- [ ] 集成测试（完整会话）
- [ ] 真机测试（AirPods 连接）

#### Sprint 12: 性能和体验优化 ⏳ 待开始（预计 3-4 天）

- [ ] Instruments 性能分析
- [ ] 内存泄漏检测
- [ ] 用户体验优化
- [ ] 无障碍支持

### 第七阶段：发布准备（待完成 - 预计 1 周）

#### Sprint 13: App Store 准备 ⏳ 待开始（预计 5-7 天）

- [ ] 应用元数据（描述/截图/视频）
- [ ] 隐私政策和用户协议
- [ ] 构建和签名配置
- [ ] TestFlight 内部测试
- [ ] App Store 提交审核

---

## 📊 整体项目进度

**当前状态**: 第二阶段 Sprint 1 完成
**完成进度**: 约 20%
**下一里程碑**: Sprint 2 - 数据可视化界面

### 进度概览

```
第一阶段: ████████████████████ 100% ✅
第二阶段: ██████░░░░░░░░░░░░░░  33% ⏳ (Sprint 1/3 完成)
第三阶段: ░░░░░░░░░░░░░░░░░░░░   0% ⏳
第四阶段: ░░░░░░░░░░░░░░░░░░░░   0% ⏳
第五阶段: ░░░░░░░░░░░░░░░░░░░░   0% ⏳
第六阶段: ░░░░░░░░░░░░░░░░░░░░   0% ⏳
第七阶段: ░░░░░░░░░░░░░░░░░░░░   0% ⏳
```

### 快速导航

- 📋 查看详细进度: [Docs/SPRINT_TRACKER.md](Docs/SPRINT_TRACKER.md)
- 🚀 下一步行动: [NEXT_STEPS.md](NEXT_STEPS.md)
- 📊 项目状态: [PROJECT_STATUS.md](PROJECT_STATUS.md)
- ⚡ 快速开始: [Docs/SPRINT1_QUICKSTART.md](Docs/SPRINT1_QUICKSTART.md)

## 常见问题

### Q1: 为什么选择 MVVM 架构？

**A**: MVVM 配合 SwiftUI 和 Combine 可以实现：

- 清晰的关注点分离
- 响应式数据绑定
- 更好的可测试性
- 代码重用性高

### Q2: 如何处理 AirPods 断开连接？

**A**: 实现重连机制：

```swift
// 监听连接状态
NotificationCenter.default.addObserver(
    self,
    selector: #selector(handleDisconnection),
    name: .CMHeadphoneMotionManagerDidDisconnect,
    object: nil
)
```

### Q3: 数据采样率如何选择？

**A**: 根据场景动态调整：

- 活跃模式：50Hz（平衡精度和功耗）
- 后台模式：10Hz（节省电量）
- 校准模式：100Hz（高精度）

### Q4: 如何确保音频反馈不会太频繁？

**A**: 实现了多重控制：

- 最小反馈间隔：3秒
- 偏差阈值控制
- 自适应策略
- 防打扰模式

### Q5: 本地数据存储方案？

**A**: 分层存储策略：

- 实时数据：内存缓冲区
- 会话数据：Core Data
- 用户配置：UserDefaults
- 敏感信息：Keychain

## 参考资源

### Apple 官方文档

- [SensorKit Framework](https://developer.apple.com/documentation/sensorkit)
- [Core Motion](https://developer.apple.com/documentation/coremotion)
- [CMHeadphoneMotionManager](https://developer.apple.com/documentation/coremotion/cmheadphonemotionmanager)
- [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- [Combine Framework](https://developer.apple.com/documentation/combine)

### 第三方资源

- [Firebase iOS SDK](https://firebase.google.com/docs/ios/setup)
- [Charts Library](https://github.com/danielgindi/Charts)
- [SwiftLint Rules](https://realm.github.io/SwiftLint/rule-directory.html)

### 研究论文

- Head Pose Estimation Using IMU Sensors
- Real-time Posture Detection and Correction Systems
- Audio Feedback in Motion Training Applications

## 项目贡献

### 代码规范

- 遵循 Swift API Design Guidelines
- 使用 SwiftLint 进行代码检查
- 所有注释使用中文
- 保持单一职责原则

### 提交规范

```bash
feat: 新功能
fix: 修复Bug
docs: 文档更新
style: 代码格式调整
refactor: 代码重构
test: 测试相关
chore: 构建或辅助工具变动
```

### 分支管理

- `main`: 生产版本
- `develop`: 开发版本
- `feature/*`: 功能分支
- `bugfix/*`: 修复分支
- `release/*`: 发布分支

## 技术支持

如有问题或建议，可以通过以下方式联系：

- 项目 Issue: [GitHub Issues]
- 邮箱: your.email@example.com
- 文档: 查看 `Docs/` 目录

## 许可证

本项目采用 MIT 许可证。详见 LICENSE 文件。

---

## 附录：关键代码片段

### A. 姿态偏差检测

```swift
// 检测姿态偏差并触发反馈
func checkPostureDeviation(_ current: Posture, target: Posture) {
    let deviation = current.deviation(from: target)

    if deviation.magnitude > 15.0 {
        // 偏差过大，触发音频反馈
        AudioFeedbackManager.shared.provideFeedback(
            for: current,
            target: target
        )
    }
}
```

### B. 数据流处理

```swift
// Combine 数据流处理链
motionManager.motionDataPublisher
    .throttle(for: .seconds(0.1), scheduler: RunLoop.main, latest: true)
    .map { data in
        // 数据处理
        return ProcessedData(from: data)
    }
    .filter { $0.quality > 0.8 }
    .sink { processedData in
        // 更新 UI
        self.updateView(with: processedData)
    }
    .store(in: &cancellables)
```

### C. 会话统计

```swift
// 计算会话统计信息
func calculateSessionStatistics(_ session: Session) -> SessionStatistics {
    let accuracy = session.motionDataPoints
        .filter { $0.posture.isWithinTolerance(of: session.targetPosture) }
        .count / session.motionDataPoints.count

    return SessionStatistics(
        duration: session.duration,
        accuracy: Double(accuracy),
        score: Int(accuracy * 100)
    )
}
```

---

**文档版本**: 1.0.0
**最后更新**: 2024-09-28
**作者**: AI Assistant
**项目状态**: 🚧 开发中

> 本文档将持续更新，请定期查看最新版本。
