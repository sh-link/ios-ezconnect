//
//  SearchViewController.m
//  SHLink
//
//  Created by 钱凯 on 15/2/5.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "SearchViewController.h"
#import "SHRectangleButton.h"
#import "PureLayout.h"
#import "Reachability.h"
#import "SHDeviceConnector.h"
#import "SHRouter.h"
#import "AccountControlTool.h"
#import "LoginViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "UIView+Extension.h"
#import "ScreenUtil.h"
#import "MessageUtil.h"
typedef NS_ENUM(int, SHSearchState) {
    SHSearchStateNotConnectWifi = 0,
    SHSearchStateSearching,
    SHSearchStateNotFound,
    SHSearchStateSuccess,
    SHSearchStateLogin,
};

#define searchLoopCount 4

@interface SearchViewController ()
@property (strong, nonatomic)  UILabel *infoLabel;
@property (strong, nonatomic)  SHRectangleButton *confirmButton;
@property (nonatomic) SHSearchState currentState;
@end

@implementation SearchViewController

-(void)becomeForeground
{
    //[MessageUtil showShortToast:@"进入前台"];
    DLog(@"发广播-------------");
    NetworkStatus status = [Reachability reachabilityForLocalWiFi].currentReachabilityStatus;
    if (status != ReachableViaWiFi) {
        self.currentState = SHSearchStateNotConnectWifi;
    }
    else {
        [self searchRouter];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    DLog(@"viewDidLoad :: self.view.frame = %@ ==================== ", NSStringFromCGRect(self.view.frame));
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(becomeForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
    _infoLabel = [[UILabel alloc]init];
    [_infoLabel setTextAlignment:NSTextAlignmentCenter];
    _infoLabel.font = [UIFont systemFontOfSize:14];
    _confirmButton = [[SHRectangleButton alloc]init];
    
    [self.view addSubview:_infoLabel];
    [self.view addSubview:_confirmButton];
    
    
    CGPoint center = CGPointMake([ScreenUtil getWidth] / 2.0f, ([ScreenUtil getHeight] - bar_length) - 70);
    _confirmButton.width = [ScreenUtil getWidth] * 0.8f;
    _confirmButton.height = 40;
    _confirmButton.center = center;
  
    _infoLabel.width = [ScreenUtil getWidth];
    _infoLabel.height = 30;
    _infoLabel.centerX = _confirmButton.centerX;
    _infoLabel.centerY = _confirmButton.centerY - 40;
   
    [SHRouter currentRouter].directLogin = NO;
    
    self.title = @"搜索";
}

- (void)viewWillAppear:(BOOL)animated {
    DLog(@"viewWillAppear :: self.view.frame = %@ ==================== ", NSStringFromCGRect(self.view.frame));
    [super viewWillAppear:animated];
    DLog(@"发广播-------------");
    NetworkStatus status = [Reachability reachabilityForLocalWiFi].currentReachabilityStatus;
    if (status != ReachableViaWiFi) {
        self.currentState = SHSearchStateNotConnectWifi;
    }
    else {
        [self searchRouter];
    }
}

#pragma mark - Search Device
#pragma mark -

- (void)searchRouter {
    
    self.currentState = SHSearchStateSearching;
    __weak SearchViewController *weakSelf =  self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SHDevice *device = nil;
        for (int i = 0; i < searchLoopCount; i++) {
            device = [SHDeviceConnector syncSearchDeviceWithPort:0 TimeoutInSec:1.0];
            if (device) break;
        }
        if (device) {
            [SHRouter currentRouter].lanIp = device.lanIp;
            [SHRouter currentRouter].mac = device.mac;
        }
        __strong SearchViewController *strongWeak = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            device ? [strongWeak setCurrentState:SHSearchStateSuccess] : [weakSelf setCurrentState:SHSearchStateNotFound];
        });
    });
}

#pragma mark - Properties
#pragma mark -

- (void)setCurrentState:(SHSearchState)currentState {
    _currentState = currentState;
    if (currentState == SHSearchStateNotConnectWifi) {
        _infoLabel.text = @"尚未连接WiFi";
        _infoLabel.textColor = [UIColor redColor];
        
        [_confirmButton setTitle:@"连接网络" forState:UIControlStateNormal];
        [_confirmButton removeTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
        [_confirmButton addTarget:self action:@selector(connectWifiSetting) forControlEvents:UIControlEventTouchUpInside];
        
        _confirmButton.inSearching = NO;
        
    } else if (currentState == SHSearchStateNotFound) {
        
        _infoLabel.text = @"未发现SHLink路由器";
        _infoLabel.textColor = [UIColor redColor];
        
        [_confirmButton setTitle:@"重新搜索" forState:UIControlStateNormal];
        [_confirmButton removeTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
        [_confirmButton addTarget:self action:@selector(connectWifiSetting) forControlEvents:UIControlEventTouchUpInside];
        
        _confirmButton.inSearching = NO;
        
    } else if (currentState == SHSearchStateSearching) {
        
        _infoLabel.text = @"正在查找shlink路由器";
        _infoLabel.textColor = [UIColor colorWithRed:85.0/255.0f green:85.0/255.0f blue:85.0/255.0f alpha:1.0f];
        
        [_confirmButton setTitle:@"正在搜索中..." forState:UIControlStateNormal];
        [_confirmButton removeTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
        [_confirmButton removeTarget:self action:@selector(connectWifiSetting) forControlEvents:UIControlEventTouchUpInside];
        
        _confirmButton.inSearching = YES;
        
    } else if (currentState == SHSearchStateSuccess) {
        _infoLabel.text = [NSString stringWithFormat:@"您已连接至网络: \"%@\"",[self getCurrentConnectSsid]];
        _infoLabel.textColor = [UIColor colorWithRed:85.0/255.0f green:85.0/255.0f blue:85.0/255.0f alpha:1.0f];
        
        [_confirmButton setTitle:@"管理路由器" forState:UIControlStateNormal];
        [_confirmButton removeTarget:self action:@selector(connectWifiSetting) forControlEvents:UIControlEventTouchUpInside];
        [_confirmButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
        
        _confirmButton.inSearching = NO;
    } else if (currentState == SHSearchStateLogin) {
        
        _infoLabel.text = [NSString stringWithFormat:@"您已连接至网络: \"%@\"",[self getCurrentConnectSsid]];
        _infoLabel.textColor = [UIColor colorWithRed:85.0/255.0f green:85.0/255.0f blue:85.0/255.0f alpha:1.0f];
        
        [_confirmButton setTitle:@"登陆中" forState:UIControlStateNormal];
        [_confirmButton removeTarget:self action:@selector(connectWifiSetting) forControlEvents:UIControlEventTouchUpInside];
        [_confirmButton removeTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
        
        _confirmButton.inSearching = YES;
    }
}

#pragma mark - Actions
#pragma mark -

- (void)connectWifiSetting {
    [self searchRouter];
}

- (void)login {
    NSString *usernameStor = [AccountControlTool getStoragedUserNameWithMac:[SHRouter currentRouter].mac];
    NSString *passwordStor = [AccountControlTool getStoragedPasswordWithMac:[SHRouter currentRouter].mac];
    
    if (usernameStor && passwordStor) {
        self.currentState = SHSearchStateLogin;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *error;
            BOOL ret = [SHDeviceConnector syncChallengeDeviceWithIp:[SHRouter currentRouter].lanIp Port:[SHRouter currentRouter].tcpPort Username:usernameStor Password:passwordStor TimeoutInSec:2 Error:&error];
            
            dispatch_async(dispatch_get_main_queue(), ^{

                if (ret) {
                    [SHRouter currentRouter].directLogin = YES;
                    [SHRouter currentRouter].username = usernameStor;
                    [SHRouter currentRouter].password = passwordStor;
                }
                    
                ret ? [self performSegueWithIdentifier:@"search2HomeSegue" sender:self] : [self performSegueWithIdentifier:@"searchToLoginSegue" sender:self];
            });
        });
    } else [self performSegueWithIdentifier:@"searchToLoginSegue" sender:self];
}


#pragma mark - Tools
#pragma mark -

/**
 *  Get current connected wifi name.
 *
 *  @return Ssid iphone connected, nil if not found.
 */
- (NSString *)getCurrentConnectSsid {
    
    NSString *currentSsid;
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (__bridge NSDictionary *)(myDict);
            DLog(@"%@", myDict);
            currentSsid = [dict valueForKey:@"SSID"];
        }
    }
    return currentSsid;
}


#pragma mark - Layout
#pragma mark -

- (void)updateViewConstraints {
       [super updateViewConstraints];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *controller = segue.destinationViewController;
    if([controller isKindOfClass:[LoginViewController class]])
    {
        LoginViewController *loginController = (LoginViewController*)controller;
        [loginController setSearchViewController:self];
    }
}

@end
