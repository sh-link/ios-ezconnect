//
//  SHRouter.m
//  SHLink
//
//  Created by 钱凯 on 15/1/22.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "SHRouter.h"
#import "SHDeviceConnector.h"
#import "Packet.h"
#import "Reachability.h"
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#import "DeviceInfo.h"
#import "UserDefaultUtil.h"

@implementation SHRouter

+ (instancetype)currentRouter {
    static dispatch_once_t onceToken;
    static SHRouter *sharedInstance;
    dispatch_once(&onceToken,^{
        sharedInstance = [[SHRouter alloc] init];
        sharedInstance.tcpPort = 10246;
        
        sharedInstance.lanIp = @"192.168.0.1";
        sharedInstance.username = @"admin";
        sharedInstance.password = @"admin";
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _wifiClocks = [[NSMutableArray alloc]init];
        _parentControlWifiClocks = [[NSMutableArray alloc]init];
        _onlineWay = -2;
        _onlineWayStr = @"当前上网方式未知";
    }
    return self;
}

-(BOOL)addCLients:(NSArray *)clients error:(NSError **)error
{
    NSMutableArray *clientsArray = [NSMutableArray array];
    for(DeviceInfo *info in clients)
    {
        [clientsArray addObject:@{@"MAC":info.MAC, @"NAME": info.NAME}];
    }
    NSData *commandJson = [NSJSONSerialization dataWithJSONObject:@{@"REQ_TYPE":@SHRequestType_AddOrDeleteParentControl, @"ADD_FLAG": @1, @"PCONTROL_CHILDREN_LIST":clientsArray} options:0 error:nil];
    [SHDeviceConnector syncSendCommandWithIp:self.lanIp Port:self.tcpPort Username:self.username Password:self.password Command:commandJson TimeoutInSec:6.0 Error:error];
    
    if(error && *error)
    {
        return NO;
    }
    else
    {
        return YES;
    }
    return NO;
}

-(BOOL)deleteClients:(NSDictionary *)clients error:(NSError **)error
{
    NSMutableArray *clientsArray = [NSMutableArray array];
    for(DeviceInfo *info in clients)
    {
        [clientsArray addObject:@{@"MAC":info.MAC, @"NAME": info.NAME}];
    }
    NSData *commandJson = [NSJSONSerialization dataWithJSONObject:@{@"REQ_TYPE":@SHRequestType_AddOrDeleteParentControl, @"ADD_FLAG": @0, @"PCONTROL_CHILDREN_LIST":clientsArray} options:0 error:nil];
    [SHDeviceConnector syncSendCommandWithIp:self.lanIp Port:self.tcpPort Username:self.username Password:self.password Command:commandJson TimeoutInSec:6.0 Error:error];
    if(error && *error)
    {
        return NO;
    }
    else
    {
        return YES;
    }
    return NO;
}

-(NSMutableArray*)getDevicesInParentControl:(NSError **)error
{
    NSData *commandJson = [NSJSONSerialization dataWithJSONObject:@{@"REQ_TYPE":@SHRequestType_getParentControlInfo} options:0 error:nil];
    NSData *receivDate = [SHDeviceConnector syncSendCommandWithIp:self.lanIp Port:self.tcpPort Username:self.username Password:self.password Command:commandJson TimeoutInSec:6.0f Error:error];
    if((error && *error) || receivDate == nil)
    {
        return  nil;
    }
    else
    {
        NSMutableDictionary *recDic = [NSJSONSerialization JSONObjectWithData:receivDate options:NSJSONReadingMutableContainers error:nil];
        return recDic[@"PCONTROL_CHILDREN_LIST"];
    }
    return nil;
}

-(BOOL)addOrDeleteParentControl:(NSString *)mac name:(NSString *)name type:(int)type error:(NSError **)error
{
    NSData* commandJson = [NSJSONSerialization dataWithJSONObject:@{@"REQ_TYPE":@SHRequestType_AddOrDeleteParentControl, @"ADD_FLAG": @(type), @"PCONTROL_CHILDREN_LIST":@[@{@"MAC":mac, @"NAME":name}]} options:0 error:nil];
    DLog(@"%@--------------------------------",mac);
    [SHDeviceConnector syncSendCommandWithIp:self.lanIp Port:self.tcpPort Username:self.username Password:self.password Command:commandJson TimeoutInSec:6.0 Error:error];
    if(error && *error)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}
-(BOOL)addClientToParentControl:(NSString *)mac name:(NSString *)name error:(NSError *__autoreleasing *)error
{
    return [self addOrDeleteParentControl:mac name:name type:1 error:error];
}

-(BOOL)deleteClientFromParentControl:(NSString *)mac name:(NSString *)name error:(NSError *__autoreleasing*)error
{
    return [self addOrDeleteParentControl:mac name:name type:0 error:error];
}
-(BOOL)setClientName:(NSString *)newName mac:(NSString*)mac error:(NSError *__autoreleasing *)error
{
    NSData* commandJson = [NSJSONSerialization dataWithJSONObject:@{@"REQ_TYPE":@SHRequestType_SetClientName, @"CLT_MAC":mac, @"NAME":newName} options:0 error:nil];
    [SHDeviceConnector syncSendCommandWithIp:self.lanIp Port:self.tcpPort Username:self.username Password:self.password Command:commandJson TimeoutInSec:6.0 Error:error];
    if(error && *error)
    {
        return  NO;
    }
    else
    {
        return YES;
    }
}

-(NSDictionary*)updateFireWare:(int)type error:(NSError *__autoreleasing *)error
{
    NSData* commandJson = [NSJSONSerialization dataWithJSONObject:@{@"REQ_TYPE":@SHRequestType_UpdateFirmware, @"REQ_PRODUCT":@(type)} options:0 error:nil];
    NSData *receiveJson = [SHDeviceConnector syncSendCommandWithIp:self.lanIp Port:self.tcpPort Username:self.username Password:self.password Command:commandJson TimeoutInSec:6 Error:error];
    if(receiveJson == nil)
    {
        return nil;
    }
    return [NSJSONSerialization JSONObjectWithData:receiveJson options:0 error:nil];
}
-(NSDictionary*)getOSVersionInfo:(int)product_type error:(NSError *__autoreleasing *)error
{
    NSData* commandJson = [NSJSONSerialization dataWithJSONObject:@{@"REQ_TYPE":@SHRequestType_CheckFirmwareUpdate, @"REQ_PRODUCT" : @(product_type)} options:0 error:nil];
    NSData *receiveJson = [SHDeviceConnector syncSendCommandWithIp:self.lanIp Port:self.tcpPort Username:self.username Password:self.password Command:commandJson TimeoutInSec:6 Error:error];
    if(receiveJson == nil)
    {
        return nil;
    }
    return  [NSJSONSerialization JSONObjectWithData:receiveJson options:0 error:nil];
}
#pragma mark - Public APIs
#pragma mark -
//判断是否可以连接上路由器
- (BOOL)updateRouterInfo {
    struct sockaddr_in deviceAddr = self.hostAddr;
    if ([Reachability reachabilityWithAddress:&deviceAddr].currentReachabilityStatus == NotReachable) {
        return NO;
    }
    return YES;
}

-(void)setOnlineWay:(int)onlineWay
{
    _onlineWay = onlineWay;
    if(_onlineWay == -2)
    {
        self.onlineWayStr = @"当前上网方式:未知";
    }
    else if(_onlineWay == -1)
    {
        self.onlineWayStr = @"wan口未连接";
    }
    else if(_onlineWay == 0)
    {
        self.onlineWayStr = @"当前上网方式:DHCP";
    }
    else if (_onlineWay == 1)
    {
        self.onlineWayStr = @"当前上网方式:静态ip";
    }
    else if(_onlineWay == 2)
    {
        self.onlineWayStr = @"当前上网方式:pppoe拔号";
    }
}
//关闭路由器
-(BOOL)closeRouter:(NSError **)error
{
    NSData* commandJson = [NSJSONSerialization dataWithJSONObject:@{@"REQ_TYPE":@SHRequestType_GoToFactory} options:0 error:nil];
    NSData *receviceJson = [SHDeviceConnector syncSendCommandWithIp:self.lanIp Port:self.tcpPort Username:self.username Password:self.password Command:commandJson TimeoutInSec:6.0 Error:error];
    if((error && *error) || !receviceJson)
    {
        return NO;
    }
    return YES;
}

//设置父母控制定时
-(BOOL)setUpPCWifiClock:(NSNumber*)wlanSchedStateParam wlanSched:(NSArray*) wlanSched error:(NSError**)error;
{
    NSData *commandJson = [NSJSONSerialization dataWithJSONObject:@{@"REQ_TYPE":@SHRequestType_SetPanrentControlInfo, @"TIME_ZONE":@(8*60), @"PARENT_CONTROL_SWITCH":wlanSchedStateParam, @"PCONTROL_SCHED":wlanSched} options:0 error:nil];
    NSData* receiveJson = [SHDeviceConnector syncSendCommandWithIp:self.lanIp Port:self.tcpPort Username:self.username Password:self.password Command:commandJson TimeoutInSec:6.0 Error:error];
    if((error && *error)|| !receiveJson)
    {
        return NO;
    }
    return YES;
}
//设置wifi定时
-(BOOL)setUpWifiClock:(NSNumber*)wlanSchedStateParam wlanSched:(NSArray *)wlanSched error:(NSError *__autoreleasing *)error
{
    NSData *commandJson = [NSJSONSerialization dataWithJSONObject:@{@"REQ_TYPE":@SHRequestType_SetWlanSchedule, @"TIME_ZONE":@(8*60), @"WLAN_SCHED_STATE":wlanSchedStateParam, @"WLAN_SCHED":wlanSched} options:0 error:nil];
    NSData* receiveJson = [SHDeviceConnector syncSendCommandWithIp:self.lanIp Port:self.tcpPort Username:self.username Password:self.password Command:commandJson TimeoutInSec:6.0 Error:error];
    if((error && *error)|| !receiveJson)
    {
        return NO;
    }
    return YES;
}

//获取父母控制定时信息
-(BOOL)getParentClockInfo:(NSError **)error
{
    NSData* commandJson = [NSJSONSerialization dataWithJSONObject:@{@"REQ_TYPE":@SHRequestType_getParentControlInfo} options:0 error:nil];
    NSData* receviceJson = [SHDeviceConnector syncSendCommandWithIp:self.lanIp Port:self.tcpPort Username:self.username Password:self.password Command:commandJson TimeoutInSec:6.0 Error:error];
    if((error && *error) || !receviceJson)
    {
        return  NO;
    }
    //解析返回的json
    NSDictionary *receiveDic = [NSJSONSerialization JSONObjectWithData:receviceJson options:0 error:nil];
    if(receiveDic)
    {
        NSNumber* schedState = receiveDic[@"PARENT_CONTROL_SWITCH"];
        if(schedState.intValue == 0)
        {
            [SHRouter currentRouter].parentControlWlanSchedState = NO;
        }
        else{
            [SHRouter currentRouter].parentControlWlanSchedState = YES;
        }
        NSNumber* time1 = 0;
        NSNumber* time2 = 0;
        NSNumber* time3 = 0;
        NSNumber* time4 = 0;
        NSNumber* initalState = 0;
        [[SHRouter currentRouter].parentControlWifiClocks removeAllObjects];
        for(NSDictionary* dic in receiveDic[@"PCONTROL_SCHED"])
        {
            time1 = dic[@"TIME1"];
            time2 = dic[@"TIME2"];
            time3 = dic[@"TIME3"];
            time4 = dic[@"TIME4"];
            initalState = dic[@"INIT_STATE"];
            [[SHRouter currentRouter].parentControlWifiClocks addObject:@[initalState,time1, time2, time3, time4]];
        }
    }
    return YES;
}
//获取wifi定时相关信息
-(BOOL)getWifiClockInfo:(NSError **)error
{
    NSData* commandJson = [NSJSONSerialization dataWithJSONObject:@{@"REQ_TYPE":@SHRequestType_GetWifiClockInfo} options:0 error:nil];
    NSData* receviceJson = [SHDeviceConnector syncSendCommandWithIp:self.lanIp Port:self.tcpPort Username:self.username Password:self.password Command:commandJson TimeoutInSec:6.0 Error:error];
    if((error && *error) || !receviceJson)
    {
        return  NO;
    }
    //解析返回的json
    NSDictionary *receiveDic = [NSJSONSerialization JSONObjectWithData:receviceJson options:0 error:nil];
    if(receiveDic)
    {
        NSNumber* schedState = receiveDic[@"WLAN_SCHED_STATE"];
        if(schedState.intValue == 0)
        {
            [SHRouter currentRouter].wlanSchedState = NO;
        }
        else{
            [SHRouter currentRouter].wlanSchedState = YES;
        }
        NSNumber* time1 = 0;
        NSNumber* time2 = 0;
        NSNumber* time3 = 0;
        NSNumber* time4 = 0;
        NSNumber* initalState = 0;
        [[SHRouter currentRouter].wifiClocks removeAllObjects];
        for(NSDictionary* dic in receiveDic[@"WLAN_SCHED"])
        {
            time1 = dic[@"TIME1"];
            time2 = dic[@"TIME2"];
            time3 = dic[@"TIME3"];
            time4 = dic[@"TIME4"];
            initalState = dic[@"INIT_STATE"];
            [[SHRouter currentRouter].wifiClocks addObject:@[initalState,time1, time2, time3, time4]];
        }
    }
    return YES;
}
//获取所有终端
-(NSMutableArray*)getAllClient:(NSError *__autoreleasing *)error
{
    NSData* commandJson = [NSJSONSerialization dataWithJSONObject:@{@"REQ_TYPE":@SHRequestType_GetTerminalWithMac, @"SLV_MAC":@"FF-FF-FF-FF-FF-FF"} options:0 error:nil];
    NSData* receiveJson = [SHDeviceConnector syncSendCommandWithIp:self.lanIp Port:self.tcpPort Username:self.username Password:self.password Command:commandJson TimeoutInSec:6.0 Error:error];
    if((error && *error) || !receiveJson)
    {
        return nil;
    }
    if(receiveJson)
    {
        NSMutableDictionary* dic = [NSJSONSerialization JSONObjectWithData:receiveJson options:NSJSONReadingMutableContainers error:nil];
        if(dic)
        {
            self.selfMac = [dic[@"HOST_MAC"] uppercaseString];
            return dic[@"CLIENTS"];
        }
    }
    return nil;

}
//获取终端列表
-(NSMutableArray*)getTerminalWithMac:(NSString *)mac error:(NSError **)error
{
    NSData* commandJson = [NSJSONSerialization dataWithJSONObject:@{@"REQ_TYPE":@SHRequestType_GetTerminalWithMac, @"SLV_MAC":mac} options:0 error:nil];
    NSData* receiveJson = [SHDeviceConnector syncSendCommandWithIp:self.lanIp Port:self.tcpPort Username:self.username Password:self.password Command:commandJson TimeoutInSec:6.0 Error:error];
    if((error && *error) || !receiveJson)
    {
        return nil;
    }
    if(receiveJson)
    {
        NSMutableDictionary* dic = [NSJSONSerialization JSONObjectWithData:receiveJson options:NSJSONReadingMutableContainers error:nil];
        if(dic)
        {
            self.selfMac = [dic[@"HOST_MAC"] uppercaseString];
            return dic[@"CLIENTS"];
        }
    }
    return nil;
}

-(NSArray*)getSlaveListWithError:(NSError *__autoreleasing *)error
{
    NSData *commandJson = [NSJSONSerialization dataWithJSONObject:@{@"REQ_TYPE":@SHRequestType_GetSlaveList} options:0 error:nil];
    NSData *receiveJson = [SHDeviceConnector syncSendCommandWithIp:self.lanIp Port:self.tcpPort Username:self.username Password:self.password Command:commandJson TimeoutInSec:6.0 Error:error];
    if((error && *error) || !receiveJson)
    {
        self.SlaveList = nil;
        return nil;
    }
    if(receiveJson)
    {
        NSDictionary *receiveDic = [NSJSONSerialization JSONObjectWithData:receiveJson options:0 error:nil];
        if(receiveDic)
        {
            self.SlaveList = receiveDic[@"SLAVES"];
            return self.SlaveList;
        }
    }
    self.SlaveList = nil;
    return nil;
}

//获取主路由器的设备列表
- (NSMutableArray *)getClientListWithError:(NSError **)error {
    NSData *commandJson = [NSJSONSerialization dataWithJSONObject:@{@"REQ_TYPE":@SHRequestType_GetClientList} options:0 error:nil];
    NSData *receviceJson = [SHDeviceConnector syncSendCommandWithIp:self.lanIp Port:self.tcpPort Username:self.username Password:self.password Command:commandJson TimeoutInSec:6.0 Error:error];
    if ((error && *error) || !receviceJson) {
        self.clientList = nil;
        return nil;
    }
    if (receviceJson) {
        NSMutableDictionary *receiveDic = [NSJSONSerialization JSONObjectWithData:receviceJson options:NSJSONReadingMutableContainers error:nil];
        if (receiveDic) {
            self.selfMac = [receiveDic[@"HOST_MAC"] uppercaseString];
            self.clientList = receiveDic[@"CLIENTS"];
            return self.clientList;
        }
    }
    self.clientList = nil;
    return nil;
}

//获取网络设置信息
- (NSDictionary *)getNetworkSettingInfoWithError:(NSError **)error {
    NSData *commandJson = [NSJSONSerialization dataWithJSONObject:@{@"REQ_TYPE":@SHRequestType_GetNetworkInfo} options:0 error:nil];
    NSData *receviceJson = [SHDeviceConnector syncSendCommandWithIp:self.lanIp Port:self.tcpPort Username:self.username Password:self.password Command:commandJson TimeoutInSec:6.0 Error:error];
    if ((error && *error) || !receviceJson) {
        return nil;
    }
    if (receviceJson) {
        NSDictionary *receiveDic = [NSJSONSerialization JSONObjectWithData:receviceJson options:0 error:nil];
        if (receiveDic) {
            NSDictionary *wlanCfg = receiveDic[@"WLAN_CFG"];
            self.ssid = wlanCfg[@"SSID"];
            self.channel = [wlanCfg[@"CHANNEL"] intValue];
            self.wifiKey = wlanCfg[@"KEY"];
            NSDictionary *wanCfg = receiveDic[@"WAN_CFG"];
            self.wanIsConnected = [wanCfg[@"WAN_ISCONNECTED"] intValue] == 1;
            self.wanIp = wanCfg[@"IP"];
            self.wanMask = wanCfg[@"MASK"];
            self.wanGateway = wanCfg[@"GATEWAY"];
            self.dns1 = wanCfg[@"DNS1"];
            self.dns2 = wanCfg[@"DNS2"];
            self.txPktNum = [wanCfg[@"TX_BYTES"] longLongValue];
            self.rxPktNum = [wanCfg[@"RX_BYTES"] longLongValue];
            NSNumber *value = wanCfg[@"WAN_INET_STAT"];
            if(value == nil)
            {
                self.WAN_INET_STAT = 0;
            }
            else
            {
                self.WAN_INET_STAT = [value intValue];
            }
            
            NSNumber *typeValue = wanCfg[@"WAN_TYPE"];
            if(typeValue == nil)
            {
                self.current_online_way = @"";
            }
            else
            {
                if(typeValue.intValue == 0)
                {
                    self.current_online_way = @"dhcp";
                }
                else if(typeValue.intValue == 1)
                {
                    self.current_online_way = @"静态ip";
                }
                else
                {
                    self.current_online_way = @"pppoe拔号";
                }
            }
            return receiveDic;
        }
    }
    return nil;
}
//修改账号和密码
- (BOOL)setRouterAccountWithUsername:(NSString *)username Password:(NSString *)password WithError:(NSError **)error {
    NSData *commandJson = [NSJSONSerialization dataWithJSONObject:@{@"REQ_TYPE":@SHRequestType_SetAccount, @"USER":username, @"PASSWORD":password} options:0 error:nil];
    NSData *receviceJson = [SHDeviceConnector syncSendCommandWithIp:self.lanIp Port:self.tcpPort Username:self.username Password:self.password Command:commandJson TimeoutInSec:6.0 Error:error];
    if ((error && *error) || !receviceJson) {
        return NO;
    }
    self.username = username;
    self.password = password;
    return YES;
}
//设置wifi的ssid和密码信道
- (BOOL)setWifiWithSsid:(NSString *)ssid WifiKey:(NSString *)key Channel:(int)channel Error:(NSError **)error {
    NSData *commandJson = [NSJSONSerialization dataWithJSONObject:@{@"REQ_TYPE":@SHRequestType_SetSsid, @"SSID":ssid, @"KEY":key, @"CHANNEL":[NSNumber numberWithInt:channel]} options:0 error:nil];
    NSData *receviceJson = [SHDeviceConnector syncSendCommandWithIp:self.lanIp Port:self.tcpPort Username:self.username Password:self.password Command:commandJson TimeoutInSec:6.0 Error:error];
    if ((error && *error) || !receviceJson) {
        return NO;
    }
    self.wifiKey = key;
    self.ssid = ssid;
    self.channel = channel;
    return YES;
}

//设置lanIP和mask
- (BOOL)setLanIP:(NSString *)ip Mask:(NSString *)mask Error:(NSError **)error {
    NSData *commandJson = [NSJSONSerialization dataWithJSONObject:@{@"REQ_TYPE":@SHRequestType_SetLan, @"IP":ip, @"MASK":mask} options:0 error:nil];
    NSData *receviceJson = [SHDeviceConnector syncSendCommandWithIp:self.lanIp Port:self.tcpPort Username:self.username Password:self.password Command:commandJson TimeoutInSec:6.0 Error:error];
    if ((error && *error) || !receviceJson) {
        return NO;
    }
    self.lanIp= ip;
    self.LanMask = mask;
    return YES;
}

- (BOOL)setWanPPPoEWithUsername:(NSString *)pppoeUsername Password:(NSString *)pppoePassword Error:(NSError **)error {
    NSDictionary *cfgDic = @{@"UserName":pppoeUsername, @"PassWd": pppoePassword};
    BOOL ret = [self setWanWithType:WanConfigTypePPPOE ConfigDic:cfgDic Error:error];
    if (ret) {
        self.currentWanCfgType = WanConfigTypePPPOE;
        self.pppoeUsername = pppoeUsername;
        self.pppoePassword= pppoePassword;
    }
    return  ret;
}

- (BOOL)setWanDHCPWithError:(NSError **)error {
    NSDictionary *cfgDic = @{};
    BOOL ret = [self setWanWithType:WanConfigTypeDHCP ConfigDic:cfgDic Error:error];
    if (ret) {
        self.currentWanCfgType = WanConfigTypeDHCP;
    }
    return  ret;
}
- (BOOL)setWanStaticIPWithIP:(NSString *)wanIp Mask:(NSString *)wanMask Gateway:(NSString *)wanGateway Dns1:(NSString *)dns1 Dns2:(NSString *)dns2 Error:(NSError **)error {
    
    NSDictionary *cfgDic = @{@"IP": wanIp, @"MASK": wanMask, @"GATEWAY": wanGateway, @"DNS1": dns1, @"DNS2": dns2};
    BOOL ret = [self setWanWithType:WanConfigTypeStatic ConfigDic:cfgDic Error:error];
    if (ret) {
        self.currentWanCfgType = WanConfigTypeStatic;
        self.wanIp = wanIp;
        self.wanMask = wanMask;
        self.wanGateway = wanGateway;
        self.dns1 = dns1;
        self.dns2 = dns2;
    }
    return  ret;
}

#pragma mark - Tools
#pragma mark -

- (BOOL)setWanWithType:(_WanConfigType)type ConfigDic:(NSDictionary *)dic Error:(NSError **)error {
    NSData *commandJson = [NSJSONSerialization dataWithJSONObject:@{@"REQ_TYPE":@SHRequestType_SetWan, @"WAN_TYPE":[NSNumber numberWithInt:type], @"WAN_CFG":dic} options:0 error:nil];
    NSData *receviceJson = [SHDeviceConnector syncSendCommandWithIp:self.lanIp Port:self.tcpPort Username:self.username Password:self.password Command:commandJson TimeoutInSec:6.0 Error:error];
    if ((error && *error) || !receviceJson) {
        return NO;
    }
    return YES;
}
#pragma mark - Properties
#pragma mark -
- (struct sockaddr_in)hostAddr {
    NSString *ip = self.lanIp ? self.lanIp : @"192.168.0.1";
    unsigned short tcpPort = self.tcpPort == 0 ? 10246 : self.tcpPort;
    struct sockaddr_in deviceAddr;
    bzero(&deviceAddr, sizeof(deviceAddr));
    deviceAddr.sin_family = AF_INET;
    deviceAddr.sin_port = htons(tcpPort);
    deviceAddr.sin_len = sizeof(deviceAddr);
    inet_pton(AF_INET, [ip UTF8String], &deviceAddr.sin_addr.s_addr);
    return deviceAddr;
}


-(BOOL)getOnlineWay:(NSError **)error
{
    NSData *commandJson = [NSJSONSerialization dataWithJSONObject:@{@"REQ_TYPE":@SHRequestType_GetOnlineWay, @"DETECT":@0} options:0 error:nil];
    NSData *receiveJson = [SHDeviceConnector syncSendCommandWithIp:self.lanIp Port:self.tcpPort Username:self.username Password:self.password Command:commandJson TimeoutInSec:6.0 Error:error];
    if ((error && *error) || !receiveJson) {
        self.onlineWay = -2;
        return NO;
    }
    else
    {
        NSDictionary * receiveDic = [NSJSONSerialization JSONObjectWithData:receiveJson options:0 error:0];
        int wan_state = [receiveDic[@"WAN_STAT"] intValue];
        if(wan_state == 3)
        {
            //wan口未连接
            self.onlineWay = -1;
        }
        else if(wan_state != 2)
        {
            self.onlineWay = -2;
        }
        else
        {
            self.onlineWay = [receiveDic[@"WAN_TYPE"] intValue];
        }
        return YES;
    }
}

-(NSDictionary *)detectOnlineWay:(NSError **)error
{
    NSData *commandJson = [NSJSONSerialization dataWithJSONObject:@{@"REQ_TYPE":@SHRequestType_GetOnlineWay, @"DETECT":@1} options:0 error:nil];
   NSData *receiveData = [SHDeviceConnector syncSendCommandWithIp:self.lanIp Port:self.tcpPort Username:self.username Password:self.password Command:commandJson TimeoutInSec:6.0 Error:error];
    if((error && *error) || receiveData == nil)
    {
        return nil;
    }
    else
    {
        NSDictionary *dic  = [NSJSONSerialization JSONObjectWithData:receiveData options:0 error:nil];
        return dic;
    }
    
}


-(NSDictionary*)getWanInfo:(NSError **)error
{
    NSData *commandJson = [NSJSONSerialization dataWithJSONObject:@{@"REQ_TYPE":@SHRequestType_GetWanInfo} options:0 error:nil];
    
    NSData *reciveData = [SHDeviceConnector syncSendCommandWithIp:self.lanIp Port:self.tcpPort Username:self.username Password:self.password Command:commandJson TimeoutInSec:6.0 Error:error];
    if((error && *error) || reciveData == nil)
    {
        self.wanInfo = nil;
        return nil;
    }
    else
    {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:reciveData options:0 error:nil];
        self.wanInfo = dic;
        return dic;
    }
}

-(NSString*)getBackupInfo:(NSError *__autoreleasing *)error
{
    NSData *commandJson = [NSJSONSerialization dataWithJSONObject:@{@"REQ_TYPE":@SHRequestType_BackupOrRestore, @"SET":@0} options:0 error:nil];
    NSData *receiveData = [SHDeviceConnector syncSendCommandWithIp:self.lanIp Port:self.tcpPort Username:self.username Password:self.password Command:commandJson TimeoutInSec:6.0 Error:error];
    if((error && *error) || receiveData == nil)
    {
        return nil;
    }
    else{
        return  [[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
    }
}

-(BOOL)restoreBackupInfo:(NSError *__autoreleasing *)error
{
    //获取备份数据
    NSString *backupInfo = [UserDefaultUtil getStringForKey:self.mac defaultValue:nil];
    if(backupInfo == nil)
    {
        return false;
    }
    NSMutableString *mutableBackupInfo = [NSMutableString stringWithString:backupInfo];
    //将RSP_TYPE替换为REQ_TYPE
    [mutableBackupInfo replaceOccurrencesOfString:@"RSP_TYPE" withString:@"REQ_TYPE" options:NSLiteralSearch range:(NSMakeRange(0, mutableBackupInfo.length))];
    
    //添加set
    [mutableBackupInfo insertString:@"\"SET\":1," atIndex:1];
    DLog(@"backup Info = %@", mutableBackupInfo);
    
    NSData *commandJson = [mutableBackupInfo dataUsingEncoding:NSUTF8StringEncoding];
    [SHDeviceConnector syncSendCommandWithIp:self.lanIp Port:self.tcpPort Username:self.username Password:self.password Command:commandJson TimeoutInSec:6.0 Error:error];
    if(error && *error)
    {
        return false;
    }
    return true;
}

@end
