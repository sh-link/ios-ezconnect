//
//  SHDeviceSeacher.m
//  SHLink
//
//  Created by 钱凯 on 15/1/22.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "SHDeviceConnector.h"
#import "Packet.h"
#import "md5.h"
#import "des.h"

#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <string.h>

//0xdeadbeafcafebabedeadbeafcafebabe
static unsigned char SHDesSrc[8] = {0xde,0xad,0xbe,0xaf,0xca,0xfe,0xba,0xbe};

@implementation SHDeviceConnector
{
    int _timeout;
    int _sockFd;
}

-(instancetype)initWithDelegate:(id<SHDeviceSearcherDelegate>)delegate SearchTimeoutInSec:(int)timeout {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _timeout = timeout;
    }
    return self;
}


//广播搜索路由器ip
+(SHDevice *)syncSearchDeviceWithPort:(unsigned short)port TimeoutInSec:(int)timeout {
    
    struct sockaddr_in broadcastAddr;
    int sockFd = -1;
    int ret;
    int flag;
    int broadcast = 1;
    fd_set rset;
    struct timeval tval;
    char readBuf[256];
    char ip[INET_ADDRSTRLEN];
    unsigned short _port;
    _SHDetect detectPacket;
    
    _port = port == 0 ? 10245 : port;

    sockFd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockFd < 0) {
        DLog(@"查询路由器:创建socket失败");
        return nil;
    }
    if ((ret = setsockopt(sockFd, SOL_SOCKET, SO_BROADCAST, &broadcast, sizeof(broadcast))) != 0) {
        DLog(@"查询路由器:setsocketopt失败");
        return nil;
    }
    
    flag = fcntl(sockFd, F_GETFL, 0);
    fcntl(sockFd, F_SETFL, flag | O_NONBLOCK);
    
    bzero(&broadcastAddr, sizeof(broadcastAddr));
    broadcastAddr.sin_family = AF_INET;
    broadcastAddr.sin_port = htons(_port);
    broadcastAddr.sin_addr.s_addr = htonl(INADDR_BROADCAST);
    broadcastAddr.sin_len = sizeof(broadcastAddr);
    
    bzero(&detectPacket, sizeof(detectPacket));
    *(int *)detectPacket.header.type = htonl(SHPacketType_Detect);
    DLog(@"查询路由器:即将发送广播数据")
    if (sendto(sockFd, &detectPacket, sizeof(detectPacket), 0, (struct sockaddr *)&broadcastAddr, sizeof(broadcastAddr)) <= 0) {
        close(sockFd);
        DLog(@"查询路由器:发送广播数据失败");
        return nil;
    }
    DLog(@"查询路由器:已经发送广播数据");
    tval.tv_sec = timeout;
    tval.tv_usec = 0;
    
    FD_ZERO(&rset);
    FD_SET(sockFd, &rset);
    //监听套接口是否可读
    if (select(sockFd + 1, &rset, NULL, NULL, &tval) == 0) {
        close(sockFd);
        DLog(@"查询路由器:select端口失败,读取数据超时");
        return nil;
    }
    //从套接口里读出数据
    if (recvfrom(sockFd, readBuf, sizeof(readBuf), 0, NULL, NULL) <= 0) {
        close(sockFd);
        DLog(@"查询路由器:读取数据失败");
        return nil;
    }
    DLog(@"查询路由器:成功获取路由器响应数据");
    close(sockFd);
    
    _SHDetectReply *reply = (_SHDetectReply *)readBuf;
    
    if (PACKET_CHECK_TYPE(SHPacketType_DetectReply, reply)) {
        
        SHDevice *device = [[SHDevice alloc] init];
        
        device.lanIp = [NSString stringWithUTF8String:inet_ntop(AF_INET, reply->ip, ip, INET_ADDRSTRLEN)];
        device.mac = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",reply->mac[0],reply->mac[1],reply->mac[2],reply->mac[3],reply->mac[4],reply->mac[5]];
        DLog(@"查询路由器:成功解析路由器响应数据，mac = %@ ip = %@", device.mac, device.lanIp);
        return device;
    }
    DLog(@"查询路由器：查询失败，响应类型错误");
    return nil;
}

//登陆认证
+(BOOL)syncChallengeDeviceWithIp:(NSString *)ip Port:(unsigned short)port Username:(NSString *)usernameString Password:(NSString *)passwordString TimeoutInSec:(int)timeout Error:(NSError **)error {
    
    int sockFd;
    int ret;
    fd_set rset;
    struct timeval tval;
    _SHChallenge challengePacket;
    char readBuf[256];
    _SHChallengeReply *reply;
    
    if (timeout <= 0) timeout = 2;
    if (port <= 0) port = 10246;
    
    sockFd = [self tcpConnectDeviceWithIp:ip Port:port TimeoutInSec:timeout];
    if (sockFd < 0) {
        if (error)
        {
            *error = [NSError errorWithDomain:SHErrorDomain code:SHError_Unreachable userInfo:@{NSLocalizedDescriptionKey: @"Can not connect to the router."}];
        }
        DLog(@"登陆认证失败：can not connect to the router");
        return NO;
    }
    
    bzero(&challengePacket, sizeof(challengePacket));
    *(int *)challengePacket.header.type = htonl(SHPacketType_Challenge);
    *(int *)challengePacket.length = htonl(0);
    strcpy((char *)challengePacket.userId, [usernameString UTF8String]);
    
    [self genChallengeWithUsername:usernameString Password:passwordString Output:(char *)challengePacket.challenge];
    
    DLog(@"即将发送登陆认证数据");
    if (write(sockFd, &challengePacket, sizeof(challengePacket)) < sizeof(challengePacket)) {
        if (error)
        {
            *error = [NSError errorWithDomain:SHErrorDomain code:SHError_Socket_Error userInfo:@{NSLocalizedDescriptionKey: @"Write to socket error."}];
        }
        DLog(@"发送登陆认证数据失败：can not connect to the router");
        close(sockFd);
        return NO;
    }
    
    FD_ZERO(&rset);
    FD_SET(sockFd, &rset);
    
    bzero(&tval, sizeof(tval));
    tval.tv_sec = timeout;
    tval.tv_usec = 0;
    
    if ((ret = select(sockFd + 1, &rset, NULL, NULL, &tval)) == 0) {
        //time out
        if (error) *error = [NSError errorWithDomain:SHErrorDomain code:SHError_Timeout userInfo:@{NSLocalizedDescriptionKey: @"Read socket timeout."}];
        DLog(@"登陆认证失败:read socket timeout");
        close(sockFd);
        return NO;
    }
    
    if ((ret = (int)read(sockFd, readBuf, 1024)) <= 0) {
        if (error) *error = [NSError errorWithDomain:SHErrorDomain code:SHError_Socket_Error userInfo:@{NSLocalizedDescriptionKey: @"Read socket error."}];
        DLog(@"登陆认证失败:read socket error");
        close(sockFd);
        return NO;
    }
    
    reply = (_SHChallengeReply *)readBuf;
    
    if (PACKET_CHECK_TYPE(SHPacketType_ChallengeReply, reply)) {
        int status = ntohl(*(int *)reply->status);
        switch (status) {
            case SHControlStatus_UserNotExist:
                if (error) *error = [NSError errorWithDomain:SHErrorDomain code:SHError_User_Not_Exist userInfo:@{NSLocalizedDescriptionKey: @"User not exist."}];
                DLog(@"user not exist");
                close(sockFd);
                return NO;
                break;
                
            case SHControlStatus_WrongPsw:
                if (error) *error = [NSError errorWithDomain:SHErrorDomain code:SHError_Wrong_Password userInfo:@{NSLocalizedDescriptionKey: @"Password wrong."}];
                DLog(@"password wrong");
                close(sockFd);
                return NO;
                break;
                
            case SHControlStatus_Failed:
                if (error) *error = [NSError errorWithDomain:SHErrorDomain code:SHError_Command_Failed userInfo:@{NSLocalizedDescriptionKey: @"Command failed."}];
                DLog(@"command failed");
                close(sockFd);
                return NO;
                break;
            
            case SHControlStatus_Success:
                DLog(@"登陆成功");
                close(sockFd);
                return YES;
                
            default:
                NSAssert(NO, @"Wrong reply status.");
        }
    }
 
    if (error) *error = [NSError errorWithDomain:SHErrorDomain code:SHError_Command_Failed userInfo:@{NSLocalizedDescriptionKey: @"Command failed."}];
    DLog(@"认证失败:响应数据类型错误: command failed");
    close(sockFd);
    return NO;
}

/*
 *发送各种与路由器通信的命令
 *
 */
+(NSData *)syncSendCommandWithIp:(NSString *)ip Port:(unsigned short)port Username:(NSString *)usernameString Password:(NSString *)passwordString Command:(NSData *)command TimeoutInSec:(int)timeout Error:(NSError **)error {
    
    int sockFd;
    int ret;
    fd_set rset;
    struct timeval tval;
    size_t packetSize;
    _SHControl *controlPacket;
    char readBuf[1024];
    _SHChallengeReply *reply;
    
    if (timeout <= 0) timeout = 2;
    if (port <= 0) port = 10246;
    
    sockFd = [self tcpConnectDeviceWithIp:ip Port:port TimeoutInSec:timeout];
    if (sockFd < 0) {
        if (error) *error = [NSError errorWithDomain:SHErrorDomain code:SHError_Unreachable userInfo:@{NSLocalizedDescriptionKey: @"Can not connect to the router."}];
        DLog(@"无法连接连到路由器");
        return nil;
    }
    
    packetSize = sizeof(_SHControl) + command.length;
    controlPacket = malloc(packetSize);
    
    bzero(controlPacket, packetSize);
    *(int *)controlPacket->header.type = htonl(SHPacketType_Control);
    *(int *)controlPacket->length = htonl(command.length);
    strcpy((char *)controlPacket->userId, [usernameString UTF8String]);
    memcpy((void *)controlPacket->content, [command bytes], command.length);
    
    [self genChallengeWithUsername:usernameString Password:passwordString Output:(char *)controlPacket->challenge];
    
    DLog(@"即将发送命令");
    if (write(sockFd, controlPacket, packetSize) < packetSize) {
        if (error) *error = [NSError errorWithDomain:SHErrorDomain code:SHError_Socket_Error userInfo:@{NSLocalizedDescriptionKey: @"Write to socket error."}];
        DLog(@"发送命令失败:write to socket error");
        close(sockFd);
        return nil;
    }
    DLog(@"已经发送命令:%@", [[NSString alloc]initWithData:command encoding:NSUTF8StringEncoding]);
    FD_ZERO(&rset);
    FD_SET(sockFd, &rset);
    
    bzero(&tval, sizeof(tval));
    tval.tv_sec = timeout;
    tval.tv_usec = 0;
    DLog(@"正在等待路由器响应");
    if ((ret = select(sockFd + 1, &rset, NULL, NULL, &tval)) == 0) {
        if (error) *error = [NSError errorWithDomain:SHErrorDomain code:SHError_Timeout userInfo:@{NSLocalizedDescriptionKey: @"Read socket timeout."}];
        DLog(@"等待响应超时:read socket timeout");
        close(sockFd);
        return nil;
    }
    
    if ((ret = (int)read(sockFd, readBuf, 1024)) <= 0) {
        if (error) *error = [NSError errorWithDomain:SHErrorDomain code:SHError_Socket_Error userInfo:@{NSLocalizedDescriptionKey: @"Read socket error."}];
        close(sockFd);
        DLog(@"读取响应失败: read socket error");
        return nil;
    }
    
    reply = (_SHControlRely *)readBuf;

    DLog(@"成功获取响应数据");
    
    int status = ntohl(*(int *)reply->status);
    DLog(@"响应状态码为:%d", status);
    if (status != 0) {
        if (error)
        {
            *error = [NSError errorWithDomain:SHErrorDomain code:status userInfo:@{NSLocalizedDescriptionKey: @"Control failed!"}];
        }
        close(sockFd);
        DLog(@"该命令执行失败:响应状态码为%d", status);
        return nil;
    }
    else
    {
        NSData *jsonData = [NSData dataWithBytes:reply->content length:ntohl(*(int *)reply->length)];
        DLog(@"已经收到响应:%@", [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
        close(sockFd);
        return jsonData;
    }
}

#pragma mark - Tools
#pragma mark -

/**
 *  Generate SHRouter login challenge bytes.
 *
 *  @param usernameString username in NSString
 *  @param passwordString password in NSString
 *  @param output         output buffer pointer, at least 8 bytes long, malloced by caller.
 *  //根据用户名和密码生成挑战字段
 */
+ (void)genChallengeWithUsername:(NSString *)usernameString Password:(NSString *)passwordString Output:(char *)output {
    char userID[16], password[16];
    md5_byte_t digest[16];
    md5_state_t mst;

    
    bzero(userID, 16);
    bzero(password, 16);
    strcpy(userID, [usernameString UTF8String]);
    strcpy(password, [passwordString UTF8String]);
    
    bzero(digest, 16);
    md5_init(&mst);
    md5_append(&mst, (unsigned char *)userID, 16);
    md5_append(&mst, (unsigned char *)password, 16);
    md5_finish(&mst, digest);
    
    des((const char *)SHDesSrc, (const char *)digest, (const char *)output, DES_ENCRYPT);
}

/**
 *  Connect to device with tcp socket.
 *
 *  @param ipString ip address in string like @"192.168.0.1"
 *  @param port     tcp port
 *  @param timeout  timeout in seconds
 *
 *  @return tcp socketfd, -1 if failed.
 *  根据指定的ip和端口号创建sokcet,并设置超时时间
 *
 */
+ (int)tcpConnectDeviceWithIp:(NSString *)ipString Port:(unsigned short)port TimeoutInSec:(int)timeout {
    struct sockaddr_in deviceAddr;
    int sockFd;
    int flag;
    int ret;
    fd_set wset;
    struct timeval tval;
    
    sockFd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockFd <= 0) {
        DLog(@"创建socket失败");
        return -1;
    }
    
    flag = fcntl(sockFd, F_GETFL, 0);
    fcntl(sockFd, F_SETFL, flag | O_NONBLOCK);
    
    bzero(&deviceAddr, sizeof(deviceAddr));
    deviceAddr.sin_family = AF_INET;
    deviceAddr.sin_port = htons(port);
    if (inet_pton(AF_INET, [ipString UTF8String], &deviceAddr.sin_addr.s_addr) <= 0) {
        DLog(@"ip地址转换出错");
        return -1;
    }
    deviceAddr.sin_len = sizeof(deviceAddr);
    
    if ((ret = connect(sockFd, (struct sockaddr *)&deviceAddr, sizeof(struct sockaddr_in))) < 0) {
        if (errno != EINPROGRESS) {
            close(sockFd);
            DLog(@"连接失败或超时");
            return -1;
        }
    }
    
    FD_ZERO(&wset);
    FD_SET(sockFd,&wset);
    tval.tv_sec = timeout;
    tval.tv_usec = 0;
    
    if ((ret = select(sockFd + 1, NULL, &wset, NULL, &tval)) == 0) {
        //timeout
        close(sockFd);
        DLog(@"读取socket超时");
        return -1;
    }
    if (!FD_ISSET(sockFd,&wset)) {
        close(sockFd);
        DLog(@"创建socket失败(FD_ISSET)");
        return -1;
    }
    DLog(@"成功创建了一个连接ip = %@, 并且可立即读取的socket",ipString);
    return sockFd;
}

@end
