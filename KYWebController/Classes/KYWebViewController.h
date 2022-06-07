//
//  KYWebViewController.h
//  KYWebController
//
//  Created by 康鹏鹏 on 2022/4/12.
//

#import <KYNaviView/KYBaseNaviViewController.h>
#import "KYWebManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface KYWebViewController : KYBaseNaviViewController

@property (nonatomic, strong) KYWebManager *webManager;

/// web容器初始化方法
/// @param urlString web地址
- (instancetype)initWithURLString:(NSString *)urlString;

/// 设置 webView 加载路径
/// @param urlString url字符串，如果是本地文件路径，直接传入文件路径即可
- (void)setWebViewURLString:(NSString *)urlString;

/// 隐藏 webView 加载进度条
/// @param isHidden YES-隐藏，NO-显示(默认)
- (void)hiddenLoadingProgress:(BOOL)isHidden;

/// 设置 webview 加载进度条颜色
/// @param color 进度条颜色
- (void)setLoadingProgressColor:(UIColor *)color;

/// 设置 webView 加载进度条高度
/// @param height 进度条高度
- (void)setLoadingProgressHeight:(NSUInteger)height;

@end

NS_ASSUME_NONNULL_END
