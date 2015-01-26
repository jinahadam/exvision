//
//  DJITypeDef.h
//  DJISDK
//
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    CameraSingleCapture,
    CameraMultiCapture,
    CameraContinousCapture,
} CameraCaptureMode;

typedef enum
{
    Video320x24015fps                       = 0x01,
    Video320x24030fps                       = 0x02,
    Video640x48015fps                       = 0x03,
    Video640x48030fps                       = 0x04,
} VideoQuality;

typedef enum
{
    CameraCameraMode                        = 0x00,
    CameraUSBMode                           = 0x01,
    CameraModeUnknown                       = 0xFF
} CameraMode;

typedef enum
{
    CameraPhotoSizeDefault                  = 0x00,
    CameraPhotoSize4384x3288                = 0x01,
    CameraPhotoSize4384x2922                = 0x02,
    CameraPhotoSize4384x2466                = 0x03,
    CameraPhotoSize4608x3456                = 0x04,
    CameraPhotoSizeUnknown                  = 0xFF
} CameraPhotoSizeType;

typedef enum
{
    CameraISOAuto                           = 0x00,
    CameraISO100                            = 0x01,
    CameraISO200                            = 0x02,
    CameraISO400                            = 0x03,
    CameraISO800                            = 0x04,
    CameraISO1600                           = 0x05,
    CameraISO3200                           = 0x06,
    CameraISOUnknown                        = 0xFF
} CameraISOType;

typedef enum
{
    CameraWhiteBalanceAuto                  = 0x00,
    CameraWhiteBalanceSunny                 = 0x01,
    CameraWhiteBalanceCloudy                = 0x02,
    CameraWhiteBalanceIndoor                = 0x03,
    CameraWhiteBalanceUnknown               = 0xFF
} CameraWhiteBalanceType;

typedef enum
{
    CameraExposureMeteringCenter            = 0x00,
    CameraExposureMeteringAverage           = 0x01,
    CameraExposureMeteringPoint             = 0x02,
    CameraExposureMeteringUnknown           = 0xFF
} CameraExposureMeteringType;

typedef enum
{
    CameraRecordingResolutionDefault        = 0x00,
    CameraRecordingResolution640x48030p     = 0x01,
    CameraRecordingResolution1280x72030p    = 0x02,
    CameraRecordingResolution1280x72060p    = 0x03,
    CameraRecordingResolution1280x96030p    = 0x04,
    CameraRecordingResolution1920x108030p   = 0x05,
    CameraRecordingResolution1920x108060i   = 0x06,
    CameraRecordingResolution1920x108025p   = 0x07,
    CameraRecordingResolution1280x96025p    = 0x08,
    CameraRecordingResolutionUnknown        = 0xFF
} CameraRecordingResolutionType;

typedef enum
{
    CameraRecordingFOV0                     = 0x00,
    CameraRecordingFOV1                     = 0x01,
    CameraRecordingFOV2                     = 0x02,
    CameraRecordingFOVUnknown               = 0xFF
} CameraRecordingFovType;


typedef enum
{
    CameraPhotoRAW                          = 0x00,
    CameraPhotoJPEG                         = 0x01,
    CameraPhotoFormatUnknown                = 0xFF
} CameraPhotoFormatType;

typedef enum
{
    CameraExposureCompensationDefault       = 0x00,
    CameraExposureCompensationN20           = 0x01,
    CameraExposureCompensationN17           = 0x02,
    CameraExposureCompensationN13           = 0x03,
    CameraExposureCompensationN10           = 0x04,
    CameraExposureCompensationN07           = 0x05,
    CameraExposureCompensationN03           = 0x06,
    CameraExposureCompensationN00           = 0x07,
    CameraExposureCompensationP03           = 0x08,
    CameraExposureCompensationP07           = 0x09,
    CameraExposureCompensationP10           = 0x0A,
    CameraExposureCompensationP13           = 0x0B,
    CameraExposureCompensationP17           = 0x0C,
    CameraExposureCompensationP20           = 0x0D,
    CameraExposureCompensationUnknown       = 0xFF
} CameraExposureCompensationType;

typedef enum
{
    CameraAntiFlickerAuto                   = 0x00,
    CameraAntiFlicker60Hz                   = 0x01,
    CameraAntiFlicker50Hz                   = 0x02,
    CameraAntiFlickerUnknown                = 0xFF
} CameraAntiFlickerType;

typedef enum
{
    CameraSharpnessStandard                 = 0x00,
    CameraSharpnessHard                     = 0x01,
    CameraSharpnessSoft                     = 0x02,
    CameraSharpnessUnknown                  = 0xFF
} CameraSharpnessType;

typedef enum
{
    CameraContrastStandard                  = 0x00,
    CameraContrastHard                      = 0x01,
    CameraContrastSoft                      = 0x02,
    CameraContrastUnknown                   = 0xFF
} CameraContrastType;

typedef enum
{
    CameraKeepCurrentState                  = 0x00,
    CameraEnterContiuousShooting            = 0x01,
    CameraEnterRecording                    = 0x02,
    CameraActionUnknown                     = 0xFF
} CameraActionWhenBreak;

typedef enum
{
    CameraMultiCapture3                     = 0x03,
    CameraMultiCapture5                     = 0x05,
    CameraMultiCaptureUnknown               = 0xFF
} CameraMultiCaptureCount;

typedef struct
{
    /**
     *  value(1 ~ 254) indicate continuous capture photo count, when the camera complete take the specified photo count, it will stop automatically
     *  value(255) indicate the camera will constantly take photo unless user stop take photo manually
     */
    uint8_t contiCaptureCount;
    
    /**
     *  time interval between two capture action. 1 ~ 65535
     */
    uint16_t timeInterval;
} CameraContinuousCapturePara;
