//
//  CircleView.m
//  SHLink
//
//  Created by zhen yang on 15/3/26.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "CircleView.h"

@implementation CircleView
{
    float _toAngle;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //设置画笔线条粗细
       CGContextSetLineWidth(ctx, 2);
    //背景弧
    CGContextAddArc(ctx, CGRectGetMidX(rect), CGRectGetMidY(rect), rect.size.width / 2.0 - 2, 126/180.0*M_PI, (126+288)/180.0*M_PI, 0);
    //设置画笔颜色
    [getColor(0xbb, 0xbb, 0xbb, 0xff) set];
    //渲染背景弧
    CGContextDrawPath(ctx, kCGPathStroke);
    
    //画另外的动态弧
    CGContextAddArc(ctx, CGRectGetMidX(rect), CGRectGetMidY(rect), rect.size.width / 2.0 - 2, 126/180.0*M_PI, (fabs(_toAngle + 144) + 126)/180.0*M_PI, 0);
    [getColor(0x86, 0xd0, 0x3d, 0xff) set];
    CGContextDrawPath(ctx, kCGPathStroke);
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        _toAngle = -144;
        self.layer.backgroundColor = [UIColor clearColor].CGColor;
    }
    return self;
}

-(void)setAngle:(float)toAngle{
    _toAngle = toAngle;
    [self setNeedsDisplay];
}

@end
