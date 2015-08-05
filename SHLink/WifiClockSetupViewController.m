//
//  WifiClockSetupViewController.m
//  SHLink
//
//  Created by zhen yang on 15/3/28.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "WifiClockSetupViewController.h"
#include "BorderUIView.h"
#include "SHRectangleButton.h"
#include "MGConferenceDatePicker.h"
#include "MGConferenceDatePickerDelegate.h"
#include "SHRouter.h"
#include "Utils.h"
#import "SHProgressDialog.h"
#import "DialogUtil.h"
#import "MBProgressHUD+MJ.h"
#import "MessageUtil.h"
#import "WifiClockViewController.h"
#define horizontalMargin 20
@interface WifiClockSetupViewController () <MGConferenceDatePickerDelegate>

@end

@implementation WifiClockSetupViewController
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
    UILabel *dayContainer;
    int strWidth;
    int width;
    
    int buttonY;
    
    //七个button
    UIButton *button1;
    UIButton *button2;
    UIButton *button3;
    UIButton *button4;
    UIButton *button5;
    UIButton *button6;
    UIButton *button7;
    
    NSArray *buttonSet;
    
    BorderUIView *everyday;
    BorderUIView *weekday;
    BorderUIView *weekend;
    
    SHRectangleButton *save;
    
    BOOL isStartTimeShow;
    BOOL isCloseTimeShow;
    
    UIColor *buttonColorOn;
    
    int _id;
    
    MBProgressHUD *hud;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    hud = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    hud.labelText = @"正在设置…";
    hud.dimBackground = YES;
    hud.minShowTime = 1.0;
    [self initView];
}
-(void)setID:(int)ID
{
    _id = ID;
}

-(void)initView
{
    isCloseTimeShow = false;
    isStartTimeShow = false;
       self.view.backgroundColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1];
    verticalSpace = self.view.frame.size.height / 64.0;
    //设置导航栏标题
    self.title = @"设置时间";
    
    UILabel *hintText = [[UILabel alloc]init];
    //[self.view addSubview:hintText];
    [hintText setTextColor:[UIColor grayColor]];
    [hintText setText:@"当每一个开启时间为0时，表示全天开启wifi"];
    [hintText setFont:[UIFont systemFontOfSize:12]];
    [hintText setTextAlignment:NSTextAlignmentCenter];
    //hintText.backgroundColor = [UIColor redColor];
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
    [self.view addSubview:startTime1];
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
    [self.view addSubview:startTime2];
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
    [self.view addSubview:startTime3];
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
    [self.view addSubview:startTime4];
    startTime4.backgroundColor = [UIColor whiteColor];
    [startTime4 setText:@" 关闭时间"];
    [startTime4 setFont:[UIFont systemFontOfSize:18]];
    
   
    
    //星期一到星期天七个Button
     dayContainer= [[UILabel alloc]init];
    dayContainer.text = @" 星期 ";
    [self.view addSubview:dayContainer];
    dayContainer.backgroundColor = [UIColor whiteColor];
    [dayContainer setFont:[UIFont systemFontOfSize:15]];
    
   
    
    //创建并添加七个button
    buttonColorOn = [UIColor colorWithRed:136/255.0 green:196/255.0 blue:63/255.0 alpha:0.9f];

    button1 = [[UIButton alloc]init];
    [button1 setTag:0];
    button2 = [[UIButton alloc]init];
    [button2 setTag:0];
    button3 = [[UIButton alloc]init];
    [button3 setTag:0];
    button4 = [[UIButton alloc]init];
    [button4 setTag:0];
    button5 = [[UIButton alloc]init];
    [button5 setTag:0];
    button6 = [[UIButton alloc]init];
    [button6 setTag:0];
    button7 = [[UIButton alloc]init];
    [button7 setTag:0];
    buttonSet = @[button7, button1,button2,button3,button4,button5,button6];
  
    if(_id == 7)
    {
        for(UIButton * bt in buttonSet)
        {
            [bt setTag:1];
        }
    }
    else
    {
        [buttonSet[_id] setTag:1];
    }
    NSArray* titles = @[@"七",@"一",@"二",@"三",@"四",@"五",@"六"];
    int i = 0;
    for(UIButton* button in buttonSet)
    {
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.8] forState:UIControlStateNormal];
        [self setButtonColor:button];
        [self.view addSubview:button];
        button.layer.cornerRadius = 2;
        button.layer.masksToBounds = YES;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        i++;
    }
  
    
    //确定位置
    strWidth = [self sizeWithFont:@" 星期 " size:15].width;
    //确定button的宽度
    width = (startTime1.frame.size.width - strWidth)/7.0 - 2;
    
    everyday = [[BorderUIView alloc]init];
    weekday = [[BorderUIView alloc]init];
    weekend = [[BorderUIView alloc]init];
    [everyday addTarget:self action:@selector(longButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [weekday addTarget:self action:@selector(longButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [weekend addTarget:self action:@selector(longButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:everyday];
    [self.view addSubview:weekend];
    [self.view addSubview:weekday];
    
    [everyday setTitle:@"每天" forState:UIControlStateNormal];
    [weekday setTitle:@"工作日" forState:UIControlStateNormal];
    [weekend setTitle:@"周末" forState:UIControlStateNormal];
    
    save = [[SHRectangleButton alloc]init];
    [save setTitle:@"保存" forState:UIControlStateNormal];
    [self.view addSubview:save];
    [save addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    
    [self updateRightBarButton];
    [self refreshFrame];
}

-(void)save
{
   //获取之前wificlock设置信息
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error;
        BOOL result = [[SHRouter currentRouter]getWifiClockInfo:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!result)
            {
                [MBProgressHUD showError:@"出错了，设置失败"];
            }
            else
            {
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
                
                
                
                NSMutableArray *wifiClockInfo = [SHRouter currentRouter].wifiClocks;
                for(int i = 0; i < wifiClockInfo.count; i++)
                {
                    UIButton *button = buttonSet[i];
                    if(button.tag == 1)
                    {
                        wifiClockInfo[i] = @{@"INIT_STATE":initalState, @"TIME1":[NSNumber numberWithInt:time1], @"TIME2":[NSNumber numberWithInt:time2],@"TIME3":[NSNumber numberWithInt:time3],@"TIME4":[NSNumber numberWithInt:time4]};
                    }else
                    {
                        wifiClockInfo[i] = @{@"INIT_STATE":wifiClockInfo[i][0], @"TIME1":wifiClockInfo[i][1], @"TIME2":wifiClockInfo[i][2],@"TIME3":wifiClockInfo[i][3],@"TIME4":wifiClockInfo[i][4]};
                    }
                }
                
                [MBProgressHUD showMessage:@"正在设置wifi定时参数"];
                
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    BOOL ret = [[SHRouter currentRouter] setUpWifiClock:[SHRouter currentRouter].wlanSchedState ?@1 : @0 wlanSched:wifiClockInfo error:nil];
                    
                    float time = 0.5;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)),dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUD];
                        if(!ret)
                        {
                            [MBProgressHUD showError:@"设置失败"];
                        }
                        else
                        {
                            [MessageUtil showShortToast:@"设置成功"];
                            [self.navigationController popViewControllerAnimated:YES];
                            WifiClockViewController *controller = [self.navigationController.viewControllers lastObject];
                            controller.isNeedRefresh = true;
                        }
                    });
                });
                
            }
        });
    });
}
-(int)getTime:(NSString*)timeStr
{
    NSArray* strs = [timeStr componentsSeparatedByString:@":"];
    int hour = [strs[0] intValue];
    int minutes = [strs[1] intValue];
    return hour*60 + minutes;
}
-(void)buttonClick:(id)target
{
    UIButton *button = target;
    int state = button.tag;
    if(state == 0)
    {
        button.tag = 1;
        [self setButtonColor:button];
    }
    else
    {
        button.tag = 0;
        [self setButtonColor:button];
    }
    
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
    
     dayContainer.frame = CGRectMake(horizontalMargin, CGRectGetMaxY(startTime4.frame) + verticalSpace, self.view.frame.size.width - 2*horizontalMargin, [self sizeWithFont:@"关闭时间" size:15].height + 15);
    
    
    button1.frame = CGRectMake(dayContainer.frame.origin.x + strWidth + 4, dayContainer.frame.origin.y
                               , width,dayContainer.frame.size.height);
    button2.frame = CGRectMake(CGRectGetMaxX(button1.frame) + 2, dayContainer.frame.origin.y, width, dayContainer.frame.size.height);
    button3.frame = CGRectMake(CGRectGetMaxX(button2.frame) + 2, dayContainer.frame.origin.y, width, dayContainer.frame.size.height);
    button4.frame = CGRectMake(CGRectGetMaxX(button3.frame) + 2, dayContainer.frame.origin.y, width, dayContainer.frame.size.height);
    button5.frame = CGRectMake(CGRectGetMaxX(button4.frame) + 2, dayContainer.frame.origin.y, width, dayContainer.frame.size.height);
    button6.frame = CGRectMake(CGRectGetMaxX(button5.frame) + 2, dayContainer.frame.origin.y, width, dayContainer.frame.size.height);
    button7.frame = CGRectMake(CGRectGetMaxX(button6.frame) + 2, dayContainer.frame.origin.y, width, dayContainer.frame.size.height);
    
    everyday.frame = CGRectMake(dayContainer.frame.origin.x, CGRectGetMaxY(dayContainer.frame) + verticalSpace * 2, dayContainer.frame.size.width/ 3.0 - 2, dayContainer.frame.size.height);
    
    weekday.frame = CGRectMake(CGRectGetMaxX(everyday.frame) + 2, everyday.frame.origin.y, dayContainer.frame.size.width/ 3.0 -2 , dayContainer.frame.size.height);
    
      weekend.frame = CGRectMake(CGRectGetMaxX(weekday.frame) + 2, everyday.frame.origin.y, dayContainer.frame.size.width/ 3.0, dayContainer.frame.size.height);
    
    save.frame = CGRectMake(everyday.frame.origin.x
                            , CGRectGetMaxY(everyday.frame) + verticalSpace * 5, dayContainer.frame.size.width, startTime1.frame.size.height);
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

-(void)setButtonColor:(UIButton*)button
{
    int state = button.tag;
    if(state == 1)
    {
        button.backgroundColor = buttonColorOn;
    }
    else
    {
        button.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
    }
}


-(void)longButtonClick:(id)target
{
    if(target == everyday)
    {
        
        button1.tag = 1;
        button2.tag = 1;
        button3.tag = 1;
        button4.tag = 1;
        button5.tag = 1;
        button6.tag = 1;
        button7.tag = 1;
    }
    else if(target == weekend)
    {
        
        button1.tag = 0;
        button2.tag = 0;
        button3.tag = 0;
        button4.tag = 0;
        button5.tag = 0;
        button6.tag = 1;
        button7.tag = 1;
    }
    else if (target == weekday)
    {
        button1.tag = 1;
        button2.tag = 1;
        button3.tag = 1;
        button4.tag = 1;
        button5.tag = 1;
        button6.tag = 0;
        button7.tag = 0;
    }
    for(UIButton * button in buttonSet)
    {
        [self setButtonColor:button];
    }
}
@end
