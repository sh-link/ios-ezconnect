//
//  SHSearchRoationLayer.m
//  SHLink
//
//  Created by 钱凯 on 15/2/5.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "SHSearchRoationLayer.h"
#import <UIKit/UIKit.h>

@implementation SHSearchRoationLayer
//画旋转的圆圈
-(void)drawInContext:(CGContextRef)ctx {
    
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = CGRectGetWidth(self.bounds) / 4.0;
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:233.0/255 green:233.0/255 blue:233.0/255 alpha:1.0f].CGColor);
    CGContextSetLineWidth(ctx, 3);
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:center
                                                            radius:radius
                                                        startAngle:0
                                                          endAngle:(M_PI * 2/ 6.0 * 5.0)
                                                         clockwise:YES];
    CGContextBeginPath(ctx);
    CGContextAddPath(ctx, circlePath.CGPath);
    CGContextStrokePath(ctx);
}

@end
