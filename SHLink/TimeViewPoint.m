//
//  TimeViewPoint.m
//  SHLink
//
//  Created by zhen yang on 15/3/27.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "TimeViewPoint.h"
#define side  4
@implementation TimeViewPoint
{
    int _time;
    CGRect _rect;
    CGPoint _position;
    TimeViewPoint *_partner;
    NSTextAlignment _align;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _align = NSTextAlignmentCenter;
    }
    return self;
}
-(int)getTime
{
    return _time;
}
-(void)setTime:(int)time
{
    _time = time;
}
-(CGRect)getRect
{
    return _rect;
}
-(void)setRect:(CGRect)rect
{
    _rect = rect;
}
-(CGPoint)getPosition
{
    return _position;
}
-(void)setPosition:(CGPoint)position
{
    _position = position;
    //根据位置设置rect
    _rect = CGRectMake(_position.x - side/2.0, _position.y - side/2.0, side , side);
    
}
-(TimeViewPoint*)getPartner
{
    return _partner;
}
-(void)setPartner:(TimeViewPoint*)partner
{
    _partner = partner;
}
-(void)setAlign:(NSTextAlignment)align
{
    _align = align;
}
-(NSTextAlignment)getAlign
{
    return  _align;
}

@end
