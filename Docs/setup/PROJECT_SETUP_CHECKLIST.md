# PostureTracker 项目配置检查清单

## 📋 Sprint 1 完成后的配置检查

### ✅ 已完成的文件

#### 1. 应用入口和导航
- [x] `PostureTracker/App/PostureTrackerApp.swift` - 应用入口
- [x] `PostureTracker/Views/ContentView.swift` - 主导航结构

#### 2. 核心视图
- [x] `PostureTracker/Views/MonitoringView.swift` - 监测页面
- [x] `PostureTracker/Views/StatisticsView.swift` - 统计页面（占位）
- [x] `PostureTracker/Views/SettingsView.swift` - 设置页面（占位）

#### 3. 可复用组件
- [x] `PostureTracker/Views/Components/StatusCard.swift` - 状态卡片
- [x] `PostureTracker/Views/Components/ConnectionIndicator.swift` - 连接指示器
- [x] `PostureTracker/Views/Components/ActionButton.swift` - 操作按钮

#### 4. 数据模型（已存在）
- [x] `PostureTracker/Models/Posture.swift` - 姿态模型
- [x] `PostureTracker/Models/MotionData.swift` - 运动数据模型
- [x] `PostureTracker/Models/Session.swift` - 会话模型

#### 5. 服务层（已存在）
- [x] `PostureTracker/Services/AirPodsMotionManager.swift` - 传感器管理
- [x] `PostureTracker/Services/AudioFeedbackManager.swift` - 音频反馈

#### 6. 文档
- [x] `README.md` - 项目说明
- [x] `DEVELOPMENT_GUIDE.md` - 开发指南
- [x] `Docs/SPRINT_TRACKER.md` - Sprint 进度跟踪
- [x] `Docs/SPRINT1_QUICKSTART.md` - 快速开始指南
- [x] `Docs/PROJECT_SETUP_CHECKLIST.md` - 本文档

---

## 🔧 必需的 Xcode 项目配置

### 1. Info.plist 配置

需要添加以下权限说明：

```xml
<!-- 必需权限 -->
<key>NSMotionUsageDescription</key>
<string>PostureTracker 需要访问运动数据来监测您的头部姿态</string>

<key>NSMicrophoneUsageDescription</key>
<string>PostureTracker 需要访问麦克风权限以播放语音反馈</string>

<!-- 可选权限（后续阶段） -->
<key>NSBluetoothAlwaysUsageDescription</key>
<string>PostureTracker 需要蓝牙权限来检测 AirPods 连接状态</string>

<key>NSUserNotificationsUsageDescription</key>
<string>PostureTracker 需要发送通知来提醒您保持正确姿态</string>
```

### 2. Capabilities 配置

在 Xcode 项目中需要启用：

- [ ] **Background Modes**（后续添加）
  - [ ] Audio, AirPlay, and Picture in Picture
  - [ ] Background fetch

- [ ] **Push Notifications**（后续添加）

- [ ] **iCloud**（第五阶段）
  - [ ] CloudKit
  - [ ] Key-value storage

### 3. Build Settings

推荐配置：

```
- iOS Deployment Target: 14.0
- Swift Language Version: Swift 5
- Enable Bitcode: No
- Enable Testability: Yes (Debug)
- Optimization Level: -Onone (Debug), -O (Release)
```

---

## 📦 依赖管理

### Swift Package Manager（推荐）

当前不需要外部依赖，所有功能使用系统框架：

```swift
// 已使用的系统框架
- SwiftUI
- Combine
- CoreMotion
- AVFoundation
- Foundation
```

### 未来依赖（Sprint 2+）

```swift
// Sprint 2: 数据可视化
- SceneKit (系统框架)
- Charts (系统框架，iOS 16+)

// Sprint 5: Firebase
- Firebase/Auth
- Firebase/Firestore
- Firebase/Storage
- Firebase/Messaging
```

---

## 🎯 项目结构验证

### 目录结构检查

```
PostureTracker 2/
├── PostureTracker/
│   ├── App/                    ✅ 已创建
│   │   └── PostureTrackerApp.swift
│   ├── Models/                 ✅ 已存在
│   │   ├── Posture.swift
│   │   ├── MotionData.swift
│   │   └── Session.swift
│   ├── Views/                  ✅ 已创建
│   │   ├── ContentView.swift
│   │   ├── MonitoringView.swift
│   │   ├── StatisticsView.swift
│   │   ├── SettingsView.swift
│   │   └── Components/         ✅ 已创建
│   │       ├── StatusCard.swift
│   │       ├── ConnectionIndicator.swift
│   │       └── ActionButton.swift
│   ├── ViewModels/             ⏳ 待创建（Sprint 3）
│   ├── Services/               ✅ 已存在
│   │   ├── AirPodsMotionManager.swift
│   │   └── AudioFeedbackManager.swift
│   ├── Utils/                  ✅ 已存在
│   ├── Resources/              ✅ 已存在
│   └── Configuration/          ✅ 已存在
├── PostureTrackerTests/        ✅ 已存在
├── Docs/                       ✅ 已创建
│   ├── SPRINT_TRACKER.md
│   ├── SPRINT1_QUICKSTART.md
│   └── PROJECT_SETUP_CHECKLIST.md
├── README.md                   ✅ 已存在
├── DEVELOPMENT_GUIDE.md        ✅ 已存在
└── Makefile                    ✅ 已存在
```

---

## 🚀 如何创建 Xcode 项目

### 方法 1: 从现有代码创建项目

```bash
# 步骤 1: 在 Xcode 中创建新项目
# File > New > Project...
# 选择 iOS > App
# Product Name: PostureTracker
# Interface: SwiftUI
# Language: Swift
# Storage: None

# 步骤 2: 将现有文件添加到项目
# 1. 删除自动生成的 ContentView.swift 和 PostureTrackerApp.swift
# 2. 右键项目 > Add Files to "PostureTracker"...
# 3. 选择 PostureTracker 文件夹下的所有子目录
# 4. 确保勾选 "Copy items if needed"
# 5. 确保勾选 "Create groups"
```

### 方法 2: 使用命令行工具

```bash
# 安装 XcodeGen（如果未安装）
brew install xcodegen

# 创建 project.yml 配置文件
# 然后运行
xcodegen generate
```

---

## ⚙️ project.yml 配置示例

如果使用 XcodeGen，创建以下配置文件：

```yaml
name: PostureTracker
options:
  bundleIdPrefix: com.yourdomain
  deploymentTarget:
    iOS: "14.0"

targets:
  PostureTracker:
    type: application
    platform: iOS
    sources:
      - PostureTracker
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.yourdomain.PostureTracker
        SWIFT_VERSION: "5.0"
        INFOPLIST_FILE: PostureTracker/Info.plist
    info:
      path: PostureTracker/Info.plist
      properties:
        CFBundleName: $(PRODUCT_NAME)
        CFBundleDisplayName: PostureTracker
        CFBundleIdentifier: $(PRODUCT_BUNDLE_IDENTIFIER)
        CFBundleVersion: 1
        CFBundleShortVersionString: 1.0.0
        UILaunchStoryboardName: LaunchScreen
        UISupportedInterfaceOrientations:
          - UIInterfaceOrientationPortrait
        NSMotionUsageDescription: "PostureTracker 需要访问运动数据来监测您的头部姿态"

  PostureTrackerTests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - PostureTrackerTests
    dependencies:
      - target: PostureTracker
```

---

## 🔍 编译检查清单

### 在创建 Xcode 项目后，确保：

- [ ] 项目能够成功编译（Cmd + B）
- [ ] 没有编译错误
- [ ] 没有编译警告
- [ ] 在模拟器上能运行（Cmd + R）
- [ ] TabView 导航正常工作
- [ ] 三个页面都能访问
- [ ] 暗色模式切换正常

### 常见编译问题

#### 问题 1: 找不到符号

```bash
错误: Cannot find 'Posture' in scope

解决方案:
1. 确认 Posture.swift 已添加到项目
2. 确认文件在正确的 Target 中
3. 清理构建缓存: Cmd + Shift + K
```

#### 问题 2: 模块导入失败

```bash
错误: No such module 'Combine'

解决方案:
1. 检查 Build Settings > Linking > Other Linker Flags
2. 确认 iOS Deployment Target >= 13.0
3. 重新构建项目
```

#### 问题 3: @main 冲突

```bash
错误: 'main' attribute can only be applied to one type

解决方案:
1. 确保只有一个 @main 入口（PostureTrackerApp.swift）
2. 删除其他带有 @main 的文件
3. 清理并重新构建
```

---

## 📱 设备测试准备

### 模拟器测试

```bash
# 推荐测试设备
✅ iPhone 15 Pro (iOS 17.0)
✅ iPhone 14 Pro (iOS 16.0)
✅ iPhone SE (3rd generation) (iOS 15.0)

# 测试场景
✅ 浅色模式
✅ 暗色模式
✅ 不同字体大小
✅ 界面切换
✅ 按钮交互
```

### 真机测试（需要 AirPods）

```bash
# 硬件要求
- iPhone (iOS 14.0+)
- AirPods Pro (1st/2nd gen) 或
- AirPods (3rd gen) 或
- AirPods Max

# 测试场景
✅ AirPods 连接检测
✅ 传感器数据读取
✅ 实时姿态更新
✅ 性能测试（CPU/内存）
✅ 电池续航影响
```

---

## 🎨 资源文件

### 需要准备的资源

#### 应用图标（未来添加）

```
AppIcon.appiconset/
├── icon-20@2x.png (40x40)
├── icon-20@3x.png (60x60)
├── icon-29@2x.png (58x58)
├── icon-29@3x.png (87x87)
├── icon-40@2x.png (80x80)
├── icon-40@3x.png (120x120)
├── icon-60@2x.png (120x120)
├── icon-60@3x.png (180x180)
└── icon-1024.png (1024x1024)
```

#### 启动屏幕（可选）

```
LaunchScreen.storyboard
或使用纯色背景 + Logo
```

#### 音频资源（未来添加）

```
Resources/Audio/
├── alert.wav          # 提示音
├── warning.wav        # 警告音
└── success.wav        # 成功音
```

---

## 🧪 测试配置

### 单元测试设置

```swift
// PostureTrackerTests/PostureTrackerTests.swift
import XCTest
@testable import PostureTracker

class PostureTrackerTests: XCTestCase {
    func testExample() {
        XCTAssert(true)
    }
}
```

### UI 测试设置

```swift
// PostureTrackerUITests/PostureTrackerUITests.swift
import XCTest

class PostureTrackerUITests: XCTestCase {
    func testLaunch() {
        let app = XCUIApplication()
        app.launch()
        XCTAssert(app.tabBars.buttons["监测"].exists)
    }
}
```

---

## 📝 下一步行动

### 如果还未创建 Xcode 项目

1. [ ] 使用 Xcode 创建新项目
2. [ ] 配置 Bundle Identifier
3. [ ] 添加现有源文件
4. [ ] 配置 Info.plist
5. [ ] 测试编译
6. [ ] 在模拟器运行
7. [ ] 提交到 Git

### 如果项目已创建

1. [ ] 验证所有文件都在项目中
2. [ ] 测试编译
3. [ ] 运行应用
4. [ ] 开始 Sprint 2 开发

---

## 🔗 相关文档

- [README.md](../README.md) - 项目说明
- [DEVELOPMENT_GUIDE.md](../DEVELOPMENT_GUIDE.md) - 完整开发指南
- [SPRINT_TRACKER.md](SPRINT_TRACKER.md) - Sprint 进度
- [SPRINT1_QUICKSTART.md](SPRINT1_QUICKSTART.md) - 快速开始

---

**最后更新**: 2024-09-30
**文档版本**: v1.0
**状态**: Sprint 1 完成，等待创建 Xcode 项目
