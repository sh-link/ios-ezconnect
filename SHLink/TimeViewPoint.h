//
//  TimeViewPoint.h
//  SHLink
//
//  Created by zhen yang on 15/3/27.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface TimeViewPoint : NSObject
-(int)getTime;
-(void)setTime:(int)time;
-(CGRect)getRect;
-(void)setRect:(CGRect)rect;
-(CGPoint)getPosition;
-(void)setPosition:(CGPoint)position;
-(TimeViewPoint*)getPartner;
-(void)setPartner:(TimeViewPoint*)partner;
-(void)setAlign:(NSTextAlignment)align;
-(NSTextAlignment)getAlign;
@end
