#
# Be sure to run `pod lib lint KYWebController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KYWebController'
  s.version          = '0.1.2'
  s.summary          = 'WKWebView 加载及交互组件'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    自定义的 WKWebView 加载控制器及JS交互组件，需要依赖自定义导航栏组件 KYNaviView
                       DESC

  s.homepage         = 'https://github.com/kangpengpeng/KYWebController'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kangpengpeng' => '353327533@qq.com' }
  s.source           = { :git => 'https://github.com/kangpengpeng/KYWebController.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'KYWebController/Classes/**/*'
  
  s.resource_bundles = {
     'KYWebController' => ['KYWebController/Assets/*']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'KYNaviView', '~> 0.3.2'
end
