//
//  LoginViewController.m
//  SHLink
//
//  Created by 钱凯 on 15/2/6.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "LoginViewController.h"
#import "PureLayout.h"
#import "SHTextField.h"
#import "SHRectangleButton.h"
#import "SHRouter.h"
#import "SHDeviceConnector.h"
#import "AccountControlTool.h"
#import "HomeViewController.h"
#import "Utils.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet SHTextField *usernameTF;
@property (weak, nonatomic) IBOutlet SHTextField *pswTF;
@property (weak, nonatomic) IBOutlet SHRectangleButton *confirmButton;

@property (nonatomic) BOOL inSearching;

@end

@implementation LoginViewController
{
    SearchViewController *_searchViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([SHRouter currentRouter].loginNeedDismiss) {
        [SHRouter currentRouter].loginNeedDismiss = NO;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setup {
    
//    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
//    [_backgroundImageView addSubview:effectview];
//    [effectview autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    _usernameTF.shLeftImage = [UIImage imageNamed:@"login"];
    _pswTF.shLeftImage = [UIImage imageNamed:@"password"];
    
    _confirmButton.shFont = [UIFont fontWithName:@"Helvetica" size:19.0];
    
    self.inSearching = NO;
}

/**
 *  Check if username & password's format valid.
 *
 *  @return YES if valid, NO if not and textfield will shake with error info.
 */
- (BOOL)checkValid {
    //TODO
    NSString *username = _usernameTF.text;
    NSString *psw = _pswTF.text;
    
    if (username.length == 0) {
        [_usernameTF shakeWithText:@"登陆名不能为空"];
        return NO;
    }
    
    if (psw.length == 0) {
        [_pswTF shakeWithText:@"登录密码不能为空"];
        return NO;
    }
    
    return YES;
}



- (IBAction)login:(id)sender {
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    if (![self checkValid]) {
        return;
    }
    
    self.inSearching = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSError *error;
        BOOL ret = [SHDeviceConnector syncChallengeDeviceWithIp:[SHRouter currentRouter].lanIp Port:[SHRouter currentRouter].tcpPort Username:_usernameTF.text Password:_pswTF.text TimeoutInSec:3 Error:&error];
        
        sleep(2);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.inSearching = NO;
            UIAlertView *alert;
            if (ret) {
                
                [SHRouter currentRouter].username = _usernameTF.text;
                [SHRouter currentRouter].password = _pswTF.text;
                
                [AccountControlTool storageUserName:_usernameTF.text Password:_pswTF.text ForMac:[SHRouter currentRouter].mac];
             
                if(_searchViewController != nil)
                {
                   
                    [_searchViewController performSegueWithIdentifier:@"search2HomeSegue" sender:self];
                    [self dismissViewControllerAnimated:YES completion:^{
                    }];
                }
            } else if (error) {
        
                if(error.code == SHError_User_Not_Exist)
                {
                     [_usernameTF shakeWithText:@"用户名不存在"];
                }
                else if(error.code == SHError_Wrong_Password)
                {
                    [_pswTF shakeWithText:@"登陆密码错误"];
                }
                else
                {
                    [self dismissViewControllerAnimated:YES
                                             completion:^{
                                                 //
                                             }];
                    [Utils showToast:@"网络故障，登陆失败" viewController:[UIApplication sharedApplication].keyWindow.rootViewController];
                }
            }
            else {
                alert = [[UIAlertView alloc] initWithTitle:SHAlert_Head message:SHAlert_LoginFaild delegate:nil cancelButtonTitle:SHAlert_OK otherButtonTitles:nil, nil];
                [alert show];
            }
        });
    });
}

- (IBAction)usernameDidEndOnExit:(id)sender {
    [_pswTF becomeFirstResponder];
}

- (IBAction)pswDidEndOnExit:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)ViewTouchDown:(id)sender {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

-(void)setInSearching:(BOOL)inSearching {
    _inSearching = inSearching;
    
    if (inSearching) {
        [_confirmButton setTitle:@"正在登陆" forState:UIControlStateNormal];
        _confirmButton.inSearching = YES;
        _confirmButton.enabled = NO;
        _usernameTF.enabled = NO;
        _pswTF.enabled = NO;
    } else {
        [_confirmButton setTitle:@"登陆" forState:UIControlStateNormal];
        _confirmButton.inSearching = NO;
        _confirmButton.enabled = YES;
        _usernameTF.enabled = YES;
        _pswTF.enabled = YES;
    }
}

-(void)setSearchViewController:(SearchViewController *)controller
{
    _searchViewController = controller;
}

@end
