//
//  KYWebManagerProtocol.h
//  KYWebController
//
//  Created by 康鹏鹏 on 2022/5/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class KYJsContext;
@protocol KYWebManagerDelegate <NSObject>

@optional
/// WebView 加载进度
/// @param webView webView
/// @param progress 加载进度值 [0-1]
- (void)ky_webView:(WKWebView *)webView loadingProgress:(CGFloat)progress;

/// 接收 JS 发送过来的交互信息
/// window.webkit.messageHandlers.postMessage2OC.postMessage(paramsObj)

/// 接收并处理 JS 发送过来的交互信息，相比系统代理多了返回值，表示是否走默认jsApi交互方案
/// @param userContentController 视图容器信息
/// @param message 交互信息 message.name、message.body
- (BOOL)ky_userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;

#pragma mark: - WKNavigationDelegate
/// 页面开始加载时调用
- (void)ky_webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation;

/// 当内容开始返回时调用
- (void)ky_webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation;

/// 页面加载完毕时调用
- (void)ky_webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation;

/// 页面加载失败时调用
- (void)ky_webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error;

/// 请求之前，决定是否要跳转:用户点击网页上的链接，需要打开新页面时，将先调用这个方法。
- (void)ky_webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;

/// 接收到相应数据后，决定是否跳转
- (void)ky_webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;

/// 主机地址被重定向时调用
- (void)ky_webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation;

/// 证书验证，认默认仅对 NSURLAuthenticationMethodServerTrust 做了信任处理
/// 外部实现该代理方法后，内部默认处理将不再生效
- (void)ky_webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler;

/// 9.0才能使用，web内容处理中断时会触发
- (void)ky_webViewWebContentProcessDidTerminate:(WKWebView *)webView NS_AVAILABLE(10_11, 9_0);

#pragma mark: - WKUIDelegate
- (nullable WKWebView *)ky_webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures;

- (void)ky_webViewDidClose:(WKWebView *)webView API_AVAILABLE(macos(10.11), ios(9.0));

/// 替换JS alert 警告弹窗，一个按钮
- (void)ky_webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler;

/// 替换JS alert 警告弹窗，两个按钮
- (void)ky_webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler;

/// 带输入框的弹窗
- (void)ky_webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler;

/// 请求麦克风、音频和摄像机、视频访问许可的委托。
- (void)ky_webView:(WKWebView *)webView requestMediaCapturePermissionForOrigin:(WKSecurityOrigin *)origin initiatedByFrame:(WKFrameInfo *)frame type:(WKMediaCaptureType)type decisionHandler:(void (^)(WKPermissionDecision decision))decisionHandler WK_SWIFT_ASYNC_NAME(webView(_:decideMediaCapturePermissionsFor:initiatedBy:type:)) WK_SWIFT_ASYNC(5) API_AVAILABLE(macos(12.0), ios(15.0));

/// 设备旋转
- (void)ky_webView:(WKWebView *)webView requestDeviceOrientationAndMotionPermissionForOrigin:(WKSecurityOrigin *)origin initiatedByFrame:(WKFrameInfo *)frame decisionHandler:(void (^)(WKPermissionDecision decision))decisionHandler API_AVAILABLE(ios(15.0)) API_UNAVAILABLE(macos);

@end

NS_ASSUME_NONNULL_END
