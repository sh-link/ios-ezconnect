//
//  PCWifiClockViewController.m
//  SHLink
//
//  Created by zhen yang on 15/5/20.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "PCWifiClockViewController.h"
#import "TimeLineView.h"
#import "SHRectangleButton.h"
#import "SHRouter.h"
#import "FaildView.h"

#import "Packet.h"
#import "Utils.h"
#import "SearchView.h"
#import "MessageUtil.h"
#import "UIBarButtonItem+Extension.h"
#import "UIView+Extension.h"
#import "ScreenUtil.h"
#import "MJRefresh.h"
#import "PCWifiClockSetupViewController.h"
#import "MBProgressHUD+MJ.h"
#import "ErrorUtil.h"
#define verticalSpace 10
#define left_right_margin 20
@interface PCWifiClockViewController ()
{
    //出错情况显示failedView;
    FaildView *faildView;
    //正常情况显示
    UIScrollView *container;
}
@end

@implementation PCWifiClockViewController
{
    id _target;
    //蒙板
    UIView *over;
    UISwitch *toggle;
    UILabel *wifiStateText;
    
    //七个时间线
    TimeLineView *line1;
    TimeLineView *line2;
    //时间线数组
    NSArray* lines;
    //七个label
    UILabel *lable1;
    UILabel *lable2;
    //按钮
    SHRectangleButton *modify;
    //保存文字矩形
    CGSize textSize;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _isNeedRefresh = true;
    self.title = @"家长控制";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]init];
    self.navigationItem.backBarButtonItem.title = @"返回";
    [self initView];
}
-(void)viewDidDisappear:(BOOL)animated
{
    _isNeedRefresh = false;
}

-(void)initView
{
    //容器
    container = [[UIScrollView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    container.height = [ScreenUtil getHeight] - bar_length;
    faildView = [[FaildView alloc]init];
    faildView.hidden = true;
    [self.view addSubview:container];
    [self.view addSubview:faildView];
    //设置下拉刷新
    __block PCWifiClockViewController *tmp = self;
    [container addLegendHeaderWithRefreshingBlock:^{
        //
        [tmp refresh];
    }];
    [faildView addLegendHeaderWithRefreshingBlock:^{
        //
        [tmp refresh];
    }];
    //蒙板
    over = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds ];
    over.backgroundColor = getColor(100, 100, 100, 100);
    
    //计算字符串"星期一"大小
    NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:18]};
    textSize =  [@"工作日" boundingRectWithSize:self.view.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    
    //导航栏设置
    toggle = [[UISwitch alloc]init];
    ////136/196/63
    toggle.tintColor = getColor(136, 196, 63, 200);
    //toggle.onTintColor = getColor(0, 200, 0, 200);
    toggle.thumbTintColor = getColor(250, 250, 250, 255);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:toggle];
    [toggle addTarget:self action:@selector(wifi_toggle:) forControlEvents:UIControlEventValueChanged];
    
    
    //wifi定时状态提示
    wifiStateText = [[UILabel alloc]init];
    [wifiStateText setTextAlignment:NSTextAlignmentCenter];
    [wifiStateText setTextColor:getColor(0, 0, 0, 180)];
    [container addSubview:wifiStateText];
    //时间线
    line1 = [[TimeLineView alloc]init];
    [container addSubview:line1];
    NSArray* times = @[@0, @(24*60)];
    [line1 setTimes:times];
    
    line2 = [[TimeLineView alloc]init];
    [container addSubview:line2];
    [line2 setTimes:times];
    
    
    lable1 = [[UILabel alloc]init];
    [container addSubview:lable1];
    lable1.text = @"工作日";
    
    lable2 = [[UILabel alloc]init];
    [container addSubview:lable2];
    lable2.text = @"休息日";
    
    
    //设置frame
    //wifi状态提示文本
    wifiStateText.frame = CGRectMake(0, 2 * verticalSpace, self.view.frame.size.width, 20);
    //星期一
    line1.frame = CGRectMake(textSize.width + left_right_margin, CGRectGetMaxY(wifiStateText.frame) +  verticalSpace, self.view.frame.size.width - 2*left_right_margin - textSize.width, line1.getHeight);
    lable1.frame = CGRectMake(left_right_margin, CGRectGetMaxY(line1.frame) - textSize.height - 10, textSize.width, textSize.height);
    
    //星期二
    line2.frame = CGRectMake(textSize.width + left_right_margin, CGRectGetMaxY(line1.frame) + verticalSpace, self.view.frame.size.width - 2*left_right_margin - textSize.width, line1.getHeight);
    lable2.frame = CGRectMake(left_right_margin, CGRectGetMaxY(line2.frame) - textSize.height - 10, textSize.width, textSize.height);
    
    //修改按钮
    modify = [[SHRectangleButton alloc]init];
    [modify setTitle:@"修改" forState:UIControlStateNormal];
    modify.frame = CGRectMake(left_right_margin, CGRectGetMaxY(line2.frame) + 3 * verticalSpace, self.view.frame.size.width - 2*left_right_margin, 40);
    
    [container addSubview:modify];
    lines = @[line1,line2];
    
    //给时间线设置监听
    for(TimeLineView * line in lines)
    {
        [line addTarget:self action:@selector(goToModifyWifiClock:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //设置事件监听
    [modify addTarget:self action:@selector(goToModifyWifiClock:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)refresh
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error = nil;
        [[SHRouter currentRouter]getParentClockInfo:&error];
        
        DLog(@"%@", [SHRouter currentRouter].parentControlWifiClocks);
        //将获取的定时信息展示出来
        if(!error)
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                int i = 0;
                for(NSArray *array in [SHRouter currentRouter].parentControlWifiClocks)
                {
                    int array0 = [array[0] intValue];
                    int array1 = [array[1] intValue];
                    int array2 = [array[2] intValue];
                    int array3 = [array[3] intValue];
                    int array4 = [array[4] intValue];
                    
                    //默认wifi处于开启状态
                    if(array0 == 1)
                    {
                        if(array1 == 0)
                        {
                            //全天开启
                            [lines[i] setTimes:@[@0, @(24*60)]];
                        }
                        else
                        {
                            if(array2 == 0)
                            {
                                [lines[i] setTimes:@[@0, array[1]]];
                            }
                            else
                            {
                                if(array3 == 0)
                                {
                                    [lines[i] setTimes:@[@0, array[1], array[2]]];
                                }
                                else
                                {
                                    if(array4 == 0)
                                    {
                                        [lines[i] setTimes:@[@0, array[1], array[2], array[3]]];
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        //初始状态是关闭
                        if(array3 == 0)
                        {
                            [lines[i] setTimes:@[array[1], array[2]]];
                        }
                        else
                        {
                            if(array4 != 0)
                            {
                                [lines[i] setTimes:@[array[1], array[2], array[3], array[4]]];
                            }
                            else
                            {
                                [lines[i] setTimes:@[array[1], array[2], array[3]]];
                            }
                        }
                    }
                    
                    i++;
                }
                
                //获取定时开关状态，是开还是关
                int wifiClockState = [SHRouter currentRouter].parentControlWlanSchedState;
                
                [self showNormal];
                
                if(wifiClockState == 0)
                {
                    toggle.on = NO;
                    wifiStateText.text = @"家长控制功能已经关闭";
                    [self.view addSubview:over];
                }
                else
                {
                    toggle.on = YES;
                    wifiStateText.text = @"家长控制功能已经开启";
                    [over removeFromSuperview];
                }
            });
        }
        else
        {
            NSString *errorMsg = [ErrorUtil doForError:error];
            [self performSelectorOnMainThread:@selector(showFailedView:) withObject:errorMsg waitUntilDone:YES];
        }
        
        float time = 0.5f;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)),dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
        });
    });
   
}

-(void)viewWillAppear:(BOOL)animated
{
    if(_isNeedRefresh)
    {
        [MBProgressHUD showMessage:@"正在获取最新家长控制时间信息"];
        [self refresh];
    }
    else
    {
        
    }
}

-(void)wifi_toggle:(UISwitch*)paramSender
{
    NSMutableArray *wifiClockInfo = [SHRouter currentRouter].parentControlWifiClocks;
    NSMutableArray *wifiClockJson = [[NSMutableArray alloc]initWithCapacity:2];
    for(int i = 0; i < wifiClockInfo.count; i++)
    {
        
        NSArray *timeArray = wifiClockInfo[i];
        NSDictionary *tmp = @{@"INIT_STATE":timeArray[0], @"TIME1":timeArray[1], @"TIME2":timeArray[2],@"TIME3":timeArray[3],@"TIME4":timeArray[4]};
        [wifiClockJson addObject:tmp];
    }
    if(paramSender.isOn)
    {
        [SHRouter currentRouter].parentControlWlanSchedState = YES;
    }
    else
    {
        [SHRouter currentRouter].parentControlWlanSchedState = NO;
    }
    //发送设置命令
    [MBProgressHUD showMessage:@"正在设置"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error;
        BOOL ret = [[SHRouter currentRouter] setUpPCWifiClock:[SHRouter currentRouter].parentControlWlanSchedState ?@1 : @0 wlanSched:wifiClockJson error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
        });
        if(!ret)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                 [over removeFromSuperview];
            });
            NSString *errorMsg = [ErrorUtil doForError:error];
            [self performSelectorOnMainThread:@selector(showFailedView:) withObject:errorMsg waitUntilDone:YES];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(!toggle.isOn)
                {
                    wifiStateText.text = @"家长控制功能已经关闭";
                    [self.view addSubview:over];
                }
                else
                {
                    wifiStateText.text = @"家长控制功能已经开启";
                    [over removeFromSuperview];
                }
            });
            dispatch_async(dispatch_get_main_queue(), ^{
                if(!toggle.isOn)
                {
                    [MessageUtil showShortToast:@"已关闭家长控制功能"];
                }
                else
                {
                    [MessageUtil showShortToast:@"已开启家长控制功能"];
                }
            });
            [self performSelectorOnMainThread:@selector(showNormal) withObject:nil waitUntilDone:YES];
        }
    });
}


-(void)goToModifyWifiClock:(id)target
{
    _target = target;
    [self performSegueWithIdentifier:@"pcwifiClockInfo2pcWifiClockSetup" sender:self];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PCWifiClockSetupViewController *controller = segue.destinationViewController;
    if(_target == line1)
    {
        [controller setID:0];
    }
    else if(_target == line2)
    {
        [controller setID:1];
    }
    else
    {
        [controller setID:2];
    }
}

-(void)showNormal
{
    container.hidden = false;
    faildView.hidden = true;
    toggle.hidden = false;
    [container.header endRefreshing];
}

-(void)showFailedView:(NSString*)msg
{
    [faildView setMessage:msg];
    faildView.hidden = false;
    container.hidden = true;
    toggle.hidden = true;
    [faildView.header endRefreshing];
}

@end