//
//  SearchView.m
//  SHLink
//
//  Created by zhen yang on 15/4/16.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "SearchView.h"
#import "SHSearchRoationLayer.h"
#import "TextUtil.h"
#import "ScreenUtil.h"
#import "UIView+Extension.h"

@implementation SearchView
{
    UILabel *_msg;
    SHSearchRoationLayer* searchLayer;
    int searchViewWidth;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        searchViewWidth = [ScreenUtil getWidth]/2;
        [self setUp];
    }
    return self;
}

+(SearchView*)initWithMsg:(NSString *)msg
{
    SearchView *searchView = [[SearchView alloc]init];
    [searchView setMsg:msg];
    return searchView;
}

-(void)setColor:(UIColor *)color
{
    _msg.textColor = color;
}

-(void)setMsg:(NSString *)msg
{
    [_msg setText:msg];
    
    _msg.bounds = CGRectMake(0, 0, [self getSize:_msg].width,[self getSize:_msg].height);
    
    _msg.centerY = CGRectGetMaxY(searchLayer.frame) +  _msg.height / 2;
    _msg.centerX = self.centerX;
}



-(void)setUp
{
    self.backgroundColor = [UIColor whiteColor];
    self.frame = [[UIScreen mainScreen]bounds];
    self.height = self.height - bar_length;
    searchLayer = [[SHSearchRoationLayer alloc]init];
    searchLayer.frame = CGRectMake(self.center.x - searchViewWidth / 2.0f, self.center.y - searchViewWidth / 2.0f - 40, searchViewWidth, searchViewWidth);
    [self.layer addSublayer:searchLayer];
    
    _msg = [[UILabel alloc]init];
    [self addSubview:_msg];
    _msg.numberOfLines = 0;
//    [_msg sizeToFit];
    [_msg setTextAlignment:NSTextAlignmentCenter];
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    
    rotationAnimation.duration = 1.0;
    rotationAnimation.repeatCount = HUGE_VALF;
    
    [searchLayer addAnimation:rotationAnimation forKey:nil];
    [searchLayer setNeedsDisplay];

}



-(CGSize)getSize:(NSString *)text withFont:(UIFont *)font
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [text boundingRectWithSize:CGSizeMake([ScreenUtil getWidth ] - 40, [ScreenUtil getHeight])  options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

-(CGSize)getSize:(NSString *)text withTextSize:(CGFloat)textSize
{
    NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:textSize]};
    return [text boundingRectWithSize:CGSizeMake([ScreenUtil getWidth], [ScreenUtil getHeight])  options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    
}


-(CGSize)getSize:(NSString *)text withLabel:(UILabel *)label
{
    NSDictionary *attrs = @{NSFontAttributeName : label.font};
    int padding = [ScreenUtil getWidth] / 4;
    return [text boundingRectWithSize:CGSizeMake([ScreenUtil getWidth] - padding, [ScreenUtil getHeight])  options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

-(CGSize)getSize:(UILabel *)label
{
    return  [self getSize:label.text withLabel:label];
}
@end
