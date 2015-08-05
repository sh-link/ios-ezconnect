//
//  TextUtil.m
//  SHLink
//
//  Created by zhen yang on 15/4/17.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "TextUtil.h"
#import "ScreenUtil.h"
@implementation TextUtil

+(CGSize)getSize:(NSString *)text withFont:(UIFont *)font
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [text boundingRectWithSize:CGSizeMake([ScreenUtil getWidth ] - 40, [ScreenUtil getHeight])  options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

+(CGSize)getSize:(NSString *)text withTextSize:(CGFloat)textSize
{
    NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:textSize]};
    return [text boundingRectWithSize:CGSizeMake([ScreenUtil getWidth], [ScreenUtil getHeight])  options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    
}


+(CGSize)getSize:(NSString *)text withLabel:(UILabel *)label
{
    NSDictionary *attrs = @{NSFontAttributeName : label.font};
    return [text boundingRectWithSize:CGSizeMake([ScreenUtil getWidth], [ScreenUtil getHeight])  options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

+(CGSize)getSize:(UILabel *)label
{
    return  [TextUtil getSize:label.text withLabel:label];
}
@end
