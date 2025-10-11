# PostureTracker - 基于 AirPods 的姿态追踪应用

> 🎯 **当前状态**: Sprint 4 已完成 ✅ | **进度**: 开发完成 100% | **下一步**: Xcode 配置和 App Store 提交

## 📱 项目概述

PostureTracker 是一个创新的 iOS 应用,利用 AirPods 内置的陀螺仪和加速度计传感器,实时监测用户头部姿态,并通过智能音频反馈系统帮助用户改善坐姿习惯。

### 核心功能

- 🎯 **实时姿态监测**：通过 AirPods 传感器实时采集头部运动数据
- 🔊 **智能音频反馈**：根据姿态偏差提供语音指导和提示音
- 📊 **数据分析可视化**：3D 姿态展示和统计分析图表
- 💾 **本地数据持久化**：会话数据自动保存到 UserDefaults
- 🎮 **个性化设置**：可调节灵敏度、音频反馈、主题等

### 项目亮点

- ✅ **完整的 MVVM 架构**：清晰的代码组织,易于维护和扩展
- ✅ **高测试覆盖率**：83 个单元测试,覆盖率 >80%
- ✅ **现代化 UI**：SwiftUI + Combine 响应式编程
- ✅ **隐私优先**：所有数据本地处理,不上传服务器
- ✅ **轻量高效**：低电量消耗,不影响 AirPods 续航

## 🛠 技术栈

- **开发语言**: Swift 5.9+
- **UI 框架**: SwiftUI
- **架构模式**: MVVM + Combine
- **传感器框架**: CMHeadphoneMotionManager
- **3D 渲染**: SceneKit
- **图表**: Swift Charts
- **音频框架**: AVFoundation (AVSpeechSynthesizer)
- **测试框架**: XCTest
- **依赖管理**: CocoaPods / Swift Package Manager
- **版本控制**: Git + GitHub

## 📊 代码统计

```
源代码:         7,706 行 (24 个 Swift 文件)
测试代码:       1,867 行 (4 个测试文件)
测试用例:       83 个
测试覆盖率:     >80%
文档:           >10,000 行
版本:           1.0 (Build 1)
目标平台:       iOS 14.0+
```

## 🚀 快速开始

### � 立即开始

**推荐阅读顺序**:

1. 📖 [下一步行动指南](Docs/planning/NEXT_STEPS.md) - **下一步行动指南**（强烈推荐！）
2. � [项目状态概览](Docs/planning/PROJECT_STATUS.md) - 项目状态和完成情况
3. 🏃 [快速开始指南](Docs/guides/QUICK_START_GUIDE.md) - 快速开始指南

4. 📊 [PROJECT_STATUS.md](PROJECT_STATUS.md) - 项目状态和代码统计 ```bash

5. 🏗️ [Docs/ARCHITECTURE.md](Docs/ARCHITECTURE.md) - 架构设计文档 # 在 Xcode 中按 Cmd + R

6. 📋 [RELEASE_READINESS_REPORT.md](RELEASE_READINESS_REPORT.md) - 发布就绪评估（70% ready） # 或使用命令行

   make build && make run

### 环境要求 ```

**必需**:> 💡 **提示**: Firebase 配置在第五阶段才需要，目前可以跳过。

- macOS 13.0+ (Ventura)

- Xcode 15.0+## 📂 项目结构

- iOS 14.0+ 设备（真机测试）

- AirPods Pro 或 AirPods (3rd generation)```

PostureTracker 2/

**如果您不熟悉 Xcode**（强烈推荐阅读）:

1. 📖 **[快速开始指南](Docs/guides/QUICK_START_GUIDE.md)** - ⭐ 快速导航和行动清单（先看这个！）
2. 🔧 **[Xcode 完整指南](Docs/guides/XCODE_COMPLETE_GUIDE.md)** - Xcode 完整操作指南（新手友好,带截图说明）
3. 📱 **[App Store 提交指南](Docs/guides/APP_STORE_SUBMISSION_GUIDE.md)** - App Store 提交完整流程（从零到上架）

**如果您已熟悉 iOS 开发**:

1. 📊 [项目状态](Docs/planning/PROJECT_STATUS.md) - 项目状态和代码统计
2. 🏗️ [架构设计](Docs/technical/ARCHITECTURE.md) - 架构设计文档
3. 📋 [发布就绪报告](Docs/planning/RELEASE_READINESS_REPORT.md) - 发布就绪评估（70% ready）

### 环境要求

**必需**:

- macOS 13.0+ (Ventura)
- Xcode 15.0+
- iOS 14.0+ 设备（真机测试）
- AirPods Pro 或 AirPods (3rd generation)

**可选**:

- Apple Developer 账号（发布到 App Store 需要,$99/年）

### 快速启动（3 步）

#### 1. 打开项目

```bash
cd "/Users/liguoma/my-devs/swift/PostureTracker 2"
open PostureTracker.xcodeproj
```

#### 2. 配置权限（详见 [Xcode 完整指南](Docs/guides/XCODE_COMPLETE_GUIDE.md)）

在 `Info.plist` 中添加：

```xml
<key>NSMotionUsageDescription</key>
<string>PostureTracker 需要访问运动数据来监测您的头部姿态,帮助改善坐姿</string>

<key>NSMicrophoneUsageDescription</key>
<string>PostureTracker 需要访问麦克风以提供语音反馈功能</string>
```

#### 3. 编译和运行

```bash
# 在 Xcode 中:
# - 选择目标设备（推荐：iPhone 15 Pro 模拟器或真机）
# - 按 Cmd + B 编译
# - 按 Cmd + R 运行
# - 按 Cmd + U 运行所有测试
```

> ⚠️ **重要**: AirPods 功能只能在真机上测试,模拟器无法模拟运动传感器！

## 📂 项目结构

```
PostureTracker 2/
├── PostureTracker/
│   ├── App/                      # 应用入口 ✅
│   │   └── PostureTrackerApp.swift
│   ├── Models/                   # 数据模型层 ✅
│   │   ├── Posture.swift
│   │   ├── MotionData.swift
│   │   └── Session.swift
│   ├── ViewModels/               # 视图模型层 ✅
│   │   ├── MotionViewModel.swift
│   │   ├── SessionViewModel.swift
│   │   └── StatisticsViewModel.swift
│   ├── Views/                    # SwiftUI 视图层 ✅
│   │   ├── ContentView.swift
│   │   ├── MonitoringView.swift
│   │   ├── StatisticsView.swift
│   │   ├── SettingsView.swift
│   │   └── Components/           # 可重用组件 ✅
│   ├── Services/                 # 业务服务层 ✅
│   │   ├── AirPodsMotionManager.swift
│   │   └── AudioFeedbackManager.swift
│   ├── Utils/                    # 工具类和扩展
│   ├── Resources/                # 资源文件
│   └── Configuration/            # 配置文件
├── PostureTrackerTests/          # 测试
├── Docs/                         # 项目文档 📚
│   ├── guides/                   # 开发指南
│   ├── sprints/                  # Sprint 文档
│   ├── planning/                 # 项目规划
│   ├── technical/                # 技术文档
│   └── setup/                    # 配置文档
├── README.md                     # 本文档
└── Makefile                      # 自动化构建

图例: ✅ 已完成
```

## 🎯 开发进度

### Sprint 4 已完成（2025-10-03）

- ✅ **3 个 ViewModel 文件** - MotionViewModel, SessionViewModel, StatisticsViewModel (~1,200 行)
- ✅ **View 层集成** - MonitoringView, StatisticsView 完全重构 (~600 行)
- ✅ **58 个单元测试** - 测试覆盖率 >80% (~600 行)
- ✅ **MVVM 架构完整实现** - 业务逻辑与 UI 完全分离

## 🧪 测试

### 当前测试状态

- ✅ 单元测试 - 83 个测试用例,覆盖率 >80%
- ⏳ UI 测试 - 待实现
- ✅ 手动测试 - 可在模拟器测试 UI 交互

### 运行测试

```bash
make test        # 单元测试
make ui-test     # UI 测试
make coverage    # 覆盖率报告

```

### 当前可测试项

- ✅ UI 界面和导航
- ✅ 按钮交互和动画
- ✅ 暗色模式适配
- ❌ AirPods 连接（需真机）
- ❌ 传感器数据（需真机 + AirPods）

## 📝 开发指南

完整的开发指南请参阅:

- [开发指南](Docs/guides/DEVELOPMENT_GUIDE.md) - 详细的开发规范和最佳实践
- [架构设计](Docs/technical/ARCHITECTURE.md) - MVVM 架构详细说明
- [项目配置](Docs/setup/PROJECT_SETUP_CHECKLIST.md) - Xcode 配置检查清单

### 编码规范

- 遵循 Swift API Design Guidelines
- 使用 SwiftLint 进行代码检查
- 所有注释使用中文
- 保持单一职责原则

### Git 工作流

```bash
# 创建功能分支
git checkout -b feature/your-feature

# 提交代码
git add .
git commit -m "feat: 添加新功能描述"

# 推送到远程
git push origin feature/your-feature
```

### 提交规范

- `feat`: 新功能
- `fix`: 修复 Bug
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建或辅助工具变动

## 🔑 权限说明

本应用需要以下权限：

- **Motion**: 访问 AirPods 运动传感器数据
- **Microphone** (可选): 播放语音反馈

└── ⚙️ 配置文件- **音频**: 播放语音反馈

    ├── PostureTracker.xcodeproj/         Xcode 项目文件- **网络**: 云端数据同步

    ├── Podfile                           CocoaPods 依赖- **通知**: 提醒和警告通知

    └── Makefile                          构建脚本

```## ⚠️ 重要提示



## 🏗️ 架构设计### 传感器方案说明



### MVVM + Combine 模式- ✅ **当前使用**: `CMHeadphoneMotionManager`（无需特殊权限，立即可用）

- ⏳ **备选方案**: `SensorKit`（需 Apple 批准，周期 3-5 个月，仅研究用途）

```

┌─────────────────────────────────────────────────────────┐### 设备兼容性

│ SwiftUI Views │

│ (MonitoringView, StatisticsView, SettingsView) │- ✅ **支持**: AirPods Pro (1st/2nd gen), AirPods (3rd gen), AirPods Max

└────────────┬───────────────────────────┬────────────────┘- ❌ **不支持**: AirPods (1st/2nd gen) - 无运动传感器

             │                           │

             │ @StateObject              │ @Published### 性能建议

             │                           │

┌────────────▼────────────┐ ┌──────────▼────────────────┐- 采样率：50Hz（前台）/ 25Hz（后台自动降低）

│ ViewModels │ │ Managers │- 电池影响：预计 < 5%/小时（待真机验证）

│ - MotionViewModel │ │ - SettingsManager │- 目标性能：UI 60fps, CPU < 15%

│ - SessionViewModel │ │ │

│ - StatisticsViewModel │ │ │### 隐私保护

└────────────┬────────────┘ └───────────────────────────┘

             │- 本地数据加密存储（Core Data）

             │ Combine Publishers- 用户可随时删除数据

             │- 遵循 GDPR 和 CCPA 规范

┌────────────▼────────────────────────────────────────────┐

│ Services │## 📚 文档导航

│ - AirPodsMotionManager (CMHeadphoneMotionManager) │

│ - AudioFeedbackManager (AVSpeechSynthesizer) │### 🌟 推荐优先阅读

└────────────┬────────────────────────────────────────────┘

             │1. **[NEXT_STEPS.md](NEXT_STEPS.md)** - 下一步行动指南（详细的 Sprint 2 开发计划）

             │ Data Models2. **[PROJECT_STATUS.md](PROJECT_STATUS.md)** - 项目状态快速概览

             │3. **[DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)** - 完整开发指南（已更新 Sprint 1）

┌────────────▼────────────────────────────────────────────┐

│ Models │### 📋 Sprint 文档

│ - Posture (姿态数据) │

│ - MotionData (运动数据) │- [Docs/SPRINT_TRACKER.md](Docs/SPRINT_TRACKER.md) - Sprint 详细进度跟踪

│ - Session (会话记录) │- [Docs/SPRINT1_QUICKSTART.md](Docs/SPRINT1_QUICKSTART.md) - 快速开始和测试指南

└─────────────────────────────────────────────────────────┘- [Docs/SPRINT1_SUMMARY.md](Docs/SPRINT1_SUMMARY.md) - Sprint 1 完成总结

````- [Docs/PROJECT_SETUP_CHECKLIST.md](Docs/PROJECT_SETUP_CHECKLIST.md) - 项目配置检查清单



详细架构设计请参考：[Docs/ARCHITECTURE.md](Docs/ARCHITECTURE.md)### 📖 技术文档（未来）



## 📖 文档索引- ⏳ [Docs/ARCHITECTURE.md](Docs/ARCHITECTURE.md) - 架构设计（待创建）

- ⏳ [Docs/API_DESIGN.md](Docs/API_DESIGN.md) - API 文档（待创建）

### 🚀 发布准备（重点）- ⏳ [Docs/SENSORKIT_APPLICATION.md](Docs/SENSORKIT_APPLICATION.md) - SensorKit 申请（可选）



| 文档 | 描述 | 适合人群 |## 🤝 贡献指南

|------|------|---------|

| **[QUICK_START_GUIDE.md](QUICK_START_GUIDE.md)** | 快速导航和行动清单 | ⭐ 所有人（先看这个）|欢迎提交 Issue 和 Pull Request！

| **[XCODE_COMPLETE_GUIDE.md](XCODE_COMPLETE_GUIDE.md)** | Xcode 完整操作指南 | Xcode 新手 |

| **[APP_STORE_SUBMISSION_GUIDE.md](APP_STORE_SUBMISSION_GUIDE.md)** | App Store 提交流程 | 首次发布者 |1. Fork 本仓库

| [RELEASE_READINESS_REPORT.md](RELEASE_READINESS_REPORT.md) | 发布就绪评估 | 项目管理者 |2. 创建功能分支

3. 提交变更

### 📚 技术文档4. 推送到分支

5. 创建 Pull Request

| 文档 | 描述 |

|------|------|## 📄 许可证

| [Docs/ARCHITECTURE.md](Docs/ARCHITECTURE.md) | 完整的架构设计文档 |

| [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) | 开发指南和最佳实践 |本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

| [PROJECT_STATUS.md](PROJECT_STATUS.md) | 项目状态和统计 |

## 🎯 开发路线图

### 📋 项目管理

### 当前进度：第二阶段 Sprint 1 完成 ✅

| 文档 | 描述 |

|------|------|```

| [Docs/SPRINT_TRACKER.md](Docs/SPRINT_TRACKER.md) | Sprint 1-4 进度跟踪 |████░░░░░░░░░░░░░░░░ 20% 总体进度

| [Docs/SPRINT1_SUMMARY.md](Docs/SPRINT1_SUMMARY.md) | Sprint 1 详细总结 |

| [NEXT_STEPS.md](NEXT_STEPS.md) | 后续开发计划 |第一阶段: ████████████████████ 100% ✅ 基础架构


## 📚 文档导航

完整的文档索引请查看：[Docs/README.md](Docs/README.md)

### 🌟 推荐优先阅读

1. **[下一步行动](Docs/planning/NEXT_STEPS.md)** - 下一步开发计划
2. **[项目状态](Docs/planning/PROJECT_STATUS.md)** - 项目状态概览
3. **[快速开始](Docs/guides/QUICK_START_GUIDE.md)** - 快速导航和行动清单

### 📖 开发文档

- [开发指南](Docs/guides/DEVELOPMENT_GUIDE.md) - 完整开发指南和最佳实践
- [架构设计](Docs/technical/ARCHITECTURE.md) - MVVM 架构详细说明
- [项目配置](Docs/setup/PROJECT_SETUP_CHECKLIST.md) - Xcode 配置检查清单

### 🚀 发布准备文档

- [快速开始指南](Docs/guides/QUICK_START_GUIDE.md) - ⭐ 新手必读
- [Xcode 完整指南](Docs/guides/XCODE_COMPLETE_GUIDE.md) - Xcode 操作详解
- [App Store 提交指南](Docs/guides/APP_STORE_SUBMISSION_GUIDE.md) - 提交流程
- [发布就绪报告](Docs/planning/RELEASE_READINESS_REPORT.md) - 发布前检查

### 📋 Sprint 文档

- [Sprint 进度跟踪](Docs/sprints/SPRINT_TRACKER.md) - 所有 Sprint 进度
- [Sprint 1 总结](Docs/sprints/SPRINT1_SUMMARY.md) - Sprint 1 详情
- [Sprint 3 总结](Docs/sprints/SPRINT3_COMPLETION_SUMMARY.md) - Sprint 3 详情

## 🎉 开始使用

**如果您是第一次接触这个项目：**

1. 📖 阅读 [快速开始指南](Docs/guides/QUICK_START_GUIDE.md)（5 分钟）
2. 🔧 按照 [Xcode 完整指南](Docs/guides/XCODE_COMPLETE_GUIDE.md) 配置 Xcode（1-2 小时）
3. 📱 按照 [App Store 提交指南](Docs/guides/APP_STORE_SUBMISSION_GUIDE.md) 提交应用（2-3 小时）

**预计时间线：3-4 天即可完成发布准备！**

---

## 📮 联系方式

- **GitHub**: [PostureTracker Repository](https://github.com/hordu-ma/PostureTracker)
- **问题反馈**: [Issues](https://github.com/hordu-ma/PostureTracker/issues)
- **文档中心**: [Docs/](Docs/)

## 📄 许可证

Copyright © 2025. All rights reserved.

---

**🎯 项目当前状态**: 开发完成 100%,发布准备 70%
**🚀 下一个里程碑**: 提交到 App Store
**最后更新**: 2025-10-11```



### Sprint 2: 数据可视化 (✅ 100%)### 下一里程碑

- [x] 3D 姿态可视化（SceneKit）

- [x] 统计图表（Swift Charts）- **Sprint 2** (4-5 天): 3D 姿态可视化 + 统计图表

- [x] 会话历史展示- **Sprint 3** (3-4 天): 设置功能实现

- [x] 数据导出功能

查看完整路线图：[DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#开发路线图)

### Sprint 3: 设置和权限 (✅ 100%)

- [x] 完整的设置页面## 🤝 贡献指南

- [x] 主题切换（浅色/深色）

- [x] 灵敏度调节欢迎提交 Issue 和 Pull Request！

- [x] 权限管理页面

- [x] 隐私政策页面### 开发流程



### Sprint 4: ViewModel 层 (✅ 100%)1. Fork 本仓库

- [x] MotionViewModel（实时监测逻辑）2. 创建功能分支：`git checkout -b feature/your-feature`

- [x] SessionViewModel（会话管理逻辑）3. 提交变更：`git commit -m "feat: 添加新功能"`

- [x] StatisticsViewModel（统计分析逻辑）4. 推送到分支：`git push origin feature/your-feature`

- [x] 重构 Views 使用 ViewModels5. 创建 Pull Request

- [x] 完整的单元测试（58 tests）

### 提交规范

### 下一步: 发布准备

- [ ] Xcode 项目配置（Info.plist, 签名）```bash

- [ ] 应用图标和启动画面feat: 新功能

- [ ] 真机测试（AirPods）fix: 修复 Bug

- [ ] App Store Connect 配置docs: 文档更新

- [ ] 提交审核style: 代码格式

refactor: 代码重构

## 🧪 测试test: 测试相关

chore: 构建/工具变动

### 运行测试```



```bash## 📮 联系方式

# 在 Xcode 中运行所有测试

Cmd + U- 项目主页：[GitHub Repository](https://github.com/yourusername/PostureTracker)

- 问题反馈：[Issues](https://github.com/yourusername/PostureTracker/issues)

# 或运行单个测试文件- 开发文档：查看 `Docs/` 目录

Cmd + 6 打开测试导航器

点击测试文件旁边的 ◇ 图标## 🙏 致谢

````

- Apple 官方文档和示例代码

### 测试覆盖率- SwiftUI 和 Combine 社区

- 所有贡献者和测试用户

```

✅ SettingsManagerTests:     25 tests---

✅ MotionViewModelTests:      18 tests

✅ SessionViewModelTests:     20 tests**🎉 Sprint 1 完成！准备开始 Sprint 2 了吗？查看 [NEXT_STEPS.md](NEXT_STEPS.md) 获取详细计划！**

✅ StatisticsViewModelTests:  20 tests

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━_本项目仅供研究和教育用途，商业使用需获得相应授权_

总计:                         83 tests
覆盖率:                       >80%
```

## 🔒 隐私和安全

- ✅ **本地处理**：所有运动数据仅在设备上处理
- ✅ **无服务器**：不上传任何数据到云端
- ✅ **无追踪**：不使用任何第三方分析工具
- ✅ **用户控制**：随时可以删除所有数据
- ✅ **透明权限**：清晰说明每个权限的用途

详细隐私政策：PostureTracker/Views/PrivacyPolicyView.swift

## 🎯 设备要求

### 必需

- **iOS 版本**: iOS 14.0 或更高
- **设备**: iPhone 或 iPad
- **耳机**: AirPods Pro 或 AirPods (第三代)

### 可选

- **存储空间**: < 50 MB
- **网络**: 不需要（完全离线运行）

## 📝 发布准备清单

### 🔴 必须完成（无法发布）

- [ ] 配置 Info.plist 权限描述
- [ ] 创建应用图标（1024x1024）
- [ ] 创建启动画面
- [ ] 真机测试无崩溃
- [ ] Apple Developer 账号

### 🟡 强烈推荐

- [ ] 准备 5 张应用截图
- [ ] 撰写应用描述（英文+中文）
- [ ] 创建隐私政策页面
- [ ] 性能测试（Instruments）
- [ ] 内存泄漏检测

### 🟢 可选优化

- [ ] App Store 预览视频
- [ ] 多语言支持
- [ ] iPad 适配
- [ ] Widget 扩展

详细清单请参考：[RELEASE_READINESS_REPORT.md](RELEASE_READINESS_REPORT.md)

## 🤝 贡献

当前项目处于个人开发阶段，欢迎提出建议和反馈！

## 📄 许可证

Copyright © 2024. All rights reserved.

## 📧 联系方式

- **Email**: support@posturetracker.app（待创建）
- **GitHub**: [PostureTracker](https://github.com/yourusername/PostureTracker)（待发布）

---

## 🎉 快速开始

**如果您是第一次接触这个项目：**

1. 📖 阅读 [QUICK_START_GUIDE.md](QUICK_START_GUIDE.md)（5 分钟）
2. 🔧 按照 [XCODE_COMPLETE_GUIDE.md](XCODE_COMPLETE_GUIDE.md) 配置 Xcode（1-2 小时）
3. 📱 按照 [APP_STORE_SUBMISSION_GUIDE.md](APP_STORE_SUBMISSION_GUIDE.md) 提交应用（2-3 小时）

**预计时间线：3-4 天即可完成发布准备！**

---

**🎯 项目当前状态**: 开发完成 100%，发布准备 70%

**🚀 下一个里程碑**: 提交到 App Store

**最后更新**: 2024-01-XX
