//
//  SHCarveLayer.m
//  SHLink
//
//  Created by 钱凯 on 15/2/1.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "SHCarveLayer.h"
//画设置界面的竖线
@implementation SHCarveLayer

- (void)drawInContext:(CGContextRef)ctx {
    //设置画笔笔颜色
    CGContextSetRGBStrokeColor(ctx, 36.0/255.0f,89.0/255.0f,116.0/255.0f,0.2f);
    //设置线条宽度
    CGContextSetLineWidth(ctx, 1);
    CGContextSetShouldAntialias(ctx, NO);
    //创建路径
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, CGRectGetMidX(self.bounds), 0);
    CGContextAddLineToPoint(ctx, CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds));
    //渲染路径
    CGContextStrokePath(ctx);
}
@end
