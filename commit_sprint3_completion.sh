#!/bin/zsh
#
# Sprint 3 数据导出功能完成 - Git 提交脚本
# 创建日期: 2025-10-11
#

echo "🚀 准备提交 Sprint 3 数据导出功能..."

# 检查 Git 状态
echo "\n📋 当前 Git 状态："
git status

# 添加所有修改的文件
echo "\n➕ 添加修改的文件..."
git add PostureTracker/Utils/FileExportManager.swift
git add PostureTracker/Views/SettingsView.swift
git add PostureTrackerTests/FileExportManagerTests.swift
git add NEXT_STEPS.md
git add PROJECT_STATUS.md
git add Docs/SPRINT_TRACKER.md
git add SPRINT3_DATA_EXPORT_COMPLETION.md

# 显示将要提交的文件
echo "\n📝 将要提交的文件："
git status --short

# 确认提交
echo "\n⚠️  确认提交信息："
echo "═══════════════════════════════════════════════════════════════"
echo "feat(sprint3): 完成数据导出功能 - Sprint 3 100% 完成 🎉"
echo ""
echo "核心功能："
echo "- ✅ JSON/CSV 格式数据导出"
echo "- ✅ UIActivityViewController 文件分享"
echo "- ✅ 导出进度指示和状态管理"
echo "- ✅ 完整的成功/失败提示"
echo "- ✅ 类型安全的错误处理"
echo "- ✅ 临时文件自动清理"
echo ""
echo "代码改进："
echo "- ✅ 修复 SettingsView 中的 ExportFormat 冲突"
echo "- ✅ 添加 ExportError 错误类型定义"
echo "- ✅ 完善 FileExportManager 错误处理逻辑"
echo "- ✅ 在 SettingsView 添加导出成功提示 UI"
echo ""
echo "测试覆盖："
echo "- ✅ 新增 FileExportManagerTests.swift (220+ 行)"
echo "- ✅ 15+ 个单元测试用例"
echo "- ✅ 导出格式、数据结构、性能测试"
echo ""
echo "文档更新："
echo "- ✅ NEXT_STEPS.md - 标记 Sprint 3 完成"
echo "- ✅ PROJECT_STATUS.md - 更新项目状态为 70%"
echo "- ✅ SPRINT_TRACKER.md - 更新 Sprint 进度"
echo "- ✅ SPRINT3_DATA_EXPORT_COMPLETION.md - 完成报告"
echo ""
echo "代码统计："
echo "- 新增文件: FileExportManagerTests.swift, SPRINT3_DATA_EXPORT_COMPLETION.md"
echo "- 修改文件: 5 个"
echo "- 生产代码: 470 行 (FileExportManager)"
echo "- 测试代码: 220+ 行 (FileExportManagerTests)"
echo "- 文档更新: 200+ 行"
echo ""
echo "Sprint 3 总结："
echo "- 总代码量: 2100+ 行（生产代码）"
echo "- 测试覆盖: 600+ 行"
echo "- 完成度: 100% ✅"
echo "═══════════════════════════════════════════════════════════════"

echo "\n📌 是否执行提交？(y/n)"
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
    # 执行提交
    git commit -m "feat(sprint3): 完成数据导出功能 - Sprint 3 100% 完成 🎉

核心功能：
- ✅ JSON/CSV 格式数据导出
- ✅ UIActivityViewController 文件分享
- ✅ 导出进度指示和状态管理
- ✅ 完整的成功/失败提示
- ✅ 类型安全的错误处理
- ✅ 临时文件自动清理

代码改进：
- ✅ 修复 SettingsView 中的 ExportFormat 冲突
- ✅ 添加 ExportError 错误类型定义
- ✅ 完善 FileExportManager 错误处理逻辑
- ✅ 在 SettingsView 添加导出成功提示 UI

测试覆盖：
- ✅ 新增 FileExportManagerTests.swift (220+ 行)
- ✅ 15+ 个单元测试用例
- ✅ 导出格式、数据结构、性能测试

文档更新：
- ✅ NEXT_STEPS.md - 标记 Sprint 3 完成
- ✅ PROJECT_STATUS.md - 更新项目状态为 70%
- ✅ SPRINT_TRACKER.md - 更新 Sprint 进度
- ✅ SPRINT3_DATA_EXPORT_COMPLETION.md - 完成报告

代码统计：
- 新增文件: FileExportManagerTests.swift, SPRINT3_DATA_EXPORT_COMPLETION.md
- 修改文件: 5 个
- 生产代码: 470 行 (FileExportManager)
- 测试代码: 220+ 行 (FileExportManagerTests)
- 文档更新: 200+ 行

Sprint 3 总结：
- 总代码量: 2100+ 行（生产代码）
- 测试覆盖: 600+ 行
- 完成度: 100% ✅"

    echo "\n✅ 提交完成！"
    echo "\n📤 推送到远程仓库？(y/n)"
    read -r push_response
    
    if [[ "$push_response" =~ ^[Yy]$ ]]; then
        git push origin main
        echo "\n🎉 推送完成！Sprint 3 数据导出功能已成功提交到远程仓库！"
    else
        echo "\n⏸️  跳过推送。你可以稍后使用 'git push origin main' 推送。"
    fi
else
    echo "\n❌ 提交已取消。"
fi

echo "\n📊 当前 Git 状态："
git status

echo "\n🎊 Sprint 3 完成！下一步：Sprint 4 - ViewModel 层实现"
