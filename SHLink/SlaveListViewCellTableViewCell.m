//
//  SlaveListViewCellTableViewCell.m
//  SHLink
//
//  Created by zhen yang on 15/4/15.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "SlaveListViewCellTableViewCell.h"
#import "ScreenUtil.h"
#import "MessageUtil.h"

#import "UIView+Extension.h"
#import "TextUtil.h"
#define margin 8
@implementation SlaveListViewCellTableViewCell
{
    UIView *_container;
    UIImageView *_img;
    UILabel* _mac;
    UILabel* _rx;
    UILabel* _tx;
    
    BOOL _isShow;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        [self setUp];
       
        _isShow = false;
        self.selectedBackgroundView = [[UIView alloc]initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = getColor(136, 216, 63, 40);
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    return self;
}


-(void)setUp
{
    UIFont *font = [UIFont systemFontOfSize:smallSize];
    _container = [[UIView alloc]init];
    [self addSubview:_container];

    
    _img = [[UIImageView alloc]init];
    [_container addSubview:_img];
    
    _mac = [[UILabel alloc]init];
    [_container addSubview:_mac];
    
    _mac.textColor = [UIColor grayColor];
    _mac.font = font;
    
    _rx = [[UILabel alloc]init];
    [_container addSubview:_rx];
  
    _rx.textColor = [UIColor grayColor];
    _rx.font = font;
    
    _tx = [[UILabel alloc]init];
    [_container addSubview:_tx];
    
    _tx.textColor = [UIColor grayColor];
    _tx.font = font;
    
    _container.backgroundColor = [UIColor whiteColor];
    self.backgroundColor = getColor(225, 225, 225, 225);
    
   }

-(void)setContent:(NSString *)content
{
    [_mac setText:[NSString stringWithFormat:@"mac地址: %@", content]];
}

-(void)setImg:(NSString *)imgName
{
    UIImage *img = [UIImage imageNamed:imgName];
    _img.image = img;
}


-(void)setRX:(int)rx
{
    _rx.text = [NSString stringWithFormat:@"RX: %dMbps", rx];
}

-(void)setTx:(int)tx
{
    _tx.text = [NSString stringWithFormat:@"TX: %dMbps", tx];
}

-(void)setCellFrame:(CellFrame *)cellFrame
{
    _img.frame = cellFrame.imgFrame;
    _mac.frame = cellFrame.macFrame;
    _rx.frame = cellFrame.rxFrame;
    _tx.frame = cellFrame.txFrame;
    _container.frame = cellFrame.containerFrame;
}
@end
