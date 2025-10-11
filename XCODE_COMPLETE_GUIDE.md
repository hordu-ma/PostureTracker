# Xcode 完整操作指南 - PostureTracker 项目

**目标读者**: Xcode 新手
**预计阅读时间**: 15 分钟
**实际操作时间**: 2-3 小时

---

## 📱 第一部分：打开和理解 Xcode

### Step 1: 打开项目（2 分钟）

#### 方式 1: 通过 Finder（推荐新手）

1. 打开 Finder（访达）
2. 导航到：`/Users/liguoma/my-devs/swift/PostureTracker 2/`
3. 找到 `PostureTracker.xcodeproj` 文件（蓝色图标）
4. **双击** 打开

#### 方式 2: 通过终端

```bash
cd "/Users/liguoma/my-devs/swift/PostureTracker 2"
open PostureTracker.xcodeproj
```

#### ⚠️ 注意事项

- 如果有 `.xcworkspace` 文件，优先打开它（CocoaPods 项目）
- 第一次打开可能需要等待 Xcode 索引文件（1-2 分钟）

---

### Step 2: 理解 Xcode 界面（5 分钟）

打开后，您会看到 Xcode 分为几个区域：

```
┌─────────────────────────────────────────────────────┐
│  Toolbar (工具栏)                                     │
├──────────┬────────────────────────┬─────────────────┤
│          │                        │                 │
│ Navigator│   Editor Area          │  Inspector      │
│ (导航栏)  │   (编辑区)              │  (检查器)        │
│          │                        │                 │
│  文件列表  │   代码编辑区域           │   属性设置       │
│          │                        │                 │
├──────────┴────────────────────────┴─────────────────┤
│  Debug Area (调试区)                                 │
│  控制台输出、变量查看                                  │
└─────────────────────────────────────────────────────┘
```

#### 关键区域说明：

**1. Navigator（左侧）** - 快捷键 `Cmd+1` 到 `Cmd+9`

- `Cmd+1`: 文件导航器（最常用）
- `Cmd+2`: 符号导航器
- `Cmd+5`: 断点导航器
- `Cmd+6`: 测试导航器

**2. Editor Area（中间）**

- 代码编辑区域
- 可以同时打开多个文件（标签页）

**3. Inspector（右侧）** - 快捷键 `Cmd+Option+1` 到 `Cmd+Option+6`

- 文件属性
- 快速帮助
- 身份检查器

**4. Toolbar（顶部）**

- 运行/停止按钮（左侧）
- 设备选择（中间）
- 显示/隐藏按钮（右侧）

#### 💡 快捷键提示

- `Cmd+B`: 编译项目
- `Cmd+R`: 运行项目
- `Cmd+.`: 停止运行
- `Cmd+U`: 运行测试
- `Cmd+Shift+K`: 清理构建
- `Cmd+0`: 显示/隐藏导航器
- `Cmd+Option+0`: 显示/隐藏检查器

---

## 🔧 第二部分：项目配置（必做任务）

### Task 1: 验证文件结构（5 分钟）

#### 操作步骤：

1. 在左侧 **Navigator** 中，确保选中 **文件导航器**（`Cmd+1`）
2. 展开 `PostureTracker` 文件夹
3. 验证以下文件夹都存在：
   ```
   PostureTracker/
   ├── App/
   │   └── PostureTrackerApp.swift ✓
   ├── Configuration/
   │   └── Config.local.swift ✓
   ├── Managers/
   │   └── SettingsManager.swift ✓
   ├── Models/
   │   ├── MotionData.swift ✓
   │   ├── Posture.swift ✓
   │   └── Session.swift ✓
   ├── ViewModels/
   │   ├── MotionViewModel.swift ✓
   │   ├── SessionViewModel.swift ✓
   │   └── StatisticsViewModel.swift ✓
   ├── Views/
   │   ├── ContentView.swift ✓
   │   ├── MonitoringView.swift ✓
   │   ├── StatisticsView.swift ✓
   │   ├── SettingsView.swift ✓
   │   ├── PermissionsView.swift ✓
   │   └── PrivacyPolicyView.swift ✓
   ├── Services/
   │   ├── AirPodsMotionManager.swift ✓
   │   └── AudioFeedbackManager.swift ✓
   └── Utils/
       └── FileExportManager.swift ✓
   ```

#### ⚠️ 如果发现文件缺失：

1. 在 Finder 中找到缺失的文件
2. 拖拽到 Xcode 左侧对应文件夹
3. 在弹出对话框中勾选：
   - ✓ Copy items if needed
   - ✓ Create groups
   - ✓ Add to targets: PostureTracker

---

### Task 2: 配置项目基本信息（10 分钟）

#### 2.1 打开项目设置

1. 在左侧 Navigator 中点击 **最顶部的蓝色项目图标** `PostureTracker`
2. 在中间区域会看到项目设置

#### 2.2 配置 General（通用设置）

##### 在 **TARGETS > PostureTracker > General** 中：

**Identity（身份）**:

```
Display Name: PostureTracker
Bundle Identifier: com.posturetracker.app
Version: 1.0
Build: 1
```

**Deployment Info（部署信息）**:

```
iOS Deployment Target: 14.0
Device Orientation:
  ✓ Portrait
  ☐ Landscape Left
  ☐ Landscape Right
  ☐ Upside Down
```

**App Icons and Launch Screen（图标和启动屏）**:

```
App Icon Source: AppIcon (稍后设置)
Launch Screen: 暂时留空（稍后创建）
```

#### 2.3 配置 Signing & Capabilities（签名和能力）

1. 切换到 **Signing & Capabilities** 标签
2. 选择 **Automatically manage signing**（自动管理签名）
3. 在 **Team** 下拉菜单中：
   - 如果有 Apple Developer 账号：选择您的团队
   - 如果没有：选择 "Add an Account..." 并登录

**添加必要的 Capabilities:** 4. 点击 **+ Capability** 按钮 5. 搜索并添加：

- ✓ **Motion** (如果需要)
- 其他暂不需要

---

### Task 3: 配置 Info.plist（最重要！）（15 分钟）

#### 3.1 找到 Info.plist

**选项 A: 通过 Navigator**

1. 在左侧文件列表中找到 `Info.plist`
2. 如果没有，可能在 `PostureTracker/Supporting Files/` 下

**选项 B: 创建 Info.plist（如果不存在）**

1. 右键点击 `PostureTracker` 文件夹
2. 选择 **New File...**
3. 选择 **iOS > Resource > Property List**
4. 命名为 `Info.plist`

#### 3.2 添加权限描述（关键步骤！）

在 `Info.plist` 中，您可以通过两种方式编辑：

**方式 1: Property List 视图（推荐新手）**

1. 点击 `Info.plist` 文件
2. 右键点击空白处，选择 **Add Row**
3. 添加以下键值对：

| Key                                      | Type   | Value                                                           |
| ---------------------------------------- | ------ | --------------------------------------------------------------- |
| `Privacy - Motion Usage Description`     | String | PostureTracker 需要访问运动数据来监测您的头部姿态，帮助改善坐姿 |
| `Privacy - Microphone Usage Description` | String | PostureTracker 需要访问麦克风以提供语音反馈功能                 |

**方式 2: Source Code 视图**

1. 右键点击 `Info.plist`
2. 选择 **Open As > Source Code**
3. 在 `<dict>` 标签内添加：

```xml
<key>NSMotionUsageDescription</key>
<string>PostureTracker 需要访问运动数据来监测您的头部姿态，帮助改善坐姿</string>

<key>NSMicrophoneUsageDescription</key>
<string>PostureTracker 需要访问麦克风以提供语音反馈功能</string>

<key>UILaunchScreen</key>
<dict>
    <key>UIColorName</key>
    <string></string>
    <key>UIImageName</key>
    <string></string>
</dict>
```

#### 3.3 验证配置

保存文件后（`Cmd+S`），确保没有语法错误。

---

### Task 4: 设置应用图标（15 分钟）

#### 4.1 准备图标（暂时可以跳过，使用占位符）

**如果您现在没有图标设计：**

- 可以先使用占位符
- 项目可以正常运行和测试
- 上架前必须准备真实图标

**如果您有图标设计：**
需要一个 **1024x1024 像素的 PNG 图片**

#### 4.2 添加图标到项目

1. 在 Navigator 中找到：

   ```
   PostureTracker/Resources/Assets.xcassets/AppIcon.appiconset
   ```

2. 点击 `AppIcon` 进入图标设置页面

3. **如果有图标文件：**

   - 将 1024x1024 的图片拖拽到 **App Store iOS 1024pt** 格子中
   - Xcode 会自动生成其他尺寸

4. **如果暂时没有图标：**
   - 保持现状即可
   - 应用会显示默认图标

#### 💡 图标设计建议

- 简洁明了
- 避免文字
- 使用品牌色
- 高对比度
- 在线工具：[AppIconizer](https://www.appiconizercom/)

---

### Task 5: 创建启动画面（10 分钟）

#### 5.1 使用 LaunchScreen.storyboard（推荐）

1. **创建 Launch Screen 文件：**

   - 右键点击 `PostureTracker` 文件夹
   - 选择 **New File...**
   - 选择 **iOS > User Interface > Launch Screen**
   - 命名为 `LaunchScreen.storyboard`
   - 点击 **Create**

2. **编辑启动画面：**

   - 双击打开 `LaunchScreen.storyboard`
   - 从右下角 **Object Library** 拖拽元素：
     - `UIImageView` - 用于 Logo
     - `UILabel` - 用于应用名称
   - 设置约束（Auto Layout）

3. **简单示例 - 纯色背景 + 文字：**

   - 拖拽一个 `UILabel` 到中心
   - 双击修改文字为 "PostureTracker"
   - 设置字体大小为 24pt
   - 添加居中约束：
     - 选中 Label
     - 点击底部 **Add New Constraints**
     - 勾选 "Horizontally in Container"
     - 勾选 "Vertically in Container"
     - 点击 **Add Constraints**

4. **连接到项目：**
   - 返回项目设置（点击蓝色项目图标）
   - **TARGETS > PostureTracker > General**
   - 在 **App Icons and Launch Screen** 部分
   - **Launch Screen File**: 选择 `LaunchScreen`

#### 5.2 使用 Assets（更简单）

**如果觉得 Storyboard 复杂，可以使用这个方法：**

1. 在 `Assets.xcassets` 中创建颜色或图片
2. 在项目设置中配置 Launch Screen

---

## 🔨 第三部分：编译和测试（30 分钟）

### Task 6: 第一次编译（5 分钟）

#### 6.1 清理构建文件夹

```
菜单栏 > Product > Clean Build Folder
或快捷键: Cmd+Shift+K
```

#### 6.2 开始编译

```
菜单栏 > Product > Build
或快捷键: Cmd+B
```

#### 6.3 查看编译结果

**成功标志：**

- 顶部状态栏显示 **Build Succeeded**
- 左侧 Navigator 没有红色错误标记

**如果有错误：**

1. 点击左侧 **Issue Navigator**（`Cmd+5`）
2. 查看错误列表
3. 点击错误可以跳转到对应代码
4. 常见错误及解决方法见下文

---

### Task 7: 运行模拟器（10 分钟）

#### 7.1 选择模拟器设备

1. 在 Xcode 顶部工具栏，找到设备选择器（Run 按钮右边）
2. 点击下拉菜单
3. 选择一个模拟器，推荐：
   ```
   iPhone 15 Pro (iOS 17.0)
   或
   iPhone 14 (iOS 16.0)
   ```

#### 7.2 运行应用

**方式 1: 点击 Run 按钮**

- 点击左上角 **播放按钮** ▶️

**方式 2: 快捷键**

```
Cmd+R
```

#### 7.3 首次运行流程

1. **编译过程**（10-30 秒）

   - 状态栏显示 "Building..."
   - 底部调试区显示编译日志

2. **启动模拟器**（10-20 秒）

   - 模拟器窗口自动打开
   - 显示 iOS 启动画面

3. **应用安装和运行**（5-10 秒）
   - 应用图标出现在模拟器主屏幕
   - 自动打开应用

#### 7.4 测试应用功能

**基本功能测试清单：**

- [ ] 应用能正常启动
- [ ] TabBar 可以切换三个页面
- [ ] 监测页面界面正常显示
- [ ] 统计页面图表显示
- [ ] 设置页面可以打开
- [ ] 没有崩溃或明显错误

---

### Task 8: 运行单元测试（10 分钟）

#### 8.1 打开测试导航器

```
快捷键: Cmd+6
或点击左侧 Navigator 中的测试图标
```

#### 8.2 运行所有测试

**方式 1: 运行全部**

```
菜单栏 > Product > Test
或快捷键: Cmd+U
```

**方式 2: 运行单个测试**

1. 在测试导航器中展开测试文件
2. 点击测试方法旁边的 **◇** 图标

#### 8.3 查看测试结果

**成功标志：**

- 所有测试旁边显示 **绿色 ✓**
- 状态栏显示 "Test Succeeded"

**如果有失败：**

- 失败的测试显示 **红色 ✗**
- 点击可查看失败原因
- 在代码中修复问题

#### 8.4 查看测试覆盖率

1. 运行测试后
2. 菜单栏 > Editor > Show Code Coverage
3. 文件旁边会显示覆盖率百分比

---

## 📱 第四部分：真机测试（1 小时）

### Task 9: 连接真实设备（10 分钟）

#### 9.1 准备工作

- **需要**：iPhone（iOS 14.0+）
- **需要**：数据线（USB-C 或 Lightning）
- **需要**：Apple ID（免费或付费）

#### 9.2 连接设备

1. **用数据线连接 iPhone 到 Mac**
2. **在 iPhone 上点击"信任此电脑"**
3. **在 Xcode 中：**
   - 顶部设备选择器会显示您的设备名称
   - 例如："liguoma 的 iPhone"

#### 9.3 配置设备信任

**第一次在真机上运行需要：**

1. 在 iPhone 上：

   ```
   设置 > 通用 > VPN与设备管理
   > 开发者App
   > 信任 "您的 Apple ID"
   ```

2. 点击 **信任**

---

### Task 10: 真机运行（10 分钟）

#### 10.1 选择真机设备

在 Xcode 顶部设备选择器中选择您的 iPhone

#### 10.2 运行应用

```
Cmd+R
或点击 Run 按钮
```

#### 10.3 首次真机运行

**可能遇到的问题：**

**问题 1: "Untrusted Developer"**

```
解决方法：
1. 在 iPhone 上打开"设置"
2. 通用 > VPN与设备管理
3. 找到您的开发者账号
4. 点击"信任"
```

**问题 2: "Code Signing Error"**

```
解决方法：
1. 返回 Xcode
2. TARGETS > Signing & Capabilities
3. 确保 "Automatically manage signing" 已勾选
4. 选择正确的 Team
```

---

### Task 11: 测试 AirPods 功能（30 分钟）

#### 11.1 准备 AirPods

- AirPods Pro 或 AirPods (3rd generation)
- 确保已配对到 iPhone
- 确保电量充足

#### 11.2 测试传感器连接

1. **戴上 AirPods**
2. **打开应用**
3. **检查连接状态：**
   - 监测页面应显示 "已连接"
   - 连接指示器应为绿色

#### 11.3 测试姿态监测

**测试步骤：**

1. 点击 "开始监测" 按钮
2. 保持正常坐姿 3 秒
3. 慢慢点头（前倾）
4. 观察：
   - [ ] 3D 模型随头部移动旋转
   - [ ] 角度数值实时更新
   - [ ] 偏差指示器变为橙色/红色
5. 恢复正常姿态
6. 观察：
   - [ ] 偏差指示器变回绿色
   - [ ] 偏差次数有增加

#### 11.4 测试音频反馈

1. 在设置中启用音频反馈
2. 开始监测
3. 故意偏离姿态
4. 检查：
   - [ ] 听到提示音
   - [ ] 听到语音提示（如启用）

#### 11.5 性能检查

**使用 Xcode Instruments:**

1. 菜单栏 > Product > Profile (Cmd+I)
2. 选择 **Time Profiler**
3. 点击录制按钮
4. 操作应用 1-2 分钟
5. 停止录制
6. 检查：
   - CPU 使用率应 < 30%
   - 帧率应保持在 55-60 fps

---

## ⚠️ 常见问题和解决方法

### 编译错误

#### 错误 1: "Cannot find 'X' in scope"

**原因**: 文件没有正确添加到项目
**解决**:

1. 在 Finder 中找到该文件
2. 拖拽到 Xcode 项目
3. 确保勾选正确的 Target

#### 错误 2: "Missing required module"

**原因**: 缺少 Framework
**解决**:

1. 项目设置 > General
2. Frameworks, Libraries, and Embedded Content
3. 点击 + 添加缺失的框架

#### 错误 3: "Code Signing Error"

**原因**: 签名配置问题
**解决**:

1. Signing & Capabilities
2. 确保 Team 已选择
3. 尝试手动指定证书

### 运行时错误

#### 问题 1: 应用启动后立即崩溃

**排查方法**:

1. 查看控制台输出（底部调试区）
2. 寻找红色错误信息
3. 检查是否缺少必需的权限描述

#### 问题 2: AirPods 无法连接

**排查方法**:

1. 检查 AirPods 是否配对成功
2. 检查是否授予运动权限
3. 重启应用
4. 重新配对 AirPods

#### 问题 3: 3D 模型不显示

**排查方法**:

1. 检查 SceneKit 是否正确导入
2. 检查模拟器是否支持（某些模拟器不支持完整的 3D 渲染）
3. 尝试真机测试

---

## 📋 快速检查清单

### 编译前检查

- [ ] 所有文件已添加到项目
- [ ] Info.plist 配置完成
- [ ] Signing 配置完成
- [ ] 应用图标已设置（可选）
- [ ] 启动画面已创建（可选）

### 测试前检查

- [ ] 项目可以成功编译（Cmd+B）
- [ ] 单元测试全部通过（Cmd+U）
- [ ] 模拟器可以运行
- [ ] 真机可以运行
- [ ] AirPods 已配对

### 发布前检查

- [ ] 所有功能已测试
- [ ] 性能达标（60fps）
- [ ] 无内存泄漏
- [ ] 应用图标已设置
- [ ] 启动画面已创建
- [ ] 版本号正确

---

## 💡 额外建议

### 1. 使用版本控制

```bash
# 在每个重要阶段提交
git add .
git commit -m "配置完成 Info.plist"
git push
```

### 2. 定期保存和备份

- Xcode 会自动保存，但建议每个重要步骤后手动保存（Cmd+S）
- 定期备份整个项目文件夹

### 3. 学习资源

- [Apple 官方文档](https://developer.apple.com/documentation/)
- [Xcode 快速入门](https://developer.apple.com/xcode/resources/)
- [SwiftUI 教程](https://developer.apple.com/tutorials/swiftui)

---

## 🎯 下一步

完成这份指南后，您应该能够：

1. ✅ 在 Xcode 中打开和导航项目
2. ✅ 配置项目基本信息
3. ✅ 编译和运行应用
4. ✅ 在模拟器和真机上测试
5. ✅ 解决常见问题

**准备好后，进入下一步：App Store 提交流程！**

---

**需要帮助？** 随时可以：

1. 查看官方文档
2. 在开发者论坛提问
3. 或者联系我继续获取指导

**祝您顺利！🚀**
