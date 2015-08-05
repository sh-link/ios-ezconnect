//
//  PppoeSettingViewController.m
//  SHLink
//
//  Created by 钱凯 on 15/2/1.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "PppoeSettingViewController.h"
#import "SHTextField.h"
#import "SHRectangleButton.h"
#import "MBProgressHUD.h"
#import "SHRouter.h"
#import "ScreenUtil.h"

@interface PppoeSettingViewController () <UIAlertViewDelegate>
{
    MBProgressHUD *hud;
}

@property (strong, nonatomic)  SHTextField *accountTF;
@property (strong, nonatomic)  SHTextField *pswTF;
@property (strong, nonatomic)  SHRectangleButton *confirmBT;
@end

@implementation PppoeSettingViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
   
    
    _accountTF = [[SHTextField alloc]init];
    _accountTF.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_accountTF];
    _accountTF.placeholder = @"请输入上网账号";
    
    _pswTF = [[SHTextField alloc]init];
    _pswTF.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_pswTF];
    _pswTF.placeholder = @"请输入上网密码";
    
    _confirmBT = [[SHRectangleButton alloc]init];
    [_confirmBT setTitle:@"设置" forState:UIControlStateNormal];
    [self.view addSubview:_confirmBT];
    
    CGFloat screenWidth = [ScreenUtil getWidth];
  
    
    
    CGFloat x = 40;
    CGFloat width = screenWidth - 2 * x;
    CGFloat height = 40;
    _accountTF.frame = CGRectMake(x, 15, width, height);
    
    _pswTF.frame = CGRectMake(x, CGRectGetMaxY(_accountTF.frame) + 8, width, height);
    
    _confirmBT.frame = CGRectMake(x, CGRectGetMaxY(_pswTF.frame) + 16, width, height);
    
    [_confirmBT addTarget:self action:@selector(ok:) forControlEvents:UIControlEventTouchUpInside];
    
    _accountTF.shLeftImage = [UIImage imageNamed:@"login"];
    _pswTF.shLeftImage = [UIImage imageNamed:@"password"];
    
    hud = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    hud.labelText = @"正在设置…";
    hud.dimBackground = YES;
    hud.minShowTime = 2.0;
    // Do any additional setup after loading the view.
    
    //获取pppoe拔号信息
    
    if([SHRouter currentRouter].wanInfo != nil)
    {
        NSString *username = [SHRouter currentRouter].wanInfo[@"PPPOE"][@"UserName"];
        NSString *password = [SHRouter currentRouter].wanInfo[@"PPPOE"][@"PassWd"];
        if(username != nil && username.length != 0 && password != nil && password.length != 0)
        {
            [_accountTF setText:username];
            [_pswTF setText:password];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [[UIApplication sharedApplication].keyWindow addSubview:hud];
    [super viewDidAppear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [hud removeFromSuperview];
    [super viewDidDisappear:animated];
}


- (BOOL)checkValid {
    
    if (_accountTF.text.length == 0) {
        [_accountTF shakeWithText:@"账号不能为空"];
        return NO;
    }
    
    if (_pswTF.text.length == 0) {
        [_pswTF shakeWithText:@"密码不能为空"];
        return NO;
    }
    
    return YES;
}

- (IBAction)viewTouchDown:(id)sender {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (IBAction)accoutDidEndOnExit:(id)sender {
    [_pswTF becomeFirstResponder];
}

- (IBAction)pswDidEndOnExit:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)ok:(id)sender {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    if (![self checkValid]) {
        return;
    }
    
    //获取当前探测到的上网方式
    int state = [SHRouter currentRouter].onlineWay;
    
    //    _onlineWay = onlineWay;
    //    if(_onlineWay == -2)
    //    {
    //        self.onlineWayStr = @"当前上网方式:未知";
    //    }
    //    else if(_onlineWay == -1)
    //    {
    //        self.onlineWayStr = @"wan口未连接";
    //    }
    //    else if(_onlineWay == 0)
    //    {
    //        self.onlineWayStr = @"当前上网方式:DHCP";
    //    }
    //    else if (_onlineWay == 1)
    //    {
    //        self.onlineWayStr = @"当前上网方式:静态ip";
    //    }
    //    else if(_onlineWay == 2)
    //    {
    //        self.onlineWayStr = @"当前上网方式:pppoe拔号";
    //    }
    
    
    if(state == 1 || state == 0 )
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:@"您当前探测到的上网方式不是pppoe拔号,设置pppoe拔号可能导致无法上网，点击继续继续设置，点击取消放弃设置" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
        [alertView show];
    }
    else
    {
        [self setup];
    }

    
   }

-(void)setup
{
    __block BOOL ret;
    
    [hud showAnimated:YES whileExecutingBlock:^{
        ret = [[SHRouter currentRouter] setWanPPPoEWithUsername:_accountTF.text Password:_pswTF.text Error:nil];
    } completionBlock:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:SHAlert_Head
                                                        message:ret ? SHAlert_SetWanSuccess : SHAlert_SetWanFailed
                                                       delegate:nil
                                              cancelButtonTitle:SHAlert_OK
                                              otherButtonTitles:nil];
        [alert show];
    }];

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        [self setup];
    }
}


@end
