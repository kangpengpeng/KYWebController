//
//  KYNavigationViewControllerDelegate.h
//  KYNaviView
//
//  Created by 康鹏鹏 on 2022/3/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class KYBaseNaviViewController, KYNaviContext;
@protocol KYNavigationViewControllerDelegate <NSObject>
@optional
#pragma mark: - 导航栏返回按钮执事件周期

/// 是否允许返回按钮执行
/// @param controller 当前控制器
/// @param context 控制器上下文环境信息
- (BOOL)ky_navigationController:(KYBaseNaviViewController *)controller
               canPerformGoback:(KYNaviContext *)context;

/// 返回按钮将要执行
/// @param controller 当前控制器
/// @param context 控制器上下文环境信息
- (void)ky_navigationController:(KYBaseNaviViewController *)controller
              willPerformGoback:(KYNaviContext *)context;

/// 返回按钮已经执行
/// @param controller 当前控制器
/// @param context 控制器上下文环境信息
- (void)ky_navigationController:(KYBaseNaviViewController *)controller
               didPerformGoback:(KYNaviContext *)context;

/// 导航栏title点击事件
/// @param controller 当前控制器
/// @param context 控制器上下文环境信息
- (void)ky_navigationController:(KYBaseNaviViewController *)controller didTouchTitleView:(KYNaviContext *)context;

#pragma mark: - 添加自定义视图
/// 添加自定义视图
- (void)ky_addCustomView:(KYNaviContext *)context;

@end

@protocol KYNavigationPageStatusDelegate <NSObject>

#pragma mark: - 控制器显示周期
/// 控制器生命周期 viewDidLoad
/// @param context 控制器上下文环境信息
- (void)ky_viewDidLoad:(KYNaviContext *)context;

/// 控制器生命周期 viewWillAppear
/// @param context 控制器上下文环境信息
- (void)ky_viewWillAppear:(KYNaviContext *)context;

/// 控制器生命周期 viewDidAppear
/// @param context 控制器上下文环境信息
- (void)ky_viewDidAppear:(KYNaviContext *)context;

/// 控制器生命周期 viewWillDisappear
/// @param context 控制器上下文环境信息
- (void)ky_viewWillDisappear:(KYNaviContext *)context;

/// 控制器生命周期 viewDidDisappear
/// @param context 控制器上下文环境信息
- (void)ky_viewDidDisappear:(KYNaviContext *)context;

@end

NS_ASSUME_NONNULL_END
