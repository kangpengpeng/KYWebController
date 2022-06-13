# KYWebController

[![CI Status](https://img.shields.io/travis/kangpengpeng/KYWebController.svg?style=flat)](https://travis-ci.org/kangpengpeng/KYWebController)
[![Version](https://img.shields.io/cocoapods/v/KYWebController.svg?style=flat)](https://cocoapods.org/pods/KYWebController)
[![License](https://img.shields.io/cocoapods/l/KYWebController.svg?style=flat)](https://cocoapods.org/pods/KYWebController)
[![Platform](https://img.shields.io/cocoapods/p/KYWebController.svg?style=flat)](https://cocoapods.org/pods/KYWebController)

## Example

### 简介
- 设计思路请您查阅博客[iOS(安卓/客户端)与JS交互方案设计](https://blog.csdn.net/kangpengpeng1/article/details/125150318)。
- KYWebViewController 是 WKWebView 的加载容器
KYWebManager 是 WKWebView 的加载管理类
- 使用时，请使用 KYWebViewController 创建控制器实例或者集成自该类做额外处理

### 使用方法
- 例如 Example 演示的用法：与 JS 的交互，如 JSAPI 文件中演示
1. 提供(创建)一个 KYJsApi.plist 文件
2. JS通过 KYJSBridge_call('jsApiHandel', {'name': 'kangpp'}, function (result) {} 与原生交互，并在闭包中获取回调结果
3. 将2中的 "jsApiHandel" 和 对应原生实现的类注册到 KYJsApi.plist 文件中
4. 原生实现类，需要遵守 KYJsApiHandlerProtocol 协议并实现协议的方法 jsApiHandler:context:callback:
5. callback 就是处理完成后，JS 收到的回调信息

## Requirements

## Installation

KYWebController is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'KYWebController', '~> 0.1.4'
```

## Author

kangpengpeng, 353327533@qq.com, kangpp@163.com

## License

KYWebController is available under the MIT license. See the LICENSE file for more info.

