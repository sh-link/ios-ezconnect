//
//  SHSetupTabBar.m
//  SHLink
//
//  Created by zhen yang on 15/3/19.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "SHSetupTabBar.h"
#import "SHTabBarButton.h"
#import "MessageUtil.h"
@interface SHSetupTabBar()
@property (nonatomic, strong) SHTabBarButton *wifiButton;
@property (nonatomic, strong) SHTabBarButton *wanButton;
@property (nonatomic, strong) SHTabBarButton *lanButton;

@end
@implementation SHSetupTabBar


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setUp];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setUp];
    }
    return self;
}

-(void)setUp
{
    _wifiButton = [[SHTabBarButton alloc]init];
    _wanButton = [[SHTabBarButton alloc]init];
    _lanButton = [[SHTabBarButton alloc]init];
    [self addSubview:_wifiButton];
    [self addSubview:_wanButton];
    [self addSubview:_lanButton];
    
    [_wifiButton setImage:[UIImage imageNamed:@"setup_radio_button_wifi_icon"] withTitle:@"无线设置" forState:UIControlStateNormal];
    [_wanButton setImage:[UIImage imageNamed:@"setup_radio_button_wan_icon"] withTitle:@"wan口设置" forState:UIControlStateNormal];
    [_lanButton setImage:[UIImage imageNamed:@"setup_radio_button_lan_icon"] withTitle:@"lan口设置" forState:UIControlStateNormal];
    
    //设置监听
    [_wifiButton addTarget:self action:@selector(wifiTap) forControlEvents:UIControlEventTouchUpInside];
    [_wanButton addTarget:self action:@selector(wanTap) forControlEvents:UIControlEventTouchUpInside];
    [_lanButton addTarget:self action:@selector(lanTap) forControlEvents:UIControlEventTouchUpInside];
    //默认触发这个按钮
    [_wifiButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

-(void)wifiTap
{
    [self.delegate onclickForTabBar:0];
    [self resetAll];
    [self highlightButton:_wifiButton];
}
-(void)wanTap
{
    [self.delegate onclickForTabBar:1];
    [self resetAll];
    [self highlightButton:_wanButton];
}
-(void)lanTap
{
    [self.delegate onclickForTabBar:2];
    [self resetAll];
    [self highlightButton:_lanButton];
}

//重置为非选中状态
-(void)resetAll
{
    UIColor* normalColor = getColor(0x4a, 0x4a, 0x4a, 255);
    _wifiButton.backgroundColor = normalColor;
    _wanButton.backgroundColor = normalColor;
    _lanButton.backgroundColor = normalColor;
}

//高亮button，选中时状态
-(void)highlightButton:(SHTabBarButton*)button
{
    button.backgroundColor = getColor(128, 188, 31, 255);
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    int width = CGRectGetWidth(self.frame)/3.0f;
    int height = CGRectGetHeight(self.frame);
    _wifiButton.frame = CGRectMake(0, 0, width, height);
    _wanButton.frame = CGRectMake(width, 0, width, height);
    _lanButton.frame = CGRectMake(width * 2, 0, width + 2, height);
}

@end
