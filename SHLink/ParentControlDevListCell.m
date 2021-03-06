//
//  ParentControlDevListCell.m
//  SHLink
//
//  Created by zhen yang on 15/5/18.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "ParentControlDevListCell.h"
#import "CheckBox.h"
@implementation ParentControlDevListCell
{
    UIView *_container;
    UIImageView *_img;
    UILabel *_mac;
    UILabel *_name;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.selectedBackgroundView = [[UIView alloc]initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = getColor(136, 216, 63, 40);
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        _container = [[UIView alloc]init];
        _img = [[UIImageView alloc]init];
        _mac = [[UILabel alloc]init];
        _name = [[UILabel alloc]init];
        [_mac setTextColor:[UIColor grayColor]];
        [_name setTextColor:[UIColor grayColor]];
        _checkBox = [[CheckBox alloc]init];
        _checkBox.hidden = YES;
        
        self.backgroundColor = getColor(225, 225, 225, 225);
        _container.backgroundColor = [UIColor whiteColor];
    
        [self addSubview:_container];
        [_container addSubview:_img];
        [_container addSubview:_mac];
        [_container addSubview:_name];
        [_container addSubview:_checkBox];
    }
    return self;
}

+(instancetype)cellWithTableView:(UITableView*)tableView showCheckBox:(BOOL)isShow
{
    NSString *ID = @"ID";
    ParentControlDevListCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
       cell = [[ParentControlDevListCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    cell.checkBox.hidden = !isShow;
    return cell;
}

-(void)setCellFrame:(ParentControlCellFrame *)cellFrame
{
    _cellFrame = cellFrame;
    _container.frame = self.cellFrame.containerViewF;
    _img.frame = self.cellFrame.imgViewF;
    _mac.frame = self.cellFrame.macViewF;
    _name.frame = self.cellFrame.nameViewF;
    _checkBox.frame = self.cellFrame.checkBoxViewF;
    if(self.cellFrame.deviceInfo.checked == 0)
    {
        [_checkBox setSelected:false];
    }
    else
    {
        [_checkBox setSelected:true];
    }
    
    [_img setImage:[UIImage imageNamed:@"device_item_icon_parent_control"]];
    [_mac setText:[NSString stringWithFormat:@"mac:%@",
                   self.cellFrame.deviceInfo.MAC]];
    
    [_mac setFont:[UIFont systemFontOfSize:14]];
    [_name setFont:[UIFont systemFontOfSize:14]];
    [_name setText:[NSString stringWithFormat:@"名称:%@", self.cellFrame.deviceInfo.NAME]];
}

@end
