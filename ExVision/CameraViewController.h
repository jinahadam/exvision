//
//  CameraViewController.h
//  ExVision
//
//  Created by Jinah Adam on 26/1/15.
//  Copyright (c) 2015 Jinah Adam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>



@interface CameraViewController : UIViewController <DJIDroneDelegate, GroundStationDelegate, DJICameraDelegate, DJISDCardOperation>
{
    DJIDrone* _drone;
    DJICamera* _camera;
    
    UILabel* _connectionStatusLabel;
    BOOL _gimbalAttitudeUpdateFlag;
    BOOL shootPan;

    

    NSObject<DJIGroundStation>* _groundStation;
    CLLocationCoordinate2D _homeLocation;
    NSString *wp_index;
    
    double currentAltitude;

    
}

@property(nonatomic, retain) IBOutlet UIView* videoPreviewView;
@property(nonatomic, strong) IBOutlet UILabel* logLabel;
@property(nonatomic, strong) IBOutlet UILabel* attitudeLabel;


/**
 *
 * Debug Outlets
 *
 */

@property(nonatomic, strong) IBOutlet UILabel* homeLocationLabel;
@property(nonatomic, strong) IBOutlet UILabel* droneLocation;
@property(nonatomic, strong) IBOutlet UILabel* targetWP;
@property(nonatomic, strong) IBOutlet UILabel* altitude;
@property(nonatomic, strong) IBOutlet UILabel* targetAltitude;

@property(nonatomic, strong) IBOutlet UILabel* WaypointAltitude;



/**
 *  Gimbal
 *
 */
-(IBAction) onGimbalScrollUpTouchDown:(id)sender;

-(IBAction) onGimbalScrollUpTouchUp:(id)sender;

-(IBAction) onGimbalScroollDownTouchDown:(id)sender;

-(IBAction) onGimbalScroollDownTouchUp:(id)sender;

-(IBAction) onGimbalYawRotationForwardTouchDown:(id)sender;

-(IBAction) onGimbalYawRotationForwardTouchUp:(id)sender;

-(IBAction) onGimbalYawRotationBackwardTouchDown:(id)sender;

-(IBAction) onGimbalYawRotationBackwardTouchUp:(id)sender;

-(IBAction) onGimbalAttitudeUpdateTest:(id)sender;






@end
