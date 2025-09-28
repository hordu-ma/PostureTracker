#!/bin/bash

# PostureTracker 项目初始化脚本
# 用于自动化环境配置和项目初始化

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印带颜色的信息
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 标题
echo "======================================"
echo "   PostureTracker 项目初始化脚本"
echo "======================================"
echo ""

# 步骤 1: 检查 Xcode
print_info "检查 Xcode 安装..."
if command_exists xcodebuild; then
    XCODE_VERSION=$(xcodebuild -version | head -n 1)
    print_success "已安装 $XCODE_VERSION"
    
    # 检查 Xcode 版本
    XCODE_VERSION_NUMBER=$(xcodebuild -version | grep Xcode | cut -d ' ' -f 2 | cut -d '.' -f 1)
    if [ "$XCODE_VERSION_NUMBER" -lt 15 ]; then
        print_warning "建议使用 Xcode 15.0 或更高版本"
    fi
else
    print_error "未找到 Xcode，请先安装 Xcode"
    exit 1
fi

# 步骤 2: 检查 CocoaPods
print_info "检查 CocoaPods..."
if command_exists pod; then
    POD_VERSION=$(pod --version)
    print_success "CocoaPods 版本: $POD_VERSION"
else
    print_warning "未安装 CocoaPods，正在安装..."
    sudo gem install cocoapods
    print_success "CocoaPods 安装完成"
fi

# 步骤 3: 检查 Firebase CLI
print_info "检查 Firebase CLI..."
if command_exists firebase; then
    FIREBASE_VERSION=$(firebase --version)
    print_success "Firebase CLI 版本: $FIREBASE_VERSION"
else
    print_warning "未安装 Firebase CLI"
    echo "建议安装 Firebase CLI 以使用云端功能"
    echo "安装命令: npm install -g firebase-tools"
fi

# 步骤 4: 检查 SwiftLint
print_info "检查 SwiftLint..."
if command_exists swiftlint; then
    SWIFTLINT_VERSION=$(swiftlint version)
    print_success "SwiftLint 版本: $SWIFTLINT_VERSION"
else
    print_warning "未安装 SwiftLint，建议安装以进行代码检查"
    echo "安装命令: brew install swiftlint"
fi

# 步骤 5: 创建必要的配置文件
print_info "创建配置文件..."

# 创建 SwiftLint 配置
if [ ! -f ".swiftlint.yml" ]; then
    cat > .swiftlint.yml << EOF
# SwiftLint 配置文件
disabled_rules:
  - trailing_whitespace
  - line_length
  - force_cast

opt_in_rules:
  - empty_count
  - closure_spacing
  - contains_over_first_not_nil
  - discouraged_optional_boolean
  - fallthrough
  - first_where
  - joined_default_parameter
  - overridden_super_call
  - redundant_nil_coalescing
  - sorted_first_last
  - trailing_semicolon
  - unneeded_break_in_switch
  - unused_closure_parameter

excluded:
  - Pods
  - .build
  - DerivedData
  - PostureTrackerTests

line_length:
  warning: 120
  error: 200

file_length:
  warning: 500
  error: 1000

type_body_length:
  warning: 300
  error: 500

function_body_length:
  warning: 50
  error: 100

cyclomatic_complexity:
  warning: 10
  error: 20

identifier_name:
  min_length:
    warning: 2
  max_length:
    warning: 40
    error: 50
  excluded:
    - id
    - x
    - y
    - z
    - w

reporter: "xcode"
EOF
    print_success "创建 .swiftlint.yml"
fi

# 创建本地配置文件模板
if [ ! -f "PostureTracker/Configuration/Config.local.swift" ]; then
    mkdir -p PostureTracker/Configuration
    cat > PostureTracker/Configuration/Config.local.swift << EOF
//
//  Config.local.swift
//  PostureTracker
//
//  本地配置文件（不要提交到版本控制）
//

import Foundation

struct LocalConfig {
    // Firebase 配置
    static let firebaseAPIKey = "YOUR_API_KEY"
    static let firebaseProjectID = "YOUR_PROJECT_ID"
    
    // 其他敏感配置
    static let analyticsKey = "YOUR_ANALYTICS_KEY"
    
    // 开发环境设置
    static let isDebugMode = true
    static let mockDataEnabled = false
}
EOF
    print_success "创建 Config.local.swift 模板"
fi

# 步骤 6: 安装 Pod 依赖
print_info "安装 Pod 依赖..."
if [ -f "Podfile" ]; then
    pod install --repo-update
    print_success "Pod 依赖安装完成"
else
    print_warning "未找到 Podfile，跳过 Pod 安装"
fi

# 步骤 7: 创建 Xcode 项目文件（如果不存在）
if [ ! -d "PostureTracker.xcodeproj" ]; then
    print_info "创建 Xcode 项目..."
    
    # 使用 xcodegen 或手动创建项目
    cat > project.yml << EOF
name: PostureTracker
options:
  bundleIdPrefix: com.yourcompany
  deploymentTarget:
    iOS: 14.0
settings:
  base:
    SWIFT_VERSION: 5.9
    IPHONEOS_DEPLOYMENT_TARGET: 14.0
targets:
  PostureTracker:
    type: application
    platform: iOS
    sources:
      - PostureTracker
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.yourcompany.PostureTracker
        INFOPLIST_FILE: PostureTracker/Info.plist
        CODE_SIGN_STYLE: Automatic
        DEVELOPMENT_TEAM: YOUR_TEAM_ID
    dependencies:
      - target: PostureTrackerTests
  PostureTrackerTests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - PostureTrackerTests
    dependencies:
      - target: PostureTracker
EOF
    
    if command_exists xcodegen; then
        xcodegen generate
        print_success "Xcode 项目创建完成"
    else
        print_warning "未安装 XcodeGen，请手动创建 Xcode 项目"
        print_info "安装 XcodeGen: brew install xcodegen"
    fi
fi

# 步骤 8: 创建 Info.plist
if [ ! -f "PostureTracker/Info.plist" ]; then
    print_info "创建 Info.plist..."
    cat > PostureTracker/Info.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>\$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleExecutable</key>
    <string>\$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>\$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>\$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>\$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <false/>
    </dict>
    <key>UILaunchScreen</key>
    <dict/>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>armv7</string>
    </array>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
    <key>NSMotionUsageDescription</key>
    <string>此应用需要访问运动传感器以追踪您的头部姿态</string>
    <key>NSSpeechRecognitionUsageDescription</key>
    <string>此应用需要语音识别权限以提供语音反馈</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>此应用需要麦克风权限以进行语音输入</string>
    <key>com.apple.developer.sensorkit.reader</key>
    <true/>
</dict>
</plist>
EOF
    print_success "Info.plist 创建完成"
fi

# 步骤 9: 创建示例 App 入口文件
if [ ! -f "PostureTracker/App/PostureTrackerApp.swift" ]; then
    print_info "创建 App 入口文件..."
    mkdir -p PostureTracker/App
    cat > PostureTracker/App/PostureTrackerApp.swift << EOF
//
//  PostureTrackerApp.swift
//  PostureTracker
//
//  应用程序入口
//

import SwiftUI
import Firebase

@main
struct PostureTrackerApp: App {
    
    init() {
        // 配置 Firebase
        // FirebaseApp.configure()
        
        // 其他初始化
        setupApp()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func setupApp() {
        // 应用级别的配置
        print("PostureTracker 启动中...")
    }
}
EOF
    print_success "App 入口文件创建完成"
fi

# 步骤 10: 创建主视图文件
if [ ! -f "PostureTracker/Views/ContentView.swift" ]; then
    print_info "创建主视图文件..."
    cat > PostureTracker/Views/ContentView.swift << EOF
//
//  ContentView.swift
//  PostureTracker
//
//  主视图容器
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "figure.stand")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                    .font(.system(size: 100))
                    .padding()
                
                Text("PostureTracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("基于 AirPods 的姿态追踪应用")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                
                Button(action: {
                    print("开始追踪")
                }) {
                    Text("开始追踪")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("PostureTracker")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
EOF
    print_success "主视图文件创建完成"
fi

# 步骤 11: 初始化 Git（如果需要）
if [ ! -d ".git" ]; then
    print_info "初始化 Git 仓库..."
    git init
    git add .
    git commit -m "Initial commit - PostureTracker project setup"
    print_success "Git 仓库初始化完成"
fi

# 步骤 12: 运行测试
print_info "运行初始测试..."
if [ -f "PostureTracker.xcworkspace" ]; then
    xcodebuild test \
        -workspace PostureTracker.xcworkspace \
        -scheme PostureTracker \
        -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.0' \
        > /dev/null 2>&1 && print_success "测试通过" || print_warning "测试未通过或未找到测试"
fi

# 完成提示
echo ""
echo "======================================"
echo -e "${GREEN}   ✓ 项目初始化完成！${NC}"
echo "======================================"
echo ""
echo "下一步操作："
echo "1. 打开 PostureTracker.xcworkspace"
echo "2. 配置开发团队和证书"
echo "3. 添加 Firebase 配置文件 (GoogleService-Info.plist)"
echo "4. 申请 SensorKit 权限"
echo "5. 运行项目: make run"
echo ""
echo "有用的命令："
echo "  make help     - 查看所有可用命令"
echo "  make build    - 构建项目"
echo "  make test     - 运行测试"
echo "  make lint     - 代码检查"
echo ""
print_success "祝您开发愉快！🚀"