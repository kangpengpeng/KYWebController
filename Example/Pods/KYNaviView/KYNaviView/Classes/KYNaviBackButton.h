//
//  KYNaviBackButton.h
//  MobileBank
//
//  Created by 康鹏鹏 on 2021/6/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 导航栏返回按钮高度（自定义返回按钮）
#define NAVI_BACK_BTN_HEIGHT  24.0
/// 导航栏返回按钮宽度 原图比例 W : H = 24 : 36
#define NAVI_BACK_BTN_WIDTH   ((NAVI_BACK_BTN_HEIGHT) * (24.0/36.0))

@interface KYNaviBackButton : UIButton

@end

NS_ASSUME_NONNULL_END
