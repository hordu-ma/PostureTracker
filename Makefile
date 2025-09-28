# PostureTracker Makefile
# 自动化构建、测试和部署任务

# 配置变量
PROJECT_NAME = PostureTracker
SCHEME = PostureTracker
WORKSPACE = $(PROJECT_NAME).xcworkspace
PROJECT = $(PROJECT_NAME).xcodeproj
SIMULATOR = iPhone 15 Pro
IOS_VERSION = 17.0
BUILD_DIR = build
COVERAGE_DIR = coverage

# 颜色输出
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
NC = \033[0m # No Color

.PHONY: help
help: ## 显示帮助信息
	@echo "$(GREEN)PostureTracker 构建系统$(NC)"
	@echo "使用方法: make [目标]"
	@echo ""
	@echo "可用目标:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'

.PHONY: setup
setup: ## 初始化项目环境
	@echo "$(GREEN)正在初始化项目环境...$(NC)"
	@./setup.sh

.PHONY: install
install: ## 安装项目依赖
	@echo "$(GREEN)正在安装 CocoaPods 依赖...$(NC)"
	@pod install --repo-update
	@echo "$(GREEN)依赖安装完成！$(NC)"

.PHONY: clean
clean: ## 清理构建产物
	@echo "$(YELLOW)正在清理构建产物...$(NC)"
	@rm -rf $(BUILD_DIR)
	@rm -rf ~/Library/Developer/Xcode/DerivedData/$(PROJECT_NAME)-*
	@xcodebuild clean -workspace $(WORKSPACE) -scheme $(SCHEME) -quiet
	@echo "$(GREEN)清理完成！$(NC)"

.PHONY: build
build: ## 构建项目（Debug）
	@echo "$(GREEN)正在构建项目...$(NC)"
	@xcodebuild build \
		-workspace $(WORKSPACE) \
		-scheme $(SCHEME) \
		-configuration Debug \
		-destination "platform=iOS Simulator,name=$(SIMULATOR),OS=$(IOS_VERSION)" \
		-derivedDataPath $(BUILD_DIR) \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO \
		CODE_SIGNING_ALLOWED=NO \
		| xcpretty
	@echo "$(GREEN)构建成功！$(NC)"

.PHONY: build-release
build-release: ## 构建项目（Release）
	@echo "$(GREEN)正在构建 Release 版本...$(NC)"
	@xcodebuild build \
		-workspace $(WORKSPACE) \
		-scheme $(SCHEME) \
		-configuration Release \
		-destination "platform=iOS Simulator,name=$(SIMULATOR),OS=$(IOS_VERSION)" \
		-derivedDataPath $(BUILD_DIR) \
		CODE_SIGN_IDENTITY="" \
		CODE_SIGNING_REQUIRED=NO \
		| xcpretty
	@echo "$(GREEN)Release 构建成功！$(NC)"

.PHONY: run
run: build ## 在模拟器中运行应用
	@echo "$(GREEN)正在启动应用...$(NC)"
	@xcrun simctl boot "$(SIMULATOR)" 2>/dev/null || true
	@open -a Simulator
	@xcodebuild install \
		-workspace $(WORKSPACE) \
		-scheme $(SCHEME) \
		-destination "platform=iOS Simulator,name=$(SIMULATOR),OS=$(IOS_VERSION)" \
		-derivedDataPath $(BUILD_DIR) \
		| xcpretty
	@xcrun simctl launch booted com.yourcompany.$(PROJECT_NAME)

.PHONY: test
test: ## 运行单元测试
	@echo "$(GREEN)正在运行单元测试...$(NC)"
	@xcodebuild test \
		-workspace $(WORKSPACE) \
		-scheme $(SCHEME) \
		-destination "platform=iOS Simulator,name=$(SIMULATOR),OS=$(IOS_VERSION)" \
		-enableCodeCoverage YES \
		| xcpretty --test
	@echo "$(GREEN)测试完成！$(NC)"

.PHONY: ui-test
ui-test: ## 运行 UI 测试
	@echo "$(GREEN)正在运行 UI 测试...$(NC)"
	@xcodebuild test \
		-workspace $(WORKSPACE) \
		-scheme "$(SCHEME)UITests" \
		-destination "platform=iOS Simulator,name=$(SIMULATOR),OS=$(IOS_VERSION)" \
		| xcpretty --test
	@echo "$(GREEN)UI 测试完成！$(NC)"

.PHONY: coverage
coverage: test ## 生成测试覆盖率报告
	@echo "$(GREEN)正在生成覆盖率报告...$(NC)"
	@mkdir -p $(COVERAGE_DIR)
	@xcrun llvm-cov export \
		-format=lcov \
		-instr-profile $(BUILD_DIR)/Build/ProfileData/*/Coverage.profdata \
		$(BUILD_DIR)/Build/Products/Debug-iphonesimulator/$(PROJECT_NAME).app/$(PROJECT_NAME) \
		> $(COVERAGE_DIR)/coverage.lcov
	@echo "$(GREEN)覆盖率报告已生成: $(COVERAGE_DIR)/coverage.lcov$(NC)"

.PHONY: lint
lint: ## 运行代码检查
	@echo "$(GREEN)正在运行 SwiftLint...$(NC)"
	@if [ -f Pods/SwiftLint/swiftlint ]; then \
		Pods/SwiftLint/swiftlint; \
	else \
		swiftlint; \
	fi
	@echo "$(GREEN)代码检查完成！$(NC)"

.PHONY: format
format: ## 格式化代码
	@echo "$(GREEN)正在格式化代码...$(NC)"
	@if [ -f Pods/SwiftLint/swiftlint ]; then \
		Pods/SwiftLint/swiftlint autocorrect; \
	else \
		swiftlint autocorrect; \
	fi
	@echo "$(GREEN)代码格式化完成！$(NC)"

.PHONY: archive
archive: ## 创建应用归档
	@echo "$(GREEN)正在创建归档...$(NC)"
	@xcodebuild archive \
		-workspace $(WORKSPACE) \
		-scheme $(SCHEME) \
		-configuration Release \
		-archivePath $(BUILD_DIR)/$(PROJECT_NAME).xcarchive \
		| xcpretty
	@echo "$(GREEN)归档创建成功！$(NC)"

.PHONY: export-ipa
export-ipa: archive ## 导出 IPA 文件
	@echo "$(GREEN)正在导出 IPA...$(NC)"
	@xcodebuild -exportArchive \
		-archivePath $(BUILD_DIR)/$(PROJECT_NAME).xcarchive \
		-exportPath $(BUILD_DIR) \
		-exportOptionsPlist ExportOptions.plist \
		| xcpretty
	@echo "$(GREEN)IPA 导出成功: $(BUILD_DIR)/$(PROJECT_NAME).ipa$(NC)"

.PHONY: docs
docs: ## 生成文档
	@echo "$(GREEN)正在生成文档...$(NC)"
	@jazzy \
		--clean \
		--author "Your Name" \
		--module $(PROJECT_NAME) \
		--output docs/api \
		--theme apple
	@echo "$(GREEN)文档生成完成: docs/api/index.html$(NC)"

.PHONY: reset
reset: clean ## 重置项目（清理并重新安装依赖）
	@echo "$(YELLOW)正在重置项目...$(NC)"
	@rm -rf Pods
	@rm -f Podfile.lock
	@$(MAKE) install
	@echo "$(GREEN)项目重置完成！$(NC)"

.PHONY: check-env
check-env: ## 检查开发环境
	@echo "$(GREEN)检查开发环境...$(NC)"
	@echo "Xcode 版本:"
	@xcodebuild -version
	@echo "\nCocoaPods 版本:"
	@pod --version
	@echo "\nSwift 版本:"
	@swift --version
	@echo "\n可用模拟器:"
	@xcrun simctl list devices | grep "iPhone"
	@echo "$(GREEN)环境检查完成！$(NC)"

.PHONY: firebase-deploy
firebase-deploy: ## 部署到 Firebase
	@echo "$(GREEN)正在部署到 Firebase...$(NC)"
	@firebase deploy --only hosting
	@echo "$(GREEN)Firebase 部署完成！$(NC)"

# 默认目标
.DEFAULT_GOAL := help