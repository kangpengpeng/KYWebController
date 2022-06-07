//
//  KYJsContext.h
//  KYJsBridge
//
//  Created by 康鹏鹏 on 2022/4/7.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@class KYWebViewController;
@interface KYJsContext : NSObject
/**
 context 被 webManager 强引用，webManager又被控制器强引用，所以viewController使用弱引用即可，否则内存泄露
 同理 webView 被 viewController 和 webManager 强引用，此处也需要弱引用处理
 */
/// webView 对象
@property (nonatomic, weak) WKWebView *webView;
/// 当前所在控制器对象
@property (nonatomic, weak) UIViewController *viewController;

@end

NS_ASSUME_NONNULL_END
