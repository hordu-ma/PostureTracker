//
//  PrivacyPolicyView.swift
//  PostureTracker
//
//  隐私政策页面 - 显示应用隐私政策和数据使用说明
//  Created on 2024-10-03
//

import SwiftUI

struct PrivacyPolicyView: View {
    
    // MARK: - 属性
    
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 标题
                    VStack(alignment: .leading, spacing: 8) {
                        Text("隐私政策")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("最后更新：2024年10月3日")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // 概述
                    policySection(
                        title: "概述",
                        content: """
                        PostureTracker 致力于保护您的隐私。本隐私政策解释了我们如何收集、使用和保护您的个人信息。
                        
                        我们遵循最小数据收集原则，只收集为您提供服务所必需的信息。
                        """
                    )
                    
                    // 数据收集
                    policySection(
                        title: "我们收集的数据",
                        content: """
                        • 头部运动数据：通过 AirPods 传感器收集的俯仰、偏航、翻滚角度数据
                        • 使用统计：训练时长、会话次数、应用使用频率
                        • 设备信息：设备型号、操作系统版本（用于兼容性）
                        • 设置偏好：您自定义的应用设置和偏好
                        """
                    )
                    
                    // 数据使用
                    policySection(
                        title: "数据用途",
                        content: """
                        您的数据仅用于以下目的：
                        
                        • 提供实时姿态监测和反馈
                        • 生成个人统计报告和趋势分析
                        • 改善应用功能和用户体验
                        • 提供个性化设置和推荐
                        
                        我们不会将您的数据用于广告或营销目的。
                        """
                    )
                    
                    // 数据存储
                    policySection(
                        title: "数据存储和安全",
                        content: """
                        • 本地存储：所有数据默认存储在您的设备上
                        • 加密保护：敏感数据使用行业标准加密
                        • 云端同步：仅在您明确同意时启用（可选）
                        • 访问控制：只有您可以访问您的数据
                        
                        我们采用技术和管理措施保护您的数据安全。
                        """
                    )
                    
                    // 数据共享
                    policySection(
                        title: "数据共享",
                        content: """
                        我们不会出售、交易或以其他方式转让您的个人信息，除非：
                        
                        • 获得您的明确同意
                        • 法律要求或保护权利所必需
                        • 为提供服务而与可信第三方合作（如云存储提供商）
                        
                        任何第三方都必须遵守同等的隐私保护标准。
                        """
                    )
                    
                    // 您的权利
                    policySection(
                        title: "您的权利",
                        content: """
                        您对自己的数据拥有以下权利：
                        
                        • 查看权：随时查看我们收集的数据
                        • 导出权：将数据导出为可读格式
                        • 删除权：随时删除您的所有数据
                        • 更正权：更正任何不准确的信息
                        • 限制权：限制数据处理的范围
                        
                        这些权利可通过应用设置随时行使。
                        """
                    )
                    
                    // 儿童隐私
                    policySection(
                        title: "儿童隐私",
                        content: """
                        我们不会故意收集13岁以下儿童的个人信息。如果我们发现无意中收集了儿童信息，我们将立即删除。
                        
                        如果您是儿童的父母或监护人，发现您的孩子向我们提供了个人信息，请联系我们。
                        """
                    )
                    
                    // 政策更新
                    policySection(
                        title: "政策更新",
                        content: """
                        我们可能会不时更新此隐私政策。重大变更时，我们会通过应用内通知的方式告知您。
                        
                        建议您定期查看此政策以了解最新变更。继续使用应用即表示您接受更新后的政策。
                        """
                    )
                    
                    // 联系我们
                    policySection(
                        title: "联系我们",
                        content: """
                        如果您对此隐私政策有任何疑问或担忧，请通过以下方式联系我们：
                        
                        • 邮箱：privacy@posturetracker.app
                        • 应用内反馈：设置 → 反馈与建议
                        • 官网：www.posturetracker.app/privacy
                        
                        我们将在24小时内回复您的询问。
                        """
                    )
                    
                    // 版本信息
                    VStack(alignment: .center, spacing: 8) {
                        Text("© 2024 PostureTracker")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("版本 1.0.0")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - 私有方法
    
    /// 政策条款组件
    private func policySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - 预览

#Preview(\"隐私政策\") {
    PrivacyPolicyView()
}

#Preview(\"隐私政策 - 暗色模式\") {
    PrivacyPolicyView()
        .preferredColorScheme(.dark)
}