//
//  SHProgressDialog.m
//  SHLink
//
//  Created by zhen yang on 15/3/31.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "SHProgressDialog.h"
#import "MBProgressHUD.h"
@implementation SHProgressDialog

+(void)dismiss
{
    [[self getInstance] removeFromSuperview];
    [[self getInstance] show:NO];
}

+(void)showDialog:(NSString *)msg ViewController:(UIViewController *)controller
{
    MBProgressHUD *progressDialog = [self getInstance];
    [controller.view addSubview:progressDialog];
    [controller.view bringSubviewToFront:progressDialog];
    progressDialog.labelText = msg;
    [progressDialog show:YES];
}

+(MBProgressHUD*)getInstance
{
    static MBProgressHUD* progressDialog;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        progressDialog = [[MBProgressHUD alloc]init];
    });
    return  progressDialog;
}
@end
