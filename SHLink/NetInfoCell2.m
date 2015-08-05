//
//  NetInfoCell2.m
//  SHLink
//
//  Created by zhen yang on 15/7/7.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "NetInfoCell2.h"
#import "UIView+Extension.h"
#import "TextUtil.h"
#import "ScreenUtil.h"
@implementation NetInfoCell2
{
    UILabel *titleLabel;
    UILabel *contentLabel;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setUp];
    }
    return self;
}

-(void)setUp
{
    titleLabel = [[UILabel alloc]init];
    contentLabel = [[UILabel alloc]init];
    titleLabel.font = [UIFont systemFontOfSize:cellFontSize];
    contentLabel.font = [UIFont systemFontOfSize:cellFontSize];
    //939393
    titleLabel.textColor = getColor(147, 183, 70, 255);
    //D6D6D6
    contentLabel.textColor = [UIColor grayColor];
    
    int screenWidth = [ScreenUtil getWidth];
    
    int padding = screenWidth / 12;
    
    titleLabel.width =  (screenWidth - 2 * padding) *2.0f / 5;
    contentLabel.width = (screenWidth - 2 * padding) * 3.0f/ 5;
    titleLabel.height = contentLabel.height = [TextUtil getSize:@"test" withLabel:titleLabel].height;
    titleLabel.x = padding;
    titleLabel.y = 0;
    contentLabel.x = CGRectGetMaxX(titleLabel.frame);
    contentLabel.y = 0;
    self.height = titleLabel.height;
    self.width = screenWidth;
    self.x = 0;
    
    [self addSubview:titleLabel];
    [self addSubview:contentLabel];
}
-(int)getPadding
{
    return titleLabel.x;
}

-(void)setTitle:(NSString *)title
{
    titleLabel.text = title;
}

-(void)setContent:(NSString *)content
{
    contentLabel.text = content;
}

-(void)setTitleColor:(UIColor *)color
{
    titleLabel.textColor = color;
}


@end
