//
//  EmptyView.m
//  SHLink
//
//  Created by zhen yang on 15/5/20.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "EmptyView.h"
#import "ScreenUtil.h"
#import "TextUtil.h"
#import "UIView+Extension.h"
@implementation EmptyView
{
    UILabel *_label;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(0, 0, [ScreenUtil getWidth], [ScreenUtil getHeight] - 64);
        _label = [[UILabel alloc]init];
        [_label setTextColor:[UIColor grayColor]];
        [self addSubview:_label];
    }
    return self;
}
-(void)setMessage:(NSString *)msg
{
    _label.text = msg;
    CGSize size = [TextUtil getSize:_label];
    _label.size = size;
    _label.center = CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.0f);
}
+(EmptyView*)getEmptyView:(NSString *)msg
{
    EmptyView *view = [[EmptyView alloc]init];
    [view setMessage:msg];
    return view;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _label.center = CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.0f);
}
@end
