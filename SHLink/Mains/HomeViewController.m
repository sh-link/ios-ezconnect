
//  HomeViewController.m
//  SHLink
//
//  Created by 钱凯 on 15/2/2.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "HomeViewController.h"
#import "SHMenuCell.h"
#import "SHRouter.h"
#import "MBProgressHUD+MJ.h"
#import "CustomAlertView.h"
#import "SHProgressDialog.h"
#import "LoginViewController.h"
#import "Utils.h"
#import "UIView+Extension.h"
#import "ScreenUtil.h"
#include <arpa/inet.h>
#include <sys/socket.h>
#include <netdb.h>
#include <ifaddrs.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#import "Reachability.h"
#import "MessageUtil.h"
#import "DialogUtil.h"
#import "UserDefaultUtil.h"
#import "SHSetupTabBarController.h"

#define linewidth  0.5

@interface HomeViewController () <UIAlertViewDelegate>

@end

@implementation HomeViewController
{
    SHMenuCell *_deviceListCell;
    SHMenuCell *_netInfoCell;
    SHMenuCell *_settingCell;
    
    SHMenuCell *_modifyAccountCell;
    SHMenuCell *_scheduleCell;
    SHMenuCell *_wifiSpeedCell;
    
    SHMenuCell *_closeRouterCell;
    SHMenuCell *_updateOSCell;
    SHMenuCell *_parentControl;
    
    //四条线，两条横线，两条竖线
    UIView *lineX1;
    UIView *lineX2;
    UIView *lineX3;
    UIView *lineX4;
    
    BOOL hasGoToUpdateOS;
    
    int currentDialog;
    
    NSString *cancelCountKey;

}



- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化
    cancelCountKey = [NSString stringWithFormat:@"%@_cancelCount", [SHRouter currentRouter].mac];
    currentDialog = 0;
    hasGoToUpdateOS = false;
    
    DLog(@"did load %@", NSStringFromCGRect(self.view.frame));
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]init];
    self.navigationItem.backBarButtonItem.title = @"返回";
    [self setup];
    
    
    //获取手机ip信息
    NSString *address = [self localIPAddress];
    NSLog(@"address = %@", address);
}

//获取手机mask地址
-(NSString*)localIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    
    if (success == 0)
    {
        temp_addr = interfaces;
        
        while(temp_addr != NULL)
        {
            // check if interface is en0 which is the wifi connection on the iPhone
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    
    return address;
}


- (void)setup {
    lineX1 = [[UIView alloc]init];
    lineX2 = [[UIView alloc]init];
    lineX3 = [[UIView alloc]init];
    lineX4 = [[UIView alloc]init];
    //设置线的颜色 灰色
    UIColor *grayColor = getColor(33, 33, 33, 35);
    lineX1.backgroundColor = grayColor;
    lineX2.backgroundColor = grayColor;
    lineX3.backgroundColor = grayColor;
    lineX4.backgroundColor = grayColor;
    
    [self.view addSubview:lineX1];
    [self.view addSubview:lineX2];
    [self.view addSubview:lineX3];
    [self.view addSubview:lineX4];
    self.view.backgroundColor = [UIColor whiteColor];
    

    //设备列表
    _deviceListCell = [self createCellWithTitle:@"设备列表" imageName:@"slave_router" action:@selector(slaveListClick)];
    //参数设置
    _settingCell = [self createCellWithTitle:@"参数设置" imageName:@"param_setup" action:@selector(settingClick)];
    //修改账户
    _modifyAccountCell = [self createCellWithTitle:@"修改账户" imageName:@"account_modify" action:@selector(changeAccountClick)];
       //获取网络
    _netInfoCell = [self createCellWithTitle:@"获取网络" imageName:@"net_info" action:@selector(networkInfoClick)];
    //wifi定时
    _scheduleCell = [self createCellWithTitle:@"wifi定时" imageName:@"on_off" action:@selector(wifiClockClick)];
    //测网速
    _wifiSpeedCell = [self createCellWithTitle:@"测网速" imageName:@"speed_measurement" action:@selector(wifiSpeedMeasureClick)];
    
    //关闭路由器
    _closeRouterCell = [self createCellWithTitle:@"恢复出厂设置" imageName:@"close_router" action:@selector(closeRouterClick)];
    //版本更新
    _updateOSCell = [self createCellWithTitle:@"版本更新" imageName:@"os_update_img" action:@selector(updateOSClick)];
    
    _parentControl = [self createCellWithTitle:@"家长控制" imageName:@"parent_control" action:@selector(parentControlClick)];
 
    //设备各个view的frame
    [self initFrame];
    
    //检查是否存在备份信息，如果不存在，则检查网络
    if([UserDefaultUtil getStringForKey:[SHRouter currentRouter].mac defaultValue:nil] == nil)
    {
        //不存在备份信息
        DLog(@"不存在备份信息");
         [self checkNet];
    }
    else
    {
        DLog(@"有备份");
    }
    
    //如果wifi定时没有被设置过也就是还处于出厂状态，则将初始状态改为1,时间点置0
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error;
        [[SHRouter currentRouter]getWifiClockInfo:&error];
        if(!error)
        {
            //检查wifi定时是否处于出厂状态,initState = 0; time1 = 0;
            int initState = [[SHRouter currentRouter].wifiClocks[0][0] intValue];
            int time1 = [[SHRouter currentRouter].wifiClocks[0][0] intValue];
            if(initState == 0 && time1 == 0)
            {
                //说明此时wifi定时处于出厂状态，更新
                for(int i = 0; i < 7; i ++)
                {
                    [SHRouter currentRouter].wifiClocks[i] = @[@1,@0,@0,@0,@0];
                }
                [[SHRouter currentRouter]setWifiClocks:[SHRouter currentRouter].wifiClocks];
            }
        }
    });
}



//创建一个cell
-(SHMenuCell*)createCellWithTitle:(NSString*)title imageName:(NSString*)imageName action:(SEL)action
{
    SHMenuCell *cell = [[SHMenuCell alloc]init];
    [cell setTitle:title];
    [cell setImage:[UIImage imageNamed:imageName]];
    [cell addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cell];
    return cell;
}

-(void)initFrame
{
    CGFloat cellWidth = [ScreenUtil getWidth] / 3.0f;
    CGFloat cellHeight = ([ScreenUtil getHeight] - bar_length) / 3.0f;
    DLog(@"%@", NSStringFromCGRect(self.view.frame));
    //设置线条frame
    lineX1.frame = CGRectMake(cellWidth - linewidth, 0, linewidth, self.view.height);
    lineX2.frame = CGRectMake(cellWidth * 2 - linewidth, 0, linewidth, self.view.height);
    lineX3.frame  = CGRectMake(0, cellHeight - linewidth, self.view.width, linewidth);
    lineX4.frame = CGRectMake(0, cellHeight * 2 - linewidth, self.view.width, linewidth);


    _settingCell.frame = CGRectMake(0, 0 + 0, cellWidth -linewidth, cellHeight -linewidth);
    _scheduleCell.frame = CGRectMake(cellWidth, 0 + 0, cellWidth -linewidth, cellHeight - linewidth);
    _parentControl.frame = CGRectMake(cellWidth * 2, 0 + 0, cellWidth -linewidth, cellHeight - linewidth);
    
    _modifyAccountCell.frame = CGRectMake(0, cellHeight + 0, cellWidth - linewidth, cellHeight - linewidth);
    _deviceListCell.frame = CGRectMake(cellWidth, cellHeight + 0, cellWidth - linewidth, cellHeight - linewidth);
    _wifiSpeedCell.frame = CGRectMake(cellWidth *2, cellHeight + 0, cellWidth - linewidth, cellHeight - linewidth);
    
    _netInfoCell.frame = CGRectMake(0, cellHeight * 2 + 0, cellWidth - linewidth, cellHeight - linewidth);
    _closeRouterCell.frame = CGRectMake(cellWidth, cellHeight * 2 + 0, cellWidth - linewidth, cellHeight - linewidth);
    _updateOSCell.frame = CGRectMake(cellWidth *2, cellHeight*2 + 0, cellWidth - linewidth, cellHeight - linewidth);

}

-(void)viewDidAppear:(BOOL)animated
{
    DLog(@"did appear %@", NSStringFromCGRect(self.view.frame));
 
    
}

//关闭路由器
-(void)closeRouterClick
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"恢复出厂设置" message:@"您确定要恢复出厂设置吗？这将会导致您断开wifi连接" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [SHProgressDialog showDialog:@"正在请求恢复出厂设置" ViewController:self];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSError *error = nil;
             [[SHRouter currentRouter]closeRouter:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SHProgressDialog dismiss];
                if(error == nil)
                {
                    //[Utils showAlertView:@"成功发送恢复出厂设置请求,路由器正在重启,请稍后自行连接wifi"];
                    [DialogUtil createAndShowDialogWithTitle:@"恢复出厂设置" message:@"成功发送恢复出厂设置请求,路由器正在重启,请稍后自行连接wifi" handler:^(UIAlertAction *action) {
                        [self.navigationController popToRootViewControllerAnimated:true];
                    }];
                }
                else
                {
                    [Utils showAlertView:@"出错了,恢复出厂设置失败"];
                }

            });
        });
       
    }];
    [alertController addAction:cancelButton];
    [alertController addAction:okButton];
    [self presentViewController:alertController animated:YES completion:nil];
}

//slave列表
-(void)slaveListClick
{
    [self performSegueWithIdentifier:@"home2SlaveList" sender:self];
}

//设置
- (void)settingClick {
    UIStoryboard *strBoard = [UIStoryboard storyboardWithName:@"Setting" bundle:nil];
    if (strBoard) {
        SHSetupTabBarController *setupControl = [strBoard instantiateViewControllerWithIdentifier:@"settingInit"];
        DLog(@"new");
        [self.navigationController pushViewController:setupControl animated:YES];
    }
    
}

- (void)settingClick2 {
    UIStoryboard *strBoard = [UIStoryboard storyboardWithName:@"Setting" bundle:nil];
    if (strBoard) {
        SHSetupTabBarController *setupControl = [strBoard instantiateViewControllerWithIdentifier:@"settingInit"];
        setupControl.gotoWan = true;
        [self.navigationController pushViewController:setupControl animated:YES];
    }
}

//wifi定时
-(void)wifiClockClick
{
    [self performSegueWithIdentifier:@"home2WifiClock" sender:self];
}

//修改账户
- (void)changeAccountClick {
    [self performSegueWithIdentifier:@"accountSegue" sender:self];
}
//查询网络信息
- (void)networkInfoClick {
    [self performSegueWithIdentifier:@"home2net" sender:self];
}

//wifi测速
-(void)wifiSpeedMeasureClick
{
    [self performSegueWithIdentifier:@"home2WifiSpeedMeasure" sender:self];
}
//版本更新
-(void)updateOSClick
{
    [self performSegueWithIdentifier:@"home2updateOS" sender:self];
}

//家长控制
-(void)parentControlClick
{
    [self performSegueWithIdentifier:@"home2ParentControl" sender:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error;
        NSArray* slaves =  [[SHRouter currentRouter] getSlaveListWithError:&error];
        if(slaves != nil)
        {
            unsigned long number = slaves.count + 1;
            dispatch_async(dispatch_get_main_queue(), ^{
                [_deviceListCell setNumber:(int)number];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_deviceListCell hideNumber];
            });
        }
    });
    
    //检查是否有备份信息
    if([UserDefaultUtil getStringForKey:[SHRouter currentRouter].mac defaultValue:nil] != nil)
    {
        DLog(@"检查到有备份文件");
        //检查是否需要恢复
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSError *error;
            NSDictionary *dic = [[SHRouter currentRouter] detectOnlineWay:&error];
            if(dic == nil)
            {
                //查询出错
            }
            else
            {
                //查询成功
                //判断返回的restore字段
                NSNumber *restoreNumber = dic[@"RESTORE"];
                if(restoreNumber != nil && restoreNumber.intValue == 1)
                {
                    //说明需要恢复参数
                    //弹出对话框
                    dispatch_async(dispatch_get_main_queue(), ^{
                        currentDialog = 2;
                        [DialogUtil createAndShowDialogWithTitle:@"参数恢复" message:@"发现您曾备份过路由器设置参数，点击确定恢复路由器参数设置，这会导致路由器重启，点击取消放弃恢复" cancelTitle:@"取消" okTitle:@"确定" delegate:self];
                    });
                }
                
                
            }
        });
    }
    else
    {
        DLog(@"检查到无备份");
    }
 

}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //点击的是连网对话框
    if(currentDialog == 0)
    {
        if(buttonIndex == 1)
        {
            //进入wan口设置界面
            [self settingClick2];
        }
    }
    //点击的是固件更新对话框
    else if(currentDialog == 1)
    {
        if(buttonIndex == 1)
        {
            //进入固件更新界面
            [self updateOSClick];
        }
    }
    else if(currentDialog == 2)
    {
        if(buttonIndex == 0)
        {
            //用户取消备份恢复
            int cancleCount = [UserDefaultUtil getIntForKey:cancelCountKey];
            if(cancleCount < 4)
            {
                cancleCount++;
                [UserDefaultUtil setInt:cancleCount forKey:cancelCountKey];
            }
            else
            {
                //删除备份信息
                [UserDefaultUtil removeKey:cancelCountKey];
                [UserDefaultUtil removeKey:[SHRouter currentRouter].mac];
            }
        }
        else
        {
            //用户点击了备份
            //发送备份请求和数据
            [MBProgressHUD showMessage:@"正在请求恢复路由器参数设置"];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSError *error;
                BOOL result = [[SHRouter currentRouter]restoreBackupInfo:&error];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUD];
                });
                
                if(result)
                {
                    //删除备份信息
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //恢复成功
                        [UserDefaultUtil removeKey:cancelCountKey];
                        [UserDefaultUtil removeKey:[SHRouter currentRouter].mac];
                      
                        [DialogUtil createAndShowDialogWithTitle:@"参数恢复成功" message:@"参数恢复成功,路由器正在重启,您将会失去wifi连接，请稍后自行连接wifi" handler:^(UIAlertAction *action) {
                            [self.navigationController popToRootViewControllerAnimated:true];
                        }];
                    });
                }
                else
                {
                    //恢复失败
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [DialogUtil createAndShowDialogWithTitle:@"参数恢复失败" message:@"出错了,参数恢复失败"];
                    });
                    
                }
            });
        }
    }
    
}


-(void)checkNet
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:0.8];
        NSHTTPURLResponse *response;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
        if(response == nil)
        {
            //[MessageUtil showShortToast:@"没有网络"];
            //弹出对话框
            dispatch_async(dispatch_get_main_queue(), ^{
                currentDialog = 0;
                [DialogUtil createAndShowDialogWithTitle:@"连接网络" message:@"您当前无法上网，点击设置进行连网操作，点击取消放弃" cancelTitle:@"取消" okTitle:@"设置" delegate:self];
            });
            
        }
        else
        {
            //[MessageUtil showShortToast:@"网络是通的"];
            //弹出对话框
            //检查master固件更新
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSError *error = nil;
                DLog(@"查询master----------------");
                NSDictionary *dic = [[SHRouter currentRouter] getOSVersionInfo:0 error:&error];
                if(dic)
                {
                    int isNeedUpdate = [dic[@"IS_NEED_UPDATE"] intValue];
                    if(isNeedUpdate == 1)
                    {
                        [self goToUpdateOS];
                    }
                }
            });
            sleep(0.5);
            //检查slaveMaster更新
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSError *error = nil;
                DLog(@"查询slave------------------");
                NSDictionary *dic = [[SHRouter currentRouter] getOSVersionInfo:1 error:&error];
                if(dic)
                {
                    int isNeedUpdate = [dic[@"IS_NEED_UPDATE"] intValue];
                    if(isNeedUpdate == 1)
                    {
                        [self goToUpdateOS];
                    }
                }
                
            });
        }
    });
}

-(void)goToUpdateOS
{
    DLog(@"goToUpdateOS");
    @synchronized(self)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(!hasGoToUpdateOS)
            {
                hasGoToUpdateOS = true;
                //跳转到固件更新界面
                currentDialog = 1;
                DLog(@"创建更新对话框--------------------------------------------------------------");
                [DialogUtil createAndShowDialogWithTitle:@"固件更新" message:@"发现新固件，点击更新进入固件更新界面，点击取消放弃" cancelTitle:@"取消" okTitle:@"更新" delegate:self];
            }
            
        });
    }
}





@end
