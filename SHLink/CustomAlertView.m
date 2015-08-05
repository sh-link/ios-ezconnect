//
//  CustomAlertView.m
//  SHLink
//
//  Created by zhen yang on 15/3/24.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "CustomAlertView.h"

@implementation CustomAlertView
{
    UIImageView *_titleView;
    UILabel *_messageView;
    UIButton *_cancel;
    UIButton *_ok;
    UIImageView *_titleIcon;
    UILabel *_title;
    UIFont *_font;
    UIImageView *_seperator;
    UIView *_centerView;
    
    UIView *_titleCenterView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
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

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setUp];
    }
    return self;
}

-(void)setUp
{
  
    
    _centerView = [[UIView alloc]init];
    [self addSubview:_centerView];
    //标题栏
    _titleView = [[UIImageView alloc]init];
    [_titleView setImage:[UIImage imageNamed:@"dialog_title_bg"]];
    [_centerView addSubview:_titleView];
    //tittleCenterView
    _titleCenterView = [[UIView alloc]init];
    [_titleView addSubview:_titleCenterView];
    //icon
    _titleIcon = [[UIImageView alloc]init];
    [_titleCenterView addSubview:_titleIcon];
    //title
    _title = [[UILabel alloc]init];
    _title.font = _font = [UIFont systemFontOfSize:18];
    _title.textAlignment = NSTextAlignmentCenter;
    [_titleCenterView addSubview:_title];
    
    //消息体
    _messageView = [[UILabel alloc]init];
    _messageView.backgroundColor = [UIColor whiteColor];
    _messageView.textAlignment = NSTextAlignmentCenter;
    [_centerView addSubview:_messageView];
    
    //取消按钮
    _cancel  = [[UIButton alloc]init];
    [_cancel setImage:[UIImage imageNamed:@"dialog_left_bt_bg_normal"] forState:UIControlStateNormal];
    [_centerView addSubview:_cancel];
    
    //分隔线
    _seperator = [[UIImageView alloc]init];
    [_seperator setImage:[UIImage imageNamed:@"dialog_bt_seperator"]];
    
    [_centerView addSubview:_seperator];
    
    //确定按钮
    _ok = [[UIButton alloc]init];
    [_ok setImage:[UIImage imageNamed:@"dialog_right_bt_bg_normal"] forState:UIControlStateNormal];
    [_centerView addSubview:_ok];
}

-(void)layoutSubviews
{
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:133/255.0];
    _centerView.bounds = CGRectMake(0, 0, self.frame.size.width /5*4, self.frame.size.height/3);
    _centerView.center = self.center;
    
    _titleView.frame = CGRectMake(0, 0, _centerView.frame.size.width, _centerView.frame.size.height/4.0);
    _messageView.frame = CGRectMake(0, _centerView.frame.size.height/4.0, _centerView.frame.size.width, _centerView.frame.size.height/2.0);
    _cancel.frame = CGRectMake(0, _centerView.frame.size.height / 4.0 * 3, _centerView.frame.size.width/2.0 , _centerView.frame.size.height/4.0);
    _ok.frame = CGRectMake(_centerView.frame.size.width / 2.0 + 1, _centerView.frame.size.height / 4.0 *3, _centerView.frame.size.width / 2.0 - 1, _centerView.frame.size.height/4.0);
    _seperator.frame = CGRectMake(_centerView.frame.size.width / 2.0, _centerView.frame.size.height / 4.0 *3, 1, _centerView.frame.size.height/4.0);
    
    _titleCenterView.center = _titleView.center;
    _titleCenterView.bounds = CGRectMake(0, 0, _titleView.frame.size.width / 2.0, _titleView.frame.size.height / 2.0);
    
    //CGFloat iconWidth = _titleCenterView.frame.size.height;
    
    //_titleIcon.frame = CGRectMake(0, 0, iconWidth, iconWidth);
    _title.frame = CGRectMake(0, 0, _titleCenterView.self.frame.size.width, _titleCenterView.frame.size.height);
    
}

-(void)show{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    if(!CGRectContainsPoint(_centerView.frame, touchPoint))
    {
        [self dismiss];
    }
}

-(void)dismiss
{
    [self removeFromSuperview];
}

-(void)setTitle:(NSString *)title
{
    _title.text = title;
}
-(void)setTitleIcon:(UIImage *)icon
{
    [_titleIcon setImage:icon];
}
-(void)setMessage:(NSString *)message
{
    _messageView.text = message;
}
@end
