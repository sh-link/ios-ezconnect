//
//  CheckBoxWithText.m
//  SHLink
//
//  Created by zhen yang on 15/5/20.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "CheckBoxWithText.h"
#import "TextUtil.h"
#import "ScreenUtil.h"
@implementation CheckBoxWithText
{
    UIImageView *_img;
    UILabel *_label;
    BOOL isChecked;
    UIImage *_on;
    UIImage *_off;
}
-(id)init
{
    self = [super init];
    if(self)
    {
        isChecked = false;
        _img = [[UIImageView alloc]init];
        _label = [[UILabel alloc]init];
        [self addSubview:_img];
        [self addSubview:_label];
        
        _on = [UIImage imageNamed:@"update_os_on"];
        _off = [UIImage imageNamed:@"update_os_off"];
        _img.image = _off;
        [self addTarget:self action:@selector(onclicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return  self;
}

-(void)onclicked:(CheckBoxWithText*)sender
{
    isChecked = !isChecked;
    if(isChecked)
    {
        _img.image = _on;
    }
    else
    {
        _img.image = _off;
    }
}

-(BOOL)getState
{
    return  isChecked;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat x= 0;
    CGFloat y = (self.frame.size.height - _img.image.size.height) / 2.0f;
    CGFloat width = _img.image.size.width;
    CGFloat height = _img.image.size.height;
    
    _img.frame = CGRectMake(x, y, width, height);
    CGSize size = [TextUtil getSize:@"休息日" withLabel:_label];
    x = self.frame.size.width - size.width;
    y = (self.frame.size.height - size.height) / 2.0f;
    _label.frame = CGRectMake(x, y, size.width, size.height);
}

+(CheckBoxWithText *)getCheckBox:(NSString*)title
{
    CheckBoxWithText *checkbox = [[CheckBoxWithText alloc]init];
    [checkbox setTitle:title];
    return checkbox;
}

-(void)setTitle:(NSString *)title
{
    [_label setText:title];
}
@end
