//
//  KYBaseNaviViewController.m
//  MobileBank
//
//  Created by 康鹏鹏 on 2021/6/10.
//

#import "KYBaseNaviViewController.h"
#import "KYControllerView.h"
#import "KYNaviTool.h"

#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height

@interface KYBaseNaviViewController ()
@property (nonatomic, strong) KYNavigationView *naviView;
/// 修改self.view 的指向，因为导航栏超出self.view 区域不可响应，为了实现超出响应事件
@property (nonatomic, strong) KYControllerView *controllerView;
/// 控制器上下问，给外部传递信息使用
@property (nonatomic, strong) KYNaviContext *naviContext;
/// self.view.y 相对顶部偏移距离
@property (nonatomic, assign) CGFloat edgesTop;
/// self.view 底部偏移距离
@property (nonatomic, assign) CGFloat edgesBottom;
@end

@implementation KYBaseNaviViewController {
    /// 用户是否设置了 edgesTop 属性
    BOOL _hasSetEdgesTop;
    /// 上级页面系统导航栏是否隐藏，为了恢复上级页面导航栏状态
    BOOL _isHiddenOfPrevControllerNaviBar;
}

- (instancetype)init {
    if (self = [super init ]) {
        [self initData];
    }
    return self;
}

- (void)initData {
    _edgesTop = [KYNaviTool getStatusBarHeight] + [KYNaviTool getNavigationBarHeight];
    _edgesBottom = 0;
    // 处理title的点击事件回传给外界
    __weak typeof(self) weakSelf = self;
    self.naviView.didTouchTitle = ^(NSString * _Nonnull title, NSSet<UITouch *> * _Nonnull touches, UIEvent * _Nonnull event) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.ky_didTouchTitle) {
            strongSelf.ky_didTouchTitle(strongSelf.naviContext);
        }
        //[strongSelf ];
        if (strongSelf.navigationDelegate && [strongSelf.navigationDelegate respondsToSelector:@selector(ky_navigationController:didTouchTitleView:)]) {
            [strongSelf.navigationDelegate ky_navigationController:strongSelf didTouchTitleView:strongSelf.naviContext];
        }
    };
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 导航根控制器，不显示返回按钮
    if (self.navigationController.viewControllers.firstObject == self) {
        [self initData];
        [self setEdgesTop:_edgesTop];
        [self hiddenNaviBackBtn:YES];
    }
    
    [self setupNaviView];
    if (self.ky_viewDidLoad) {
        self.ky_viewDidLoad(self.naviContext);
    }
    if (self.navigatinPageStatusDelegate && [self.navigatinPageStatusDelegate respondsToSelector:@selector(ky_viewDidLoad:)]) {
        [self.navigatinPageStatusDelegate ky_viewDidLoad:self.naviContext];
    }
    
    if (self.ky_addCustomView) {
        self.ky_addCustomView(self.naviContext);
    }
    if (self.navigationDelegate && [self.navigationDelegate respondsToSelector:@selector(ky_addCustomView:)]) {
        [self.navigationDelegate ky_addCustomView:self.naviContext];
    }
  
}

#pragma mark: - 通用/常用方法
- (void)setTitle:(NSString *)title {
    [self setNaviTitle:title];
}
- (void)setNaviTitle:(NSString *)title {
    [self.naviView setTitle:title];
}
- (NSString *)title {
     return [self.naviView title];
}
- (void)hiddenNaviView:(BOOL)isHidden {
    self.naviView.hidden = isHidden;
    [self updateControllerViewFrame];
    [self updateNaviViewFrame];
}

- (void)setNaviBackgroundColor:(UIColor *)color {
    if (color == nil) return;
    // 背景透明，导航栏下的分割线默认也要设置成透明
    if (color == [UIColor clearColor]) {
        [self.naviView setSeparatorLineColor:color];
    }
    self.naviView.backgroundColor = color;
}
/// 设置导航栏背景图片
/// @param image 图片
- (void)setNaviBackgroundImage:(UIImage *)image {
    if (image == nil) return;
    [self setNaviBackgroundImage:image contentMode:UIViewContentModeScaleToFill];
}
- (void)setNaviBackgroundImage:(UIImage *)image contentMode:(UIViewContentMode)contentMode {
    if (image == nil) return;
    [self.naviView setBackgroundImage:image contentMode:contentMode];
}

/// 是否隐藏导航栏底部分割线
/// @param hidden 默认显示
- (void)hiddenNaviSeparatorLine:(BOOL)hidden {
    [self.naviView hiddenSeparatorLine:hidden];
}
/// 设置导航栏分割线颜色
/// @param color 颜色，默认 #F0F0F0
- (void)setNaviSeparatorLineColor:(UIColor *)color {
    if (color == nil) return;
    [self.naviView setSeparatorLineColor:color];
}

/// self.view.y 零点相对顶部偏移距离，
/// 设置后，self.view.y 零点将不再从导航栏底部开始算起
/// 同时，隐藏导航栏后，self.view.y 也还会根据该值设置
/// @param top 相对顶部偏移距离，默认偏移量为 系统导航栏高度+系统状态栏高度
- (void)setEdgesTop:(CGFloat)top {
    _edgesTop = top;
    _hasSetEdgesTop = YES;
    // 此处要修正self.view 的坐标 和 导航栏坐标
    [self updateControllerViewFrame];
    [self updateNaviViewFrame];
}
/// 设置 self.view 距离底部偏移距离，默认 0，
/// 目的是为了适配底部有自定义 tabbar 的情况
/// 如果使用系统的 tabbar，此处无需设置
/// @param bottom 相对于底部偏移量
- (void)setEdgesBottom:(CGFloat)bottom {
    _edgesBottom = bottom;
    [self updateControllerViewFrame];
}

- (void)goback {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark: - 返回按钮设置
/// 设置返回按钮图片
/// @param image 图片，图片显示状态默认 UIControlStateNormal 状态
- (void)setNaviBackBtnImage:(UIImage *)image {
    [self setNaviBackBtnImage:image forState:UIControlStateNormal];
}
/// 设置返回按钮图片
/// @param image 图片
/// @param state 图片显示状态
- (void)setNaviBackBtnImage:(UIImage *)image forState:(UIControlState)state
{
    [self.naviView setBackBtnImage:image forState:state];
}
/// 设置返回按钮背景图
/// @param image 图片，图片显示状态默认 UIControlStateNormal 状态
- (void)setNaviBackBtnBackgroundImage:(UIImage *)image {
    [self setNaviBackBtnBackgroundImage:image forState:UIControlStateNormal];
}

/// 设置返回按钮背景图
/// @param image 图片
/// @param state 图片显示状态
- (void)setNaviBackBtnBackgroundImage:(UIImage *)image forState:(UIControlState)state {
    [self.naviView setBackBtnBackgroundImage:image forState:state];
}

/// 设置返回按钮标题
/// @param title 提示内容
- (void)setNaviBackBtnTitle:(NSString *)title {
    [self.naviView setBackBtnTitle:title];
}
/// 设置导航按钮标题和颜色
/// @param title 提示内容
/// @param color 标题颜色
- (void)setNaviBackBtnTitle:(NSString *)title color:(UIColor *)color {
    [self.naviView setBackBtnTitle:title color:color];
}

/// 隐藏返回按钮
/// @param isHidden 是否隐藏返回按钮，默认 NO 不隐藏
- (void)hiddenNaviBackBtn:(BOOL)isHidden {
    [self.naviView hiddenBackBtn:isHidden];
}

#pragma mark: - 添加右侧自定义按钮
/// 添加右侧自定义按钮
/// @param item 自定义视图
- (void)addNaviRightItem:(UIView *)item {
    [self.naviView addRightItem:item];
    //[self.naviConfig.naviRightItems addObject:item];
}
/// 批量添加右侧自定义按钮
/// @param items 自定义视图数组
- (void)addNaviRightItems:(NSArray<UIView *> *)items {
    if (items == nil) return;
    //[self.naviConfig.naviRightItems addObjectsFromArray:items];
    [self.naviView addRightItems:items];
}

#pragma mark: - 获取状态栏信息
/// 获取自定义导航控制器上下文信息
- (KYNaviContext *)getNaviContext {
    return self.naviContext;
}
/// 获取状态栏高度
- (CGFloat)getStatusBarHeight {
    return [KYNaviTool getStatusBarHeight];
}
/// 获取导航栏高度
- (CGFloat)getNavigationBarHeight {
    return [KYNaviTool getNavigationBarHeight];
}
/// 获取导航栏和状态栏总高度
- (CGFloat)getNaviBarAndStatusBarHeight {
    return [self getStatusBarHeight] + [self getNavigationBarHeight];
}
/// 获取底部安全区域高度
- (CGFloat)getSafeArea {
    return [KYNaviTool getSafeArea];
}
/// 获取底部 TabBar 高度
- (CGFloat)getTabBarHeight {
    return self.tabBarController.tabBar.frame.size.height;
}
/// 是否隐藏了状态栏
- (BOOL)isHiddenNaviView {
    return [self.naviView isHiddenNaviView];
}
/// 是否隐藏了返回按钮
- (BOOL)isHiddenBackBtn {
    return [self.naviView isHiddenBackBtn];
}
/// 获取右侧返回按钮个数
- (NSUInteger)getRightItemsCount {
    return [self getRightItemsCount];
}

#pragma mark: - 私有方法
- (void)gobackBtnAction:(UIButton *)button {
    BOOL canGoback = YES;
    if (self.navigationDelegate && [self.navigationDelegate respondsToSelector:@selector(ky_navigationController:canPerformGoback:)]) {
        canGoback = [self.navigationDelegate ky_navigationController:self canPerformGoback:self.naviContext];
    }
    if (canGoback == NO) return;
    if (self.ky_canPerformGoback) {
        canGoback = self.ky_canPerformGoback(self.naviContext);
    }
    if (canGoback == NO) return;
    if (self.navigationDelegate && [self.navigationDelegate respondsToSelector:@selector(ky_navigationController:willPerformGoback:)]) {
        [self.navigationDelegate ky_navigationController:self willPerformGoback:self.naviContext];
    }
    if (self.ky_willPerformGoback) {
        self.ky_willPerformGoback(self.naviContext);
    }
    [self goback];
    if (self.navigationDelegate && [self.navigationDelegate respondsToSelector:@selector(ky_navigationController:didPerformGoback:)]) {
        [self.navigationDelegate ky_navigationController:self didPerformGoback:self.naviContext];
    }
    if (self.ky_didPerformGoback) {
        self.ky_didPerformGoback(self.naviContext);
    }
}

#pragma mark: - UI 布局
//- (void)viewDidLayoutSubviews
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self updateControllerViewFrame];
    [self updateNaviViewFrame];
    // 视图每次更新渲染后，将导航栏放到最上层
    [self.view bringSubviewToFront:self.naviView];
}

- (void)setupNaviView {
    // 替换controller.view 指针，
    self.controllerView.frame = self.view.frame;
    [self updateControllerViewFrame];
    self.view = self.controllerView;
//    for (UIView *item in self.view.subviews) {
//
//    }
    // 设置导航栏
    [self updateNaviViewFrame];
    [self.naviView gobackBtnAddTarget:self action:@selector(gobackBtnAction:)];
    [self.naviView addToController:self];
    [self.view layoutIfNeeded];
}

/// 更新self.view.frame
- (void)updateControllerViewFrame {
    CGFloat viewY = [self calculateControllerViewOriginY];
    CGFloat viewH = [self calculateControllerViewHeight];
    //self.view.frame = CGRectMake(0, viewY, SCREEN_WIDTH, viewH);
    self.controllerView.frame = CGRectMake(0, viewY, SCREEN_WIDTH, viewH);
}
/// 更新导航栏Y坐标
- (void)updateNaviViewFrame {
    CGFloat statusAndNaviHeight = [KYNaviTool getStatusBarHeight] + [KYNaviTool getNavigationBarHeight];
    self.naviView.frame = CGRectMake(0, -self.edgesTop, SCREEN_WIDTH, statusAndNaviHeight);
}
/// 计算self.view.height
- (CGFloat)calculateControllerViewHeight {
    CGFloat tabbarHeight = 0;
    if (self.tabBarController.tabBar.isHidden == NO) {
        tabbarHeight = self.tabBarController.tabBar.frame.size.height;
    }
    return SCREEN_HEIGHT - [self calculateControllerViewOriginY] - tabbarHeight - self.edgesBottom;
}
/// 计算self.view.y
- (CGFloat)calculateControllerViewOriginY {
    // 如果设置了隐藏导航，顶部偏移距离设置为0
    if (self.naviView.isHidden) {
        return 0;
    }
    // 如果设置了顶部偏移距离，将不再考虑导航栏是否隐藏
    // 如果调用者未设置顶部偏移，则根据导航栏是否隐藏设置 self.view.y
    if (_hasSetEdgesTop) return self.edgesTop;
    CGFloat statusAndNaviHeight = [KYNaviTool getStatusBarHeight] + [self getNavigationBarHeight];
    return self.naviView.isHidden ? 0 : statusAndNaviHeight;
}

#pragma mark: - 属性
/// 导航栏视图
- (KYNavigationView *)naviView {
    if (!_naviView) {
        _naviView = [[KYNavigationView alloc] init];
    }
    return _naviView;
}
/// 控制器上的View
- (KYControllerView *)controllerView {
    if (!_controllerView) {
        _controllerView = [[KYControllerView alloc] init];
        _controllerView.backgroundColor = self.view.backgroundColor;
    }
    return _controllerView;
}
- (KYNaviContext *)naviContext {
    if (!_naviContext) {
        _naviContext = [[KYNaviContext alloc] init];
        _naviContext.controller = self;
        _naviContext.navigationView = self.naviView;
    }
    return _naviContext;
}


#pragma mark: - 控制器周期方法block
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _isHiddenOfPrevControllerNaviBar = self.navigationController.navigationBar.isHidden;
    self.navigationController.navigationBar.hidden = YES;
    if (self.ky_viewWillAppear) {
        self.ky_viewWillAppear(self.naviContext);
    }
    if (self.navigatinPageStatusDelegate && [self.navigatinPageStatusDelegate respondsToSelector:@selector(ky_viewWillAppear:)]) {
        [self.navigatinPageStatusDelegate ky_viewWillAppear:self.naviContext];
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.ky_viewDidAppear) {
        self.ky_viewDidAppear(self.naviContext);
    }
    if (self.navigatinPageStatusDelegate && [self.navigatinPageStatusDelegate respondsToSelector:@selector(ky_viewDidAppear:)]) {
        [self.navigatinPageStatusDelegate ky_viewDidAppear:self.naviContext];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = _isHiddenOfPrevControllerNaviBar;
    if (self.ky_viewWillDisappear) {
        self.ky_viewWillDisappear(self.naviContext);
    }
    if (self.navigatinPageStatusDelegate && [self.navigatinPageStatusDelegate respondsToSelector:@selector(ky_viewWillDisappear:)]) {
        [self.navigatinPageStatusDelegate ky_viewWillDisappear:self.naviContext];
    }
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.ky_viewDidDisappear) {
        self.ky_viewDidDisappear(self.naviContext);
    }
    // self.controllerView 不会导致内存泄露
    // self.controllerView = nil;
    if (self.navigatinPageStatusDelegate && [self.navigatinPageStatusDelegate respondsToSelector:@selector(ky_viewDidDisappear:)]) {
        [self.navigatinPageStatusDelegate ky_viewDidDisappear:self.naviContext];
    }
    // 上下文和self强引用，此处要释放
    self.naviContext = nil;
}


//- (void)dealloc {
//    NSLog(@"****************");
//}


@end
