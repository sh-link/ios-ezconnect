//
//  SHRouter.h
//  SHLink
//
//  Created by 钱凯 on 15/1/22.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "SHDevice.h"

typedef NS_ENUM(int, _WanConfigType) {
    WanConfigTypePPPOE = 1,
    WanConfigTypeDHCP = 2,
    WanConfigTypeStatic = 3,
};

@interface SHRouter : SHDevice

@property (nonatomic, copy) NSString* selfMac;

@property (nonatomic) BOOL loginNeedDismiss;

@property (nonatomic) BOOL directLogin;

@property (nonatomic) struct sockaddr_in hostAddr;

@property (nonatomic) unsigned short tcpPort;

@property (nonatomic, copy) NSMutableArray *clientList;

@property (nonatomic, copy) NSArray *SlaveList;

@property (nonatomic) BOOL wanIsConnected;

@property (nonatomic, copy) NSString *LanMask;

@property (nonatomic, copy) NSString *wanMask;

@property (nonatomic, copy) NSString *wanGateway;

@property (nonatomic, copy) NSString *dns1;

@property (nonatomic, copy) NSString *dns2;

@property (nonatomic, assign) int WAN_INET_STAT;

@property (nonatomic) long long txPktNum;

@property (nonatomic) long long rxPktNum;

@property (nonatomic) NSString *current_online_way;

@property (nonatomic, copy) NSString *ssid;

@property (nonatomic) int channel;

@property (nonatomic, copy) NSString *wifiKey;

@property (nonatomic) _WanConfigType currentWanCfgType;

@property (nonatomic, strong) NSString *pppoeUsername;

@property (nonatomic, strong) NSString *pppoePassword;

@property (nonatomic) int onlineWay;

@property (nonatomic, copy) NSString * onlineWayStr;

//wifi定时相关信息
@property (nonatomic, strong) NSMutableArray* wifiClocks;
@property (nonatomic) BOOL  wlanSchedState;

//父母控制定时相关信息
@property (nonatomic, strong) NSMutableArray* parentControlWifiClocks;
@property (nonatomic) BOOL parentControlWlanSchedState;


@property (nonatomic, strong) NSDictionary* wanInfo;


//获取路由器实例，单例
+(instancetype)currentRouter;
//更新路由器信息
- (BOOL)updateRouterInfo;
/**
 *获取处于父母控制列表中的设备
 */
-(NSMutableArray*)getDevicesInParentControl:(NSError **)error;
/**
 *获取mac地址为mac的路由器上的终端设备列表
 */
-(NSMutableArray*)getTerminalWithMac:(NSString*)mac error:(NSError**)error;
/**
 *获取主路由器上的终端列表
 */
- (NSMutableArray *)getClientListWithError:(NSError **)error;
/**
 *获取slave路由器列表
 */
-(NSArray *)getSlaveListWithError:(NSError**)error;
/**
 *获取网络信息
 */
- (NSDictionary *)getNetworkSettingInfoWithError:(NSError **)error;
/**
 *设置路由器登陆账号和密码
 */
- (BOOL)setRouterAccountWithUsername:(NSString *)username Password:(NSString *)password WithError:(NSError **)error;
/**
 *设置wifi名称，连接密码和通信信道
 */
- (BOOL)setWifiWithSsid:(NSString *)ssid WifiKey:(NSString *)key Channel:(int)channel Error:(NSError **)error;
/**
 *设置lan端口ip地址,mask掩码
 */
- (BOOL)setLanIP:(NSString *)ip Mask:(NSString *)mask Error:(NSError **)error;
/**
 *pppoe拨号设置
 */
- (BOOL)setWanPPPoEWithUsername:(NSString *)pppoeUsername Password:(NSString *)pppoePassword Error:(NSError **)error;

/**
 *获取pppoe拔号信息
 */
-(NSDictionary *)getWanInfo:(NSError **)error;
/**
 *dhcp设置
 */
- (BOOL)setWanDHCPWithError:(NSError **)error;

/**
 *静态ip设置
 */
- (BOOL)setWanStaticIPWithIP:(NSString *)wanIp Mask:(NSString *)wanMask Gateway:(NSString *)wanGateway Dns1:(NSString *)dns1 Dns2:(NSString *)dns2 Error:(NSError **)error;

/**
 *关闭路由器
 */
-(BOOL)closeRouter:(NSError**)error;

/**
 *获取wifi定时信息，获取的信息存在SHRouter成员变量中
 */
-(BOOL)getWifiClockInfo:(NSError**)error;

/**
 *设置wifi定时信息
 */
-(BOOL)setUpWifiClock:(NSNumber*)wlanSchedStateParam wlanSched:(NSArray*) wlanSched error:(NSError**)error;
/**
 *获取父母控制时间设置信息
 */
-(BOOL)getParentClockInfo:(NSError **)error;
/**
 *设置家长控制定时信息
 */
-(BOOL)setUpPCWifiClock:(NSNumber*)wlanSchedStateParam wlanSched:(NSArray*) wlanSched error:(NSError**)error;
/**
 *获取操作系统版本信息,type指示主路由器或者从路由器
 */
-(NSDictionary*)getOSVersionInfo:(int)type error:(NSError**)error;

/**
 *更新路由器固件, type指示主路由器或从路由器
 */
-(NSDictionary*)updateFireWare:(int)type error:(NSError**)error;
/**
 *给终端重命名
 */
-(BOOL)setClientName:(NSString *)newName mac:(NSString*)mac error:(NSError**)error;
/**
 *添加一个设备到父母控制列表
 */
-(BOOL)addClientToParentControl:(NSString*)mac name:(NSString*)name error:(NSError**)error;

/**
 *从父母控制列表里删除一个设备
 */
-(BOOL)deleteClientFromParentControl:(NSString*)mac name:(NSString*)name error:(NSError**)error;
/**
 *从父母控制列表中删除一批设备
 */
-(BOOL)deleteClients:(NSArray *)clients error:(NSError**)error;
/**
 *添加一批设备到父母控制列表中
 */
-(BOOL)addCLients:(NSArray*)clients error:(NSError**)error;
/**
 *获取所有的路由器上的终端设备，路由器返回的所有设备有时会有重复的，需要自己处理，去除重复
 */
-(NSMutableArray*)getAllClient:(NSError**)error;

/**
 *获取当前上网方式
 */
-(BOOL)getOnlineWay:(NSError **)error;
-(NSDictionary*)detectOnlineWay:(NSError **)error;

/**
 *获取需要备份的参数信息
 **/
-(NSString*)getBackupInfo:(NSError **)error;

-(BOOL)restoreBackupInfo:(NSError **)error;

@end
