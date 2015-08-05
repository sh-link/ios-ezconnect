//
//  SHSlideLayer.m
//  SHLink
//
//  Created by 钱凯 on 15/2/1.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "SHSlideLayer.h"
#import <UIKit/UIKit.h>
#define arrowHeight 5.0

@implementation SHSlideLayer
- (void)drawInContext:(CGContextRef)ctx {
    CGContextSetRGBStrokeColor(ctx, 36.0/255.0f,89.0/255.0f,116.0/255.0f,0.3f);
    
    CGContextSetLineWidth(ctx, 1);
    CGContextSetShouldAntialias(ctx, NO);
    int maxY = CGRectGetHeight(self.bounds) - 2;
    
    CGContextBeginPath(ctx);
    //第一个，最左边
    CGContextMoveToPoint(ctx, 0, maxY);
    //第二个
    CGContextAddLineToPoint(ctx, CGRectGetMidX(self.bounds) - arrowHeight - 1, maxY);
    //第三个，尖点
    CGContextAddLineToPoint(ctx, CGRectGetMidX(self.bounds) - 1, maxY - arrowHeight);
    
    
    //第四个，尖点
    CGContextMoveToPoint(ctx, CGRectGetMidX(self.bounds) + 1, maxY - arrowHeight);
    //第五个
    CGContextAddLineToPoint(ctx, CGRectGetMidX(self.bounds) + arrowHeight + 1, maxY);
    //第六个，最右边
    CGContextAddLineToPoint(ctx, CGRectGetWidth(self.bounds) , maxY);
    
    CGContextStrokePath(ctx);
}

@end
