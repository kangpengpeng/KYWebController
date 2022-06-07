//
//  KYNavigationView.m
//  MobileBank
//
//  Created by 康鹏鹏 on 2021/6/9.
//

#import "KYNavigationView.h"
#import "KYNaviBackButton.h"
#import "KYNaviTool.h"
#import "KYNaviTitleLabel.h"


/// 默认背景色
#define NAVI_BG_COLOR           [UIColor whiteColor]
/// 默认标题颜色
#define NAVI_TITLE_COLOR        [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]
/// 默认分割线颜色
#define NAVI_BOTTOM_LINE_COLOR  [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1]
/// 默认返回按钮颜色
#define NAVI_BACK_COLOR         [UIColor colorWithRed:120/255.0 green:120/255.0 blue:120/255.0 alpha:1]

#define SCREEN_WIDTH            [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT           [UIScreen mainScreen].bounds.size.height

/// 右侧按钮最宽宽度
#define MAX_WIDTH_OF_RIGHT_ITEMS_CONTENT    120
/// 右侧按钮最窄宽度，即默认宽度
#define MIN_WIDTH_OF_BACK_BTN    60
/// 返回按钮最宽宽度
#define MAX_WIDTH_OF_BACK_BTN               MAX_WIDTH_OF_RIGHT_ITEMS_CONTENT



@interface KYNavigationView()

/// 返回按钮
@property (nonatomic, strong)KYNaviBackButton *backBtn;
/// 导航栏标题
@property (nonatomic, strong)KYNaviTitleLabel *titleLabel;

/// 拿到控制器引用
@property (nonatomic, weak)UIViewController *controller;
/// 导航栏下方分割线
@property (nonatomic, strong)UIView *bottomLine;

/// 背景图片
@property (nonatomic, strong)UIImageView *backgroundImageView;

/// 外部添加的右侧自定义按钮
@property (nonatomic, strong)NSMutableArray *rightItemArr;
/// 外部自定义按钮容器
@property (nonatomic, strong)UIView *rightItemsContent;
@end

@implementation KYNavigationView


- (instancetype)init {
    self = [super init];
    if (self) {
        [self setBackgroundColor:NAVI_BG_COLOR];
        [self setupSubviews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // 如果 push 之前设置了 controller 右侧按钮，会导致坐标不准确
    // 所以，视图开始布局的时候，排版右侧自定义按钮
    [self composingRightItems:self.rightItemArr];
    // 动态调整布局
    [self layoutStrategy];
}

/// 返回按钮、标题和右侧按钮布局策略
/// 左侧按钮宽度范围 60——120
/// 右侧按钮宽度范围 0——120
/// 右侧按钮最多显示 3 个
/// 右侧按钮容器宽度不大于返回按钮宽度(或等于)，为了中间title可以居中显示
/// title 可以全显的情况下，左侧按钮和右侧按钮不大于 120
/// title 不可以全显的情况下，左侧按钮宽度不会小于 60
- (void)layoutStrategy {
    CGFloat backBtnWidth = [self getBackBtnShowAllWidth];
    CGFloat titleLbWidth = [self getTitleLabelShowAllWith];
    CGFloat rightItemsContentWidth = self.rightItemArr.count > 0 ? CGRectGetWidth(self.rightItemsContent.frame) : 0;
    if (rightItemsContentWidth > MAX_WIDTH_OF_RIGHT_ITEMS_CONTENT) {
        rightItemsContentWidth = MAX_WIDTH_OF_BACK_BTN;
        NSLog(@"右侧按钮数量支持最大 3 个，多出按钮不再显示！如有特殊需要，请自定义导航栏布局。");
        self.rightItemsContent.frame = CGRectMake(self.frame.size.width - rightItemsContentWidth, self.rightItemsContent.frame.origin.y, rightItemsContentWidth, self.rightItemsContent.frame.size.height);
    }
    if (titleLbWidth == 0 || self.titleLabel.text.length == 0) {
        backBtnWidth = MAX_WIDTH_OF_BACK_BTN;
    }
    // title 显示全的情况下，返回按钮宽度可以达到最大值
    else if ((titleLbWidth + MAX(MAX_WIDTH_OF_BACK_BTN, MAX_WIDTH_OF_RIGHT_ITEMS_CONTENT) * 2) < self.frame.size.width) {
        backBtnWidth = MAX_WIDTH_OF_BACK_BTN;
        rightItemsContentWidth = MAX_WIDTH_OF_BACK_BTN;
        titleLbWidth = self.frame.size.width - MAX(MAX_WIDTH_OF_BACK_BTN, MAX_WIDTH_OF_RIGHT_ITEMS_CONTENT) * 2;
    }
    // title 可以显示全的情况下，且右侧按钮在阀值内，返回按钮在阀值范围内(60——120)，
    // 那么优先把title全显，剩余宽度显示返回按钮
    else if ((titleLbWidth + MAX(rightItemsContentWidth, MIN_WIDTH_OF_BACK_BTN) * 2) < self.frame.size.width) {
        backBtnWidth = (self.frame.size.width - titleLbWidth) / 2;
    }
    // title 可以显示全的情况下，且右侧按钮在阀值内，返回按钮宽度低于最低阀值
    // 返回按钮取最小阀值，剩余宽度给title
    else if ((titleLbWidth + MAX(rightItemsContentWidth, MIN_WIDTH_OF_BACK_BTN) * 2) >= self.frame.size.width) {
        backBtnWidth = MAX(rightItemsContentWidth, MIN_WIDTH_OF_BACK_BTN);
        titleLbWidth = self.frame.size.width - backBtnWidth * 2;
    }
    self.backBtn.frame = CGRectMake(self.backBtn.frame.origin.x, self.backBtn.frame.origin.y, backBtnWidth, self.backBtn.frame.size.height);
    self.titleLabel.frame = CGRectMake(backBtnWidth, self.titleLabel.frame.origin.y, titleLbWidth, self.titleLabel.frame.size.height);
    /*
    CGFloat backBtnWidth = [self getBackBtnShowAllWidth];
    CGFloat titleLbWidth = [self getTitleLabelShowAllWith];
    CGFloat rightItemsContentWidth = self.rightItemArr.count > 0 ? CGRectGetWidth(_rightItemsContent.frame) : 0;
    // 右侧按钮超出阀值，设置为阀值
    if (rightItemsContentWidth > MAX_WIDTH_OF_RIGHT_ITEMS_CONTENT) {
        rightItemsContentWidth = MAX_WIDTH_OF_RIGHT_ITEMS_CONTENT;
        NSLog(@"右侧按钮数量支持最大 3 个，否则将出现布局问题！如有特殊需要，请自定义导航栏布局。");
    }
    // 左侧按钮小于最小阀值，设置为最小阀值
    if (backBtnWidth < MIN_WIDTH_OF_BACK_BTN) {
        backBtnWidth = MIN_WIDTH_OF_BACK_BTN;
    }
    // 左侧按钮大于最大阀值，设置为最大阀值
    if (backBtnWidth > MAX_WIDTH_OF_BACK_BTN) {
        backBtnWidth = MAX_WIDTH_OF_BACK_BTN;
    }
    // 更新返回按钮宽度
    CGFloat titleX = MAX(backBtnWidth, rightItemsContentWidth);
    CGFloat titleW = self.frame.size.width - (titleX * 2);
    self.backBtn.frame = CGRectMake(self.backBtn.frame.origin.x, self.backBtn.frame.origin.y, titleX, self.backBtn.frame.size.height);
    self.titleLabel.frame = CGRectMake(titleX, self.titleLabel.frame.origin.y, titleW, self.titleLabel.frame.size.height);
    // 更新右侧按钮容器宽度，右侧容器不可更新，否则右侧按钮坐标出错
//    NSLog(@"backBtnWidth = %f", backBtnWidth);
//    NSLog(@"rightItemsContentWidth = %f", rightItemsContentWidth);
//    NSLog(@"titleLbWidth = %f", titleLbWidth);
//    NSLog(@"titleLbWidth = %f", titleX);
     */
}

/// 默认初始化布局
- (void)setupSubviews {
    CGFloat btnWidth = MAX_WIDTH_OF_BACK_BTN;
    CGFloat naviBarHeight = [KYNaviTool getNavigationBarHeight];
    CGFloat statusBarHeight = [KYNaviTool getStatusBarHeight];
    // 返回按钮
    self.backBtn.frame = CGRectMake(0, statusBarHeight, btnWidth, naviBarHeight);
    self.backBtn.backgroundColor = [UIColor clearColor];
    [self addSubview:self.backBtn];
    [self bringSubviewToFront:self.backBtn];
    // 标题
    self.titleLabel.frame = CGRectMake(btnWidth, statusBarHeight, SCREEN_WIDTH-btnWidth*2, naviBarHeight);
    [self addSubview:self.titleLabel];
    // 分割线
    self.bottomLine.frame = CGRectMake(0, naviBarHeight+statusBarHeight-1, SCREEN_WIDTH, 1);
    [self addSubview:self.bottomLine];
}


#pragma mark: - KYNavigationViewProtocol
/// 将导航栏添加到指定控制器
/// @param controller 自定义导航栏所在控制器
- (void)addToController:(UIViewController *)controller {
    self.controller = controller;
    [controller.view addSubview:self];
}
/// 给返回按钮添加方法
/// @param target 目标实例
/// @param selector 方法名
- (void)gobackBtnAddTarget:(id)target action:(SEL)selector {
    [self.backBtn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}
/// 设置背景图片，默认 UIViewContentModeScaleToFill 拉伸铺满
/// @param image 图片对象
- (void)setBackgroundImage:(UIImage *)image {
    if (image == nil) return;
    [self setBackgroundImage:image contentMode:UIViewContentModeScaleToFill];
}
/// 设置背景图片
/// @param image 图片对象
/// @param contentMode 图片填充方式
- (void)setBackgroundImage:(UIImage *)image contentMode:(UIViewContentMode)contentMode {
    if (image == nil) return;
    [self.backgroundImageView removeFromSuperview];
    self.backgroundImageView.image = image;
    self.backgroundImageView.contentMode = contentMode;
    self.backgroundImageView.frame = self.bounds;
    [self addSubview:self.backgroundImageView];
    [self sendSubviewToBack:self.backgroundImageView];
}
/// 设置标题
/// @param title 导航栏标题
- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
    // 最后设置title 布局不更新的问题
    [self layoutStrategy];
}
- (NSString *)title {
    return self.titleLabel.text;
}
/// 是否隐藏导航栏底部分割线
/// @param hidden 默认显示
- (void)hiddenSeparatorLine:(BOOL)hidden {
    self.bottomLine.hidden = hidden;
}
/// 设置导航栏分割线颜色
/// @param color 颜色，默认 #F0F0F0
- (void)setSeparatorLineColor:(UIColor *)color {
    self.bottomLine.backgroundColor = color;
}
/// 设置返回按钮图片
/// @param image 图片
- (void)setBackBtnImage:(UIImage *)image {
    [self setBackBtnImage:image forState:UIControlStateNormal];
}
/// 设置返回按钮图片
/// @param image 图片
/// @param state 按钮状态
- (void)setBackBtnImage:(UIImage *)image forState:(UIControlState)state {
    [self.backBtn setImage:image forState:state];
}
- (void)setBackBtnBackgroundImage:(UIImage *)image {
    [self setBackBtnBackgroundImage:image forState:UIControlStateNormal];
}
- (void)setBackBtnBackgroundImage:(UIImage *)image forState:(UIControlState)state {
    [self.backBtn setBackgroundImage:image forState:state];
}
- (void)setBackBtnTitle:(NSString *)title {
    [self.backBtn setTitle:title forState:UIControlStateNormal];
}
/// 设置返回按钮标题和颜色
/// @param title 提示内容
/// @param color 文本颜色
- (void)setBackBtnTitle:(NSString *)title color:(UIColor *)color {
    [self.backBtn setTitle:title forState:UIControlStateNormal];
    [self.backBtn setTitleColor:color forState:UIControlStateNormal];
    [self layoutStrategy];
}

- (void)hiddenBackBtn:(BOOL)hidden {
    [self.backBtn setHidden:hidden];
}

#pragma mark: - 添加右侧自定义按钮
/// 添加右侧自定义按钮
/// @param item 自定义View
- (void)addRightItem:(UIView *)item {
    if (item == nil) return;
    [self.rightItemArr addObject:item];
    //[self composingRightItems:self.rightItemArr];
}

/// 添加右侧自定义按钮
/// @param items 自定义View数组
- (void)addRightItems:(NSArray<UIView *> *)items {
    //[self.rightItemArr removeAllObjects];
    [self.rightItemArr addObjectsFromArray:items];
    //[self composingRightItems:self.rightItemArr];
}
/// 排版右侧自定义视图集合
- (void)composingRightItems:(NSArray<UIView *> *)items {
    // 如果数组为空，且右侧按钮容器已初始化，清除右侧按钮，并将容器释放
    if (items.count == 0) {
        return;
    }
    if (items.count == 0 && _rightItemsContent) {
        for (UIView *item in _rightItemsContent.subviews) {
            [item removeFromSuperview];
        }
        [_rightItemsContent removeFromSuperview];
        _rightItemsContent = nil;
        return;
    }
    CGFloat rightSpace = 10;
    CGFloat eleSpace = 10;
    CGFloat eleW = 30;
    CGFloat eleH = 30;
    CGFloat eleY = (CGRectGetHeight(self.frame) - [KYNaviTool getStatusBarHeight] - eleH) / 2.0;
    CGFloat contentW = (items.count * eleW) + (eleSpace * items.count);
    CGFloat contentX = CGRectGetWidth(self.frame) - contentW;
    CGFloat contentY = [KYNaviTool getStatusBarHeight];
    CGFloat contentH = CGRectGetHeight(self.frame) - contentY;
    self.rightItemsContent.frame = CGRectMake(contentX, contentY, contentW, contentH);
    [self addSubview:self.rightItemsContent];
    // 倒序遍历，从右向左排版显示
    [self.rightItemArr enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *element = (UIView *)obj;
        CGFloat eleX = contentW - rightSpace - ((idx+1) * eleW) - (idx * eleSpace);
        element.frame = CGRectMake(eleX, eleY, eleW, eleH);
        element.backgroundColor = [UIColor clearColor];
        [self.rightItemsContent addSubview:element];
    }];
    self.rightItemsContent.backgroundColor = [UIColor clearColor];
}

#pragma mark: - 获取状态栏信息
/// 是否隐藏了状态栏
- (BOOL)isHiddenNaviView {
    return self.isHidden;
}
/// 是否隐藏了返回按钮
- (BOOL)isHiddenBackBtn {
    return self.backBtn.isHidden;
}
/// 获取右侧返回按钮个数
- (NSUInteger)getRightItemsCount {
    return self.rightItemArr.count;
}

#pragma mark: - 工具方法
/// 计算 titleLabel 显示全需要的宽度
- (CGFloat)getTitleLabelShowAllWith {
    if (self.titleLabel.isHidden) {
        return 0;
    }
    //self.titleLabel.attributedText
    CGRect titleRect = [self.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, self.titleLabel.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:self.titleLabel.font forKey:NSFontAttributeName] context:nil];
    return titleRect.size.width;
}
/// 计算返回按钮文本显示全需要的宽度
- (CGFloat)getBackBtnShowAllWidth {
    if (self.backBtn.isHidden) {
        return 0;
    }
    CGRect btnTitleRect = [self.backBtn.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, self.backBtn.titleLabel.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:self.backBtn.titleLabel.font forKey:NSFontAttributeName] context:nil];
    CGFloat titleW = btnTitleRect.size.width;
    CGFloat titleX = self.backBtn.imageView.frame.size.width + self.backBtn.imageView.frame.origin.x;
    return titleX + titleW;
}
///// 计算右侧自定义按钮全部显示需要的宽度
//- (CGFloat)getRightItemsShowAllWidth {
//    return 0;
//}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches.allObjects lastObject];
    CGPoint point = [touch locationInView:self.titleLabel];
    BOOL result = [self.titleLabel.layer containsPoint:point];
    if (result && self.didTouchTitle) {
        self.didTouchTitle(self.titleLabel.text, touches, event);
    }
}
#pragma mark: - 属性
- (KYNaviTitleLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[KYNaviTitleLabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = NAVI_TITLE_COLOR;
        _titleLabel.font = [UIFont boldSystemFontOfSize:20];
        _titleLabel.backgroundColor = [UIColor clearColor];
    }
    return _titleLabel;
}

- (KYNaviBackButton *)backBtn {
    if (!_backBtn) {
        NSBundle *currBundle = [NSBundle bundleForClass:self.class];
        NSString *imagePath = [currBundle pathForResource:@"navi_back_black@2x.png" ofType:nil inDirectory:@"KYNaviView.bundle"];
        UIImage *backImg = [UIImage imageWithContentsOfFile:imagePath];
        _backBtn = [KYNaviBackButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:backImg forState:UIControlStateNormal];
        // 默认设置和返回按钮一样的颜色
        [_backBtn setTitleColor:NAVI_BACK_COLOR forState:UIControlStateNormal];
    }
    return _backBtn;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = NAVI_BOTTOM_LINE_COLOR;
    }
    return _bottomLine;
}

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] init];
        // 拉伸铺满
        _backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    }
    return _backgroundImageView;
}
- (NSMutableArray *)rightItemArr {
    if (!_rightItemArr) {
        _rightItemArr = [NSMutableArray arrayWithCapacity:2];
    }
    return _rightItemArr;
}
- (UIView *)rightItemsContent {
    if (!_rightItemsContent) {
        _rightItemsContent = [[UIView alloc] init];
        _rightItemsContent.backgroundColor = [UIColor clearColor];
    }
    return _rightItemsContent;
}





@end
