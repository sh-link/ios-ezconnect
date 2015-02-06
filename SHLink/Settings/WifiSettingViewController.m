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

#define REGEX_USER_NAME @"[A-Za-z0-9]{3,10}"
@interface WifiSettingViewController ()

@property (weak, nonatomic) IBOutlet SHTextField *ssidTF;
@property (weak, nonatomic) IBOutlet SHTextField *pswTF;
@property (weak, nonatomic) IBOutlet SHTextField *retypePswTF;

@end

@implementation WifiSettingViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.tabBarController.navigationItem.title = @"设置";
    
    _ssidTF.shLeftImage  = [UIImage imageNamed:@"iconTest3"];
    
    _pswTF.shLeftImage = [UIImage imageNamed:@"iconTest3"];
    
    _retypePswTF.shLeftImage = [UIImage imageNamed:@"iconTest3"];
    
}
- (IBAction)shake:(id)sender {
    [_ssidTF shakeWithText:@"密码格式不正确"];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
