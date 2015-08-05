//
//  OSVersionInfoView.m
//  SHLink
//
//  Created by zhen yang on 15/4/20.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "OSVersionInfoView.h"
#import "TextUtil.h"
#define padding 15
#define padding2 5

@implementation OSVersionInfoView
{
    UIButton *_masterSelected;
    UILabel *_masterTitle;
    UIView *_horizontalLine;
    UILabel *_currentVersionText;
    UILabel *_currentVersionCode;
    UIView *_verticalLine;
    UILabel *_otaVersionText;
    UILabel *_otaVersionCode;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

-(void)setTitle:(NSString *)title
{
    _masterTitle.text = title;
}

-(void)setUp
{
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = true;
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderWidth = 1;
    self.layer.borderColor = getColor(200, 200, 200, 200).CGColor;
    
    
    _masterTitle = [[UILabel alloc]init];
    _masterTitle.textColor = [UIColor grayColor];
    [_masterTitle setText:@"更新master固件"];
    _masterTitle.font = [UIFont systemFontOfSize:20];
    [self addSubview:_masterTitle];
    
    _masterSelected = [[UIButton alloc]init];
    UIImage *normalImage = [UIImage imageNamed:@"update_os_off"];
    UIImage *highlightedImage = [UIImage imageNamed:@"update_os_on"];
    _masterSelected.bounds = CGRectMake(0, 0, 20, 20);
    [_masterSelected setImage:normalImage forState:UIControlStateNormal];
    [_masterSelected setImage:highlightedImage forState:UIControlStateSelected];
    [self addSubview:_masterSelected];
    
    _horizontalLine = [[UIView alloc]init];
    _horizontalLine.backgroundColor = getColor(200, 200, 200, 200);
    [self addSubview:_horizontalLine];
    
    _currentVersionText = [[UILabel alloc]init];
    _currentVersionText.textColor = [UIColor grayColor];
    _currentVersionText.text = @"当前版本";
    [self addSubview:_currentVersionText];
    
    _currentVersionCode = [[UILabel alloc]init];
    _currentVersionCode.textColor = [UIColor grayColor];
    _currentVersionCode.text = @"未知";
    [self addSubview:_currentVersionCode];
    
    _verticalLine = [[UIView alloc]init];
    _verticalLine.backgroundColor = getColor(200, 200, 200, 200);
    [self addSubview:_verticalLine];
    
    _otaVersionCode = [[UILabel alloc]init];
    _otaVersionCode.textColor = [UIColor grayColor];
    _otaVersionCode.text = @"未知";
    [self addSubview:_otaVersionCode];
    
    _otaVersionText = [[UILabel alloc]init];
    _otaVersionText.textColor = [UIColor grayColor];
    _otaVersionText.text = @"最新版本";
    [self addSubview:_otaVersionText];
    
    _masterSelected.userInteractionEnabled = false;
    
}

-(void)layoutSubviews
{
    DLog(@"layoutSubviews");
    _masterTitle.frame = CGRectMake(padding, padding, [TextUtil getSize:_masterTitle].width, [TextUtil getSize:_masterTitle].height);
    
    _masterSelected.frame = CGRectMake(self.frame.size.width - _masterSelected.bounds.size.width - padding, _masterTitle.frame.origin.y, _masterSelected.bounds.size.width, _masterSelected.bounds.size.height);
    
    _horizontalLine.frame = CGRectMake(0, CGRectGetMaxY(_masterTitle.frame) + padding2, self.frame.size.width, 1);
    
    _currentVersionText.frame = CGRectMake(padding, CGRectGetMaxY(_horizontalLine.frame) + padding, [TextUtil getSize:_currentVersionText].width, [TextUtil getSize:_currentVersionText].height);
    
    _currentVersionCode.frame = CGRectMake(padding, CGRectGetMaxY(_currentVersionText.frame) + padding, [TextUtil getSize:_currentVersionCode].width, [TextUtil getSize:_currentVersionCode].height);
    
    _verticalLine.frame = CGRectMake(self.frame.size.width / 2, CGRectGetMaxY(_horizontalLine.frame), 1, 3*padding + [TextUtil getSize:_currentVersionText].height + [TextUtil getSize:_currentVersionCode].height);
    
    _otaVersionText.frame = CGRectMake(CGRectGetMidX(_horizontalLine.frame) + padding, CGRectGetMaxY(_horizontalLine.frame) + padding, [TextUtil getSize:_otaVersionText].width, [TextUtil getSize:_otaVersionCode].height);
    
    _otaVersionCode.frame = CGRectMake(CGRectGetMidX(_horizontalLine.frame) + padding, CGRectGetMaxY(_otaVersionText.frame) + padding, [TextUtil getSize:_otaVersionCode].width, [TextUtil getSize:_otaVersionCode].height);}

-(int)getHeight
{
    return 4*padding + padding2 + [TextUtil getSize:_masterTitle].height + [TextUtil getSize:_currentVersionText].height + [TextUtil getSize:_currentVersionCode].height;
}

-(void)setCurrentVersion:(NSString *)currentVersion
{
    DLog(@"setCurrent");
    if([currentVersion isEqual:@"0.0.0"] || [currentVersion isEqual:@""])
    {
        currentVersion = @"未知";
    }
    _currentVersionCode.text = currentVersion;
    _currentVersionCode.frame = CGRectMake(_currentVersionCode.frame.origin.x, _currentVersionCode.frame.origin.y, [TextUtil getSize:_currentVersionCode].width, [TextUtil getSize:_currentVersionCode].height);
}

-(void)setOtaVersion:(NSString *)otaVersion
{
    if([otaVersion isEqual:@"0.0.0"] || [otaVersion isEqual:@""])
    {
        otaVersion = @"未知";
    }
    _otaVersionCode.text = otaVersion;
    _otaVersionCode.frame = CGRectMake(_otaVersionCode.frame.origin.x, _otaVersionCode.frame.origin.y, [TextUtil getSize:_otaVersionCode].width, [TextUtil getSize:_otaVersionCode].height);
}

-(void)update:(BOOL)update
{
    _masterSelected.selected = update;
}


@end
