//
//  DJIGimbal.h
//  DJISDK
//
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DJISDK/DJIObject.h>

@class DJIGimbal;
@class DJIGimbalCapacity;

typedef struct
{
    int pitch;
    int roll;
    int yaw;
} DJIGimbalAttitude;

typedef enum
{
    RotationForward,
    RotationBackward,
} DJIGimbalRotationDirection;

typedef enum
{
    RelativeAngle,
    AbsoluteAngle,
} DJIGimbalRotationAngleType;

typedef struct
{
    /**
     *  The gimbal is rotation enable.
     */
    BOOL enable;
    
    /**
     *  The gimbal rotation angle.
     */
    int angle;
    
    /**
     *  The gimbal rotation type
     */
    DJIGimbalRotationAngleType angleType;
    
    /**
     *  The gimbal rotation direction
     */
    DJIGimbalRotationDirection direction;
} DJIGimbalRotation;

typedef enum
{
    GimbalErrorNone,
    GimbalMotorAbnormal,
    GimbalClamped,
} DJIGimbalError;


/*
 *  GimbalAttitudeResult
 *
 *  Discussion:
 *    Typedef of block to be invoked when the remote attitude data get success.
 */
typedef void (^GimbalAttitudeResultBlock)(DJIGimbalAttitude attitude);

@protocol DJIGimbalDelegate <NSObject>

@optional


/*
 *  Gimbal Error Handler
 *
 *  Discussion:
 *    error delegate to be invoked when detect a gimbal error.
 */
-(void) gimbalController:(DJIGimbal*)controller didGimbalError:(DJIGimbalError)error;

@end

@interface DJIGimbal : DJIObject

@property(nonatomic, weak) id<DJIGimbalDelegate> delegate;

/**
 *  the attitude update time interval, the value should not smaller then 25ms. default is 50ms
 */
@property(nonatomic, assign) int attitudeUpdateInterval;

/*
 *  gimbalAttitude
 *
 *  Discussion:
 *			Returns the latest gimbal attitude data, or nil if none is available.
 */
@property(nonatomic, readonly) DJIGimbalAttitude gimbalAttitude;


/**
 *  Get the gimbal's capacity.
 *
 *  @return gimbal capacity, return nil if connection failured.
 */
-(DJIGimbalCapacity*) getGimbalCapacity;

/*
 *  Starts gimbal attitude updates with no handler. To receive the latest attitude data
 *			when desired, examine the gimbalAttitude property.
 */
-(void) startGimbalAttitudeUpdates;

/*
 *	Stops gimbal attitude updates.
 */
-(void) stopGimbalAttitudeUpdates;

/*
 *  Gimbal Attitude Handler. Typedef of block to be invoked when remote gimbal attitude data is available.
 */
-(void) startGimbalAttitudeUpdateToQueue:(NSOperationQueue*)queue withResultBlock:(GimbalAttitudeResultBlock)block;

/**
 *  Set FPV mode. Typedef of block to be invoked when fpv mode is set success.
 *
 */
-(void) setGimbalFpvMode:(BOOL)isFpv withResult:(DJIExecuteResultBlock)block;

/**
 *  Set gimbal's pitch roll yaw rotation.
 *
 *  @param pitch Gimbal's pitch rotation parameter
 *  @param roll Gimbal's roll rotation parameter
 *  @param yaw Gimbal's yaw rotation parameter
 */
-(void) setGimbalPitch:(DJIGimbalRotation)pitch Roll:(DJIGimbalRotation)roll Yaw:(DJIGimbalRotation)yaw withResult:(DJIExecuteResultBlock)block;

@end
