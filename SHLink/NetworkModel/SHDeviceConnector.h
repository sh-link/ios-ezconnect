//
//  SHDeviceSeacher.h
//  SHLink
//
//  Created by 钱凯 on 15/1/22.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHDevice.h"
#import "ErrorUtil.h"
#define SHErrorDomain @"com.shRouter.error"



@protocol SHDeviceSearcherDelegate;

@interface SHDeviceConnector : NSObject

@property (nonatomic, weak) id<SHDeviceSearcherDelegate> delegate;

/**
 *  omnipotent Initialization
 *
 *  @param delegate delegate for callback.
 *  @param timeout  Search timeout in seconds.
 *
 *  @return Instancetype of SHDeviceSearcher.
 */
-(instancetype)initWithDelegate:(id<SHDeviceSearcherDelegate>)delegate SearchTimeoutInSec:(int)
timeout;

/**
 *  Async search device, call back with delegate.
 *
 *  @param port UDP port we search on, default is 10245.
 *
 *  @return YES if no error happens(not gurantee device found)
 */
-(BOOL)asyncSearchDeviceWithPort:(unsigned short)port;

/**
 *  Sync search device.
 *
 *  @param port UDP port we search on, default is 10245.
 *
 *  @return Nil if no device found.
 */
-(SHDevice *)syncSearchDeviceWithPort:(unsigned short)port;

/**
 *  Sync search device.
 *
 *  @param port UDP port we search on, default is 10245.
 *  @param timeout  Search timeout in seconds, default is 2sec.
 *
 *  @return Nil if no device found.
 */
+(SHDevice *)syncSearchDeviceWithPort:(unsigned short)port TimeoutInSec:(int)timeout;

/**
 *  Sync login device.
 *
 *  @param ip             IP address
 *  @param port           TCP port
 *  @param usernameString Username
 *  @param passwordString Password
 *  @param timeout        Timeout in seconds, default is 2sec.
 *  @param error          Error
 *
 *  @return YES if success.
 */
+(BOOL)syncChallengeDeviceWithIp:(NSString *)ip Port:(unsigned short)port Username:(NSString *)usernameString Password:(NSString *)passwordString TimeoutInSec:(int)timeout Error:(NSError **)error;

/**
 *  Sync send control command to SHRouter, payload is jason data.
 *
 *  @param ip             Ip address
 *  @param port           TCP port
 *  @param usernameString Login username
 *  @param passwordString Login password
 *  @param command        Command in jason data
 *  @param timeout        Timeout in seconds, default is 2sec.
 *  @param error          Error
 *
 *  @return Reply jason data if success, set error if error happens.
 */
+(NSData *)syncSendCommandWithIp:(NSString *)ip Port:(unsigned short)port Username:(NSString *)usernameString Password:(NSString *)passwordString Command:(NSData *)command TimeoutInSec:(int)timeout Error:(NSError **)error;

@end


@protocol SHDeviceSearcherDelegate <NSObject>
 
-(void)didFindDeviceWithIp:(NSString *)ip Mac:(NSString *)mac;

@end