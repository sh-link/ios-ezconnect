//
//  SHSlideMenu.m
//  SHLink
//
//  Created by 钱凯 on 15/1/30.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "SHSlideMenu.h"
#import "SHCarveLayer.h"
#import "SHSlideLayer.h"

#define buttonTagBase 1000

#define padding 10.0
#define carveMargin 2.0
#define scaleFactor 1.05
//设置界面上面的三个按钮切换菜单
@implementation SHSlideMenu
{
    NSMutableArray *_buttonArray;
    NSMutableArray *_carveLayerArray;
    //这个层上有带尖头的横线
    SHSlideLayer *_slideLayer;
    UIView *_slideView;
    long _currentIndex;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    _buttonArray = [[NSMutableArray alloc] initWithCapacity:3];
    _carveLayerArray = [[NSMutableArray alloc] initWithCapacity:2];
    //这个view显示带尖头的切换线
    _slideView = [[UIView alloc] initWithFrame:CGRectZero];
    _slideView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:_slideView];
    
    _slideLayer = [SHSlideLayer layer];
    
    [_slideView.layer addSublayer:_slideLayer];
    
    self.backgroundColor = [UIColor clearColor];
    
    _currentIndex = 0;
}

- (void)layoutSubviews {
    
    if (!_buttonArray.count) {
        return;
    }
    
    long buttonIndex;
    CGFloat boundWidth = CGRectGetWidth(self.bounds);
    CGFloat buttonHeight = 44.0f;
    //每个button宽度将近整个宽度三分之一
    CGFloat buttonWidth = (boundWidth - padding * 2) / _buttonArray.count;
    //表示小尖头所在的横坐标
    CGFloat currentMidX = 0;
    
    for (UIButton *button in _buttonArray) {
        buttonIndex = button.tag - buttonTagBase;
        //确定每个button的frame
        button.frame = CGRectMake(padding + buttonIndex * buttonWidth, padding, buttonWidth, buttonHeight);
        //高亮显示当前button//136/196/63
        if (buttonIndex == _currentIndex) {
            [button setTitleColor:[UIColor colorWithRed:136.0/255 green:196.0/255 blue:63.0/255 alpha:1.0f] forState:UIControlStateNormal];
            currentMidX = CGRectGetMidX(button.frame);
        }
    }
    
    //画button之间的间隔线
    for (SHCarveLayer *layer in _carveLayerArray) {
        
        [layer removeFromSuperlayer];
    }
    
    [_carveLayerArray removeAllObjects];
    
    for (int i = 0; i < (_menuArray.count - 1); i++) {
        SHCarveLayer *layer = [SHCarveLayer layer];
        
        layer.frame = CGRectMake(padding + (i + 1) * buttonWidth - carveMargin / 2.0, padding - carveMargin, carveMargin, carveMargin * 2 + buttonHeight);
        
        [self.layer addSublayer:layer];
        [_carveLayerArray addObject:layer];
        [layer setNeedsDisplay];
    }
    //画下面的尖线
    _slideView.frame = CGRectMake(padding, padding + buttonHeight, boundWidth - padding * 2, padding);
    _slideLayer.frame = CGRectMake(-CGRectGetWidth(_slideView.frame), 0, CGRectGetWidth(_slideView.frame)*3 , CGRectGetHeight(_slideView.frame));
    _slideView.clipsToBounds = YES;
    
    _slideLayer.transform = CATransform3DMakeTranslation(currentMidX - CGRectGetMidX(self.bounds), 1, 1);
    
    [_slideLayer setNeedsDisplay];
}
//设置并构造菜单项，初始化菜单属性
- (void)setMenuArray:(NSArray *)menuArray {
    _menuArray = menuArray;
    //移除之前的
    for (UIButton *button in _buttonArray) {
        [button removeFromSuperview];
    }
    //清空重新设置
    [_buttonArray removeAllObjects];
    
    for (NSString *title in menuArray) {
        NSAssert([title isKindOfClass:[NSString class]], @"menuArray should be type of string.");
        //构造按钮
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
        
        //设置按钮属性
        [button setTitle:title forState:UIControlStateNormal];
        button.tag = buttonTagBase + [menuArray indexOfObject:title];
        //设置监听事件
        [button addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        
        [button setTitleColor:[UIColor colorWithRed:172.0/255.0 green:172.0/255.0 blue:172.0/255.0 alpha:1.0f] forState:UIControlStateNormal];
        
        button.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
        
        [_buttonArray addObject:button];
        
        [self addSubview:button];
    }
    
}
//处理点击事件，主要是实现button切换和带尖头线切换
- (void)tapped:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    
    CGFloat currentMidX = CGRectGetMidX(button.frame);
    CGFloat boundsMidX = CGRectGetMidX(self.bounds);
    
    for (UIButton *bt in _buttonArray) {
        [bt setTitleColor:[UIColor colorWithRed:172.0/255.0 green:172.0/255.0 blue:172.0/255.0 alpha:1.0f] forState:UIControlStateNormal];
    }
    
    //高亮//136/196/63
    [button setTitleColor:[UIColor colorWithRed:136.0/255 green:196.0/255 blue:63.0/255 alpha:1.0f] forState:UIControlStateNormal];
    
    _slideLayer.transform = CATransform3DMakeTranslation(currentMidX - boundsMidX, 1, 1);
    
    _currentIndex = button.tag - buttonTagBase;
    
    if (_delegate && [_delegate respondsToSelector:@selector(didTapButtonWithIndex:)]) {
        [_delegate didTapButtonWithIndex:(int)_currentIndex];
    }
}

-(void)selectItem:(int)index
{
    UIButton *button = _buttonArray[index];
    [button sendActionsForControlEvents:UIControlEventTouchUpInside];
}

@end
