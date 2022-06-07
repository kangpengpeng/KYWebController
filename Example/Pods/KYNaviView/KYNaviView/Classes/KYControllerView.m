//
//  KYControllerView.m
//  KYNaviView
//
//  Created by 康鹏鹏 on 2022/3/14.
//

#import "KYControllerView.h"

@implementation KYControllerView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.clipsToBounds || self.hidden || (self.alpha == 0.f)) {
        return nil;
     }
    UIView *result = [super hitTest:point withEvent:event];
    // 如果事件发生在self.view里面直接返回
    if (result) {
        return result;
    }
    // 这里遍历那些超出的部分就可以了，不过这么写比较通用。
    for (UIView *subview in self.subviews) {
        //NSLog(@"%@", subview.class);
        if ([subview isKindOfClass:NSClassFromString(@"KYNavigationView")]) {
            // 把这个坐标从tabbar的坐标系转为subview的坐标系
            CGPoint subPoint = [subview convertPoint:point fromView:self];
            result = [subview hitTest:subPoint withEvent:event];
            // 如果事件发生在subView里就返回
            if (result) {
                return result;
            }
        };
    }
    return nil;
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    /* tableview 顶部会预留一个状态栏的空白区域，打开此处可以不预留空白区域
    if ([view isKindOfClass:[UITableView class]]) {
        if (@available(iOS 11.0, *)) {
            ((UITableView *)view).contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
    }
     */
}


@end
