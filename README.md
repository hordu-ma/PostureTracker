# PostureTracker - 基于 AirPods 的姿态追踪应用

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

### 环境要求
- macOS 13.0+ (Ventura)
- Xcode 15.0+
- iOS 14.0+ (设备)
- AirPods Pro 或 AirPods (3rd generation)
- Apple Developer 账号

### 安装步骤

1. **克隆项目**
```bash
git clone https://github.com/yourusername/PostureTracker.git
cd PostureTracker
```

2. **运行初始化脚本**
```bash
chmod +x setup.sh
./setup.sh
```

3. **配置 Firebase**
- 在 Firebase Console 创建新项目
- 下载 `GoogleService-Info.plist`
- 将文件放入 `PostureTracker/Configuration/` 目录

4. **配置权限**
- 申请 SensorKit 权限（需要 Apple 特殊批准）
- 配置 App Groups 和 Background Modes

5. **构建运行**
```bash
make build
make run
```

## 📂 项目结构

```
PostureTracker/
├── PostureTracker/
│   ├── App/                    # 应用入口和生命周期
│   ├── Models/                  # 数据模型层
│   ├── ViewModels/              # 视图模型层 (MVVM)
│   ├── Views/                   # SwiftUI 视图层
│   │   └── Components/          # 可重用组件
│   ├── Services/                # 业务服务层
│   ├── Utils/                   # 工具类和扩展
│   │   └── Extensions/          # Swift 扩展
│   ├── Resources/               # 资源文件
│   └── Configuration/           # 配置文件
├── PostureTrackerTests/         # 单元测试和 UI 测试
├── Docs/                        # 项目文档
└── .github/workflows/           # CI/CD 配置
```

## 🧪 测试

### 运行单元测试
```bash
make test
```

### 运行 UI 测试
```bash
make ui-test
```

### 生成覆盖率报告
```bash
make coverage
```

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

## ⚠️ 注意事项

1. **SensorKit 权限申请**
   - 仅限研究用途，需要 Apple 批准
   - 申请周期约 3-5 个月
   - 详见 `Docs/SENSORKIT_APPLICATION.md`

2. **隐私保护**
   - 所有传感器数据本地加密存储
   - 用户可随时删除个人数据
   - 遵循 GDPR 和 CCPA 规范

3. **性能优化**
   - 建议采样率：50Hz
   - 后台运行时自动降低采样率
   - 电池优化模式下限制功能

## 📚 文档

- [架构设计](Docs/ARCHITECTURE.md)
- [API 文档](Docs/API_DESIGN.md)
- [部署指南](Docs/DEPLOYMENT.md)
- [SensorKit 申请指南](Docs/SENSORKIT_APPLICATION.md)

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建功能分支
3. 提交变更
4. 推送到分支
5. 创建 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 📮 联系方式

- 作者：[Your Name]
- 邮箱：[your.email@example.com]
- 项目主页：[https://github.com/yourusername/PostureTracker](https://github.com/yourusername/PostureTracker)

## 🙏 致谢

- Apple ResearchKit & CareKit 团队
- Firebase 开发团队
- 所有贡献者和测试用户

---

*本项目仅供研究和教育用途，商业使用需获得相应授权*