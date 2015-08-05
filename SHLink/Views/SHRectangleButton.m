//
//  SHButton.m
//  SHLink
//
//  Created by 钱凯 on 15/1/26.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "SHRectangleButton.h"
#import "SHSearchRoationLayer.h"
#import "ImageUtil.h"

#define Radius 5.0
#define searchingPadding 3.0
//这个应该是有搜索圆圈的那个按钮
@implementation SHRectangleButton
{
    SHSearchRoationLayer *_searchLayer;
}


-(id)initWithFrame:(CGRect)frame {
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
    
    if (_shFont) {
        self.titleLabel.font = _shFont;
    } else {
        self.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    }
    
    [self setTitleColor:[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0f] forState:UIControlStateNormal];
    
    [self setBackgroundImage:[ImageUtil imageWithColor:getColor(136, 196, 63, 255) andSize:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    [self setBackgroundImage:[ImageUtil imageWithColor:getColor(136, 216, 63, 255) andSize:CGSizeMake(1, 1)] forState:UIControlStateHighlighted];
    UIImage *img = [ImageUtil imageWithColor:getColor(136, 196, 63, 255) andSize:CGSizeMake(1, 1)];
    DLog(@"%f %f", img.size.width, img.size.height);
    //self.showsTouchWhenHighlighted = YES;
    self.inSearching = NO;
    
    _searchLayer = [SHSearchRoationLayer layer];
    _searchLayer.backgroundColor = [UIColor clearColor].CGColor;
    _searchLayer.frame = CGRectMake(0, 0, 30, 30);
    
    
    [self.layer addSublayer:_searchLayer];
    
}

- (void)drawRect:(CGRect)rect {
    
    self.layer.cornerRadius = Radius;
    self.layer.masksToBounds = YES;
    //136/196/63
    
    //self.layer.backgroundColor = [UIColor colorWithRed:136/255.0 green:196/255.0 blue:63/255.0 alpha:1.0f].CGColor;
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    size_t gradLocationsNum = 2;
//    CGFloat gradLocations[2] = {0.0f, 1.0f};
//    CGFloat gradColors[8] = {1.0f,1.0f,1.0f,1.0f,
//                        0.99f,0.0f,0.0f,1.0f};
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    
//    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocations, gradLocationsNum);
//    
//    CGContextDrawLinearGradient(context, gradient, CGPointMake(CGRectGetMidX(rect), 0), CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect)), kCGGradientDrawsAfterEndLocation);
//    
//    CGColorSpaceRelease(colorSpace);
//    CGGradientRelease(gradient);
    
//    CGContextSetStrokeColorWithColor(contex, [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.2].CGColor);
//    CGContextSetLineWidth(contex, 2);
//    
//    CGContextBeginPath(contex);
//    //生成一个比按钮rect矩形内缩0.5带圆角的矩形的路径
//    CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 0.2, 0.2) cornerRadius:Radius].CGPath;
//    
//    CGContextAddPath(contex, path);
//    
//    CGContextClosePath(contex);
//    
//    CGContextStrokePath(contex);
    
    CGRect titleRect = [self titleRectForContentRect:rect];
    CGFloat searchingWidth = CGRectGetHeight(rect) - searchingPadding * 2.0;
    
    [_searchLayer removeAllAnimations];
    
    _searchLayer.frame = CGRectMake(CGRectGetMinX(titleRect) - searchingPadding - searchingWidth, searchingPadding, searchingWidth, searchingWidth);
    
    if (_inSearching) {
        
        _searchLayer.hidden = NO;
        
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
        
        rotationAnimation.duration = 1.0;
        rotationAnimation.repeatCount = HUGE_VALF;
        
        [_searchLayer addAnimation:rotationAnimation forKey:@"KCBasicAnimation_Rotation"];
        
        [_searchLayer setNeedsDisplay];
        
    } else {
        _searchLayer.hidden = YES;
    }
    
    [_searchLayer setNeedsDisplay];
}

- (void)setInSearching:(BOOL)inSearching {
    _inSearching = inSearching;
    
//    [_searchLayer setNeedsDisplay];
    [self setNeedsDisplay];
    
}

- (void)setShFont:(UIFont *)shFont {
    _shFont = shFont;
    self.titleLabel.font = shFont;
    [self setNeedsDisplay];
}



@end
