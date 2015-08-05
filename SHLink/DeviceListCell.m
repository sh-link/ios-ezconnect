//
//  DeviceListCell.m
//  SHLink
//
//  Created by zhen yang on 15/4/23.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "DeviceListCell.h"
#import "ScreenUtil.h"
#import "MessageUtil.h"
#import "TextUtil.h"

#define padding 8
@implementation DeviceListCell
{
    UILabel *_mac;
    UILabel *_recv;
    UILabel *_send;
    UIImageView *_img;
    UILabel *_name;
    UIView* _container;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        [self setUp];
        self.selectedBackgroundView = [[UIView alloc]initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}



-(void)setUp
{

    _img = [[UIImageView alloc]init];
    _mac = [[UILabel alloc]init];
    _send = [[UILabel alloc]init];
    _recv = [[UILabel alloc]init];
    _name = [[UILabel alloc]init];
    UIFont *font = [UIFont systemFontOfSize:14];
    _mac.font = font;
    _send.font = font;
    _recv.font = font;
    _name.font = font;
    _mac.textColor = [UIColor grayColor];
    _send.textColor = [UIColor grayColor];
    _recv.textColor = [UIColor grayColor];
    _name.textColor = [UIColor grayColor];
    
    _mac.text = @"mac";
    _send.text = @"send";
    _recv.text = @"recv";
    _name.text = @"name";
    
    _container = [[UIView alloc]init];
    [self.contentView addSubview:_container];
    [_container addSubview:_img];
    [_container addSubview:_mac];
    [_container addSubview:_send];
    [_container addSubview:_recv];
    [_container addSubview:_name];
    
   
    _container.frame = CGRectMake(0, 0,  [ScreenUtil getWidth ], 5*padding + 4 * [TextUtil getSize:_mac].height);
    float imgHeight = (_container.frame.size.height  - 2*padding) / 2.0f;
    _img.frame = CGRectMake(2 * padding, (_container.frame.size.height - imgHeight) / 2.0f, imgHeight / 101.0f * 85.0f, imgHeight) ;
    [_img setImage:[UIImage imageNamed:@"device_item_icon"]];
    
    self.totalHeight = CGRectGetMaxY(_container.frame) + 2;
    _container.backgroundColor = [UIColor whiteColor];
    self.backgroundColor = getColor(225, 225, 225, 225);
}

-(void)setName:(NSString *)name
{
    _name.text = [NSString stringWithFormat:@"名称:%@", name];
    [self refreshFrame];
}

-(void)setImgWithImgName:(NSString*)imgName
{
    [_img setImage:[UIImage imageNamed:imgName]];
}
-(void)setMac:(NSString *)mac
{
    _mac.text = [NSString stringWithFormat:@"mac:%@", mac];
    [self refreshFrame];
}

-(void)setSend:(int)send
{
    _send.text = [NSString stringWithFormat:@"接收到的数据包:%d个", send];
    [self refreshFrame];
}

-(void)setRecv:(int)recv
{
    _recv.text = [NSString stringWithFormat:@"发送的数据包:%d个", recv];
    [self refreshFrame];
}

-(void)refreshFrame
{
    _mac.frame = CGRectMake(CGRectGetMaxX(_img.frame) + padding , padding, [TextUtil getSize:_mac].width, [TextUtil getSize:_mac].height);
    _recv.frame = CGRectMake(CGRectGetMaxX(_img.frame) + padding, CGRectGetMaxY(_mac.frame) + padding, [TextUtil getSize:_recv].width, [TextUtil getSize:_recv].height);
    _send.frame = CGRectMake(CGRectGetMaxX(_img.frame) + padding , CGRectGetMaxY(_recv.frame) + padding, [TextUtil getSize:_send].width, [TextUtil getSize:_send].height);
    _name.frame = CGRectMake(CGRectGetMaxX(_img.frame) + padding, CGRectGetMaxY(_send.frame) + padding, [TextUtil getSize:_name].width, [TextUtil getSize:_name].height);
}

@end
