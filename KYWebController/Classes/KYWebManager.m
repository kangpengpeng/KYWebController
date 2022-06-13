//
//  KYWebManager.m
//  KYJsBridge
//
//  Created by 康鹏鹏 on 2022/4/6.
//

#import "KYWebManager.h"
#import "KYWebHelper.h"
#import "KYJsApiHandlerProtocol.h"
//#import <objc/runtime.h>

// 注册 JSApi 的文件名
#define KY_JSAPI_FILE_NAME      @"KYJsApi"
// H5 alert 弹窗确定和取消按钮默认文案
#define KY_ALERT_CONFIRM_TEXT   @"确定"
#define KY_ALERT_CANCEL_TEXT    @"取消"
/// webview.scrollView 背景颜色
#define WEB_CONTENT_BACKGROUND_COLOR    [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1]

@interface KYWebManager() <WKUIDelegate, WKScriptMessageHandler, WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSArray *jsApiArr;
@property (nonatomic, strong) KYJsContext *jsContext;
//@property (nonatomic, weak) KYWebViewController *targetViewController;
// webview 提供者展示 label
@property (nonatomic, strong) UILabel *webProviderLabel;
@end

@implementation KYWebManager

/// 创建一个 WKWebView
/// @param frame 坐标
- (WKWebView *)getWebView:(CGRect)frame {
    if (self.webView) {
        [self removeScriptMessageHandler];
        [self.webView removeFromSuperview];
        [self removeWebObserver];
        self.webView = nil;
    }
    WKWebViewConfiguration *webConfig = [self getWebConfig];
    self.webView = [[WKWebView alloc] initWithFrame:frame configuration:webConfig];
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.opaque = NO;
    self.webView.scrollView.backgroundColor = [UIColor clearColor];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    
    UIView *webBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    webBgView.backgroundColor = WEB_CONTENT_BACKGROUND_COLOR;
    self.webProviderLabel.frame = CGRectMake(50, 0, frame.size.width-100, 30);
    //self.webProviderLabel.text = @"此网页由 www.baidu.com 提供";
    self.webProviderLabel.hidden = YES;
    [webBgView addSubview:self.webProviderLabel];
    [self.webView addSubview:webBgView];
    [self.webView sendSubviewToBack:webBgView];
    
    [self addWebObserver];
    return self.webView;
}

/// 加载 WebView
/// @param urlString url字符串
- (void)loadWebView:(NSString *)urlString {
    if ([self isLocalWebFile:urlString]) {
        NSURL *url = [NSURL fileURLWithPath:urlString];
        [self.webView loadFileURL:url allowingReadAccessToURL:url];
        return;
    }
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    self.webProviderLabel.text = [NSString stringWithFormat:@"此网页由 %@ 提供", url.host];
}

/// 加载一个webview
/// @param urlString webview 地址
/// @param frame 坐标位置
- (WKWebView *)loadWebView:(NSString *)urlString withFrame:(CGRect)frame {
    [self getWebView:frame];
    [self loadWebView:urlString];
    return self.webView;
}

/// 是否显示此网页提供者（此网页由xxx提供）
/// @param isShow YES-显示，NO-不显示
/// 默认不显示，如有需要请手动开启
- (void)showProvider:(BOOL)isShow {
    [self.webProviderLabel setHidden:!isShow];
}

/// 销毁 webView，因为需要移除监听及ScriptMessageHandler
/// 建议调用时机，应该在控制器退出后
- (void)destroy {
    [self removeWebObserver];
    [self removeScriptMessageHandler];
    self.webView.UIDelegate = nil;
    self.webView.navigationDelegate = nil;
    self.jsContext = nil;
}

- (void)callJsFunc:(NSString *)jsFunc params:(id)params callback:(void (^)(id _Nullable))callback {
    if (jsFunc == nil) {
        return;
    }
    NSString *paramsString = @"";
    if (params) {
        if ([params isKindOfClass:NSString.class]) {
            paramsString = params;
        }
        else if ([params isKindOfClass:NSDictionary.class]) {
            paramsString = [KYWebHelper dictionaryToJson:params];
        }
        else {
            NSLog(@"%s，不能解析的参数类型", __func__);
            return;
        }
    }
    NSString *javaScript = [NSString stringWithFormat:@"%@(%@)", jsFunc, paramsString];
    [self.webView evaluateJavaScript:javaScript completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        if (callback) {
            callback(response);
        }
    }];
}

#pragma init
- (instancetype)init {
    if (self = [super init]) {
        [self addNotify];
    }
    return self;
}
/// 添加通知
- (void)addNotify {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardwillHide:) name:UIKeyboardWillHideNotification object:nil];
}
/// 移除通知
- (void)removeNotify {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/// 键盘关闭
- (void)keyboardwillHide:(NSNotification *)notification {
    NSLog(@"键盘关闭");
    // 修复 底部input输入框收起键盘后，页面不能恢复的问题
    NSDictionary *userInfo = [notification userInfo];
    // 获取键盘关闭动画时长
    double keyboardAnimationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSString *jsStr = [NSString stringWithFormat:@"setTimeout(() => {const scrollHeight = document.documentElement.scrollTop || document.body.scrollTop || 0;window.scrollTo(0, Math.max(scrollHeight - 1, 0));}, %f);", keyboardAnimationDuration];
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (error) {
            NSLog(@"webview键盘关闭处理 %@", error);
        }
    }];
}
#pragma mark: - delloc
- (void)dealloc {
    NSLog(@"%s", __func__);
    [self removeNotify];
}

#pragma 私有方法
/// 判断 URL 是本地还是网络
- (BOOL)isLocalWebFile:(NSString *)urlString {
    if ([urlString hasPrefix:@"http"]) {
        return NO;
    }
    return YES;
}

/// 获取 webView 配置，注入交互 JS
- (WKWebViewConfiguration *)getWebConfig {
    // 读取注入 JS 文件，以字符串形式注入
    NSBundle *currBundle = [NSBundle bundleForClass:self.class];
    NSString *jsBridgePath = [currBundle pathForResource:@"KYInjectBridge.js" ofType:nil inDirectory:@"KYWebController.bundle"];
    NSData *jsBridgeData = [NSData dataWithContentsOfFile:jsBridgePath];
    //转换成NSData字符串
    NSString *jsBridgeString = [[NSString alloc]initWithData:jsBridgeData encoding:NSUTF8StringEncoding];
    // 注入
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jsBridgeString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [wkUController addUserScript:wkUScript];
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.userContentController = wkUController;
    return config;
}


- (KYJsContext *)getJsContext {
    if (!self.jsContext) {
        self.jsContext = [[KYJsContext alloc] init];
    }
    self.jsContext.webView = self.webView;
    self.jsContext.viewController = [KYWebHelper findViewController:self.webView];
    return self.jsContext;
}

/// 获取 jsApi 数组
- (NSArray *)getJsApis {
    NSDictionary *jsApiDict = [KYWebHelper readLocalPlistFileWithName:KY_JSAPI_FILE_NAME];
    NSArray *jsApiArr = jsApiDict[@"jsApis"];
    return jsApiArr;
}

/// 获取 jsApi 对应的实现类名
/// @param jsApi js调用的api
- (NSString *)gethandleClassNameWithJsApi:(NSString *)jsApi {
    NSString *handleClass;
    NSArray *jsApis = [self getJsApis];
    for (NSDictionary *item in jsApis) {
        if ([item[@"jsApi"] isEqualToString:jsApi]) {
            handleClass = item[@"handleClass"];
            break;
        }
    }
    return handleClass;
}


/// 处理 jsApi 的交互信息
/// @param jsApi jsApi
/// @param jsParams jsApi 传递过来的参数
/// @param interactCode 本次交互唯一码
- (void)handleJsApi:(NSString *)jsApi jsParams:(NSDictionary *)jsParams interactCode:(NSString *)interactCode {
    NSString *handleClass = [self gethandleClassNameWithJsApi:jsApi];
    if (handleClass == nil || handleClass.length == 0) {
#ifdef DEBUG
        NSString *tip = [NSString stringWithFormat:@"发现jsApi未注册。======> jsApi: %@, handleClass: %@", jsApi, handleClass];
        NSAssert(NO, tip);
        return;
#endif
    }
    Class targetClass = NSClassFromString(handleClass);
    if (targetClass == nil) {
#ifdef DEBUG
        NSString *tip = [NSString stringWithFormat:@"发现jsApi已注册但handleClass未实现。======>  jsApi: %@, handleClass: %@", jsApi, handleClass];
        NSAssert(NO, tip);
        return;
#endif
    }
    id<KYJsApiHandlerProtocol> apiInstance = [[targetClass alloc] init];
    if (apiInstance && [apiInstance respondsToSelector:@selector(jsApiHandler:context:callback:)]) {
        [apiInstance jsApiHandler:jsParams context:[self getJsContext] callback:^(id  _Nonnull responseData) {
            // TODO: KPP 此处默认 responseData 是个字典，设计成id类型，是希望有一个model转字典的处理，后续添加
            NSDictionary * callParamsDict = responseData;
            /// 执行JS回调，并将本次交互编号告诉JS
            NSDictionary *jsParamsDict = @{
                @"interactCode": interactCode,
                @"jsParams": [KYWebHelper dictionaryToJson:callParamsDict]
            };
            NSString *jsParamsJsonString = [KYWebHelper dictionaryToJson:jsParamsDict];
            NSString *jsStr = [NSString stringWithFormat:@"KYExecuteJSCallback(%@)", jsParamsJsonString];
            [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                if (error) {
                    // 回调中的result 就是 js 的返回值
                    NSLog(@"jsApi: %@ 已完成, 发现异常请处理 ======> result: %@\nerror: %@", jsApi, result, error);
                }
            }];
        }];
    } else {
#ifdef DEBUG
        NSString *tip = [NSString stringWithFormat:@"发现已注册的jsApi对应的handleClass未实现协议<KYJsApiHandlerProtocol>中的 jsApiHandler:context:callback 方法。======> jsApi: %@, handleClass: %@", jsApi, handleClass];
        NSAssert(NO, tip);
#endif
    }
}

/// 向JS注入交互方法
- (void)addScriptMessageHandler {
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"postMessage2OC"];
}
/// 从JS移除交互方法
- (void)removeScriptMessageHandler {
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"postMessage2OC"];
}

/// 添加监听
- (void)addWebObserver {
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}
/// 移除监听
- (void)removeWebObserver {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}
/// KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (self.loadingProgress) {
            self.loadingProgress(self.webView.estimatedProgress);
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(ky_webView:loadingProgress:)]) {
            [self.delegate ky_webView:self.webView loadingProgress:self.webView.estimatedProgress];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark: - WKScriptMessageHandler
/// 接收 JS 发送过来的交互信息
/// window.webkit.messageHandlers.postMessage2OC.postMessage(paramsObj)
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ky_userContentController:didReceiveScriptMessage:)]) {
        BOOL isContinue = [self.delegate ky_userContentController:userContentController didReceiveScriptMessage:message];
        if (isContinue == NO) return;
    }
    //NSString *msgName = message.name;
    NSDictionary *msgBody = message.body;
    NSString *jsApi = msgBody[@"jsApi"]; // 方法名
    NSDictionary *jsApiParams = msgBody[@"jsApiParams"]; // 方法参数
    NSString *interactCode = msgBody[@"interactCode"]; // 本次交互的唯一交互码
    //NSLog(@"message.name == %@\n message.body == %@",msgName, msgBody);
    [self handleJsApi:jsApi jsParams:jsApiParams interactCode:interactCode];
}
#pragma mark: - WKNavigationDelegate
/// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ky_webView:didStartProvisionalNavigation:)]) {
        [self.delegate ky_webView:webView didStartProvisionalNavigation:navigation];
    }
}
/// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ky_webView:didCommitNavigation:)]) {
        [self.delegate ky_webView:webView didCommitNavigation:navigation];
    }
}
/// 页面加载完毕时调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    /// 注入 JS 交互方法
    [self removeScriptMessageHandler];
    [self addScriptMessageHandler];
    if (self.delegate && [self.delegate respondsToSelector:@selector(ky_webView:didFinishNavigation:)]) {
        [self.delegate ky_webView:webView didFinishNavigation:navigation];
    }
}
/// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ky_webView:didFailProvisionalNavigation:withError:)]) {
        [self.delegate ky_webView:webView didFailProvisionalNavigation:navigation withError:error];
    }
}


/// 请求之前，决定是否要跳转:用户点击网页上的链接，需要打开新页面时，将先调用这个方法。
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ky_webView:decidePolicyForNavigationAction:decisionHandler:)]) {
        [self.delegate ky_webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}
/// 接收到相应数据后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ky_webView:decidePolicyForNavigationResponse:decisionHandler:)]) {
        [self.delegate ky_webView:webView decidePolicyForNavigationResponse:navigationResponse decisionHandler:decisionHandler];
        return;
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}
/// 主机地址被重定向时调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ky_webView:didReceiveServerRedirectForProvisionalNavigation:)]) {
        [self.delegate ky_webView:webView didReceiveServerRedirectForProvisionalNavigation:navigation];
    }
}
/// 如果需要证书验证，默认仅对 NSURLAuthenticationMethodServerTrust 做处理
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ky_webView:didReceiveAuthenticationChallenge:completionHandler:)]) {
        [self.delegate ky_webView:webView didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
        return;
    }
    /**
     
     NSURLAuthenticationMethodClientCertificate
     此保护空间使用客户端证书身份验证。
     NSURLAuthenticationMethodNegotiate
     协商在这个保护空间中使用Kerberos还是NTLM身份验证。
     NSURLAuthenticationMethodNTLM
     对这个保护空间使用NTLM身份验证。
     NSURLAuthenticationMethodServerTrust
     为这个保护空间执行服务器信任身份验证(证书验证)。
     
     NSURLSessionAuthChallengeUseCredential = 0,
     使用指定证书验证
     NSURLSessionAuthChallengePerformDefaultHandling = 1,
     未实现代理情况下的默认处理
     NSURLSessionAuthChallengeCancelAuthenticationChallenge = 2,
     取消请求
     NSURLSessionAuthChallengeRejectProtectionSpace = 3,
     拒绝身份认证，尝试下一次身份认证
     */
    // 默认为由系统默认处理
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *cert = nil;
    // 判断是否为服务器身份验证质询，即客户端验证服务端证书
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if (challenge.previousFailureCount == 0) {
            // 无条件信任证书
            disposition = NSURLSessionAuthChallengeUseCredential;
            // 获取服务器发来的证书
            cert = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        }
        else {
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    }
    // 服务器验证客户端证书
    else if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate]) {
        // 不做任何处理，由外部调用者实现处理
        
    }
    else {
        // 默认处理，根据系统根证书验证证书链
        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    }
    completionHandler(disposition, cert);
}


/// 9.0才能使用，web内容处理中断时会触发
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView NS_AVAILABLE(10_11, 9_0) {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ky_webViewWebContentProcessDidTerminate:)]) {
        [self.delegate ky_webViewWebContentProcessDidTerminate:webView];
    }
}

#pragma mark: - WKUIDelegate
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ky_webView:createWebViewWithConfiguration:forNavigationAction:windowFeatures:)]) {
        return [self.delegate ky_webView:webView createWebViewWithConfiguration:configuration forNavigationAction:navigationAction windowFeatures:windowFeatures];
    }
    // TODO: KPP 此处需要兼容 target="_blank"
    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if ([frameInfo isMainFrame] == NO) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}
- (void)webViewDidClose:(WKWebView *)webView API_AVAILABLE(macos(10.11), ios(9.0)) {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ky_webViewDidClose:)]) {
        [self.delegate ky_webViewDidClose:webView];
    }
}

/// 替换JS alert 警告弹窗，一个按钮
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ky_webView:runJavaScriptAlertPanelWithMessage:initiatedByFrame:completionHandler:)]) {
        [self.delegate ky_webView:webView runJavaScriptAlertPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:KY_ALERT_CONFIRM_TEXT style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [[KYWebHelper findViewController:webView] presentViewController:alert animated:YES completion:nil];
}

/// 替换JS alert 警告弹窗，两个按钮
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ky_webView:runJavaScriptConfirmPanelWithMessage:initiatedByFrame:completionHandler:)]) {
        [self.delegate ky_webView:webView runJavaScriptConfirmPanelWithMessage:message initiatedByFrame:frame completionHandler:completionHandler];
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:KY_ALERT_CANCEL_TEXT style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:KY_ALERT_CONFIRM_TEXT style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [[KYWebHelper findViewController:webView] presentViewController:alert animated:YES completion:nil];
}

/// 带输入框的弹窗
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ky_webView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:completionHandler:)]) {
        [self.delegate ky_webView:webView runJavaScriptTextInputPanelWithPrompt:prompt defaultText:defaultText initiatedByFrame:frame completionHandler:completionHandler];
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
        //textField.placeholder = prompt;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:KY_ALERT_CANCEL_TEXT style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {

    }]];
    [alert addAction:[UIAlertAction actionWithTitle:KY_ALERT_CONFIRM_TEXT style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alert.textFields.firstObject.text);
    }]];
    [[KYWebHelper findViewController:webView] presentViewController:alert animated:YES completion:nil];
}
/// 请求麦克风、音频和摄像机、视频访问许可的委托。
- (void)webView:(WKWebView *)webView requestMediaCapturePermissionForOrigin:(WKSecurityOrigin *)origin initiatedByFrame:(WKFrameInfo *)frame type:(WKMediaCaptureType)type decisionHandler:(void (^)(WKPermissionDecision decision))decisionHandler WK_SWIFT_ASYNC_NAME(webView(_:decideMediaCapturePermissionsFor:initiatedBy:type:)) WK_SWIFT_ASYNC(5) API_AVAILABLE(macos(12.0), ios(15.0)) {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ky_webView:requestMediaCapturePermissionForOrigin:initiatedByFrame:type:decisionHandler:)]) {
        [self.delegate ky_webView:webView requestMediaCapturePermissionForOrigin:origin initiatedByFrame:frame type:type decisionHandler:decisionHandler];
        return;
    }
    decisionHandler(WKPermissionDecisionPrompt);
}
/// 设备旋转
- (void)webView:(WKWebView *)webView requestDeviceOrientationAndMotionPermissionForOrigin:(WKSecurityOrigin *)origin initiatedByFrame:(WKFrameInfo *)frame decisionHandler:(void (^)(WKPermissionDecision decision))decisionHandler API_AVAILABLE(ios(15.0)) API_UNAVAILABLE(macos) {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ky_webView:requestDeviceOrientationAndMotionPermissionForOrigin:initiatedByFrame:decisionHandler:)]) {
        [self.delegate ky_webView:webView requestDeviceOrientationAndMotionPermissionForOrigin:origin initiatedByFrame:frame decisionHandler:decisionHandler];
        return;
    }
    // TODO: 待完善
    decisionHandler(WKPermissionDecisionPrompt);
}

#pragma mark: - 属性懒加载
- (UILabel *)webProviderLabel {
    if (!_webProviderLabel) {
        _webProviderLabel = [[UILabel alloc] init];
        _webProviderLabel.backgroundColor = [UIColor clearColor];
        _webProviderLabel.textColor = [UIColor colorWithRed:184/255.0 green:184/255.0 blue:184/255.0 alpha:1];
        _webProviderLabel.textAlignment = NSTextAlignmentCenter;
        _webProviderLabel.font = [UIFont systemFontOfSize:12];
    }
    return _webProviderLabel;
}


@end
