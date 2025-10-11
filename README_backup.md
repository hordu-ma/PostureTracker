# PostureTracker - 基于 AirPods 的姿态追踪应用

> 🎯 **当前状态**: Sprint 1 已完成 ✅ | **进度**: 第二阶段 33% (1/3) | **最后更新**: 2024-09-30

## 📱 项目概述

PostureTracker 是一个创新的 iOS 应用，利用 AirPods 内置的陀螺仪和加速度计传感器，实时监测用户头部姿态，并通过智能音频反馈系统帮助用户改善姿势。

### 核心功能

- 🎯 **实时姿态监测**：通过 AirPods 传感器实时采集头部运动数据
- 🔊 **智能音频反馈**：根据姿态偏差提供语音指导和提示音
- 📊 **数据分析可视化**：3D 姿态展示和统计分析图表
- ☁️ **云端同步**：训练数据自动备份到 Firebase
- 🎮 **个性化设置**：可调节反馈频率、音量和阈值

## 🛠 技术栈

- **开发语言**: Swift 5.9+
- **UI 框架**: SwiftUI
- **架构模式**: MVVM + Combine
- **传感器框架**: SensorKit / CMHeadphoneMotionManager
- **音频框架**: AVFoundation
- **云服务**: Firebase (Firestore + Storage)
- **依赖管理**: CocoaPods / Swift Package Manager

## 🚀 快速开始

### 🎬 立即开始

**推荐阅读顺序**:

1. 📖 [NEXT_STEPS.md](NEXT_STEPS.md) - **下一步行动指南**（强烈推荐！）
2. 📊 [PROJECT_STATUS.md](PROJECT_STATUS.md) - 项目状态概览
3. 🏃 [Docs/SPRINT1_QUICKSTART.md](Docs/SPRINT1_QUICKSTART.md) - 快速开始指南

### 环境要求

- macOS 13.0+ (Ventura)
- Xcode 15.0+
- iOS 14.0+ (设备)
- AirPods Pro 或 AirPods (3rd generation) - 真机测试用
- Apple Developer 账号

### 三步快速启动

1. **创建 Xcode 项目**（如果尚未创建）

    ```bash
    # 在 Xcode 中: File > New > Project > iOS > App
    # 然后添加现有代码文件到项目
    ```

2. **配置权限** - 在 `Info.plist` 添加：

    ```xml
    <key>NSMotionUsageDescription</key>
    <string>需要访问运动数据来监测头部姿态</string>
    ```

3. **构建运行**
    ```bash
    # 在 Xcode 中按 Cmd + R
    # 或使用命令行
    make build && make run
    ```

> 💡 **提示**: Firebase 配置在第五阶段才需要，目前可以跳过。

## 📂 项目结构

```
PostureTracker 2/
├── PostureTracker/
│   ├── App/                         # 应用入口 ✅
│   │   └── PostureTrackerApp.swift  # 应用入口和生命周期管理
│   ├── Models/                      # 数据模型层 ✅
│   │   ├── Posture.swift            # 姿态数据模型
│   │   ├── MotionData.swift         # 运动数据模型
│   │   └── Session.swift            # 会话管理模型
│   ├── ViewModels/                  # 视图模型层 ⏳ (Sprint 3-4)
│   ├── Views/                       # SwiftUI 视图层 ✅
│   │   ├── ContentView.swift        # 主导航（TabView）
│   │   ├── MonitoringView.swift    # 监测页面（核心功能）
│   │   ├── StatisticsView.swift    # 统计页面（占位）
│   │   ├── SettingsView.swift      # 设置页面（占位）
│   │   └── Components/              # 可重用组件 ✅
│   │       ├── StatusCard.swift         # 状态卡片
│   │       ├── ConnectionIndicator.swift # 连接指示器
│   │       └── ActionButton.swift       # 操作按钮
│   ├── Services/                    # 业务服务层 ✅
│   │   ├── AirPodsMotionManager.swift   # 传感器管理
│   │   └── AudioFeedbackManager.swift   # 音频反馈
│   ├── Utils/                       # 工具类和扩展
│   ├── Resources/                   # 资源文件
│   └── Configuration/               # 配置文件
├── PostureTrackerTests/             # 测试
├── Docs/                            # 项目文档 ✅
│   ├── SPRINT_TRACKER.md            # Sprint 进度跟踪
│   ├── SPRINT1_QUICKSTART.md        # 快速开始指南
│   ├── SPRINT1_SUMMARY.md           # Sprint 1 总结
│   └── PROJECT_SETUP_CHECKLIST.md   # 配置检查清单
├── README.md                        # 本文档
├── NEXT_STEPS.md                    # 下一步行动指南 ⭐
├── PROJECT_STATUS.md                # 项目状态概览
├── DEVELOPMENT_GUIDE.md             # 完整开发指南
└── Makefile                         # 自动化构建

图例: ✅ 已完成  ⏳ 进行中  空白 = 待开发
```

### 🎯 Sprint 1 已完成（2024-09-30）

- ✅ **8 个视图文件** - 完整 UI 框架
- ✅ **3 个可复用组件** - StatusCard, ConnectionIndicator, ActionButton
- ✅ **1,830 行代码** - 注释覆盖率 24%
- ✅ **22 个 Preview** - 完整预览支持
- ✅ **6 个文档文件** - 约 2,716 行文档

## 🧪 测试

### 当前测试状态

- ⏳ 单元测试 - Sprint 3-4 实现（目标覆盖率 > 80%）
- ⏳ UI 测试 - Sprint 6 实现
- ✅ 手动测试 - 可在模拟器测试 UI 交互

### 运行测试（未来）

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

- **SensorKit**: 访问 AirPods 传感器数据（需特殊批准）
- **音频**: 播放语音反馈
- **网络**: 云端数据同步
- **通知**: 提醒和警告通知

## ⚠️ 重要提示

### 传感器方案说明

- ✅ **当前使用**: `CMHeadphoneMotionManager`（无需特殊权限，立即可用）
- ⏳ **备选方案**: `SensorKit`（需 Apple 批准，周期 3-5 个月，仅研究用途）

### 设备兼容性

- ✅ **支持**: AirPods Pro (1st/2nd gen), AirPods (3rd gen), AirPods Max
- ❌ **不支持**: AirPods (1st/2nd gen) - 无运动传感器

### 性能建议

- 采样率：50Hz（前台）/ 25Hz（后台自动降低）
- 电池影响：预计 < 5%/小时（待真机验证）
- 目标性能：UI 60fps, CPU < 15%

### 隐私保护

- 本地数据加密存储（Core Data）
- 用户可随时删除数据
- 遵循 GDPR 和 CCPA 规范

## 📚 文档导航

### 🌟 推荐优先阅读

1. **[NEXT_STEPS.md](NEXT_STEPS.md)** - 下一步行动指南（详细的 Sprint 2 开发计划）
2. **[PROJECT_STATUS.md](PROJECT_STATUS.md)** - 项目状态快速概览
3. **[DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)** - 完整开发指南（已更新 Sprint 1）

### 📋 Sprint 文档

- [Docs/SPRINT_TRACKER.md](Docs/SPRINT_TRACKER.md) - Sprint 详细进度跟踪
- [Docs/SPRINT1_QUICKSTART.md](Docs/SPRINT1_QUICKSTART.md) - 快速开始和测试指南
- [Docs/SPRINT1_SUMMARY.md](Docs/SPRINT1_SUMMARY.md) - Sprint 1 完成总结
- [Docs/PROJECT_SETUP_CHECKLIST.md](Docs/PROJECT_SETUP_CHECKLIST.md) - 项目配置检查清单

### 📖 技术文档（未来）

- ⏳ [Docs/ARCHITECTURE.md](Docs/ARCHITECTURE.md) - 架构设计（待创建）
- ⏳ [Docs/API_DESIGN.md](Docs/API_DESIGN.md) - API 文档（待创建）
- ⏳ [Docs/SENSORKIT_APPLICATION.md](Docs/SENSORKIT_APPLICATION.md) - SensorKit 申请（可选）

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建功能分支
3. 提交变更
4. 推送到分支
5. 创建 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 🎯 开发路线图

### 当前进度：第二阶段 Sprint 1 完成 ✅

```
████░░░░░░░░░░░░░░░░ 20% 总体进度

第一阶段: ████████████████████ 100% ✅ 基础架构
第二阶段: ██████░░░░░░░░░░░░░░  33% ⏳ 视图层
  ├─ Sprint 1: ████████████████████ 100% ✅ 核心界面框架
  ├─ Sprint 2: ░░░░░░░░░░░░░░░░░░░░   0% ⏳ 数据可视化
  └─ Sprint 3: ░░░░░░░░░░░░░░░░░░░░   0% ⏳ 设置配置
第三阶段: ░░░░░░░░░░░░░░░░░░░░   0% ⏳ ViewModel 层
第四阶段: ░░░░░░░░░░░░░░░░░░░░   0% ⏳ 数据处理优化
第五阶段: ░░░░░░░░░░░░░░░░░░░░   0% ⏳ 云端集成
第六阶段: ░░░░░░░░░░░░░░░░░░░░   0% ⏳ 测试和优化
第七阶段: ░░░░░░░░░░░░░░░░░░░░   0% ⏳ 发布准备
```

### 下一里程碑

- **Sprint 2** (4-5 天): 3D 姿态可视化 + 统计图表
- **Sprint 3** (3-4 天): 设置功能实现

查看完整路线图：[DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#开发路线图)

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

### 开发流程

1. Fork 本仓库
2. 创建功能分支：`git checkout -b feature/your-feature`
3. 提交变更：`git commit -m "feat: 添加新功能"`
4. 推送到分支：`git push origin feature/your-feature`
5. 创建 Pull Request

### 提交规范

```bash
feat: 新功能
fix: 修复 Bug
docs: 文档更新
style: 代码格式
refactor: 代码重构
test: 测试相关
chore: 构建/工具变动
```

## 📮 联系方式

- 项目主页：[GitHub Repository](https://github.com/yourusername/PostureTracker)
- 问题反馈：[Issues](https://github.com/yourusername/PostureTracker/issues)
- 开发文档：查看 `Docs/` 目录

## 🙏 致谢

- Apple 官方文档和示例代码
- SwiftUI 和 Combine 社区
- 所有贡献者和测试用户

---

**🎉 Sprint 1 完成！准备开始 Sprint 2 了吗？查看 [NEXT_STEPS.md](NEXT_STEPS.md) 获取详细计划！**

_本项目仅供研究和教育用途，商业使用需获得相应授权_
