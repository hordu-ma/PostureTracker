# Podfile for PostureTracker
platform :ios, '14.0'
use_frameworks!

# 禁用输入/输出路径分析以提升构建速度
install! 'cocoapods',
         :deterministic_uuids => false,
         :disable_input_output_paths => true

target 'PostureTracker' do
  # 网络和云服务
  pod 'Firebase/Core'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'Firebase/Auth'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  
  # UI 和图表
  pod 'Charts', '~> 4.1'
  pod 'Lottie', '~> 4.3'
  
  # 工具库
  pod 'SwiftLint', '~> 0.53'
  pod 'KeychainSwift', '~> 20.0'
  
  # 网络请求（备选方案）
  # pod 'Alamofire', '~> 5.8'
  
  # 日志和调试
  pod 'CocoaLumberjack/Swift', '~> 3.8'
  
  target 'PostureTrackerTests' do
    inherit! :search_paths
    # 测试框架
    pod 'Quick', '~> 7.0'
    pod 'Nimble', '~> 13.0'
    pod 'Mockingjay', '~> 3.0'
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # 优化编译设置
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      config.build_settings['SWIFT_VERSION'] = '5.9'
      
      # 启用模块稳定性
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      
      # 优化二进制大小
      config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Osize'
      config.build_settings['SWIFT_COMPILATION_MODE'] = 'wholemodule'
      
      # 代码签名设置
      config.build_settings['CODE_SIGN_IDENTITY'] = ''
      config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
    end
  end
  
  # 运行 SwiftLint
  puts "Running SwiftLint..."
  system("Pods/SwiftLint/swiftlint autocorrect --config .swiftlint.yml")
end