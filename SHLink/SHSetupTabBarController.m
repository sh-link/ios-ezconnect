//
//  SHSetupTabBarController.m
//  SHLink
//
//  Created by zhen yang on 15/3/19.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "SHSetupTabBarController.h"
#import "SHSetupTabBar.h"
#import "UIView+Extension.h"
#import "SHRouter.h"
@interface SHSetupTabBarController () <SHSetupTabBarDelegate>
@property (nonatomic, strong) SHSetupTabBar* shTabBar;
@end

@implementation SHSetupTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    DLog(@"setup load");
    //将系统默认的tabBar移除,用自定义的tabBar替换
    [self.tabBar removeFromSuperview];
    _shTabBar = [[SHSetupTabBar alloc]init];
    _shTabBar.delegate = self;
    _shTabBar.frame = CGRectMake(self.tabBar.x, self.tabBar.y - bar_length, self.tabBar.width, self.tabBar.height);
    [self.view addSubview:_shTabBar];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //
        NSError *error;
        [[SHRouter currentRouter]getWanInfo:&error];
    });
    
    if(self.gotoWan)
    {
        [_shTabBar wanTap];
    }
}

-(void)onclickForTabBar:(int)index
{
    self.selectedIndex = index;
}



@end
