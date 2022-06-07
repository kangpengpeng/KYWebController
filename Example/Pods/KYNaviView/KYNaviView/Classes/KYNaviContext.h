//
//  KYNaviContext.h
//  KYNaviView
//
//  Created by 康鹏鹏 on 2022/3/17.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "KYNavigationView.h"
#import "KYBaseNaviViewController.h"

NS_ASSUME_NONNULL_BEGIN

//@class KYBaseNaviViewController;
@interface KYNaviContext : NSObject

/// 自定义导航栏
@property (nonatomic, strong)KYNavigationView *navigationView;
/// 自定义导航栏所在控制器
@property (nonatomic, strong)KYBaseNaviViewController *controller;


@end

NS_ASSUME_NONNULL_END
