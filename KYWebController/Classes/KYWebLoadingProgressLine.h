//
//  KYWebLoadingProgressLine.h
//  KYWebController
//
//  Created by 康鹏鹏 on 2022/4/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KYWebLoadingProgressLine : UIView

/// 设置进度值
/// @param progressValue [0.00, 1.00]
- (void)setProgressValue:(CGFloat)progressValue;

/// 设置进度条高度
/// @param progressLineHeight 进度条宽度（无符号整形）
//- (void)setProgressLineHeight:(NSUInteger)progressLineHeight;

/// 设置进度条颜色
/// @param progressLineColor 进度条颜色
- (void)setProgressLineColor:(UIColor *)progressLineColor;

@end

NS_ASSUME_NONNULL_END
