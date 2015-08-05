//
//  AllDeviceHeader.m
//  SHLink
//
//  Created by zhen yang on 15/5/26.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "AllDeviceHeader.h"
#import "ScreenUtil.h"
#define margin 8
@implementation AllDeviceHeader
{
    UIView *_container;
    UIImageView *_img;
    UILabel* _mac;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        [self setUp];
    }
    return  self;
}
-(void)setUp
{
    _container = [[UIView alloc]init];
    [self addSubview:_container];
    _container.userInteractionEnabled = false;
    
    _img = [[UIImageView alloc]init];
    [_container addSubview:_img];
    
    _mac = [[UILabel alloc]init];
    [_container addSubview:_mac];
    _mac.textColor = [UIColor grayColor];
    _mac.text = @"所有设备";
    
    //图片到左边的间距
    CGFloat paddingLeft = [ScreenUtil getWidth] / 20.0f;
    //图片上下padding
    CGFloat paddingTop = margin;
    //计算图片矩形
    _img.frame = CGRectMake(paddingLeft, paddingTop, 50, 50);
    //设置图片
    [_img setImage:[UIImage imageNamed:@"all_devices_icon"]];
    
    //计算文本矩形
    _mac.center = CGPointMake(CGRectGetMaxX(_img.frame) + paddingLeft + 110, _img.center.y);
    _mac.bounds = CGRectMake(0, 0, 220, 30);
    
    _container.frame = CGRectMake(0, 0, [ScreenUtil getWidth], _img.frame.size.height + 2 * paddingTop);
    
    _container.backgroundColor = [UIColor whiteColor];
    
    _height = CGRectGetMaxY(_container.frame) + 1;
    
    self.backgroundColor = getColor(225, 225, 225, 225);

}


@end
