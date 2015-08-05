//
//  AccountViewController.m
//  SHLink
//
//  Created by 钱凯 on 15/2/3.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "AccountViewController.h"
#import "SHTextField.h"
#import "SHRectangleButton.h"
#import "PureLayout.h"
#import "SHRouter.h"
#import "MBProgressHUD.h"
#import "AccountControlTool.h"

@interface AccountViewController ()
{
    MBProgressHUD *hud;
}

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeightConstraint;

@property (weak, nonatomic) IBOutlet SHTextField *currentAccountTF;
@property (weak, nonatomic) IBOutlet SHTextField *currentPswTF;
@property (weak, nonatomic) IBOutlet SHTextField *accountTF;
@property (weak, nonatomic) IBOutlet SHTextField *pswTF;
@property (weak, nonatomic) IBOutlet SHTextField *retypePswTF;

@property (weak, nonatomic) IBOutlet SHRectangleButton *confirmButton;

@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改账户";

    [self setup];
}

- (void)viewDidAppear:(BOOL)animated {
    [[UIApplication sharedApplication].keyWindow addSubview:hud];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [hud removeFromSuperview];
    [super viewDidDisappear:animated];
}

#pragma mark - Tools
#pragma mark -

- (void)setup {
    
    _currentAccountTF.shLeftImage = [UIImage imageNamed:@"login"];
    _currentPswTF.shLeftImage = [UIImage imageNamed:@"password"];
    _accountTF.shLeftImage = [UIImage imageNamed:@"login"];
    _pswTF.shLeftImage = [UIImage imageNamed:@"password"];
    _retypePswTF.shLeftImage = [UIImage imageNamed:@"password"];
    
    hud = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    hud.labelText = @"正在设置…";
    hud.dimBackground = YES;
    hud.minShowTime = 2.0;
    
}

- (BOOL)checkValid {
    
    SHRouter *router = [SHRouter currentRouter];
    
    if (![_currentAccountTF.text isEqualToString:router.username]) {
        [_currentAccountTF shakeWithText:@"当前账号用户名错误"];
        return NO;
    }
    
    if (![_currentPswTF.text isEqualToString:router.password]) {
        [_currentPswTF shakeWithText:@"当前账号密码错误"];
        return NO;
    }
    
    if (_accountTF.text.length == 0) {
        [_accountTF shakeWithText:@"用户名不能为空"];
        return NO;
    }
    
    if (_pswTF.text.length == 0) {
        [_pswTF shakeWithText:@"密码不能为空"];
        return NO;
    }
    
    if (![_pswTF.text isEqualToString:_retypePswTF.text]) {
        [_pswTF shakeWithText:nil];
        [_retypePswTF shakeWithText:@"两次输入的密码不一致"];
        return NO;
    }
    
    return YES;
}

#pragma mark - Layout
#pragma mark -

- (void)updateViewConstraints {
    CGFloat buttonMaxY = CGRectGetMaxY(_confirmButton.frame);
    CGFloat minHeightNeeded = buttonMaxY + 30.0;
    
    if (minHeightNeeded > CGRectGetHeight(_contentView.frame)) {
        [_contentHeightConstraint autoRemove];
        _contentHeightConstraint = [_contentView autoSetDimension:ALDimensionHeight toSize:minHeightNeeded];
    } else {
    }
    
    [super updateViewConstraints];
}

#pragma mark - Actions
#pragma mark -

- (IBAction)viewTouchDown:(id)sender {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (IBAction)currentAccountDidEndOnExit:(id)sender {
    [_currentPswTF becomeFirstResponder];
}

- (IBAction)currentPswDidEndOnExit:(id)sender {
    [_accountTF becomeFirstResponder];
}

- (IBAction)accountDidEndOnExit:(id)sender {
    [_pswTF becomeFirstResponder];
}

- (IBAction)passwordDidEndOnExit:(id)sender {
    [_retypePswTF becomeFirstResponder];
}

- (IBAction)retypePswDidEndOnExit:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)ok:(id)sender {
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    if (![self checkValid]) {
        return;
    }
    __block BOOL ret;
    [hud showAnimated:YES whileExecutingBlock:^{
        ret = [[SHRouter currentRouter] setRouterAccountWithUsername:_accountTF.text Password:_pswTF.text WithError:nil];
    } completionBlock:^{
        if (ret) {
            
            [AccountControlTool storageUserName:_accountTF.text Password:_pswTF.text ForMac:[SHRouter currentRouter].mac];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:SHAlert_Head
                                                            message:SHAlert_SetAccountSuccess
                                                           delegate:nil
                                                  cancelButtonTitle:SHAlert_OK
                                                  otherButtonTitles:nil];
            [alert show];
            
            [[self navigationController] popViewControllerAnimated:YES];
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:SHAlert_Head
                                                            message:SHAlert_SetAccountFailed
                                                           delegate:nil
                                                  cancelButtonTitle:SHAlert_OK
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

@end
