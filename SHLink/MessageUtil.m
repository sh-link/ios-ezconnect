//
//  MessageUtil.m
//  SHLink
//
//  Created by zhen yang on 15/4/17.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "MessageUtil.h"
#import <UIKit/UIKit.h>
#import "ScreenUtil.h"
#import "TextUtil.h"
@implementation MessageUtil

+(void)showToast:(NSString *)toast time:(int)time
{
    dispatch_async(dispatch_get_main_queue(),  ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        
        UILabel *toastLabel = [[UILabel alloc]init];
        toastLabel.numberOfLines = 0;
        
        //计算文本宽度
        CGSize size = [TextUtil getSize:toast withFont:toastLabel.font];
        
        toastLabel.backgroundColor = getColor(0, 0, 0, 255);
        toastLabel.center = CGPointMake(window.center.x, [ScreenUtil getHeight] - 100);
        toastLabel.bounds = CGRectMake(0, 0, size.width + 20, size.height + 10);
        [toastLabel setTextAlignment:NSTextAlignmentCenter];
        [toastLabel setTextColor:[UIColor whiteColor]];
        toastLabel.font = [UIFont systemFontOfSize:13];
  
       
        toastLabel.layer.cornerRadius = 5;
        toastLabel.layer.masksToBounds = true;
        
        toastLabel.text = toast;
        
        //加到窗口上
        [window addSubview:toastLabel];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [toastLabel removeFromSuperview];
        });

    });
}

+(void)showLongToast:(NSString *)toast
{
    [MessageUtil showToast:toast time:2];
}

+(void)showShortToast:(NSString *)toast
{
    [MessageUtil showToast:toast time:1];
}

@end
