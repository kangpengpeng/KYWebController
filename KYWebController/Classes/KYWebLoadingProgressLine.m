//
//  KYWebLoadingProgressLine.m
//  KYWebController
//
//  Created by 康鹏鹏 on 2022/4/13.
//  WKWebView 加载进度条

#import "KYWebLoadingProgressLine.h"

@interface KYWebLoadingProgressLine()
/// 当前进度值
@property (nonatomic, assign) CGFloat progressValue;
/// 进度条高度
@property (nonatomic, assign) NSUInteger progressLineHeight;
/// 进度条颜色
@property (nonatomic, strong) UIColor *progressLineColor;
/// 进度条轨道颜色
@property (nonatomic, strong) UIColor *progressLineTrackColor;
@end

@implementation KYWebLoadingProgressLine

- (instancetype)init {
    if (self = [super init]) {
        self.progressValue = 0.00;
        self.progressLineHeight = 2;
        self.progressLineColor = [UIColor colorWithRed:42/255.0 green:142/255.0 blue:251/255.0 alpha:1];
        self.progressLineTrackColor = [UIColor colorWithRed:240.0/255
                                                      green:240.0/255
                                                       blue:240.0/255
                                                      alpha:1.0];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.progressLineHeight = frame.size.height;
}

/// 设置进度值
/// @param progressValue [0.00, 1.00]
- (void)setProgressValue:(CGFloat)progressValue {
    _progressValue = progressValue;
    [self setNeedsDisplay];
}
/// 设置进度条颜色
/// @param progressLineColor 进度条颜色
- (void)setProgressLineColor:(UIColor *)progressLineColor {
    _progressLineColor = progressLineColor;
}

///// 设置进度条高度
///// @param progressLineHeight 无符号整形
//- (void)setProgressLineHeight:(NSUInteger)progressLineHeight {
//    _progressLineHeight = progressLineHeight;
//}



- (void)drawRect:(CGRect)rect {
    CGFloat lineY = self.progressLineHeight/2;
    CGPoint startPoint = CGPointMake(0, lineY);
    CGFloat progressX = MIN(rect.size.width, rect.size.width*self.progressValue);
    CGPoint progressPoint = CGPointMake(progressX, self.progressLineHeight/2);
    CGPoint endPoint = CGPointMake(rect.size.width, lineY);
    
    // 进度条背景色
    UIBezierPath *bgPath = [UIBezierPath bezierPath];
    [bgPath moveToPoint:startPoint];
    [bgPath addLineToPoint:endPoint];
    bgPath.lineWidth = self.progressLineHeight;
    [self.progressLineTrackColor setStroke];
    [bgPath stroke];
    
    UIBezierPath *progressPath = [UIBezierPath bezierPath];
    [progressPath moveToPoint:startPoint];
    [progressPath addLineToPoint:progressPoint];
    progressPath.lineWidth = self.progressLineHeight;
    [self.progressLineColor setStroke];
    [progressPath stroke];
}


@end
