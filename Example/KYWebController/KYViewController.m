//
//  KYViewController.m
//  KYWebController
//
//  Created by kangpengpeng on 04/02/2022.
//  Copyright (c) 2022 kangpengpeng. All rights reserved.
//

#import "KYViewController.h"
#import "KYMyWebViewController.h"

@interface KYViewController ()
@end

@implementation KYViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.title = @"系统导航栏控制器";
}

- (IBAction)pushWebController:(id)sender {
    NSString *h5FilePath = [[NSBundle mainBundle] pathForResource:@"KYIndex.html" ofType:nil];
    //KYWebViewController *webVC = [[KYWebViewController alloc] init];
    KYMyWebViewController *webVC = [[KYMyWebViewController alloc] init];
    
    //@"https://www.dddbaidu.com" // https://www.hao123.com/?src=from_pc_logon
    [webVC setWebViewURLString:@"https://www.hao123.com/?src=from_pc_logon"];
    [webVC setNaviTitle:@"自定义的web加载及交互容器"];
    [webVC hiddenNaviView:NO];
    // 是否显示网页提供者，默认不显示
    [webVC showProvider:YES];
    [self.navigationController pushViewController:webVC animated:YES];
}


@end
