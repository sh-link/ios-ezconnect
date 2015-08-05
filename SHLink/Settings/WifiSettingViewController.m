//
//  WifiSettingViewController.m
//  SHLink
//
//  Created by 钱凯 on 15/1/26.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "WifiSettingViewController.h"
#import "SHTextField.h"
#import "CMPopTipView.h"
#import "MBProgressHUD.h"
#import "SHRouter.h"
#import "UIView+Extension.h"
#import "ScreenUtil.h"
#import "SHRectangleButton.h"
#import "DialogUtil.h"
#define REGEX_USER_NAME @"[A-Za-z0-9]{3,10}"
#define successTag 10086
@interface WifiSettingViewController ()<UIAlertViewDelegate>

@property (strong, nonatomic)  SHTextField *ssidTF;
@property (strong, nonatomic)  SHTextField *pswTF;
@property (strong, nonatomic)  SHTextField *retypePswTF;
@property (strong, nonatomic) SHRectangleButton *confirm;

@end

@implementation WifiSettingViewController
{
    MBProgressHUD *hud;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //导航栏的标题
    self.tabBarController.navigationItem.title = @"设置";
    _ssidTF = [[SHTextField alloc]init];
    _pswTF = [[SHTextField alloc]init];
    _retypePswTF = [[SHTextField alloc]init];
    _ssidTF.backgroundColor = [UIColor whiteColor];
    _pswTF.backgroundColor = [UIColor whiteColor];
    _retypePswTF.backgroundColor = [UIColor whiteColor];
    _confirm = [[SHRectangleButton alloc]init];
    [self.view addSubview:_confirm];
    [self.view addSubview:_ssidTF];
    [self.view addSubview:_pswTF];
    [self.view addSubview:_retypePswTF];
    _ssidTF.placeholder = @"请设置wifi名称";
    _pswTF.placeholder = @"请设置新wifi连接密码";
    _retypePswTF.placeholder = @"请确定新wifi连接密码";
    
    _ssidTF.shLeftImage  = [UIImage imageNamed:@"wifi_icon"];
    _pswTF.shLeftImage = [UIImage imageNamed:@"password"];
    _retypePswTF.shLeftImage = [UIImage imageNamed:@"password"];
    _ssidTF.text = [SHRouter currentRouter].ssid;
    
    hud = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    hud.labelText = @"正在设置…";
    hud.dimBackground = YES;
    hud.minShowTime = 2.0;
    
    CGFloat screenWith = [ScreenUtil getWidth];
    CGFloat x = 40;
    CGFloat width = screenWith - 2 * x;
    CGFloat height = 40;
    _ssidTF.frame = CGRectMake(x, 90, width, height);
    _pswTF.frame = CGRectMake(x, CGRectGetMaxY(_ssidTF.frame) + 8, width, height);
    _retypePswTF.frame = CGRectMake(x, CGRectGetMaxY(_pswTF.frame) + 8, width, height);
    _confirm.frame = CGRectMake(x, CGRectGetMaxY(_retypePswTF.frame) + 16, width, height);
    [_confirm setTitle:@"确定修改" forState:UIControlStateNormal];
    [_confirm addTarget:self action:@selector(ok:) forControlEvents:UIControlEventTouchUpInside];
    
    //后台获取wifi名称
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        //
        NSError *error;
        NSDictionary* netInfo = [[SHRouter currentRouter]getNetworkSettingInfoWithError:&error];
        if(netInfo != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_ssidTF setText:[SHRouter currentRouter].ssid];
            });
        }
    });
    
}

- (void)viewDidAppear:(BOOL)animated {
    [[UIApplication sharedApplication].keyWindow addSubview:hud];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [hud removeFromSuperview];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tools
#pragma mark -

- (BOOL)checkValid {
    
    if (_ssidTF.text.length == 0) {
        [_ssidTF shakeWithText:@"WiFi名称不能为空"];
        return NO;
    }
    
    if (_pswTF.text.length == 0) {
        [_pswTF shakeWithText:@"无线密码不能为空"];
        return NO;
    }
    
    if (![_pswTF.text isEqualToString:_retypePswTF.text]) {
        [_pswTF shakeWithText:nil];
        [_retypePswTF shakeWithText:@"两次输入的密码不一致"];
        return NO;
    }
    
    return YES;
}

#pragma mark - Actions
#pragma mark - 

- (IBAction)ssidDidEndOnExit:(id)sender {
    [_pswTF becomeFirstResponder];
}

- (IBAction)pswDidEndOnExit:(id)sender {
    [_retypePswTF becomeFirstResponder];
}

- (IBAction)retypePswDidEndOnExit:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)viewTouchDown:(id)sender {
     [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (IBAction)ok:(id)sender {
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    if (![self checkValid]) {
        return;
    }
    
    __block BOOL ret;
    
    [hud showAnimated:YES whileExecutingBlock:^{
        ret = [[SHRouter currentRouter] setWifiWithSsid:_ssidTF.text WifiKey:_pswTF.text Channel:0 Error:nil];
    } completionBlock:^{
        if (ret) {
            
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
//                                                            message:[NSString stringWithFormat:@"设置成功，请将手机连接到网络\"%@\"以重新登陆。",_ssidTF.text]
//                                                           delegate:self
//                                                  cancelButtonTitle:SHAlert_OK
//                                                  otherButtonTitles:nil];
//            alert.tag = successTag;
//            [alert show];
            
            [DialogUtil createAndShowDialogWithTitle:@"修改成功" message:[NSString stringWithFormat:@"修改成功，请将手机连接到网络\"%@\"以重新登陆。",_ssidTF.text] handler:^(UIAlertAction *action) {
                [self.navigationController popToRootViewControllerAnimated:true];
            }];
            
            
            
        } else {
            
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:SHAlert_Head
//                                                            message:SHAlert_SetWiFiFailed
//                                                           delegate:nil
//                                                  cancelButtonTitle:SHAlert_OK
//                                                  otherButtonTitles:nil];
//            [alert show];
            
            [DialogUtil createAndShowDialogWithTitle:@"修改失败" message:@"修改ssid和密码失败了"];
        }
    }];
    
}

#pragma mark - UIAlertViewDelegate
#pragma mark -


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (alertView.tag == successTag) {
//        if (![SHRouter currentRouter].directLogin) {
//            [[SHRouter currentRouter] setLoginNeedDismiss:YES];
//        }
//        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//    }
}

@end
