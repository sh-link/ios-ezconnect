//
//  NetInfoViewController.m
//  SHLink
//
//  Created by zhen yang on 15/7/7.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "NetInfoViewController.h"
#import "NetInfoCell.h"
#import "UIView+Extension.h"
#import "ScreenUtil.h"
#import "TextUtil.h"
#import "MJRefresh.h"
#import "FaildView.h"
#import "MBProgressHUD+MJ.h"
#import "SHRouter.h"
#import "NetInfoCell2.h"
#define padding 10
@interface NetInfoViewController ()
@end

@implementation NetInfoViewController
{
    NetInfoCell2 *ssid;
    NetInfoCell2 *password;
    NetInfoCell2 *channel;
    
    NetInfoCell *ip;
    NetInfoCell *mask;
    NetInfoCell *gateway;
    NetInfoCell *dns1;
    NetInfoCell *dns2;
    NetInfoCell *sendBytes;
    NetInfoCell *receiveBytes;
    NetInfoCell *onlineWay;
    UILabel *pppoeHint;
    
    
    UIView *line1;
    UIView *line2;
    UIView *line3;
    
    UILabel *wanInfo;
    
    UIScrollView *containerView;
    FaildView *failedView;
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"当前网络信息";
    containerView = [[UIScrollView alloc]init];
    failedView = [[FaildView alloc]init];
    failedView.frame = [UIScreen mainScreen].bounds;
    containerView.frame = [UIScreen mainScreen].bounds;
    [self.view addSubview:containerView];
    [self.view addSubview:failedView];
    failedView.hidden = true;
    containerView.hidden = true;
    int screenWidth = [ScreenUtil getWidth];
    int linePadding = screenWidth / 14.0f;
    ssid = [[NetInfoCell2 alloc]init];
    password = [[NetInfoCell2 alloc]init];
    channel = [[NetInfoCell2 alloc]init];
    ip = [[NetInfoCell alloc]init];
    mask = [[NetInfoCell alloc]init];
    gateway = [[NetInfoCell alloc]init];
    dns1 = [[NetInfoCell alloc]init];
    dns2 = [[NetInfoCell alloc]init];
    sendBytes = [[NetInfoCell alloc]init];
    receiveBytes = [[NetInfoCell alloc]init];
    onlineWay = [[NetInfoCell alloc]init];
    pppoeHint = [[UILabel alloc]init];
    
    wanInfo = [[UILabel alloc]init];
    wanInfo.font = [UIFont systemFontOfSize:20];
    
    line1 = [[UIView alloc]init];
    line2 = [[UIView alloc]init];
    line3 = [[UIView alloc]init];
    line1.backgroundColor = line2.backgroundColor = line3.backgroundColor = getColor(0, 0, 0, 50);
   
    
    [containerView addSubview:ssid];
    [containerView addSubview:password];
    [containerView addSubview:channel];
    [containerView addSubview:ip];
    [containerView addSubview:mask];
    [containerView addSubview:gateway];
    [containerView addSubview:dns1];
    [containerView addSubview:dns2];
    [containerView addSubview:sendBytes];
    [containerView addSubview:receiveBytes];
    [containerView addSubview:line1];
    [containerView addSubview:line2];
    [containerView addSubview:line3];
    [containerView addSubview:wanInfo];
    [containerView addSubview:onlineWay];
    [containerView addSubview:pppoeHint];
    pppoeHint.textColor = [UIColor redColor];
    pppoeHint.text = @"test";
    
    [ssid setTitle:@"网络名称"];
    [password setTitle:@"连接密码"];
    [channel setTitle:@"通信信道"];
    
    [ip setTitle:@"ip地址"];
    [mask setTitle:@"mask掩码"];
    [gateway setTitle:@"网关地址"];
    [dns1 setTitle:@"dns1"];
    [dns2 setTitle:@"dns2"];
    [sendBytes setTitle:@"发出的字节数"];
    [receiveBytes setTitle:@"接收的字节数"];
    [onlineWay setTitle:@"当前上网方式"];
    onlineWay.hidden = true;
    wanInfo.text = @"当前wan口信息";
    wanInfo.textColor = getColor(147, 183, 70, 255);
    
    
    ssid.x = password.x = channel.x = ip.x = mask.x = gateway.x = dns1.x = dns2.x = sendBytes.x = receiveBytes.x = 0;
    
    ssid.y = 2*padding;
    line1.frame = CGRectMake(linePadding, CGRectGetMaxY(ssid.frame) + padding, screenWidth - 2 * linePadding, 1);
    password.y = CGRectGetMaxY(line1.frame) + padding;
    line2.frame = CGRectMake(linePadding, CGRectGetMaxY(password.frame) + padding, screenWidth - 2 *linePadding, 1);
    channel.y = CGRectGetMaxY(line2.frame) + padding;
    line3.frame = CGRectMake(linePadding, CGRectGetMaxY(channel.frame) + padding, screenWidth - 2*linePadding, 1);
    
    wanInfo.frame = CGRectMake([ssid getPadding], CGRectGetMaxY(line3.frame) +  padding, [TextUtil getSize:wanInfo].width, [TextUtil getSize:wanInfo].height);
    
    ip.y = CGRectGetMaxY(wanInfo.frame) + padding;
    mask.y = CGRectGetMaxY(ip.frame) + padding;
    gateway.y = CGRectGetMaxY(mask.frame) + padding;
    dns1.y = CGRectGetMaxY(gateway.frame) + padding;
    dns2.y = CGRectGetMaxY(dns1.frame) + padding;
    sendBytes.y = CGRectGetMaxY(dns2.frame) + padding;
    receiveBytes.y = CGRectGetMaxY(sendBytes.frame) + padding;
    
     pppoeHint.frame = CGRectMake([ssid getPadding], CGRectGetMaxY(receiveBytes.frame) + padding, [ScreenUtil getWidth] - 2 * [ssid getPadding], [TextUtil getSize:pppoeHint].height);
    
  
    
    __block NetInfoViewController *tmpViewControll = self;
    [containerView addLegendHeaderWithRefreshingBlock:^{
        [tmpViewControll getNetInfo];
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [MBProgressHUD showMessage:@"正在获取网络信息"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
         [self getNetInfo];
    });
    
}

-(void)getNetInfo
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error;
        NSDictionary *dic = [[SHRouter currentRouter]getNetworkSettingInfoWithError:&error];
    
        if(dic)
        {
            //获取信息成功
            dispatch_async(dispatch_get_main_queue(), ^{
                //
                [ssid setContent:[SHRouter currentRouter].ssid];
                [password setContent:[SHRouter currentRouter].password];
                [channel setContent:[NSString stringWithFormat:@"%d", [SHRouter currentRouter].channel]];
                
                if([SHRouter currentRouter].wanIsConnected)
                {
                    [ip setContent:[SHRouter currentRouter].wanIp];
                    [mask setContent:[SHRouter currentRouter].wanMask];
                    [gateway setContent:[SHRouter currentRouter].wanGateway];
                    [dns1 setContent:[SHRouter currentRouter].dns1];
                    [dns2 setContent:[SHRouter currentRouter].dns2];
                    [sendBytes setContent:[NSString stringWithFormat:@"%lld", [SHRouter currentRouter].txPktNum]];
                    [receiveBytes setContent:[NSString stringWithFormat:@"%lld", [SHRouter currentRouter].rxPktNum]];
                    mask.hidden = gateway.hidden = dns1.hidden = dns2.hidden = sendBytes.hidden = receiveBytes.hidden = onlineWay.hidden = pppoeHint.hidden =  false;
                    [ip setTitleColor:getColor(147, 183, 70, 255)];
                    [ip setTitle:@"ip地址"];
                    
                    if([SHRouter currentRouter].WAN_INET_STAT == 0)
                    {
                        pppoeHint.hidden = true;
                        
                    }
                    else
                    {
                        pppoeHint.hidden = false;
                        SHRouter *router = [SHRouter currentRouter];
                        if(router.WAN_INET_STAT == 1)
                        {
                            pppoeHint.text = @"pppoe用户名密码错误";
                        }
                        else if(router.WAN_INET_STAT == 2)
                        {
                            pppoeHint.text = @"pppoe服务器无响应";
                        }
                        else if(router.WAN_INET_STAT == 3)
                        {
                            pppoeHint.text = @"pppoe服务器未知错务";
                        }
                        else if(router.WAN_INET_STAT == 4)
                        {
                            pppoeHint.text = @"您可能选择了错误的上网方式";
                        }
                    }
                    
                    if(pppoeHint.isHidden)
                    {
                        if([SHRouter currentRouter].current_online_way.length == 0)
                        {
                            onlineWay.hidden = true;
                        }
                        else
                        {
                            [onlineWay setContent:[SHRouter currentRouter].current_online_way];
                            onlineWay.y = CGRectGetMaxY(receiveBytes.frame) + padding;
                            onlineWay.hidden = false;
                        }
                    }
                    else
                    {
                        if([SHRouter currentRouter].current_online_way.length == 0)
                        {
                            onlineWay.hidden = true;
                        }
                        else
                        {
                            [onlineWay setContent:[SHRouter currentRouter].current_online_way];
                            onlineWay.y = CGRectGetMaxY(pppoeHint.frame) + padding;
                            onlineWay.hidden = false;
                        }
                        
                    }
                    
                    
                    
                    if(!onlineWay.isHidden)
                    {
                        containerView.contentSize = CGSizeMake(0, CGRectGetMaxY(onlineWay.frame) + 2 * padding + containerView.header.height);
                    }
                    else if(!pppoeHint.isHidden)
                    {
                        containerView.contentSize = CGSizeMake(0, CGRectGetMaxY(pppoeHint.frame) + 2 * padding + containerView.header.height);
                    }
                    else
                    {
                        containerView.contentSize = CGSizeMake(0, CGRectGetMaxY(receiveBytes.frame) + 2 * padding + containerView.header.height);
                    }
                    

                }
                else
                {
                    [ip setTitle:@"wan口未连接"];
                    [ip setTitleColor:[UIColor redColor]];
                    mask.hidden = gateway.hidden = dns1.hidden = dns2.hidden = sendBytes.hidden = receiveBytes.hidden = onlineWay.hidden = pppoeHint.hidden =  true;
                    
                }
                
                
                [self showNormal];
            });
        }
        else
        {
            //失败
            [self performSelectorOnMainThread:@selector(showFailedView:) withObject:@"获取网络信息失败" waitUntilDone:true];
        }
    });
}


-(void)showNormal
{
    [MBProgressHUD hideHUD];
    containerView.hidden = false;
    failedView.hidden = true;
    [containerView.header endRefreshing];
}

-(void)showFailedView:(NSString*)msg
{
    [MBProgressHUD hideHUD];
    containerView.hidden = true;
    failedView.hidden = false;
    [failedView setMessage:msg];
    [failedView.header endRefreshing];
}


@end
