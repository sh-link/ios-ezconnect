//
//  AddDeviceFrame.m
//  SHLink
//
//  Created by zhen yang on 15/5/21.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "AddDeviceFrame.h"
#import "TextUtil.h"
#define textsize 14
#define padding 8
@implementation AddDeviceFrame
-(NSString*)description
{
    DLog(@"%@", NSStringFromCGRect(self.containerViewF));
    DLog(@"%@", NSStringFromCGRect(self.imgViewF));
    DLog(@"%@", NSStringFromCGRect(self.macViewF));
    DLog(@"%@", NSStringFromCGRect(self.nameViewF));
    DLog(@"%@", NSStringFromCGRect(self.checkBoxViewF));
    return [super description];
}

-(void)setDeviceInfo:(DeviceInfo *)deviceInfo
{
    _deviceInfo = deviceInfo;
    CGFloat cellW = [UIScreen mainScreen].bounds.size.width;
    CGSize macSize = [TextUtil getSize:self.deviceInfo.MAC withTextSize: textsize];
    CGFloat cellH = 2 * macSize.height + 4 * padding;
    self.containerViewF = CGRectMake(0, 0, cellW, cellH);
    float imgHeight = (self.containerViewF.size.height  - 2*padding);
    self.imgViewF = CGRectMake(2* padding, (self.containerViewF.size.height - imgHeight) / 2.0f, imgHeight / 101.0f * 85.0f, imgHeight) ;
    self.macViewF = CGRectMake(CGRectGetMaxX(self.imgViewF) + padding, padding*2, macSize.width, macSize.height);
    CGSize nameSize = [TextUtil getSize:self.deviceInfo.NAME withTextSize:textsize];
    self.nameViewF = CGRectMake(CGRectGetMaxX(self.imgViewF) +padding, CGRectGetMaxY(self.macViewF) + padding, nameSize.width, nameSize.height);
    CGFloat checkIconWH = macSize.height;
    CGFloat checkIconX = cellW - checkIconWH - 30;
    CGFloat checkIconY = (cellH - checkIconWH) / 2.0f;
    self.checkBoxViewF = CGRectMake(checkIconX, checkIconY, checkIconWH, checkIconWH);
    self.cellHeight = self.containerViewF.size.height + 1;
}

@end
