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
#import "ProcessController.h"
#import <pop/POP.h>
#import "CircleView.h"
#import "CaptureButton.h"
#import "PresentingAnimationController.h"
#import "DismissingAnimationController.h"
#import "Reprocess.h"


@interface CameraView : UIViewController <DJIDroneDelegate, GroundStationDelegate, DJICameraDelegate,UIViewControllerTransitioningDelegate, UIAlertViewDelegate, DJIMainControllerDelegate,RestartCameraFeedDelegate>
{
    DJIDrone* _drone;
    DJICamera* _camera;
    
    UILabel* _connectionStatusLabel;
    BOOL connection;
    BOOL _gimbalAttitudeUpdateFlag;
    BOOL shootPan;
    BOOL readyForShoot;
    int flightMode;

    NSObject<DJIGroundStation>* _groundStation;
    CLLocationCoordinate2D _homeLocation;
    CLLocationCoordinate2D _CurrentDroneLocation;
    
    NSTimer* _readBatteryInfoTimer;

    
    UIView *mask;
    
    int total_images;
    int wp_idx;
    double currentAltitude;
    double currentYaw;
    double PanoSpanAngle;
    int direction;
    
    MBProgressHUD *connectionHud;

    bool cameraSettingsShown;
    NSArray *ExposureSettings;
    NSArray *ExposureSettingString;
    NSArray *ContrastSettingString;
    NSArray *SharpnessSettingString;
    NSArray *WhiteBalanceString;
    int currentExposure;
    int currentContrast;
    int currentSharpness;
    int currentWB;
    
    
}

@property (strong, nonatomic) IBOutlet CircleView *cirlce;
@property(nonatomic, retain) IBOutlet UIView* videoPreviewView;
@property(nonatomic, retain) IBOutlet UIVisualEffectView* cameraSettingsView;
@property(nonatomic, retain) IBOutlet UILabel* settingValue;

@property(nonatomic, strong) IBOutlet CaptureButton *captureBtn;
@property(nonatomic, strong) IBOutlet UIButton *panUpBtn;
@property(nonatomic, strong) IBOutlet UIButton *panDownBtn;
@property(nonatomic, strong) IBOutlet UIButton *ProcessBtn;


@property(nonatomic, strong) IBOutlet UIBarButtonItem *barStatus;
@property(nonatomic, strong) IBOutlet UIBarButtonItem *satCount;
@property(nonatomic, strong) IBOutlet UIBarButtonItem *battery;
@property(nonatomic, strong) IBOutlet UIBarButtonItem *reprocessItem;


-(void)setup;

-(IBAction)presentProcessingView:(id)sender;
-(IBAction)showSettings:(id)sender;

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
