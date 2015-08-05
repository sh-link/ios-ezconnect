
//  SHMenuCell.m
//  SHLink
//
//  Created by 钱凯 on 15/1/28.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "SHMenuCell.h"
#import "SHSquareButton.h"
#import "SHShadowLayer.h"

#define padding 10
#define labelHeight 20.0
//主功能界面的几个button
@implementation SHMenuCell
{
    UIImageView *_imgView;
    UILabel *_label;
    UIView *_centerContainer;
    UILabel *_number;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    
    _imgView = [[UIImageView alloc]init];
    _label = [[UILabel alloc]init];
    _label.font = [UIFont systemFontOfSize:13.0f];
    [_label setTextColor:getColor(0, 0, 0, 225)];
    [_label setTextAlignment:NSTextAlignmentCenter];
    _centerContainer = [[UIView alloc]init];
    _centerContainer.userInteractionEnabled = false;
    [_centerContainer addSubview:_imgView];
    [_centerContainer addSubview:_label];
    [self addSubview:_centerContainer];
    _number = [[UILabel alloc]init];
    _number.hidden = true;
    [_centerContainer addSubview:_number];
    [_number setTextAlignment:NSTextAlignmentCenter];
    [_number setTextColor:getColor(169, 204, 91, 255)];
    [_number setFont:[UIFont systemFontOfSize:12]];
    
}

- (void)layoutSubviews {
    _centerContainer.center = CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0);
    _centerContainer.bounds = CGRectMake(0, 0, self.frame.size.width / 3.0 * 2, self.frame.size.height / 3.0 * 2);
    CGFloat buttonWidth = CGRectGetWidth(_centerContainer.frame) - 2 * padding;
    _imgView.frame = CGRectMake(padding, padding, buttonWidth, buttonWidth);
    CGFloat labelExtra = 20;
    _label.frame = CGRectMake(-labelExtra, padding + buttonWidth, CGRectGetWidth(_centerContainer.frame) + 2 * labelExtra, _centerContainer.frame.size.height - buttonWidth - 2 * padding);
    
    _number.frame = CGRectMake(CGRectGetMaxX(_imgView.frame), _imgView.frame.origin.y, 10, 10);
}

- (void)setTitle:(NSString *)title {
    [_label setText:title];
    _title = title;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [_imgView setImage:image];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    DLog(@"beginTrackingWithTouch");
    self.backgroundColor = getColor(225, 225, 225, 225);
    return true;
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    DLog(@"continueTrackingWithTouch");
    return true;
}
-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    DLog(@"endTrackingWithTouch");
    self.backgroundColor = getColor(255, 255, 255, 255);
}

-(void)hideNumber
{
    _number.hidden = true;
}

-(void)setNumber:(int)number
{
    _number.hidden = false;
    
    [_number setText:[NSString stringWithFormat:@"%d", number]];
}
@end
