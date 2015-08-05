//
//  ErrorUtil.h
//  SHLink
//
//  Created by zhen yang on 15/5/22.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, SHErrorCode) {
    SHError_Socket_Error = -1,
    SHError_Unreachable = -2,
    SHError_Timeout = -3,
    SHError_User_Not_Exist = 3,
    SHError_Wrong_Password = 4,
    SHError_Command_Failed = 5,
    SHError_program_erro = 6,
    SHError_wan_not_connect = 7,
    SHError_wifi_clock_setup_error = 8,
    SHError_json_format_error = 9,
    SHError_update_firmware = 10,
    SHError_get_slave_failed = 11,
    SHError_param_error = 12,
    SHError_get_ota_version_error = 13,
    SHError_get_client_from_slave_failed = 14,
    SHError_modify_client_name_failed = 15,
    SHError_unknown_error = 16,
    SHError_set_parent_control_clock_failed = 17,
    SHError_mac_format_error= 18,
    SHError_child_in_parent_control_full = 19,
    SHError_not_need_delete_child_from_parent_control = 20,
    SHError_child_has_been_in_parent_control = 21,
};
@interface ErrorUtil : NSObject
+(NSString*)doForError:(NSError *)error;
@end
