//
//  DJIError.h
//  DJISDK
//
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ERR_Successed                         0x00

#define ERR_NotSupport                        0x01
#define ERR_NotActivation                     0x02
#define ERR_ActivationFailed                  0x03
#define ERR_NoPermission                      0x04

#define ERR_InvalidSSID                       0x10
#define ERR_SendFailed                        0x11
#define ERR_ConnectFailed                     0x12
#define ERR_InvalidParameter                  0x13

#define ERR_NotSupportedCommand               0xE0
#define ERR_Timeout                           0xE1
#define ERR_MemoryAllocFailed                 0xE2
#define ERR_InvalidCommand                    0xE3
#define ERR_NotSupportNow                     0xE4
#define ERR_TimeNotSync                       0xE5
#define ERR_ParameterSetFailed                0xE6
#define ERR_ParameterGetFailed                0xE7
#define ERR_SDCardNotInserd                   0xE8
#define ERR_SDCardFull                        0xE9
#define ERR_SDCardError                       0xEA
#define ERR_SensorError                       0xEB
#define ERR_SystemError                       0xEC
#define ERR_NotDefined                        0xFF

@interface DJIError : NSObject

/**
 *  Error code. defned as "ERR_xxx"
 */
@property(nonatomic, readonly) int errorCode;

/**
 *  Error descritpion.
 */
@property(nonatomic, readonly) NSString* errorDescription;

-(id) initWithErrorCode:(int)errCode;
@end
