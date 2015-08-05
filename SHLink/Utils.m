//
//  Utils.m
//  SHLink
//
//  Created by zhen yang on 15/3/28.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "Utils.h"
#import "MBProgressHUD.h"
@implementation Utils

//弹出一个提示，1.5秒后消失
+(void)showToast:(NSString*)toast viewController:(UIViewController*)controller
{
    //只显示文字
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:controller.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = toast;
    hud.margin = 10.f;
    hud.yOffset = 100.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.5];
}

+(void)showAlertView:(NSString *)message
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alert show];
}

+(BOOL)checkIP:(NSString *)ip
{
    return  true;
}

@end
