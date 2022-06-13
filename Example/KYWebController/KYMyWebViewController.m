//
//  KYMyWebViewController.m
//  KYWebController_Example
//
//  Created by 康鹏鹏 on 2022/4/13.
//  Copyright © 2022 kangpengpeng. All rights reserved.
//

#import "KYMyWebViewController.h"
#import <KYWebController/KYWebManager.h>

@interface KYMyWebViewController ()

@end

@implementation KYMyWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;
    self.ky_didTouchTitle = ^(KYNaviContext * _Nonnull context) {
        NSLog(@"开始调用 js 函数");
        [weakSelf.webManager callJsFunc:@"ocCallJs" params:@{@"key": @"oc调用js传递的参数"} callback:^(NSDictionary * _Nonnull response) {
            // response 是js函数的返回值
            NSLog(@"%@", response);
        }];
    };
}

#pragma mark: - KYWebManagerDelegate
- (void)ky_webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"页面加载失败");
}

@end
