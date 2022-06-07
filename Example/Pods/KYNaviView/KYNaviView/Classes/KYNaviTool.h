//
//  KYNaviTool.h
//  KYNaviView
//
//  Created by 康鹏鹏 on 2022/3/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KYNaviTool : NSObject

/// 获取状态栏高度
+ (CGFloat)getStatusBarHeight;

/// 获取导航栏高度
+ (CGFloat)getNavigationBarHeight;

/// 获取底部安全区域高度
+ (CGFloat)getSafeArea;


/// 计算 Label 宽度
/// @param text 文本内容
/// @param height Label 高度
/// @param font 文本字体
//+ (CGFloat)getLabelWidthWithText:(NSString *)text
//                          height:(CGFloat)height
//                            font:(CGFloat)font;



@end

NS_ASSUME_NONNULL_END
