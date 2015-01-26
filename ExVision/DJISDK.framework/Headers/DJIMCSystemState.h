//
//  DJIMCSystemState.h
//  DJISDK
//
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <DJISDK/DJIMainController.h>

typedef NS_ENUM(NSUInteger, DJIMainControllerFlightMode)
{
    ManualMode,         //Manual
    GPSMode,            //GPS
    OutOfControlMode,   //Out of control
    AttitudeMode,       //Attitude
    GoHomeMode,         //Go home
    LandingMode,        //Landing
    UnknownMode,        //Unknown
};

typedef NS_ENUM(NSUInteger, DJIMainControllerNoFlyStatus)
{
    DroneNormalFlying,          //drone normal flying
    DroneTakeOffProhibited,     //drone is in a no fly zone, take off prohibited
    DroneFroceAutoLanding,      //drone is in a no fly zone, will force landing
    DroneApproachingNoFlyZone,  //drone is approaching to a no fly zone
    DroneReachMaxFlyingHeight,  //drone had reach the max flying height
    DroneReachMaxFlyingDistance,//drone had reach the max flying distance
    DroneUnderLimitFlyZone,     //drone is in a no fly zone, the flying heigh will limited
    UnknownStatus,              //unknown status
};

@interface DJIMCSystemState : NSObject

/**
 *  Satellite count.
 */
@property(nonatomic, readonly) int satelliteCount;

/**
 *  Home location of the drone
 */
@property(nonatomic, readonly) CLLocationCoordinate2D homeLocation;

/**
 *  Current location of the drone
 */
@property(nonatomic, readonly) CLLocationCoordinate2D droneLocation;

/**
 *  Speed x (m/s)
 */
@property(nonatomic, readonly) float velocityX;

/**
 *  Speed y (m/s)
 */
@property(nonatomic, readonly) float velocityY;

/**
 *  Speed z (m/s)
 */
@property(nonatomic, readonly) float velocityZ;

/**
 *  Altitude of the drone, (0.1m)
 */
@property(nonatomic, readonly) float altitude;

/**
 *  Attitude of the drone
 */
@property(nonatomic, readonly) DJIAttitude attitude;

/**
 *  Power level of the drone: 0 - very low power warning, 1- low power warning, 2 - height power, 3 - full power
 */
@property(nonatomic, readonly) int powerLevel;

/**
 *  Whether the drone is in flying
 */
@property(nonatomic, readonly) BOOL isFlying;

/**
 *  Flight mode
 */
@property(nonatomic, readonly) DJIMainControllerFlightMode flightMode;

/**
 *  No fly status
 */
@property(nonatomic, readonly) DJIMainControllerNoFlyStatus noFlyStatus;

/**
 *  The no fly zone center coordinate
 */
@property(nonatomic, readonly) CLLocationCoordinate2D noFlyZoneCenter;

/**
 *  The no fly zone radius
 */
@property(nonatomic, readonly) int noFlyZoneRadius;

@end
