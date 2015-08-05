//
//  DetectView.m
//  SHLink
//
//  Created by zhen yang on 15/6/4.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "DetectView.h"
#import "ScreenUtil.h"
#import "UIView+Extension.h"
#import "TextUtil.h"
#import "MessageUtil.h"
#import "SHRouter.h"
#define paddingLR 5
#define paddingTB 10
#define fontsize 14
@implementation DetectView
{
    UILabel *label;
    UIButton *container;
    UIImageView *img;
    UILabel *hint;
    
    BOOL isDetecting;
    
    CABasicAnimation *rotationAnimation;
    
    int count;
   
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        isDetecting = true;
        count = 0;
        [self setup];
    }
    return  self;
}


-(void)setup
{
    label = [[UILabel alloc]init];
    label.text = @"正在探测当前上网方式";
    label.font = [UIFont systemFontOfSize:fontsize];
    label.textColor = [UIColor grayColor];
    [label sizeToFit];
    container = [[UIButton alloc]init];

    [self addSubview:label];
    [self addSubview:container];
   
    img = [[UIImageView alloc]init];
    hint = [[UILabel alloc]init];
    hint.font = [UIFont systemFontOfSize:fontsize];
    hint.text = @"探测中";
    hint.textColor = [UIColor grayColor];
    [hint sizeToFit];
    [container addSubview:img];
    [container addSubview:hint];
    
    UIImage *highted = [UIImage imageNamed:@"detect_bg_normal"];
    UIImage *normal = [UIImage imageNamed:@"detect_bg_pressed"];
    [container setBackgroundImage:normal forState:UIControlStateNormal];
    [container setBackgroundImage:highted forState:UIControlStateHighlighted];
    
    UIImage *detectingIcon = [UIImage imageNamed:@"detecting"];
    [img setImage:detectingIcon];
    
    //获取检测图标的高度
    CGFloat detectIconWidth = detectingIcon.size.width;
    CGFloat detectIconHeight = detectingIcon.size.height;
    
    img.width = detectIconWidth/1.8;
    img.height  = detectIconHeight/1.8;
    
    //获取container宽高
    container.height = paddingTB + paddingTB + img.height;
    container.width = paddingLR + img.width + paddingLR + hint.width + paddingLR;
    
    //确定img的位置
    img.x = paddingLR;
    img.y = paddingTB;
    
    //获取hint的位置
    hint.x = CGRectGetMaxX(img.frame) + paddingLR;
    hint.y = (container.height - hint.height) / 2.0f;
    
    
    [container addTarget:self action:@selector(detect) forControlEvents:UIControlEventTouchUpInside];
    self.height = container.height;
    
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:M_PI * 2.0];
    rotationAnimation.toValue = [NSNumber numberWithFloat:0.0f];
    rotationAnimation.duration = 1.0;
    rotationAnimation.repeatCount = HUGE_VALF;
    
    [container sendActionsForControlEvents:UIControlEventTouchUpInside];
}

-(void)startAnimation
{
    [img.layer removeAllAnimations];
    [img.layer addAnimation:rotationAnimation forKey:@"rotate"];
}

-(void)stopAnimation
{
    [img.layer removeAllAnimations];
}

-(void)layoutSubviews
{
    container.y = 0;
    container.x = self.width - container.width;
    self.height = container.height;
    label.y = (self.height - label.height)/2.0f;
}


-(void)detect
{
    //探测当前上网方式
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //发起探测请求
        [self showDetecting];
        NSError *error;
        BOOL ret = [[SHRouter currentRouter]detectOnlineWay:&error];
        if(ret)
        {
            //探测查询结果
            //延迟一会
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
                [self getOnlineWay];
            });
        }
        else
        {
            //发起探测查询请求失败
            [self showDetectOver:@"未探测到当前上网方式"];
        }
    });
    
}

-(void)showDetectOver:(NSString *)result
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        img.hidden = true;
        hint.text = @"探测";
        [hint sizeToFit];
        hint.x = (container.width - hint.width)/2.0f;
        hint.y = (container.height - hint.height)/ 2.0f;
        container.userInteractionEnabled = true;
        label.text = result;
        [label sizeToFit];
        //[self stopAnimation];
    });
   
}

-(void)showDetecting
{
    dispatch_async(dispatch_get_main_queue(), ^{
        img.hidden = false;
        hint.text = @"探测中";
        [hint sizeToFit];
        //获取hint的位置
        hint.x = CGRectGetMaxX(img.frame) + paddingLR;
        hint.y = (container.height - hint.height) / 2.0f;
        container.userInteractionEnabled = false;
        label.text = @"正在探测当前上网方式";
        [label sizeToFit];
        [self startAnimation];
    });
}


-(void)getOnlineWay
{
    count++;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showDetecting];
        });
        
        NSError *error;
        BOOL ret = [[SHRouter currentRouter] getOnlineWay:&error];
        if(ret)
        {
            if([SHRouter currentRouter].onlineWay == -1)
            {
                //wan口未连接，结束探测
                [self showDetectOver:[SHRouter currentRouter].onlineWayStr];
            }
            else if([SHRouter currentRouter].onlineWay == -2)
            {
                if(count < 8)
                {
                    //路由器正在查询，app再次发出请求
                    //延迟一会儿再发
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
                        [self getOnlineWay];
                    });
                }
                else
                {
                    [self showDetectOver:[SHRouter currentRouter].onlineWayStr];
                }
            }
            else
            {
                //已经查到结果
                [self showDetectOver:[SHRouter currentRouter].onlineWayStr];
            }
            
        }
        else
        {
            //查询出错
            [self showDetectOver:@"未探测到当前上网方式"];
        }
    });
}

@end
