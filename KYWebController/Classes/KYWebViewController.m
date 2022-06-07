//
//  KYWebViewController.m
//  KYWebController
//
//  Created by 康鹏鹏 on 2022/4/12.
//

#import "KYWebViewController.h"
#import "KYWebLoadingProgressLine.h"

#define PROGRESS_LINE_HEIGHT    2

@interface KYWebViewController ()<KYWebManagerDelegate>
@property (nonatomic, strong) KYWebLoadingProgressLine *loadingProgressLine;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, copy) NSString *urlString;
@end

@implementation KYWebViewController

- (instancetype)initWithURLString:(NSString *)urlString {
    if (self = [super init]) {
        _urlString = urlString;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.title = @"自定义的web加载及交互容器";
    [self loadWebView:self.urlString];
}

/// 设置 webView 加载路径
/// @param urlString url字符串，如果是本地文件路径，直接传入文件路径即可
- (void)setWebViewURLString:(NSString *)urlString {
    _urlString = urlString;
}

- (void)loadWebView:(NSString *)urlString {
    //[self.webManager loadWebView:urlString targetViewController:self];
    WKWebView *webView = [self.webManager loadWebView:urlString withFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.webView = webView;
    self.webManager.delegate = self;

    if ([self isHiddenNaviView] == NO) {
        if (@available(iOS 11.0, *)) {
            webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
    }
    [self.view addSubview:webView];
    
    __weak typeof(self) weakSelf = self;
    self.webManager.loadingProgress = ^(CGFloat progress) {
        [weakSelf.loadingProgressLine setProgressValue:progress];
        if (progress == 1) {
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.loadingProgressLine.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
            } completion:^(BOOL finished) {
                weakSelf.loadingProgressLine.hidden = YES;
            }];
        }
    };
    
}


/// 隐藏 webView 加载进度条
/// @param isHidden YES-隐藏，NO-显示(默认)
- (void)hiddenLoadingProgress:(BOOL)isHidden {
    self.loadingProgressLine.hidden = isHidden;
}
/// 设置 webview 加载进度条颜色
/// @param color 进度条颜色
- (void)setLoadingProgressColor:(UIColor *)color {
    [self.loadingProgressLine setProgressLineColor:color];
}

/// 设置 webView 加载进度条高度
/// @param height 进度条高度
- (void)setLoadingProgressHeight:(NSUInteger)height {
    CGRect frame = self.loadingProgressLine.frame;
    frame.size.height = height;
    [self.loadingProgressLine setFrame:frame];
}

/// 重写返回按钮响应，执行webview逐级返回
- (void)goback {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
        return;
    }
    [super goback];
}

#pragma mark: - KYWebManagerDelegate
- (void)ky_webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // 外部未设置导航 title 的情况下，将其设置为 H5 的 title 标签值
    if (self.title.length == 0) {
        self.title = webView.title;
    }
}

#pragma mark: - 属性
- (KYWebManager *)webManager {
    if (!_webManager) {
        _webManager = [[KYWebManager alloc] init];
    }
    return _webManager;
}
- (KYWebLoadingProgressLine *)loadingProgressLine {
    if (!_loadingProgressLine) {
        _loadingProgressLine = [[KYWebLoadingProgressLine alloc] init];
        CGFloat progressY = 0;
        if (self.isHiddenNaviView) {
            progressY = [self getStatusBarHeight];
        }
        _loadingProgressLine.frame = CGRectMake(0, progressY, self.view.frame.size.width, PROGRESS_LINE_HEIGHT);
        [self.loadingProgressLine setProgressValue:0];
        [self.view addSubview:_loadingProgressLine];
    }
    return _loadingProgressLine;
}

#pragma mark: - 释放时机
- (void)dealloc {
    NSLog(@"%s", __func__);
    [self.webManager destroy];
}

@end
