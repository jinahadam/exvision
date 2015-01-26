//
//  CameraViewController.h
//  ExVision
//
//  Created by Jinah Adam on 26/1/15.
//  Copyright (c) 2015 Jinah Adam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJIDrone.h>
#import <DJISDK/DJICamera.h>
#import <DJISDK/DJIGimbal.h>


@interface CameraViewController : UIViewController<DJICameraDelegate, DJIGimbalDelegate>
{
    DJIDrone* _drone;
    DJICamera* _camera;
    
    UILabel* _connectionStatusLabel;
    BOOL _gimbalAttitudeUpdateFlag;
    
    
    
    
}

@property(nonatomic, retain) IBOutlet UIView* videoPreviewView;


@property(nonatomic, strong) IBOutlet UILabel* attitudeLabel;
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
