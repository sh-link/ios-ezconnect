//
//  StaticIpSettingViewController.m
//  SHLink
//
//  Created by 钱凯 on 15/2/1.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "StaticIpSettingViewController.h"
#import "SHTextField.h"
#import "SHRectangleButton.h"
#import "PureLayout.h"
#import "SHRouter.h"
#import "MBProgressHUD.h"
#import "ScreenUtil.h"
#import "MessageUtil.h"
#import "IPUtil.h"
#import "StringUtil.h"
@interface StaticIpSettingViewController ()<UIAlertViewDelegate>
{
    MBProgressHUD *hud;
}

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentHeightConstraint;
@property (strong, nonatomic) IBOutlet SHTextField *ipTF;
@property (strong, nonatomic) IBOutlet SHTextField *maskTF;
@property (strong, nonatomic) IBOutlet SHTextField *gateTF;
@property (strong, nonatomic) IBOutlet SHTextField *dns1TF;
@property (strong, nonatomic) IBOutlet SHTextField *dns2TF;
@property (strong, nonatomic) IBOutlet SHRectangleButton *confirmBT;


@end

@implementation StaticIpSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    hud = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    hud.labelText = @"正在设置…";
    hud.dimBackground = YES;
    hud.minShowTime = 2.0;
    
    
    
    UIScrollView *scrollView = [[UIScrollView alloc]init];
    scrollView.frame = self.view.frame;
    [self.view addSubview:scrollView];
    
  
    
    CGFloat screenWidth = [ScreenUtil getWidth];
   
    
    _ipTF = [[SHTextField alloc]init];
    [scrollView addSubview:_ipTF];
    _ipTF.backgroundColor = [UIColor whiteColor];
    _ipTF.placeholder = @"请输入ip地址";
    
    
    _maskTF = [[SHTextField alloc]init];
    [scrollView addSubview:_maskTF];
    _maskTF.backgroundColor = [UIColor whiteColor];
    _maskTF.placeholder = @"请输入mask掩码地址";
    
    _gateTF = [[SHTextField alloc]init];
    [scrollView addSubview:_gateTF];
    _gateTF.backgroundColor = [UIColor whiteColor];
    _gateTF.placeholder = @"请输入网关地址";
    
    _dns1TF = [[SHTextField alloc]init];
    [scrollView addSubview:_dns1TF];
    _dns1TF.backgroundColor = [UIColor whiteColor];
    _dns1TF.placeholder = @"请输入dns1地址";
    
    _dns2TF = [[SHTextField alloc]init];
    [scrollView addSubview:_dns2TF];
    _dns2TF.backgroundColor = [UIColor whiteColor];
    _dns2TF.placeholder = @"请输入dns2地址";
    
    _confirmBT = [[SHRectangleButton alloc]init];
    [scrollView addSubview:_confirmBT];
    [_confirmBT setTitle:@"设置" forState:UIControlStateNormal];
    [_confirmBT addTarget:self action:@selector(ok:) forControlEvents:UIControlEventTouchUpInside];
    
    //设置frame

    CGFloat padding = 8;
    CGFloat x = 40;
    CGFloat width = screenWidth - 2 * x;
    CGFloat height = 40;
    
    _ipTF.frame = CGRectMake(x, 15, width, height);
    _maskTF.frame = CGRectMake(x, CGRectGetMaxY(_ipTF.frame) + padding, width, height);
    _gateTF.frame = CGRectMake(x, CGRectGetMaxY(_maskTF.frame) + padding, width, height);
    _dns1TF.frame = CGRectMake(x, CGRectGetMaxY(_gateTF.frame) + padding, width, height);
    _dns2TF.frame = CGRectMake(x, CGRectGetMaxY(_dns1TF.frame) + padding, width, height);
    
    _confirmBT.frame = CGRectMake(x, CGRectGetMaxY(_dns2TF.frame) + 2 * padding, width, height);
    
    scrollView.contentSize = CGSizeMake([ScreenUtil getWidth], scrollView.frame.size.height+ 100);
    scrollView.scrollEnabled = true;
    
    
    //获取静态ip信息
    if ([SHRouter currentRouter].wanInfo != nil) {
        NSString *ip = [SHRouter currentRouter].wanInfo[@"STATIC_IP"][@"IP"];
         NSString *mask = [SHRouter currentRouter].wanInfo[@"STATIC_IP"][@"MASK"];
         NSString *gateway = [SHRouter currentRouter].wanInfo[@"STATIC_IP"][@"GATEWAY"];
         NSString *dns1 = [SHRouter currentRouter].wanInfo[@"STATIC_IP"][@"DNS1"];
         NSString *dns2 = [SHRouter currentRouter].wanInfo[@"STATIC_IP"][@"DNS2"];
        
        if(ip != nil && ip.length != 0 && ![ip isEqualToString:@"0.0.0.0"])
        {
            _ipTF.text = ip;
            _maskTF.text = mask;
            _gateTF.text = gateway;
            _dns1TF.text = dns1;
            _dns2TF.text = dns2;
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

- (void)updateViewConstraints {
    
    [_contentHeightConstraint autoRemove];
    
    _contentHeightConstraint = [_contentView autoSetDimension:ALDimensionHeight toSize:CGRectGetMaxY(_confirmBT.frame) > CGRectGetHeight(self.view.bounds) ? CGRectGetMaxY(_confirmBT.frame) : CGRectGetHeight(self.view.bounds)];
    
    [super updateViewConstraints];
}

- (BOOL)checkValid {
    
    _ipTF.text = [StringUtil trim:_ipTF.text];
    _maskTF.text = [StringUtil trim:_maskTF.text];
    _gateTF.text = [StringUtil trim:_gateTF.text];
    _dns1TF.text = [StringUtil trim:_dns1TF.text];
    _dns2TF.text = [StringUtil trim:_dns2TF.text];
    
    if (_ipTF.text.length == 0) {
        //[_ipTF shakeWithText:@"ip地址不能为空"];
        [MessageUtil showShortToast:@"ip地址不能为空"];
        return NO;
    }else if(![IPUtil isIPValid:_ipTF.text])
    {
        [MessageUtil showShortToast:@"ip地址不合法"];
        return NO;
    }
    
    
    if (_maskTF.text.length == 0) {
        //[_maskTF shakeWithText:@"子网掩码不能为空"];
        [MessageUtil showShortToast:@"mask地址不能为空"];
        return NO;
    }else if(![IPUtil isIPValid:_maskTF.text])
    {
        [MessageUtil showShortToast:@"mask地址不合法"];
        return NO;
    }else if(![IPUtil isMaskValid:_maskTF.text])
    {
        [MessageUtil showShortToast:@"mask地址不合法"];
        return NO;
    }
    
    if (_gateTF.text.length == 0) {
        //[_gateTF shakeWithText:@"网关地址不能为空"];
        [MessageUtil showShortToast:@"网关地址不能为空"];
        return NO;
    }else if(![IPUtil isIPValid:_gateTF.text])
    {
        [MessageUtil showShortToast:@"网关地址不合法"];
        return NO;
    }
    
    if(![IPUtil isIPMaskGatewayValid:_ipTF.text mask:_maskTF.text gateway:_gateTF.text])
    {
        [MessageUtil showShortToast:@"IP & MASK必须和GATEWAY & MASK是相同的"];
        return NO;
    }
    
    
    
    if (_dns1TF.text.length == 0) {
        //[_dns1TF shakeWithText:@"DNS 地址不能为空"];
        [MessageUtil showShortToast:@"dns1不能为空"];
        return NO;
    }else if(![IPUtil isIPValid:_dns1TF.text])
    {
        [MessageUtil showShortToast:@"dns1地址不合法"];
        return NO;
    }
    
    if(_dns2TF.text.length > 0 && ![IPUtil isIPValid:_dns2TF.text])
    {
        [MessageUtil showShortToast:@"dns2地址不合法"];
        return NO;
    }
    
    
    return YES;
    
   
}

- (IBAction)viewTouchDown:(id)sender {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (IBAction)ipDidEndOnExit:(id)sender {
    [_maskTF becomeFirstResponder];
}

- (IBAction)maskDidEndOnExit:(id)sender {
    [_gateTF becomeFirstResponder];
}

- (IBAction)gatewayDidEndOnExit:(id)sender {
    [_dns1TF becomeFirstResponder];
}

- (IBAction)dns1DidEndOnExit:(id)sender {
    [_dns2TF becomeFirstResponder];
}

- (IBAction)dns2DidEndOnExit:(id)sender {
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
    
    
    if(state == 0 || state == 2 )
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:@"您当前探测到的上网方式不是静态ip,设置静态ip可能导致无法上网，点击继续继续设置，点击取消放弃设置" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
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
        ret = [[SHRouter currentRouter] setWanStaticIPWithIP:_ipTF.text Mask:_maskTF.text Gateway:_gateTF.text Dns1:_dns1TF.text Dns2:_dns2TF.text Error:nil];
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
