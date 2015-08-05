//
//  Packet.h
//  SHLink
//
//  Created by 钱凯 on 15/1/20.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#ifndef SHLink_Packet_h
#define SHLink_Packet_h

#define _UINT8          unsigned char
 //请求及响应头部想着字段
#define VERSION_LEN     4
#define TYPE_LEN        4
#define MAC_LEN         8
#define IP_LEN          4
#define MASK_LEN        4
#define DESC_LEN        32
#define RESE_LEN        4
#define USER_ID_LEN     16
#define CHALLENGE_LEN   8
#define LEN_LEN         4
#define STATS_LEN       4

#define SHPacketType_Detect         0x00000100
#define SHPacketType_DetectReply    0x00000101
#define SHPacketType_Challenge      0x00000200
#define SHPacketType_ChallengeReply 0x00000201
#define SHPacketType_Control        0x00000300
#define SHPacketType_ControlReply   0x00000301
//请求类型
#define SHRequestType_GetClientList         1
#define SHRequestType_SetSsid               2
#define SHRequestType_SetWan                3
#define SHRequestType_SetLan                4
#define SHRequestType_GetNetworkInfo        5
#define SHRequestType_SetAccount            6
#define SHRequestType_CheckFirmwareUpdate   7
#define SHRequestType_UpdateFirmware        8
#define SHRequestType_GetFirmwareLog        9
#define SHRequestType_SetWlanSchedule       10
#define SHRequestType_GetWifiClockInfo      11
#define SHRequestType_PowerOff              12
#define SHRequestType_GetSlaveList          13
#define SHRequestType_GetTerminalWithMac    14
#define SHRequestType_GetWanInfo            15
#define SHRequestType_SetClientName         16
#define SHRequestType_SetPanrentControlInfo 17
#define SHRequestType_getParentControlInfo 18
#define SHRequestType_AddOrDeleteParentControl 19
#define SHRequestType_GetOnlineWay 20
#define SHRequestType_GoToFactory 21
#define SHRequestType_BackupOrRestore 22

#define SHControlStatus_Success  0
#define SHControlStatus_UserNotExist  3
#define SHControlStatus_WrongPsw  4
#define SHControlStatus_Failed  5


#define PACKET_CHECK_VERSION(_version, _packet) (*(int *)(((_SHHeader *)(_packet))->version) == htonl(_version))
#define PACKET_CHECK_TYPE(_type, _packet) (*(int *)(((_SHHeader *)(_packet))->type) == htonl(_type))

#pragma pack(1)

/**
 *  Common header
 */
typedef struct SHHeader {
    _UINT8 version[VERSION_LEN];
    _UINT8 type[TYPE_LEN];
} _SHHeader;

/**
 *  UDP detect packet on port 10245
 */
typedef struct SHDetect {
    _SHHeader header;
} _SHDetect;

/**
 *  UDP detect reply packet
 */
typedef struct SHDetectReply {
    _SHHeader header;
    _UINT8 mac[MAC_LEN];
    _UINT8 ip[IP_LEN];
    _UINT8 mask[MASK_LEN];
    _UINT8 description[DESC_LEN];
} _SHDetectReply;

/**
 *  TCP challenge packet on port 10246
 */
typedef struct SHChallenge {
    _SHHeader header;
    _UINT8 reserve[RESE_LEN];
    _UINT8 userId[USER_ID_LEN];
    _UINT8 challenge[CHALLENGE_LEN];
    _UINT8 length[LEN_LEN];
    
    _UINT8 content[0];
} _SHChallenge;

/**
 *  TCP challenge reply packet
 */
typedef struct SHChallengeReply {
    _SHHeader header;
    _UINT8 reserve[RESE_LEN];
    _UINT8 status[STATS_LEN];
    _UINT8 length[LEN_LEN];
    _UINT8 content[0];
} _SHChallengeReply;

/**
 *  Device control packet
 */
typedef struct SHChallenge _SHControl;

/**
 *  Device control relay packet
 */
typedef struct SHChallengeReply _SHControlRely;

#pragma pack()

#endif
