//
//  KYNaviBackButton.m
//  MobileBank
//
//  Created by 康鹏鹏 on 2021/6/9.
//

#import "KYNaviBackButton.h"

@implementation KYNaviBackButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    // 原图比例 W : H = 24 : 36
    // 上边距和下边距
    if (self.currentImage) {
        CGFloat height = NAVI_BACK_BTN_HEIGHT;
        // 根据高度计算宽度
        CGFloat width = NAVI_BACK_BTN_WIDTH;
        // 再计算 X Y 坐标
        CGFloat x = 16;
        CGFloat y = (contentRect.size.height - height) / 2;
        //NSLog(@"w=%f, h=%f", width, height);
        return CGRectMake(x, y, width, height);
    }
    return CGRectZero;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    if (self.currentTitle) {
        CGFloat x = NAVI_BACK_BTN_WIDTH + 16 + 4;
        CGFloat y = 0;
        CGFloat width = contentRect.size.width - x;
        CGFloat height = contentRect.size.height;
        return CGRectMake(x, y, width, height);
    }
    return CGRectZero;
}

@end
