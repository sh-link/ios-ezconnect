//
//  PCWifiClockSetupViewController.m
//  SHLink
//
//  Created by zhen yang on 15/5/20.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "PCWifiClockSetupViewController.h"
#import "BorderUIView.h"
#import "SHRectangleButton.h"
#import "MGConferenceDatePicker.h"
#import "MGConferenceDatePickerDelegate.h"
#import "SHRouter.h"
#import "MessageUtil.h"
#import "SearchView.h"
#import "ScreenUtil.h"
#import "CheckBoxWithText.h"
#import "MBProgressHUD+MJ.h"
#import "PCWifiClockViewController.h"
#define horizontalMargin 20
@interface PCWifiClockSetupViewController ()
{
    UIView* _container;
}
@end

@implementation PCWifiClockSetupViewController
{
    //获取四个时间
    int time1;
    int time2;
    int time3;
    int time4;
    UIButton *btStartTime1;
    UIButton *btCloseTime1;
    UIButton *btStartTime2;
    UIButton *btCloseTime2;
    
    //时间选择器
    UIViewController *pickerViewController;
    int verticalSpace;
    UILabel *startTime1;
    UILabel *startTime2;
    UILabel *startTime3;
    UILabel *startTime4;
    //两个button
    CheckBoxWithText *button1;
    CheckBoxWithText *button2;
    NSArray *buttonSet;
    SHRectangleButton *save;

    BOOL isStartTimeShow;
    BOOL isCloseTimeShow;
    int _id;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置导航栏标题
    self.title = @"设置时间";
    [self initView];
}

-(void)setID:(int)ID
{
    _id = ID;
}

-(void)initView
{
    //容器
    _container = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:_container];
    
    isCloseTimeShow = false;
    isStartTimeShow = false;
    self.view.backgroundColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1];
    verticalSpace = self.view.frame.size.height / bar_length;
    
    //目前没有使用到这个提示文本
    UILabel *hintText = [[UILabel alloc]init];
    [hintText setTextColor:[UIColor grayColor]];
    [hintText setText:@"当每一个开启时间为0时，表示全天开启wifi"];
    [hintText setFont:[UIFont systemFontOfSize:12]];
    [hintText setTextAlignment:NSTextAlignmentCenter];
    hintText.frame = CGRectMake(horizontalMargin, 5*verticalSpace, self.view.frame.size.width - 2*horizontalMargin, [self sizeWithFont:@"当" size:12].height);
    
    btStartTime1 = [[UIButton alloc]init];
    btCloseTime1 = [[UIButton alloc]init];
    btStartTime2 = [[UIButton alloc]init];
    btCloseTime2 = [[UIButton alloc]init];
    [btStartTime1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btCloseTime1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btStartTime2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btCloseTime2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btStartTime1 setTitle:@"00:00" forState:UIControlStateNormal];
    [btCloseTime1 setTitle:@"00:00" forState:UIControlStateNormal];
    [btStartTime2 setTitle:@"00:00" forState:UIControlStateNormal];
    [btCloseTime2 setTitle:@"00:00" forState:UIControlStateNormal];
    [btStartTime1 setBackgroundImage:[UIImage imageNamed:@"time_bg"] forState:UIControlStateNormal];
    [btCloseTime1 setBackgroundImage:[UIImage imageNamed:@"time_bg"] forState:UIControlStateNormal];
    [btStartTime2 setBackgroundImage:[UIImage imageNamed:@"time_bg"] forState:UIControlStateNormal];
    [btCloseTime2 setBackgroundImage:[UIImage imageNamed:@"time_bg"] forState:UIControlStateNormal];
    
    [btStartTime1 addTarget:self action:@selector(selectTime:) forControlEvents:UIControlEventTouchUpInside];
    [btCloseTime1 addTarget:self action:@selector(selectTime:) forControlEvents:UIControlEventTouchUpInside];
    [btStartTime2 addTarget:self action:@selector(selectTime:) forControlEvents:UIControlEventTouchUpInside];
    [btCloseTime2 addTarget:self action:@selector(selectTime:) forControlEvents:UIControlEventTouchUpInside];
    
    //第一个开启时间提示框
    startTime1 = [[UILabel alloc]init];
    startTime1.userInteractionEnabled = YES;
    [startTime1 addSubview:btStartTime1];
    [startTime1 bringSubviewToFront:btStartTime1];
    startTime1.layer.cornerRadius = 3;
    startTime1.layer.masksToBounds = YES;
    [_container addSubview:startTime1];
    startTime1.backgroundColor = [UIColor whiteColor];
    [startTime1 setText:@" 开启时间"];
    [startTime1 setFont:[UIFont systemFontOfSize:18]];
    startTime1.frame = CGRectMake(horizontalMargin, CGRectGetMaxY(hintText.frame) + verticalSpace, self.view.frame.size.width - 2*horizontalMargin, [self sizeWithFont:@"开启时间" size:18].height + 20);
    
    //第一个关闭时间提示框
    startTime2 = [[UILabel alloc]init];
    startTime2.userInteractionEnabled = YES;
    [startTime2 addSubview:btCloseTime1];
    [startTime2 bringSubviewToFront:btCloseTime1];
    startTime2.layer.cornerRadius = 3;
    startTime2.layer.masksToBounds = YES;
    [_container addSubview:startTime2];
    startTime2.backgroundColor = [UIColor whiteColor];
    [startTime2 setText:@" 关闭时间"];
    [startTime2 setFont:[UIFont systemFontOfSize:18]];
    startTime2.frame = CGRectMake(horizontalMargin, CGRectGetMaxY(startTime1.frame) + verticalSpace/2.0, self.view.frame.size.width - 2*horizontalMargin, [self sizeWithFont:@"关闭时间" size:18].height + 20);
    
    //第二个开启时间提示框
    startTime3 = [[UILabel alloc]init];
    startTime3.userInteractionEnabled = YES;
    [startTime3 addSubview:btStartTime2];
    [startTime3 bringSubviewToFront:btStartTime2];
    startTime3.layer.cornerRadius = 3;
    startTime3.layer.masksToBounds = YES;
    [_container addSubview:startTime3];
    startTime3.backgroundColor = [UIColor whiteColor];
    [startTime3 setText:@" 开启时间"];
    [startTime3 setFont:[UIFont systemFontOfSize:18]];
    
    
    //第二个关闭时间提示框
    startTime4 = [[UILabel alloc]init];
    startTime4.userInteractionEnabled = YES;
    [startTime4 addSubview:btCloseTime2];
    [startTime4 bringSubviewToFront:btCloseTime2];
    startTime4.layer.cornerRadius = 3;
    startTime4.layer.masksToBounds = YES;
    [_container addSubview:startTime4];
    startTime4.backgroundColor = [UIColor whiteColor];
    [startTime4 setText:@" 关闭时间"];
    [startTime4 setFont:[UIFont systemFontOfSize:18]];
    
    button1 = [CheckBoxWithText getCheckBox:@"工作日"];
    [button1 setTag:0];
    button2 = [CheckBoxWithText getCheckBox:@"休息日"];
    [button2 setTag:0];
    [self.view addSubview:button1];
    [self.view addSubview:button2];
    buttonSet = @[button1, button2];
    
    if(_id == 2)
    {
            [button1 sendActionsForControlEvents:UIControlEventTouchUpInside];
            [button2 sendActionsForControlEvents:UIControlEventTouchUpInside];
       
    }
    else
    {
        [buttonSet[_id] sendActionsForControlEvents:UIControlEventTouchUpInside];
    }

    save = [[SHRectangleButton alloc]init];
    [save setTitle:@"保存" forState:UIControlStateNormal];
    [_container addSubview:save];
    [save addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    
    [self updateRightBarButton];
    [self refreshFrame];
}

-(void)save
{
    //获取之前wificlock设置信息
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error;
        BOOL result = [[SHRouter currentRouter]getParentClockInfo:&error];
        if(!result)
        {
            [self performSelectorOnMainThread:@selector(showNormal) withObject:nil waitUntilDone:true];
            [MessageUtil showLongToast:@"出错了，设置失败"];
            return;
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                time1 = [self getTime:btStartTime1.titleLabel.text];
                time2 = [self getTime:btCloseTime1.titleLabel.text];
                time3 = [self getTime:btStartTime2.titleLabel.text];
                time4 = [self getTime:btCloseTime2.titleLabel.text];
                
                //检查时间是否合法
                if((time2!= 0 && time1 > time2) || (time3 != 0 && time2 > time3) || (time4 != 0 && time3 > time4))
                {
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"时间不合法" message:@"请检查您设置的时间是否合法，时间应该递增设置" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                    [alertView show];
                    return;
                }
                
                NSNumber *initalState = @0;
                if(time1 != 0 && time2 == 0)
                {
                    time2 = 24*60;
                }
                if(time1 == 0)
                {
                    initalState = @1;
                    time1 = time2;
                    time2 = time3;
                    time3 = time4;
                    time4 = 0;
                }
                
                NSMutableArray *wifiClockInfo = [SHRouter currentRouter].parentControlWifiClocks;
                for(int i = 0; i < wifiClockInfo.count; i++)
                {
                    CheckBoxWithText *button = buttonSet[i];
                    if([button getState])
                    {
                        wifiClockInfo[i] = @{@"INIT_STATE":initalState, @"TIME1":[NSNumber numberWithInt:time1], @"TIME2":[NSNumber numberWithInt:time2],@"TIME3":[NSNumber numberWithInt:time3],@"TIME4":[NSNumber numberWithInt:time4]};
                    }else
                    {
                        wifiClockInfo[i] = @{@"INIT_STATE":wifiClockInfo[i][0], @"TIME1":wifiClockInfo[i][1], @"TIME2":wifiClockInfo[i][2],@"TIME3":wifiClockInfo[i][3],@"TIME4":wifiClockInfo[i][4]};
                    }
                }
                
                //发送设置请求
                [MBProgressHUD showMessage:@"正在发送设置请求"];
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    BOOL ret = [[SHRouter currentRouter] setUpPCWifiClock:[SHRouter currentRouter].parentControlWlanSchedState ?@1 : @0 wlanSched:wifiClockInfo error:nil];
                    
                    if(ret)
                    {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [MBProgressHUD hideHUD];
                            [MessageUtil showShortToast:@"设置成功"];
                            [self.navigationController popViewControllerAnimated:true];
                            PCWifiClockViewController *controller = [self.navigationController.viewControllers lastObject];
                            controller.isNeedRefresh = true;
                        });
                    }
                    else
                    {
                        [MessageUtil showLongToast:@"出错了，设置失败"];
                    }
                });
            });
        }
    });
    
}
-(int)getTime:(NSString*)timeStr
{
    NSArray* strs = [timeStr componentsSeparatedByString:@":"];
    int hour = [strs[0] intValue];
    int minutes = [strs[1] intValue];
    return hour*60 + minutes;
}

//监听时间选择器
- (void)conferenceDatePicker:(MGConferenceDatePicker *)datePicker saveDate:(NSDate *)date
{
    if(pickerViewController)
    {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
        NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSDateComponents *comps  = [calendar components:unitFlags fromDate:date];
        int year = [comps year];
        int month = [comps month];
        int day = [comps day];
        int hour = [comps hour];
        int min = [comps minute];
        int sec = [comps second];
        NSString *hourStr;
        if(hour < 10)
        {
            hourStr = [NSString stringWithFormat:@"0%d", hour];
        }
        else
        {
            hourStr = [NSString stringWithFormat:@"%d", hour];
        }
        NSString *minutesStr;
        if(min < 10)
        {
            minutesStr = [NSString stringWithFormat:@"0%d", min];
        }
        else
        {
            minutesStr = [NSString stringWithFormat:@"%d", min];
        }
        
        NSString *time = [NSString stringWithFormat:@"%@:%@", hourStr,minutesStr];
        int tag = datePicker.tag;
        if(tag == 1)
        {
            [btStartTime1 setTitle:time forState:UIControlStateNormal];
            
        }
        else if(tag == 2)
        {
            [btCloseTime1 setTitle:time forState:UIControlStateNormal];
        }
        else if(tag == 3)
        {
            [btStartTime2 setTitle:time forState:UIControlStateNormal];
        }
        else if(tag == 4)
        {
            [btCloseTime2 setTitle:time forState:UIControlStateNormal];
        }
        [self.navigationController popViewControllerAnimated:YES];
        //[self dismissViewControllerAnimated:YES completion:nil];
    }
}


-(CGSize)sizeWithFont:(NSString *)str size:(int)size
{
    NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:size]};
    return [str boundingRectWithSize:self.view.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

-(void)refreshFrame
{
    if(isStartTimeShow)
    {
        startTime3.frame = CGRectMake(horizontalMargin, CGRectGetMaxY(startTime2.frame) + verticalSpace/2.0, self.view.frame.size.width - 2*horizontalMargin, [self sizeWithFont:@"开启时间" size:18].height + 20);
    }
    else{
        startTime3.frame = CGRectMake(horizontalMargin, CGRectGetMaxY(startTime2.frame) + verticalSpace/2.0, self.view.frame.size.width - 2*horizontalMargin, 0);
    }
    
    if(isCloseTimeShow)
    {
        startTime4.frame = CGRectMake(horizontalMargin, CGRectGetMaxY(startTime3.frame) + verticalSpace/2.0, self.view.frame.size.width - 2*horizontalMargin, [self sizeWithFont:@"关闭时间" size:18].height + 20);    }
    else
    {
        startTime4.frame = CGRectMake(horizontalMargin, CGRectGetMaxY(startTime3.frame) + verticalSpace/2.0, self.view.frame.size.width - 2*horizontalMargin, 0);
    }
    
    int w = ([ScreenUtil getWidth] - 3 *horizontalMargin) / 3.0f;
    
    button1.frame = CGRectMake(horizontalMargin, CGRectGetMaxY(startTime4.frame) + verticalSpace, w, 40);
    button2.frame = CGRectMake([ScreenUtil getWidth] - horizontalMargin - w, button1.frame.origin.y, w, 40);
    save.frame = CGRectMake(button1.frame.origin.x, CGRectGetMaxY(button1.frame) + 3*verticalSpace, [ScreenUtil getWidth] - 2 * horizontalMargin, 40);
    
    btStartTime1.frame = CGRectMake(startTime1.frame.size.width / 3.0 * 2, 2, startTime1.frame.size.width / 3.0 - 2, startTime1.frame.size.height - 4);
    btCloseTime1.frame = CGRectMake(startTime2.frame.size.width / 3.0 * 2, 2, startTime2.frame.size.width / 3.0 - 2, startTime2.frame.size.height - 4);
    btStartTime2.frame = CGRectMake(startTime3.frame.size.width / 3.0 * 2, 2, startTime3.frame.size.width / 3.0 - 2, startTime3.frame.size.height - 4);
    btCloseTime2.frame = CGRectMake(startTime4.frame.size.width / 3.0 * 2, 2, startTime4.frame.size.width / 3.0 - 2, startTime4.frame.size.height - 4);
}


-(void)add
{
    if(isStartTimeShow)
    {
        //显示第二个关闭时间,即closeTime2;
        isCloseTimeShow = true;
    }
    else{
        //显示第二个开启时间,即startTime2
        isStartTimeShow = true;
    }
    
    [self updateRightBarButton];
    [self refreshFrame];
}

-(void)updateRightBarButton
{
    if(!isStartTimeShow || !isCloseTimeShow)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

-(void)selectTime:(id)target
{
    int i = 0;
    if(target == btStartTime1)
    {
        i = 1;
    }
    else if(target == btCloseTime1)
    {
        i = 2;
    }
    else if(target == btStartTime2)
    {
        i = 3;
    }
    else if(target == btCloseTime2)
    {
        i = 4;
    }
    pickerViewController = [[UIViewController alloc]init];
    pickerViewController.title = @"选择时间";
    MGConferenceDatePicker *datePicker = [[MGConferenceDatePicker alloc]initWithFrame:self.view.bounds];
    [datePicker setTag:i];
    [datePicker setDelegate:self];
    [datePicker setBackgroundColor:[UIColor whiteColor]];
    [pickerViewController setView:datePicker];
    //[self presentViewController:pickerViewController animated:YES completion:nil];
    [self.navigationController pushViewController:pickerViewController animated:YES];
}

@end

