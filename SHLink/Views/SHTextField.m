//
//  SHTextField.m
//  SHLink
//
//  Created by 钱凯 on 15/1/29.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "SHTextField.h"
#import "CMPopTipView.h"

#define padding 5.5

@implementation SHTextField
// 这是一个左边有图片，右边输入文字的文本框
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
    self.textColor = [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0];
    self.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    self.layer.cornerRadius = 5.0f;
    self.clearButtonMode = UITextFieldViewModeAlways;
    
}

-(CGRect)textRectForBounds:(CGRect)bounds {
    CGFloat leftViewWidth = CGRectGetHeight(bounds) - padding * 2.0;

    CGRect textRect = CGRectMake(padding * 3 + leftViewWidth, 0, CGRectGetWidth(bounds) - padding * 3 - leftViewWidth - 50, CGRectGetHeight(bounds));

    if (!_shLeftImage) {
        return CGRectMake(padding, 0, CGRectGetWidth(bounds) - padding, CGRectGetHeight(bounds));
    }
    
    return textRect;
}

-(CGRect)editingRectForBounds:(CGRect)bounds {
    CGFloat leftViewWidth = CGRectGetHeight(bounds) - padding * 2.0;
    
    CGRect textRect = CGRectMake(padding * 3 + leftViewWidth, 0, CGRectGetWidth(bounds) - padding * 3 - leftViewWidth, CGRectGetHeight(bounds));
    
    if (!_shLeftImage) {
        return CGRectMake(padding, 0, CGRectGetWidth(bounds) - padding, CGRectGetHeight(bounds));
    }
    
    return textRect;
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    
    CGFloat leftViewWidth = CGRectGetHeight(bounds) - padding * 2.0;
    CGRect leftRect = CGRectMake(padding, padding, leftViewWidth, leftViewWidth);
    
    if (!_shLeftImage) {
        return CGRectZero;
    }
    
    return leftRect;
}
//设置左边图片
-(void)setShLeftImage:(UIImage *)shLeftImage {
    _shLeftImage = shLeftImage;
    
    if (shLeftImage) {
        UIImageView *leftImg = [[UIImageView alloc] initWithImage:shLeftImage];
        leftImg.contentMode = UIViewContentModeScaleAspectFit;
        self.leftView = leftImg;
        self.leftViewMode = UITextFieldViewModeAlways;
    }else {
        self.leftView = nil;
        self.leftViewMode = UITextFieldViewModeNever;
    }
    
    [self setNeedsDisplay];
}

-(void)shakeWithText:(NSString *)text {
    //TextView晃动
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    CGFloat currentTx = self.transform.tx;
    
    animation.duration = 0.5;
    animation.values = @[ @(currentTx), @(currentTx + 10), @(currentTx-8), @(currentTx + 8), @(currentTx -5), @(currentTx + 5), @(currentTx) ];
    animation.keyTimes = @[ @(0), @(0.225), @(0.425), @(0.6), @(0.75), @(0.875), @(1) ];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.layer addAnimation:animation forKey:@"kAFViewShakerAnimationKey"];
    //提示框
    if (text) {
        CMPopTipView *tip = [[CMPopTipView alloc] initWithMessage:text];
        [tip setBackgroundColor:[UIColor whiteColor]];
        [tip setBorderColor:[UIColor clearColor]];
        [tip setDismissTapAnywhere:YES];
        [tip setHas3DStyle:NO];
        [tip setHasShadow:YES];
        [tip setPointerSize:5];
        [tip setTextColor:[UIColor colorWithRed:120.0/255 green:120.0/255 blue:120.0/255 alpha:1.0]];
        [tip setHasGradientBackground:NO];
        [tip presentPointingAtView:self inView:self.superview animated:YES];
        [tip autoDismissAnimated:YES atTimeInterval:1.5];
    }
}

@end
