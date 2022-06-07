//
//  KYNaviTool.m
//  KYNaviView
//
//  Created by 康鹏鹏 on 2022/3/14.
//

#import "KYNaviTool.h"

// 状态栏高度
#define STATUS_BAR_HEIGHT       (IS_FULL_SCREEN ? (44.0) : (20.0))
#define NAVI_BAR_HEIGHT         (44.0)

#define IS_FULL_SCREEN \
^(){ \
BOOL isFullIphone = NO; \
    if (@available(iOS 11.0, *)) { \
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window]; \
        if (mainWindow.safeAreaInsets.bottom > 0.0) { \
            isFullIphone = YES; \
        } \
    } \
    return isFullIphone; \
}()

@implementation KYNaviTool

#pragma mark: - 工具方法
/// 获取状态栏高度
+ (CGFloat)getStatusBarHeight {
    return STATUS_BAR_HEIGHT;
}

/// 获取导航栏高度
+ (CGFloat)getNavigationBarHeight {
    return NAVI_BAR_HEIGHT;
}

/// 获取底部安全区域高度
+ (CGFloat)getSafeArea {
    CGFloat safeArea = 0.0f;
    if (@available(iOS 11.0, *)) {
        safeArea = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom;
    } else {
        // Fallback on earlier versions
    }
    return safeArea;
}


@end
