//
//  DhcpSettingViewController.m
//  SHLink
//
//  Created by 钱凯 on 15/2/1.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "DhcpSettingViewController.h"
#import "SHRouter.h"
#import "MBProgressHUD.h"
#import "ScreenUtil.h"
#import "SHRectangleButton.h"
#import "DetectView.h"
#import "MessageUtil.h"
#import "UIView+Extension.h"
@interface DhcpSettingViewController () <UIAlertViewDelegate>
{
    MBProgressHUD *hud;
}

@end

@implementation DhcpSettingViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    hud = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    hud.labelText = @"正在设置…";
    hud.dimBackground = YES;
    hud.minShowTime = 2.0;
  
    UILabel *hint = [[UILabel alloc]init];
    hint.text = @"点击设置为自动分配ip地址";
    hint.textColor = [UIColor grayColor];
    [self.view addSubview:hint];
    [hint setTextAlignment:NSTextAlignmentCenter];
    hint.frame = CGRectMake(0, 25, [ScreenUtil getWidth], 40);
    
    SHRectangleButton *confirmButton = [[SHRectangleButton alloc]init];
    [confirmButton setTitle:@"设置" forState:UIControlStateNormal];
    [self.view addSubview:confirmButton];
    [confirmButton addTarget:self action:@selector(ok:) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.frame = CGRectMake(40, CGRectGetMaxY(hint.frame) + 20, [ScreenUtil getWidth] - 2 * 40, 40);
    
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
}

- (IBAction)ok:(id)sender {
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
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
    
    
    if(state == 1 || state == 2 )
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:@"您当前探测到的上网方式不是dhcp,设置dhcp可能导致无法上网，点击继续继续设置，点击取消放弃设置" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
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
        ret = [[SHRouter currentRouter] setWanDHCPWithError:nil];
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
