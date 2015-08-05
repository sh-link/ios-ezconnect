//
//  DialogUtil.h
//  SHLink
//
//  Created by zhen yang on 15/4/3.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DialogUtil : NSObject
+(void)createAndShowDialogWithTitle:(NSString *)title message:(NSString *)message;
+(void)createAndShowDialogWithTitle:(NSString*)title message:(NSString*)message handler:(void (^)(UIAlertAction *action))handler;
+(void)createAndShowDialogWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString*)cancelTitle okTitle:(NSString*)okTitle delegate:(id<UIAlertViewDelegate>)delegate;
@end
