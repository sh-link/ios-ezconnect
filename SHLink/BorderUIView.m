//
//  BorderUIView.m
//  SHLink
//
//  Created by zhen yang on 15/3/30.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "BorderUIView.h"

@implementation BorderUIView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)setUp
{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 3;
    self.layer.masksToBounds = true;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor colorWithRed:0x22/255.0 green:0x22/255.0 blue:0x22/255.0 alpha:0.2f].CGColor;
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setUp];
    }
    return self;
}
@end
