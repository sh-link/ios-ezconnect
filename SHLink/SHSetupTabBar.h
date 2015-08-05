//
//  SHSetupTabBar.h
//  SHLink
//
//  Created by zhen yang on 15/3/19.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SHSetupTabBarDelegate<NSObject>

@required
-(void)onclickForTabBar:(int) index;

@end


@interface SHSetupTabBar : UIView

@property  (nonatomic, strong) id<SHSetupTabBarDelegate> delegate;
-(void)wifiTap;
-(void)wanTap;
-(void)lanTap;
@end
