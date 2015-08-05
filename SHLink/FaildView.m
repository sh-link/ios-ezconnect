//
//  FaildView.m
//  SHLink
//
//  Created by zhen yang on 15/4/1.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "FaildView.h"
#import "MJRefresh.h"
@implementation FaildView
{
    UIImageView *imgView;
    UILabel *label;
}

-(void)setUp
{
    int screenWidth = [UIScreen mainScreen].bounds.size.width;
    int screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.frame = CGRectMake(0, 0, screenWidth,screenHeight - 64);
    
    
    imgView = [[UIImageView alloc]init];
    [imgView setImage:[UIImage imageNamed:@"failed"]];
    [self addSubview:imgView];
    
    label = [[UILabel alloc]init];
    [self addSubview:label];
    [label setTextAlignment:NSTextAlignmentCenter];
    label.numberOfLines = 0;
    [label sizeToFit];
   
    imgView.center = CGPointMake(self.frame.size.width / 2.0, self
                                 .frame.size.height/ 2.0 - 60);
    imgView.bounds = CGRectMake(0, 0, 257/1.5f, 197/1.5f);

}


-(void)setMessage:(NSString *)message
{
    label.text = message;
    CGSize size = [self sizeWithFont:message];
    label.frame = CGRectMake(20
                             , CGRectGetMaxY(imgView.frame)  , self.frame.size.width - 40, size.height * 3);
}


-(CGSize)sizeWithFont:(NSString *)str
{
    NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:22]};
    return [str boundingRectWithSize:CGSizeMake(self.frame.size.width /  3.0 * 2, self.frame.size.height)   options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setUp];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}
@end
