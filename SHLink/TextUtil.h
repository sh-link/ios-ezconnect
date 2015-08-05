//
//  TextUtil.h
//  SHLink
//
//  Created by zhen yang on 15/4/17.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface TextUtil : NSObject

//测量文本
+(CGSize)getSize:(NSString*)text withFont:(UIFont*)font;

//测量文本
+(CGSize)getSize:(NSString *)text withTextSize:(CGFloat)textSize;

+(CGSize)getSize:(NSString *)text withLabel:(UILabel *)label;

+(CGSize)getSize:(UILabel *)label;
@end
