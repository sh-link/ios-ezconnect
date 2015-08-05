//
//  SHSlideMenu.h
//  SHLink
//
//  Created by 钱凯 on 15/1/30.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SHSlideMenuDelegate;

@interface SHSlideMenu : UIView

@property (nonatomic, weak) id<SHSlideMenuDelegate> delegate;
@property (nonatomic) NSArray *menuArray;

-(void)selectItem:(int)index;

@end


@protocol SHSlideMenuDelegate <NSObject>

- (void)didTapButtonWithIndex:(int)index;

@end