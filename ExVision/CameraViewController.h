//
//  CameraViewController.h
//  ExVision
//
//  Created by Jinah Adam on 26/1/15.
//  Copyright (c) 2015 Jinah Adam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>
#import "UIButton+Bootstrap.h"



@interface CameraViewController : UIViewController <DJIDroneDelegate, GroundStationDelegate, DJICameraDelegate>
{
    DJIDrone* _drone;
    DJICamera* _camera;
    
    UILabel* _connectionStatusLabel;
    BOOL _gimbalAttitudeUpdateFlag;
    BOOL shootPan;

    

    NSObject<DJIGroundStation>* _groundStation;
    CLLocationCoordinate2D _homeLocation;
    CLLocationCoordinate2D _CurrentDroneLocation;
    int wp_idx;
    
    double currentAltitude;
    double currentYaw;

    
}

@property(nonatomic, retain) IBOutlet UIView* videoPreviewView;
@property(nonatomic, strong) IBOutlet UIBarButtonItem *barStatus;
@property(nonatomic, strong) IBOutlet UIBarButtonItem *barAlt;
@property(nonatomic, strong) IBOutlet UIBarButtonItem *satCount;
@property(nonatomic, strong) IBOutlet UIButton *captureBtn;
@property(nonatomic, strong) IBOutlet UIButton *panUpBtn;
@property(nonatomic, strong) IBOutlet UIButton *panDownBtn;
@property(nonatomic, strong) IBOutlet UIButton *ProcessBtn;






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
