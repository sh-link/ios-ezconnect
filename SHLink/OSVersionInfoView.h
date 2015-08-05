//
//  OSVersionInfoView.h
//  SHLink
//
//  Created by zhen yang on 15/4/20.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSVersionInfoView : UIControl
-(int)getHeight;
-(void)setCurrentVersion:(NSString*)currentVersion;
-(void)setOtaVersion:(NSString*)otaVersion;
-(void)update:(BOOL)update;
-(void)setTitle:(NSString*)title;
@end
