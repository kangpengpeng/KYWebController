//
//  KYNavigationView.h
//  MobileBank
//
//  Created by 康鹏鹏 on 2021/6/9.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^KYNavigationViewDidTouchTitle)(NSString *title, NSSet<UITouch *> *touches, UIEvent *event);

@interface KYNavigationView : UIView

@property (nonatomic, copy)KYNavigationViewDidTouchTitle didTouchTitle;

#pragma mark: - 初始化后必须实现方法
/// 给返回按钮添加方法
/// @param target 目标实例
/// @param selector 方法名
- (void)gobackBtnAddTarget:(id)target action:(SEL)selector;

/// 将导航栏添加到指定控制器
/// @param controller 自定义导航栏所在控制器
- (void)addToController:(UIViewController *)controller;

#pragma mark: - 背景设置相关方法
/// 设置背景图片，默认 UIViewContentModeScaleToFill 拉伸铺满
/// @param image 图片对象
- (void)setBackgroundImage:(UIImage *)image;

/// 设置背景图片
/// @param image 图片对象
/// @param contentMode 图片填充方式
- (void)setBackgroundImage:(UIImage *)image contentMode:(UIViewContentMode)contentMode;

#pragma mark: - 标题设置相关方法
/// 设置标题
/// @param title 导航栏标题
- (void)setTitle:(NSString *)title;

/// 获取标题内容
- (NSString *)title;

#pragma mark: - 分割线设置相关方法
/// 是否隐藏导航栏底部分割线
/// @param hidden 默认显示
- (void)hiddenSeparatorLine:(BOOL)hidden;

/// 设置导航栏分割线颜色
/// @param color 颜色，默认 #F0F0F0
- (void)setSeparatorLineColor:(UIColor *)color;

#pragma mark: - 返回按钮相关方法
/// 设置返回按钮图片
/// @param image 图片，图片显示状态默认 UIControlStateNormal 状态
- (void)setBackBtnImage:(UIImage *)image;
/// 设置返回按钮图片
/// @param image 图片
/// @param state 图片显示状态
- (void)setBackBtnImage:(UIImage *)image forState:(UIControlState)state;

/// 设置返回按钮背景图
/// @param image 图片，图片显示状态默认 UIControlStateNormal 状态
- (void)setBackBtnBackgroundImage:(UIImage *)image;

/// 设置返回按钮背景图
/// @param image 图片
/// @param state 图片显示状态
- (void)setBackBtnBackgroundImage:(UIImage *)image forState:(UIControlState)state;

/// 设置返回按钮标题
/// @param title 提示内容，默认 #787878
- (void)setBackBtnTitle:(NSString *)title;


/// 设置返回按钮标题和颜色
/// @param title 提示内容
/// @param color 文本颜色
- (void)setBackBtnTitle:(NSString *)title color:(UIColor *)color;


/// 隐藏返回按钮
/// @param hidden 是否隐藏，默认显示
- (void)hiddenBackBtn:(BOOL)hidden;

#pragma mark: - 添加右侧自定义按钮
/// 添加右侧自定义按钮，超过 3 个可能会有显示问题
/// @param item 自定义View
- (void)addRightItem:(UIView *)item;

/// 添加右侧自定义按钮，超过 3 个可能会有显示问题
/// @param items 自定义View数组
- (void)addRightItems:(NSArray<UIView *> *)items;

#pragma mark: - 获取状态栏信息
/// 是否隐藏了状态栏
- (BOOL)isHiddenNaviView;
/// 是否隐藏了返回按钮
- (BOOL)isHiddenBackBtn;
/// 获取右侧返回按钮个数
- (NSUInteger)getRightItemsCount;

@end
NS_ASSUME_NONNULL_END
