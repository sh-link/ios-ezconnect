//
//  DialogUtil.m
//  SHLink
//
//  Created by zhen yang on 15/4/3.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "DialogUtil.h"
#import <UIKit/UIKit.h>
@implementation DialogUtil
+(void)createAndShowDialogWithTitle:(NSString *)title message:(NSString *)message handler:(void (^)(UIAlertAction *action))handler
{
    if(title != nil && title.length == 0)
    {
        title = nil;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:handler];
    [alertController addAction:cancleAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:true completion:^{
        //
    }];
}

+(void)createAndShowDialogWithTitle:(NSString *)title message:(NSString *)message
{
    if(title != nil && title.length == 0)
    {
        title = nil;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //
    }];
    [alertController addAction:cancleAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:true completion:^{
        //
    }];
    
}

+(void)createAndShowDialogWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString*)cancelTitle okTitle:(NSString*)okTitle delegate:(id<UIAlertViewDelegate>)delegate
{
    if(title != nil && title.length == 0)
    {
        title = nil;
    }
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelTitle otherButtonTitles:okTitle, nil];
    [alertView show];
}
@end
