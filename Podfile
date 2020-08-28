source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'
platform :ios, '12.0'
# 这里标记使用Framework
use_frameworks!
## 优化cocoapods索引（1.7.0以上有效）
install! 'cocoapods',
generate_multiple_pod_projects: true,
incremental_installation: true


workspace 'TuringMachine.xcworkspace'

# 这里调用的全部库
def shared_pods
  pod 'SDAutoLayout'##约束布局
  pod 'MJExtension','~>3.2.1'##模型JSON互转
  pod 'QMUIKit'##UI控件合集
end

target 'TuringMachine' do
  project 'TuringMachine.xcodeproj'

  shared_pods
end
