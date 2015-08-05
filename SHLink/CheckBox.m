//
//  CheckBox.m
//  SHLink
//
//  Created by zhen yang on 15/5/18.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "CheckBox.h"

@implementation CheckBox


-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.userInteractionEnabled = false;
        [self setImage:[UIImage imageNamed:@"checkbox_unchecked"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"checkbox_checked"] forState:UIControlStateSelected];
        [self addTarget:self action:@selector(onclick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)onclick:(CheckBox *)checkBox
{
    [self setSelected:!self.isSelected];
}

@end
