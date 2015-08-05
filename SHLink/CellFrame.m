//
//  CellFrame.m
//  SHLink
//
//  Created by zhen yang on 15/7/9.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "CellFrame.h"
#import "ScreenUtil.h"
#import "MessageUtil.h"
#import "TextUtil.h"
#import "UIView+Extension.h"
#import <UIKit/UIKit.h>
#define margin 8

@implementation CellFrame
{
    BOOL _isShow;
}
-(void)setInfo:(SlaveInfo *)info
{
    _info = info;
    
    
    if(info.rx == -1 || info.tx == -1)
    {
        _isShow = false;
    }
    else
    {
        _isShow = true;
    }
    
    if(!_isShow)
    {
        //图片到左边的间距
        CGFloat paddingLeft = [ScreenUtil getWidth] / 20.0f;
        //图片上下padding
        CGFloat paddingTop = margin;
        //计算图片矩形
        _imgFrame = CGRectMake(paddingLeft, paddingTop, 50, 50);
        //不显示
        int macX = CGRectGetMaxX(_imgFrame) + paddingLeft;
        CGSize macSize  = [TextUtil getSize:[NSString stringWithFormat:@"mac地址: %@", info.mac] withTextSize:smallSize];
        int macY = CGRectGetMidY(_imgFrame) - macSize.height / 2.0f;
        _macFrame = CGRectMake(macX, macY, macSize.width, macSize.height);
        _containerFrame = CGRectMake(0, 0, [ScreenUtil getWidth],_imgFrame.size.height +  2 * paddingTop);
        _cellHeight = CGRectGetMaxY(_containerFrame) + 1;
    }
    else
    {
        //图片到左边的间距
        CGFloat paddingLeft = [ScreenUtil getWidth] / 20.0f;
        //图片上下padding
        CGFloat paddingTop = margin;
        //计算图片矩形
        _imgFrame = CGRectMake(paddingLeft, paddingTop, 50, 50);
        //显示
        int macX = CGRectGetMaxX(_imgFrame) + paddingLeft ;
        int macY = paddingTop*2;
        CGSize macSize  = [TextUtil getSize:[NSString stringWithFormat:@"mac地址: %@", info.mac] withTextSize:smallSize];
        _macFrame = CGRectMake(macX, macY, macSize.width, macSize.height);
        
        int rxX = macX;
        int rxY  = CGRectGetMaxY(_macFrame) + paddingTop;
        CGSize rxSize = [TextUtil getSize:[NSString stringWithFormat:@"RX: %dMbps", info.rx] withTextSize:smallSize];
        _rxFrame = CGRectMake(rxX, rxY, _macFrame.size.width / 2.0f, rxSize.height);
        
        int txX = CGRectGetMaxX(_rxFrame);
        int txY = rxY;
        CGSize txSize = [TextUtil getSize:[NSString stringWithFormat:@"TX: %dMbps", info.tx] withTextSize:smallSize];
        _txFrame = CGRectMake(txX, txY, txSize.width, txSize.height);
        
//        if(CGRectGetMaxY(_rxFrame) > CGRectGetMaxY(_imgFrame))
//        {
            _containerFrame = CGRectMake(0, 0, [ScreenUtil getWidth], CGRectGetMaxY(_rxFrame) + paddingTop*2);
            _cellHeight = CGRectGetMaxY(_containerFrame) + 1;
        _imgFrame= CGRectMake(paddingLeft, (_containerFrame.size.height - 50) / 2, 50, 50);
//        }
//        else
//        {
//            _containerFrame = CGRectMake(0, 0, [ScreenUtil getWidth], _imgFrame.size.height +  2 * paddingTop);
//            _cellHeight = CGRectGetMaxY(_containerFrame) + 1;
//        }
    }

    
}
@end
