# Sprint 1 快速开始指南

## 🎯 Sprint 1 完成情况

恭喜！Sprint 1 已经成功完成，核心界面框架已经搭建完毕。

### ✅ 已完成的功能

1. **应用架构**
   - ✅ MVVM 架构基础
   - ✅ Combine 响应式框架
   - ✅ 生命周期管理
   - ✅ 后台电量优化

2. **导航结构**
   - ✅ TabView 三标签导航
   - ✅ 监测页面
   - ✅ 统计页面（占位）
   - ✅ 设置页面（占位）

3. **监测功能**
   - ✅ AirPods 连接状态检测
   - ✅ 实时姿态数据显示（俯仰/偏航/翻滚）
   - ✅ 开始/停止监测控制
   - ✅ 会话统计（时长/偏差次数/采样率）
   - ✅ 偏差可视化指示器

4. **可复用组件**
   - ✅ StatusCard - 状态卡片
   - ✅ ConnectionIndicator - 连接指示器
   - ✅ ActionButton - 操作按钮

5. **用户体验**
   - ✅ 触觉反馈
   - ✅ 暗色模式支持
   - ✅ 动画效果
   - ✅ 使用提示

## 🚀 如何运行项目

### 前置要求

```bash
# 系统要求
- macOS 13.0+ (Ventura)
- Xcode 15.0+
- iOS 14.0+ 设备或模拟器
- AirPods Pro 或 AirPods (3rd generation) - 真机测试用
```

### 步骤 1: 克隆或打开项目

```bash
cd ~/my-devs/swift/PostureTracker\ 2
```

### 步骤 2: 安装依赖

如果使用 CocoaPods：
```bash
pod install
```

如果使用 SPM（推荐）：
- Xcode 会自动解析依赖

### 步骤 3: 在 Xcode 中打开

```bash
# 如果使用 CocoaPods
open PostureTracker.xcworkspace

# 如果使用 SPM
open PostureTracker.xcodeproj
```

### 步骤 4: 配置签名

1. 在 Xcode 中选择项目
2. 选择 Target: `PostureTracker`
3. 进入 `Signing & Capabilities`
4. 选择你的 Team
5. 确保 Bundle Identifier 唯一

### 步骤 5: 构建并运行

```bash
# 命令行方式（如果配置了 Makefile）
make build
make run

# 或者在 Xcode 中
# 1. 选择目标设备（iPhone 模拟器或真机）
# 2. 点击 ▶️ 运行按钮
# 3. 或按 Cmd + R
```

### 步骤 6: 测试功能

#### 模拟器测试（有限功能）
- ✅ 查看 UI 界面
- ✅ 测试导航切换
- ✅ 测试按钮交互
- ❌ 无法测试真实传感器数据

#### 真机测试（完整功能）
1. 佩戴 AirPods Pro 或 AirPods 3
2. 确保 AirPods 已连接到 iPhone
3. 打开应用
4. 点击"开始监测"
5. 移动头部查看姿态变化

## 📱 功能演示

### 1. 监测页面

```
监测页面功能清单：
✅ AirPods 连接状态卡片
  - 实时显示连接状态
  - 设备信息展示
  - 状态指示灯（红/橙/绿）

✅ 当前姿态显示
  - 俯仰角度 (Pitch)
  - 偏航角度 (Yaw)
  - 翻滚角度 (Roll)
  - 偏差指示器

✅ 控制按钮
  - 开始监测（蓝色主按钮）
  - 停止监测
  - 暂停功能
  - 重置会话

✅ 会话统计
  - 实时计时器
  - 偏差次数统计
  - 当前采样率显示

✅ 使用提示
  - 佩戴引导
  - 校准建议
  - 使用建议
```

### 2. 统计页面（占位）

```
即将推出：
📊 姿态趋势图表
📊 训练时长统计
📊 偏差分析
⭐ 训练成就
```

### 3. 设置页面（占位）

```
设置结构：
⚙️ 监测设置
  - 采样率选择
  - 灵敏度调节
  - 提示延迟

🔊 音频反馈
  - 提示音音量
  - 语音提示开关
  - 勿扰模式

📦 数据和隐私
  - 云端同步
  - 数据导出
  - 清除数据

🎨 外观
  - 主题切换
  - 字体大小

ℹ️ 关于
  - 应用信息
  - 版本号
  - 许可证
```

## 🔍 代码结构

### 核心文件说明

```
PostureTracker/
├── App/
│   └── PostureTrackerApp.swift      # 应用入口，生命周期管理
│
├── Views/
│   ├── ContentView.swift            # 主导航结构（TabView）
│   ├── MonitoringView.swift         # 监测页面（核心功能）
│   ├── StatisticsView.swift         # 统计页面（占位）
│   ├── SettingsView.swift           # 设置页面（占位）
│   │
│   └── Components/
│       ├── StatusCard.swift         # 状态卡片组件
│       ├── ConnectionIndicator.swift # 连接指示器
│       └── ActionButton.swift       # 操作按钮
│
├── Models/
│   ├── Posture.swift                # 姿态数据模型
│   ├── MotionData.swift             # 运动数据模型
│   └── Session.swift                # 会话数据模型
│
├── Services/
│   ├── AirPodsMotionManager.swift   # 传感器管理（已完成）
│   └── AudioFeedbackManager.swift   # 音频反馈（已完成）
│
└── ViewModels/                      # 待实现（Sprint 3）
```

## 🧪 测试建议

### 界面测试

```bash
测试场景：
1. ✅ 启动应用，查看监测页面
2. ✅ 切换到统计页面
3. ✅ 切换到设置页面
4. ✅ 点击"开始监测"按钮（无 AirPods 时显示错误）
5. ✅ 查看状态卡片的不同状态
6. ✅ 测试暗色模式切换（系统设置）
7. ✅ 点击工具栏的校准按钮
8. ✅ 查看关于页面
```

### 真机测试（需要 AirPods）

```bash
测试场景：
1. 佩戴 AirPods，确认连接
2. 打开应用，查看连接状态指示器变为绿色
3. 点击"开始监测"
4. 保持坐姿静止 5 秒
5. 缓慢前倾头部，观察俯仰角度变化
6. 左右转头，观察偏航角度变化
7. 侧倾头部，观察翻滚角度变化
8. 观察偏差指示器颜色变化
9. 查看会话统计的实时更新
10. 点击"停止监测"
```

## ⚠️ 已知限制

### 当前版本限制

```
1. 模拟器限制
   - ❌ 无法测试 AirPods 连接
   - ❌ 无法获取真实传感器数据
   - ✅ 可以测试 UI 交互

2. 功能限制
   - ⏳ 统计页面仅占位
   - ⏳ 设置页面功能未实现
   - ⏳ 校准功能未完成
   - ⏳ 无数据持久化

3. 传感器方案
   - ✅ 使用 CMHeadphoneMotionManager（备选方案）
   - ❌ 未使用 SensorKit（需要 Apple 批准）
```

### 传感器数据说明

```swift
// 当前实现使用 CMHeadphoneMotionManager
// 优点：无需特殊权限，立即可用
// 限制：精度可能不如 SensorKit

// 支持的设备：
✅ AirPods Pro (1st & 2nd generation)
✅ AirPods (3rd generation)
✅ AirPods Max
❌ AirPods (1st & 2nd generation) - 不支持
```

## 🐛 故障排除

### 问题 1: AirPods 显示未连接

```bash
解决方案：
1. 确认 AirPods 已连接到 iPhone
2. 在设置 > 蓝牙中查看连接状态
3. 重新佩戴 AirPods
4. 重启应用
```

### 问题 2: 构建失败

```bash
解决方案：
1. 清理构建缓存: Cmd + Shift + K
2. 清理 DerivedData: Cmd + Shift + Option + K
3. 重新安装依赖: pod install 或 File > Packages > Reset Package Caches
4. 重启 Xcode
```

### 问题 3: 运行时崩溃

```bash
检查项：
1. 查看 Xcode 控制台错误信息
2. 确认所有模型文件存在
3. 确认权限配置正确（Info.plist）
4. 检查 AirPodsMotionManager 初始化
```

### 问题 4: 数据不更新

```bash
调试步骤：
1. 确认 isTracking 状态为 true
2. 查看控制台日志输出
3. 检查 Combine 订阅是否正常
4. 验证 @ObservedObject 绑定
```

## 📚 下一步学习资源

### Sprint 2 准备

```
需要学习的技术：
1. SceneKit 基础
   - 3D 场景搭建
   - 节点和几何体
   - 材质和光照

2. Swift Charts
   - 图表类型
   - 数据绑定
   - 自定义样式

3. 数据可视化
   - 颜色理论
   - 图表设计原则
   - 动画效果
```

### 推荐文档

```
Apple 官方文档：
- SwiftUI Views and Controls
- Combine Framework
- Core Motion
- SceneKit
- Swift Charts

第三方资源：
- Hacking with Swift - SwiftUI by Example
- SwiftUI Lab - Advanced Techniques
- objc.io - Thinking in SwiftUI
```

## 🎯 Sprint 2 预告

### 即将开发的功能

```
Sprint 2: 数据可视化界面（4-5 天）

1. 3D 姿态展示
   - SceneKit 集成
   - 头部模型渲染
   - 实时旋转更新
   - 性能优化（60fps）

2. 统计图表
   - Swift Charts 集成
   - 折线图（姿态趋势）
   - 柱状图（训练时长）
   - 日期筛选功能

3. 会话统计卡片
   - 详细数据展示
   - 分享功能
   - 数据格式化
```

### 开发建议

```
1. 优先级
   ⭐⭐⭐ 3D 姿态可视化（核心功能）
   ⭐⭐⭐ 统计图表（用户体验）
   ⭐⭐ 会话统计卡片（数据展示）

2. 技术准备
   - 研究 SceneKit 示例代码
   - 学习 Swift Charts API
   - 准备测试数据

3. 时间分配
   - 3D 可视化：2-3 天
   - 统计图表：1-2 天
   - 统计卡片：1 天
```

## 💡 最佳实践

### 代码规范

```swift
// 1. 使用有意义的命名
✅ Good: var sessionDuration: TimeInterval
❌ Bad:  var dur: Double

// 2. 添加完整注释
✅ Good: /// 开始监测姿态数据
         func startTracking()
❌ Bad:  func startTracking()

// 3. 使用类型注解
✅ Good: @State private var isTracking: Bool = false
❌ Bad:  @State private var isTracking = false

// 4. 组织代码结构
✅ 使用 MARK: - 分组
✅ 属性 > 初始化 > Body > 子视图 > 方法
```

### Git 提交规范

```bash
# 功能提交
git commit -m "feat: 添加 3D 姿态可视化"

# 修复提交
git commit -m "fix: 修复连接状态更新问题"

# 文档提交
git commit -m "docs: 更新 Sprint 1 完成文档"

# 样式提交
git commit -m "style: 优化按钮阴影效果"
```

## 📞 获取帮助

### 遇到问题？

```
1. 查看控制台日志
   - Xcode 底部控制台
   - 筛选错误和警告

2. 查看文档
   - README.md
   - DEVELOPMENT_GUIDE.md
   - SPRINT_TRACKER.md

3. 调试技巧
   - 使用断点
   - print() 输出
   - LLDB 调试器

4. 社区支持
   - Stack Overflow
   - Swift Forums
   - Reddit r/iOSProgramming
```

## 🎉 恭喜！

你已经完成了 Sprint 1 的所有任务！

**下一步**: 开始 Sprint 2 - 数据可视化界面开发

**当前进度**: 第二阶段 33% 完成 (1/3 Sprint)

---

**文档版本**: v1.0
**最后更新**: 2024-09-30
**作者**: PostureTracker Team
