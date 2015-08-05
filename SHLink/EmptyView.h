//
//  EmptyView.h
//  SHLink
//
//  Created by zhen yang on 15/5/20.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmptyView : UIScrollView
-(void)setMessage:(NSString*)msg;
+(EmptyView*)getEmptyView:(NSString*)msg;
@end
