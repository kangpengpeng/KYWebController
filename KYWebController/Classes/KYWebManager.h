//
//  KYWebManager.h
//  KYJsBridge
//
//  Created by 康鹏鹏 on 2022/4/6.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "KYWebManagerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^KYWebViewLoadingProgress)(CGFloat progress);

@interface KYWebManager : NSObject

/// 代理给外部提供数据
@property (nonatomic, weak) id<KYWebManagerDelegate> delegate;
/// WebView 加载进度[0-1]
@property (nonatomic, copy) KYWebViewLoadingProgress loadingProgress;

/// 创建一个 WKWebView
/// @param frame 坐标
- (WKWebView *)getWebView:(CGRect)frame;

/// 加载 WebView
/// @param urlString url字符串，如果是本地文件路径，直接传入文件路径即可
- (void)loadWebView:(NSString *)urlString;

/// 加载一个webview
/// @param urlString webview 地址
/// @param frame 坐标位置
- (WKWebView *)loadWebView:(NSString *)urlString withFrame:(CGRect)frame;

/// 是否显示此网页提供者（此网页由xxx提供）
/// @param isShow YES-显示，NO-不显示
/// 默认不显示，如有需要请手动开启
- (void)showProvider:(BOOL)isShow;

/// 销毁 webView，因为需要移除监听及ScriptMessageHandler
/// 建议调用时机，应该在控制器退出后
- (void)destroy;

/// 调用 JS 方法
/// @param jsFunc js 方法名
/// @param params 参数
/// @param callback 返回值通过block返回
- (void)callJsFunc:(NSString *)jsFunc params:(id)params callback:(void(^)(id _Nullable response))callback;

@end

NS_ASSUME_NONNULL_END
