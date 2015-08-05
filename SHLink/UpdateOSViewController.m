//
//  UpdateOSViewController.m
//  SHLink
//
//  Created by zhen yang on 15/4/20.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "UpdateOSViewController.h"
#import "TextUtil.h"
#import "OSVersionInfoView.h"
#import "SearchView.h"
#import "FaildView.h"
#import "SHRouter.h"
#import "SHRectangleButton.h"
#import "MessageUtil.h"
#import "DialogUtil.h"
#import "ErrorUtil.h"
#import "UserDefaultUtil.h"
#import "ErrorUtil.h"
#import "MJRefresh.h"
#define padding 15
#define sleepTimeLong 30
#define sleepTimeShort 5
#define sleepTimeNormal 5
@interface UpdateOSViewController ()

@end

@implementation UpdateOSViewController
{
    UILabel *_hint;
    OSVersionInfoView *_masterView;
    OSVersionInfoView *_slaveView;
    
    UIScrollView *_container;
    SearchView *_searchView;
    FaildView *_failedView;
    
    BOOL isUpdateMasterOS;
    BOOL isUpdateSlaveOS;
    
    SHRectangleButton *_update;
    
    NSString *masterCurrentVersion;
    NSString *masterOtaVersion;
    
    NSString *slaveCurrentVersion;
    NSString *slaveOtaVersion;
    
    int updateMasterCount;
    
    BOOL needSleep15Sec;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"固件更新";
    updateMasterCount = 0;
    needSleep15Sec = false;
    _container = [[UIScrollView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _container.backgroundColor = getColor(230, 230, 230, 255);
    [self.view addSubview:_container];
    
    _searchView = [SearchView initWithMsg:@"正在查询固件信息"];
    [self.view addSubview:_searchView];
    
    _failedView = [[FaildView alloc]init];
    [self.view addSubview:_failedView];
    
    _hint = [[UILabel alloc]init];
    [_container addSubview:_hint];
    _hint.text = @"更新固件";
    [_hint setTextAlignment:NSTextAlignmentCenter];
    _hint.center = CGPointMake(self.view.frame.size.width / 2, 20);
    _hint.bounds = CGRectMake(0, 0, self.view.frame.size.width, [TextUtil getSize:_hint].height);
    
    _masterView = [[OSVersionInfoView alloc]init];
    [_masterView setTitle:@"更新master固件"];
    _masterView.frame = CGRectMake(padding, CGRectGetMaxY(_hint.frame) + padding, self.view.frame.size.width - 2*padding, _masterView.getHeight);
    [_container addSubview:_masterView];
    
    
    _slaveView = [[OSVersionInfoView alloc]init];
    [_slaveView setTitle:@"更新slave固件"];
    _slaveView.frame = CGRectMake(padding, CGRectGetMaxY(_masterView.frame) + padding, self.view.frame.size.width - 2 *padding, _slaveView.getHeight);
    [_container addSubview:_slaveView];
    
    _update = [[SHRectangleButton alloc]init];
    [_update setTitle:@"更新" forState:UIControlStateNormal];
    [_update setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_container addSubview:_update];
    _update.frame = CGRectMake(padding, CGRectGetMaxY(_slaveView.frame) + 2*padding, self.view.frame.size.width - 2 *padding, 50);
    [_update addTarget:self action:@selector(updateOS:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [_masterView addTarget:self action:@selector(masterViewClick) forControlEvents:UIControlEventTouchUpInside];
    [_slaveView addTarget:self action:@selector(slaveViewClick) forControlEvents:UIControlEventTouchUpInside];
    
    isUpdateSlaveOS = false;
    isUpdateMasterOS = false;
    
    UpdateOSViewController *tmp = self;
    [_container addLegendHeaderWithRefreshingBlock:^{
        [tmp getOSInfo];
    }];
    
    [_failedView addLegendHeaderWithRefreshingBlock:^{
        [tmp getOSInfo];
    }];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self showSearchView];
}


-(void)getOSInfo
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        DLog(@"获取固件信息-----------------------------");
        NSError *error;
        NSDictionary* dic = [[SHRouter currentRouter]getOSVersionInfo:0 error:&error];
        if(dic)
        {
            int isNeedUpdate = [dic[@"IS_NEED_UPDATE"] intValue];
            masterCurrentVersion = dic[@"CURRENT_VER"];
            masterOtaVersion = dic[@"OTA_VER"];
            if([masterCurrentVersion isEqual:@""] || [masterCurrentVersion isEqual:@"0.0.0"] )
            {
                masterCurrentVersion = @"未知";
                isNeedUpdate = 0;
            }
            if([masterOtaVersion isEqual:@""] || [masterOtaVersion isEqual:@"0.0.0"])
            {
                masterOtaVersion = @"未知";
                isNeedUpdate = 0;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if(isNeedUpdate == 1)
                {
                    [_masterView update:true];
                    isUpdateMasterOS = true;
                }
                else
                {
                    [_masterView update:false];
                    isUpdateSlaveOS = false;
                }
                
                [_masterView setCurrentVersion:masterCurrentVersion];
                [_masterView setOtaVersion:masterOtaVersion];
                
                //查询slave
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    NSError *error;
                    NSDictionary* dic = [[SHRouter currentRouter]getOSVersionInfo:1 error:&error];
                    if(dic)
                    {
                        int isNeedUpdate = [dic[@"IS_NEED_UPDATE"] intValue];
                        slaveCurrentVersion = dic[@"CURRENT_VER"];
                        slaveOtaVersion = dic[@"OTA_VER"];
                        if([slaveCurrentVersion isEqual:@""] || [slaveCurrentVersion isEqual:@"0.0.0"] )
                        {
                            slaveCurrentVersion = @"未知";
                            isNeedUpdate = 0;
                        }
                        if([slaveOtaVersion isEqual:@""] || [slaveOtaVersion isEqual:@"0.0.0"])
                        {
                            slaveOtaVersion = @"未知";
                            isNeedUpdate = 0;
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(isNeedUpdate == 1)
                            {
                                [_slaveView update:true];
                                isUpdateSlaveOS = true;
                            }
                            else
                            {
                                [_slaveView update:false];
                                isUpdateSlaveOS = false;
                            }
                            
                            [_slaveView setCurrentVersion:slaveCurrentVersion];
                            [_slaveView setOtaVersion:slaveOtaVersion];
                            
                            if(!isUpdateSlaveOS)
                            {
                                _slaveView.enabled = false;
                            }
                            else
                            {
                                _slaveView.enabled = true;
                            }
                            
                            if(!isUpdateMasterOS)
                            {
                                _masterView.enabled = false;
                            }
                            else
                            {
                                _masterView.enabled = true;
                            }
                            
                            if(!isUpdateMasterOS && !isUpdateSlaveOS)
                            {
                                _update.hidden = true;
                                [_hint setText:@"无需更新固件"];
                            }
                            else
                            {
                                _update.hidden = false;
                                [_hint setText:@"发现新固件"];
                            }
                            if(isUpdateSlaveOS && isUpdateMasterOS)
                            {
                                isUpdateMasterOS = true;
                                isUpdateSlaveOS = true;
                            }
                            
                            [_masterView update:isUpdateMasterOS];
                            [_slaveView update:isUpdateSlaveOS];
                            
                            [self showNormal];
                        });
                        
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSString *errorMsg = [ErrorUtil doForError:error];
                            [self showFailedView:errorMsg];
                        });
                        
                    }
                });
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *errorMsg = [ErrorUtil doForError:error];
                [self showFailedView:errorMsg];
            });
        }
    });

}

-(void)viewDidAppear:(BOOL)animated
{
    
    [self getOSInfo];
}

-(void)showNormal
{
    _container.hidden = false;
    _searchView.hidden = true;
    _failedView.hidden = true;
    //self.navigationItem.hidesBackButton = NO;
    [_container.header endRefreshing];
    [_failedView.header endRefreshing];
}

-(void)showSearchView
{
    _container.hidden = true;
    _searchView.hidden = false;
    _failedView.hidden = true;
    [_container.header endRefreshing];
    [_failedView.header endRefreshing];
    //self.navigationItem.hidesBackButton = YES;
}

-(void)showFailedView:(NSString*)msg
{
    _container.hidden = true;
    _searchView.hidden = true;
    _failedView.hidden = false;
    [_failedView setMessage:msg];
    [_container.header endRefreshing];
    [_failedView.header endRefreshing];
    //self.navigationItem.hidesBackButton = NO;
}

-(void)masterViewClick
{
    isUpdateMasterOS = !isUpdateMasterOS;

    if(isUpdateSlaveOS && isUpdateMasterOS)
    {
        //isUpdateSlaveOS = false;
    }
        [_masterView update:isUpdateMasterOS];
    [_slaveView update:isUpdateSlaveOS];
}

-(void)slaveViewClick
{
    isUpdateSlaveOS = !isUpdateSlaveOS;
    if(isUpdateSlaveOS && isUpdateMasterOS)
    {
        //isUpdateMasterOS = false;
    }
    [_masterView update:isUpdateMasterOS];
    [_slaveView update:isUpdateSlaveOS];
}



-(void)updateOS:(id)target
{
    if(!isUpdateMasterOS && !isUpdateSlaveOS)
    {
        [MessageUtil showShortToast:@"请选择需要更新的固件"];
        return;
    }
    
    if(isUpdateMasterOS && !isUpdateSlaveOS)
    {
        //检查是否需要备份
        //获取当前版本前两位
        NSArray *array = [masterCurrentVersion componentsSeparatedByString:@"."];
        NSString *currentVersion1Str = array[0];
        NSString *currentVersion2Str = array[1];
        array = [masterOtaVersion componentsSeparatedByString:@"."];
        NSString *otaVersion1Str = array[0];
        NSString *otaVersion2Str = array[1];
        int currentVersion1 = [currentVersion1Str intValue];
        int currentVersion2 = [currentVersion2Str intValue];
        int otaVersion1 = [otaVersion1Str intValue];
        int otaVersion2 = [otaVersion2Str intValue];
        DLog(@"curVersion1 = %d  curVersion2 = %d otaVersion1 = %d otaVersion2 = %d", currentVersion1, currentVersion2, otaVersion1, otaVersion2);
        [self showSearchView];
        if(currentVersion1 < otaVersion1 || currentVersion2 < otaVersion2)
        {
            //有重大升级，需要备份参数
            [_searchView setMsg:@"正在备份路由器参数"];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSError *error;
                NSString *backupInfo = [[SHRouter currentRouter]getBackupInfo:&error];
                if(backupInfo == nil)
                {
                    if(error.code == SHError_unknown_error)
                    {
                        //说明是旧版本，没有此接口,需要自己获取需要备份的数据
                        //获取wan相关信息
                        NSError *error;
                        NSDictionary *wanInfodic = [[SHRouter currentRouter]getWanInfo:&error];
                        if(wanInfodic)
                        {
                            //成功获取wan信息
                            //再获取网络信息
                            NSError *error;
                            NSDictionary *netInfoDic = [[SHRouter currentRouter] getNetworkSettingInfoWithError:&error];
                            if(netInfoDic)
                            {
                                //成功获取网络信息
                                //提取需要备份的信息
                                NSString *userName = wanInfodic[@"PPPOE"][@"UserName"];
                                NSString *passwd = wanInfodic[@"PPPOE"][@"PassWd"];
                                NSString *ip = wanInfodic[@"STATIC_IP"][@"IP"];
                                NSString *mask = wanInfodic[@"STATIC_IP"][@"MASK"];
                                NSString *gateway = wanInfodic[@"STATIC_IP"][@"GATEWAY"];
                                NSString *dns1 = wanInfodic[@"STATIC_IP"][@"DNS1"];
                                NSString *dns2 = wanInfodic[@"STATIC_IP"][@"DNS2"];
                                NSString *ssid = netInfoDic[@"WLAN_CFG"][@"SSID"];
                                NSString *key = netInfoDic[@"WLAN_CFG"][@"KEY"];
                                int wan_type;
                                NSNumber *WANTYPE = wanInfodic[@"WAN_TYPE"];
                                if(WANTYPE == nil)
                                {
                                    if(userName.length > 0)
                                    {
                                        wan_type = 2;
                                    }
                                    else if(ip.length > 0 && ![ip isEqualToString:@"0.0.0.0"])
                                    {
                                        wan_type = 1;
                                    }
                                    else
                                    {
                                        wan_type = 0;
                                    }
                                }
                                else
                                {
                                    wan_type = WANTYPE.intValue;
                                }
                                //构造需要保存的json
                                NSDictionary *jsonDic = @{@"RSP_TYPE":@22, @"WAN":@{@"WAN_TYPE":@(wan_type), @"PPPOE":@{@"UserName":userName, @"PassWd":passwd}, @"STATIC_IP":@{@"IP":ip, @"MASK":mask, @"GATEWAY":gateway, @"DNS1":dns1, @"DNS2":dns2}}, @"WLAN":@{@"SSID":ssid, @"KEY":key}, @"NAMES":@[]};
                                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:0 error:nil];
                                NSString *backupJson = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
                                //保存起来
                                [UserDefaultUtil setString:backupJson forKey:[SHRouter currentRouter].mac];
                                DLog(@"备份成功");
                                DLog(@"备份数据: %@", backupJson);
                                //备份完之后升级master固件
                                [self updateMasterOS];
                            }
                            else
                            {
                                //获取网络信息失败，备份失败
                                [MessageUtil showShortToast:@"获取备份信息失败，无法更新"];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.navigationController popViewControllerAnimated:true];
                                });                            }
                        }
                        else
                        {
                            //获取wan信息息失败,备份失败
                            [MessageUtil showShortToast:@"获取备份信息失败，无法更新"];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                 [self.navigationController popViewControllerAnimated:true];
                            });
                        }
                    }
                    else
                    {
                        //获取备份信息失败
                        [MessageUtil showShortToast:@"获取备份信息失败，无法更新"];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.navigationController popViewControllerAnimated:true];
                        });
                    }
                }
                else
                {
                    //保存获取的备份参数
                    [UserDefaultUtil setString:backupInfo forKey:[SHRouter currentRouter].mac];
                    DLog(@"备份成功:%@", backupInfo);
                    //更新固件
                    [self updateMasterOS];
                }
            });
        }
        else
        {
            //不需要备份直接升级
            [self updateMasterOS];
            
        }
    }
    
    //更新slave固件
    if(isUpdateSlaveOS && !isUpdateMasterOS)
    {
        [self updateSlaveOS];
    }
    
    //更新master和slave
    if(isUpdateMasterOS && isUpdateSlaveOS)
    {
        //检查是否需要备份
        //获取当前版本前两位
        NSArray *array = [masterCurrentVersion componentsSeparatedByString:@"."];
        NSString *currentVersion1Str = array[0];
        NSString *currentVersion2Str = array[1];
        array = [masterOtaVersion componentsSeparatedByString:@"."];
        NSString *otaVersion1Str = array[0];
        NSString *otaVersion2Str = array[1];
        int currentVersion1 = [currentVersion1Str intValue];
        int currentVersion2 = [currentVersion2Str intValue];
        int otaVersion1 = [otaVersion1Str intValue];
        int otaVersion2 = [otaVersion2Str intValue];
        DLog(@"curVersion1 = %d  curVersion2 = %d otaVersion1 = %d otaVersion2 = %d", currentVersion1, currentVersion2, otaVersion1, otaVersion2);
        [self showSearchView];
        if(currentVersion1 < otaVersion1 || currentVersion2 < otaVersion2)
        {
            //有重大升级，需要备份参数
            [_searchView setMsg:@"正在备份路由器参数"];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSError *error;
                NSString *backupInfo = [[SHRouter currentRouter]getBackupInfo:&error];
                if(backupInfo == nil)
                {
                    if(error.code == SHError_unknown_error)
                    {
                        //说明是旧版本，没有此接口,需要自己获取需要备份的数据
                        //获取wan相关信息
                        NSError *error;
                        NSDictionary *wanInfodic = [[SHRouter currentRouter]getWanInfo:&error];
                        if(wanInfodic)
                        {
                            //成功获取wan信息
                            //再获取网络信息
                            NSError *error;
                            NSDictionary *netInfoDic = [[SHRouter currentRouter] getNetworkSettingInfoWithError:&error];
                            if(netInfoDic)
                            {
                                //成功获取网络信息
                                //提取需要备份的信息
                                NSString *userName = wanInfodic[@"PPPOE"][@"UserName"];
                                NSString *passwd = wanInfodic[@"PPPOE"][@"PassWd"];
                                NSString *ip = wanInfodic[@"STATIC_IP"][@"IP"];
                                NSString *mask = wanInfodic[@"STATIC_IP"][@"MASK"];
                                NSString *gateway = wanInfodic[@"STATIC_IP"][@"GATEWAY"];
                                NSString *dns1 = wanInfodic[@"STATIC_IP"][@"DNS1"];
                                NSString *dns2 = wanInfodic[@"STATIC_IP"][@"DNS2"];
                                NSString *ssid = netInfoDic[@"WLAN_CFG"][@"SSID"];
                                NSString *key = netInfoDic[@"WLAN_CFG"][@"KEY"];
                                int wan_type;
                                NSNumber *WANTYPE = wanInfodic[@"WAN_TYPE"];
                                if(WANTYPE == nil)
                                {
                                    if(userName.length > 0)
                                    {
                                        wan_type = 2;
                                    }
                                    else if(ip.length > 0 && ![ip isEqualToString:@"0.0.0.0"])
                                    {
                                        wan_type = 1;
                                    }
                                    else
                                    {
                                        wan_type = 0;
                                    }
                                }
                                else
                                {
                                    wan_type = WANTYPE.intValue;
                                }
                                //构造需要保存的json
                                NSDictionary *jsonDic = @{@"RSP_TYPE":@22, @"WAN":@{@"WAN_TYPE":@(wan_type), @"PPPOE":@{@"UserName":userName, @"PassWd":passwd}, @"STATIC_IP":@{@"IP":ip, @"MASK":mask, @"GATEWAY":gateway, @"DNS1":dns1, @"DNS2":dns2}}, @"WLAN":@{@"SSID":ssid, @"KEY":key}, @"NAMES":@[]};
                                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:0 error:nil];
                                NSString *backupJson = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
                                //保存起来
                                [UserDefaultUtil setString:backupJson forKey:[SHRouter currentRouter].mac];
                                DLog(@"备份成功");
                                DLog(@"备份数据: %@", backupJson);
                                //备份完之后升级master固件
                                [self updateMasterAndSlave];
                            }
                            else
                            {
                                //获取网络信息失败，备份失败
                                [MessageUtil showShortToast:@"获取备份信息失败，无法更新"];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.navigationController popViewControllerAnimated:true];
                                });                            }
                        }
                        else
                        {
                            //获取wan信息息失败,备份失败
                            [MessageUtil showShortToast:@"获取备份信息失败，无法更新"];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.navigationController popViewControllerAnimated:true];
                            });
                        }
                    }
                    else
                    {
                        //获取备份信息失败
                        [MessageUtil showShortToast:@"获取备份信息失败，无法更新"];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.navigationController popViewControllerAnimated:true];
                        });
                    }
                }
                else
                {
                    //保存获取的备份参数
                    [UserDefaultUtil setString:backupInfo forKey:[SHRouter currentRouter].mac];
                    DLog(@"备份成功:%@", backupInfo);
                    //更新固件
                    [self updateMasterAndSlave];
                }
            });
        }
        else
        {
            //不需要备份直接升级
            [self updateMasterAndSlave];
            
        }
    }
}



-(void)updateMasterAndSlave
{
   //先更新slave
    [self showSearchView];
    [_searchView setMsg:@"正在请求路由器更新slave固件"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        int count = 30;
        int i = 0;
        __block BOOL needUpdateSlave = true;
        for(; i < count; i++)
        {
            if(needUpdateSlave)
            {
                //更新slave
                NSError *error;
                NSDictionary *dic = [[SHRouter currentRouter]updateFireWare:1 error:&error];
                if(dic)
                {
                    //请求成功
                    if(dic[@"UPGRADE_SLAVE_STATUS"] == nil)
                    {
                        //旧版本，查看upgrade_status字段
                        if([dic[@"UPGRADE_STATUS"] intValue] == 0)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [_searchView setMsg:@"路由器已经收到更新请求，正在下载slave最新固件"];
                            });
                        }
                        if([dic[@"UPGRADE_STATUS"] intValue] == 1)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [_searchView setMsg:@"slave固件已经下载完成，正在更新"];
                            });
                            needUpdateSlave = false;
                            needSleep15Sec = true;
                        }
                    }
                    else
                    {
                        //新版本
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if([dic[@"UPGRADE_SLAVE_STATUS"] intValue] == 0)
                            {
                                [_searchView setMsg:@"路由器已经接收到更新请求，正在下载slave固件"];
                            }
                            else if([dic[@"UPGRADE_SLAVE_STATUS"] intValue] == 1)
                            {
                                [_searchView setMsg:@"已经成功下载slave固件，正在升级，请稍候"];
                            }
                            else if([dic[@"UPGRADE_SLAVE_STATUS"] intValue] == 2)
                            {
                                [_searchView setMsg:@"正在等待slave更新完成,请稍候"];
                            }
                            else if([dic[@"UPGRADE_SLAVE_STATUS"] intValue] == 3)
                            {
                                [_searchView setMsg:@"slave固件升级成功，正在请求更新master固件"];
                                needUpdateSlave = false;
                            }
                            else
                            {
                                [_searchView setMsg:@"slave固件升级失败，正在请求更新master固件"];
                                needUpdateSlave = false;
                            }
                            
                        });
                        
                    }
                }
                else
                {
                    //请求失败
                }
                
                if(needSleep15Sec)
                {
                    //睡15秒
                    DLog(@"睡%d秒--------------------", 15);
                    sleep(15);
                    needSleep15Sec = false;
                }
                else
                {
                    //睡眠
                    if(dic[@"UPGRADE_SLAVE_STATUS"] == nil)
                    {
                        //旧版
                        if(i == 0 && dic != nil)
                        {
                            sleep(sleepTimeLong);
                            DLog(@"睡%d秒--------------------", sleepTimeLong);
                        }
                        else
                        {
                            sleep(sleepTimeShort);
                            DLog(@"睡%d秒--------------------", sleepTimeShort);
                        }
                    }
                    else
                    {
                        //新版本
                        DLog(@"睡%d秒--------------------", sleepTimeNormal);
                        sleep(sleepTimeNormal);
                        
                    }

                }
            }
            else
            {
                updateMasterCount ++;
                //更新master固件
                NSError *error;
                NSDictionary *dic = [[SHRouter currentRouter]updateFireWare:0 error:&error];
                if(dic)
                {
                    //请求成功
                    if([dic[@"UPGRADE_STATUS"] intValue] == 0)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [_searchView setMsg:@"路由器已经收到更新请求，正在下载master最新固件"];
                        });
                    }
                    if([dic[@"UPGRADE_STATUS"] intValue] == 1)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [_searchView setMsg:@"路由器已经下载完成master的最新固件，正在更新"];
                        });
                    }
                    if([dic[@"UPGRADE_STATUS"] intValue] == 2)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [self.navigationController popViewControllerAnimated:true];
                            
                            [DialogUtil createAndShowDialogWithTitle:@"更新成功" message:@"更新成功，路由器正在重启生效，请稍候自行连接wifi" handler:^(UIAlertAction *action) {
                                [(UINavigationController*)[UIApplication sharedApplication].keyWindow.rootViewController popToRootViewControllerAnimated:true];
                            }];
                        });
                        //跳出循环
                        break;
                    }
                }
                else
                {
                   //请求失败
                }
                //睡眠
                if(dic[@"UPGRADE_SLAVE_STATUS"] == nil)
                {
                    //旧版
                    if(updateMasterCount == 1 && dic != nil)
                    {
                        DLog(@"睡%d秒----------------------", sleepTimeLong);
                        sleep(sleepTimeLong);
                        
                    }
                    else
                    {
                        DLog(@"睡%d秒----------------------", sleepTimeShort);
                        sleep(sleepTimeShort);
                        
                    }
                }
                else
                {
                    //新版本
                    DLog(@"睡%d秒----------------------", sleepTimeNormal);
                    sleep(sleepTimeNormal);
                }

            }
        }
        
        //如果已经发了二十次请求仍未获取到成功响应，则认为固件更新失败了
        if(i == count)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showFailedView:@"超时，固件更新可能已经失败"];
            });
        }
    });

}


-(void)updateSlaveOS
{
    //更新slave固件
    [self showSearchView];
    [_searchView setMsg:@"正在请求路由器更新slave固件"];
    //更新slave固件
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        int count = 20;
        int i = 0;
        for(; i < count; i++)
        {
            DLog(@"第%d次请求-------------------------------", i);
            NSError *error;
            NSDictionary* dic = [[SHRouter currentRouter]updateFireWare:1 error:&error];
            if(dic)
            {
                //成功
                if(dic[@"UPGRADE_SLAVE_STATUS"] == nil)
                {
                    //旧版本
                    if([dic[@"UPGRADE_STATUS"] intValue] == 0)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [_searchView setMsg:@"路由器已经收到更新请求，正在下载slave最新固件"];
                        });
                    }
                    
                    if([dic[@"UPGRADE_STATUS"] intValue] == 1)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.navigationController popViewControllerAnimated:true];
                            [DialogUtil createAndShowDialogWithTitle:@"下载成功" message:@"成功下载slave固件,正在更新"];
                            
                        });
                        break;
                    }

                }
                else
                {
                    //新版本
                    
                        if([dic[@"UPGRADE_SLAVE_STATUS"] intValue] == 0)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [_searchView setMsg:@"路由器已经接收到更新请求，正在下载slave固件"];
                            });
                            
                        }
                        else if([dic[@"UPGRADE_SLAVE_STATUS"] intValue] == 1)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [_searchView setMsg:@"已经成功下载slave固件，正在升级，请稍候"];
                            });
                            
                        }
                        else if([dic[@"UPGRADE_SLAVE_STATUS"] intValue] == 2)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                               [_searchView setMsg:@"正在等待slave更新完成,请稍候"];
                            });
                            
                        }
                        else if([dic[@"UPGRADE_SLAVE_STATUS"] intValue] == 3)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //更新成功
                                [self.navigationController popViewControllerAnimated:true];
                                [DialogUtil createAndShowDialogWithTitle:@"更新成功" message:@"slave固件更新成功"];
                            });
                            break;
                        }
                        else
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //更新失败
                                [self.navigationController popViewControllerAnimated:true];
                                [DialogUtil createAndShowDialogWithTitle:@"更新失败" message:@"slave固件更新失败"];
                            });
                            break;
                        }
                    
                }
            }
            else
            {
                //出错重试
            }
            
            if(i == 0)
            {
                if(dic)
                {
                    //第一次发送请求成功
                    
                    if(dic[@"UPGRADE_SLAVE_STATUS"] == nil)
                    {
                        //旧版本
                        DLog(@"睡%d秒----------------------------------------------", sleepTimeLong);
                        sleep(sleepTimeLong);
                        
                    }
                    else
                    {
                        //新版本
                        DLog(@"睡%d秒----------------------------------------", sleepTimeNormal);
                        sleep(sleepTimeNormal);
                        
                    }
                }
                else
                {
                    //第一次发送失败
                     DLog(@"睡%d秒----------------------------------------", sleepTimeShort);
                    sleep(sleepTimeShort);
                   
                }
                
            }
            else
            {
                if(dic[@"UPGRADE_SLAVE_STATUS"] == nil)
                {
                    DLog(@"睡%d秒----------------------------------------", sleepTimeShort);
                     sleep(sleepTimeShort);
                    
                }
                else
                {
                    //新版本
                    DLog(@"睡%d秒----------------------------------------", sleepTimeNormal);
                    sleep(sleepTimeNormal);
                    
                }
            }
        }
        
        if(i == count)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showFailedView:@"超时， slave固件更新可能已经失败"];
            });
        }

    });
}

-(void)updateMasterOS
{
    //更新
    [_searchView setMsg:@"正在请求路由器更新master固件"];
    //更新master固件
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        int count = 20;
        int i = 0;
        for(; i < count; i++)
        {
            DLog(@"第%d次更新master请求-------------------------------------------------", i);
            NSError *error;
            NSDictionary* dic = [[SHRouter currentRouter]updateFireWare:0 error:&error];
            if(dic)
            {
                if([dic[@"UPGRADE_STATUS"] intValue] == 0)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_searchView setMsg:@"路由器已经收到更新请求，正在下载master最新固件"];
                    });
                }
                if([dic[@"UPGRADE_STATUS"] intValue] == 1)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_searchView setMsg:@"路由器已经下载完成master的最新固件，正在更新"];
                    });
                }
                if([dic[@"UPGRADE_STATUS"] intValue] == 2)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.navigationController popViewControllerAnimated:true];
                        
                        [DialogUtil createAndShowDialogWithTitle:@"固件更新成功" message:@"master固件更新成功，路由器正在重启生效，请稍候自行连接wifi" handler:^(UIAlertAction *action) {
                            [(UINavigationController*)[UIApplication sharedApplication].keyWindow.rootViewController popToRootViewControllerAnimated:true];
                        }];
                    });
                    //跳出循环
                    break;
                }
            }
            else
            {
                //出错
            }
            //睡眠一会再次探测更新状态
            if(i == 0)
            {
                if(dic)
                {
                     //第一次发送请求成功
                    if(dic[@"UPGRADE_SLAVE_STATUS"] == nil)
                    {
                        //旧版本,需要睡30秒
                        DLog(@"睡%d秒==================================", sleepTimeLong);
                        sleep(sleepTimeLong);
                        
                    }
                    else
                    {
                        //新版本，睡一会
                        DLog(@"睡%d秒==================================", sleepTimeNormal);
                        sleep(sleepTimeNormal);
                        
                    }
                }
                else
                {
                    //第一次请求失败
                    DLog(@"睡%d秒==================================", sleepTimeShort);
                    sleep(sleepTimeShort);
                    
                }
            }
            else
            {
                if(dic[@"UPGRADE_SLAVE_STATUS"] == nil)
                {
                    //旧版本
                    DLog(@"睡%d秒==================================", sleepTimeShort);
                    sleep(sleepTimeShort);
                    
                }
                else
                {
                    //新版本
                    DLog(@"睡%d秒==================================", sleepTimeNormal);
                    sleep(sleepTimeNormal);
                    
                }
            }
        }
        //如果已经发了二十次请求仍未获取到成功响应，则认为固件更新失败了
        if(i == count)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showFailedView:@"超时，master固件更新可能已经失败"];
            });
        }
    });

}


@end
