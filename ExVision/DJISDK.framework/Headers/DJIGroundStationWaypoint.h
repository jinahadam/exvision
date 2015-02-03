//
//  DJIGroundStationWaypoint.h
//  DJISDK
//
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface DJIGroundStationWaypoint : NSObject

/**
 *  Waypoint coordinate (degree)
 */
@property(nonatomic) CLLocationCoordinate2D coordinate;

/**
 *  Altitude (meters)
 */
@property(nonatomic) float altitude;

/**
 *  Horizontal velocity (m/s)
 */
@property(nonatomic) float horizontalVelocity;

/**
 *  Staying time at waypoint (second)
 */
@property(nonatomic) int stayTime;

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
