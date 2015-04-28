//
//  CameraViewController.m
//  ExVision
//
//  Created by Jinah Adam on 26/1/15.
//  Copyright (c) 2015 Jinah Adam. All rights reserved.
//

#import "CameraView.h"
#import "VideoPreviewer.h"
#import <DJISDK/DJISDK.h>
#import <DJISDK/DJISDCardOperation.h>
#import <DJISDK/DJIBattery.h>
#import "Settings.h"

#define YAW_180 140
#define YAW_360 120
#define PANO_SHOTS 7

@interface CameraView ()

@end

@implementation CameraView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    NSLog(@"view did load");
 
    [self setup];
}

-(void)restartCameraFeed {
    [mask removeFromSuperview];
 
    
    
    
    _drone = [[DJIDrone alloc] initWithType:DJIDrone_Phantom];

    _camera = _drone.camera;
    _camera.delegate = self;
    _groundStation = _drone.mainController;
    _groundStation.groundStationDelegate = self;
    _drone.mainController.mcDelegate = self;
    
    
    [_drone.mainController startUpdateMCSystemState];
    [_camera startCameraSystemStateUpdates];
    [[VideoPreviewer instance] start];
    
    [_drone connectToDrone];
    [[VideoPreviewer instance] setView:self.videoPreviewView];


}

-(void)setup {
    
    

    self.navigationItem.title = @"Phantom Pano";

    
    
    _drone = [[DJIDrone alloc] initWithType:DJIDrone_Phantom];
    _camera = _drone.camera;
    _camera.delegate = self;
    _groundStation = _drone.mainController;
    _groundStation.groundStationDelegate = self;
    _drone.mainController.mcDelegate = self;
    
    
    [_drone.mainController startUpdateMCSystemState];
    [_camera startCameraSystemStateUpdates];
    [[VideoPreviewer instance] start];
    
    
    currentAltitude = 0;
    shootPan = false;
    wp_idx = -1;
    connection = false;
    
    
    total_images = 0;
    
    [self.panDownBtn warningStyle];
    [self.panUpBtn warningStyle];
    [self.ProcessBtn dangerStyle];
    
    [self.cirlce setStrokeColor:[UIColor colorWithRed:240/255.0 green:173/255.0 blue:78/255.0 alpha:1]];
    [self.cirlce setStrokeEnd:0.0 animated:NO];
    
    
    
    _readBatteryInfoTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(onReadBatteryInfoTimerTicked:) userInfo:nil repeats:YES];
    
    PanoSpanAngle = 26;
    
    //settings
    [self loadSettings];
    
    [mask setHidden:YES];
}
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [_drone connectToDrone];
    [[VideoPreviewer instance] setView:self.videoPreviewView];
    
}


-(void)loadSettings {
    NSMutableArray *settingsArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"]mutableCopy];
    
    if ((int)settingsArray.count == 0) {
        //first time. create defaut settings
        NSArray *settings = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:180], nil];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:settings forKey:@"settings"];
        [userDefaults synchronize];
        NSLog(@"settings saved");
    } else { //load settings
        
        direction = (int)[[settingsArray objectAtIndex:0] integerValue];
        
        if (direction == 0) {
            NSLog(@"Right");
        } else {
            NSLog(@"Left");
        }
        
        NSNumber *scale = [settingsArray objectAtIndex:1];
        if ([scale integerValue] == 180)
        {
            PanoSpanAngle = 14;
            NSLog(@"180");
        } else {
            PanoSpanAngle = 27;
            NSLog(@"360");
            
        }
        
        
        
    }

}


-(IBAction)showSettings:(id)sender {
    

    
    
    Settings *modalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Settings"];
    modalVC.transitioningDelegate = self;
    modalVC.modalPresentationStyle = UIModalPresentationCustom;
    [self.navigationController presentViewController:modalVC animated:YES completion:nil];
    
    
    
}

#pragma mark - UIViewControllerTransitionDelegate -

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [[PresentingAnimationController alloc] init];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    
    [self performSelector:@selector(restartCameraFeed) withObject:nil afterDelay:0.5];
    return [[DismissingAnimationController alloc] init];
}
-(IBAction)presentProcessingView:(id)sender
{

    mask = [[UIView alloc] initWithFrame:self.view.frame];
    [mask setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.95]];
    [self.view addSubview:mask];
    
    

    
    _drone.delegate = Nil;
    _groundStation.groundStationDelegate = nil;
    
    [_camera stopCameraSystemStateUpdates];
    [_drone disconnectToDrone];
    [[VideoPreviewer instance] setView:nil];
    [_connectionStatusLabel removeFromSuperview];
    [_drone.mainController stopUpdateMCSystemState];
    
    [_drone destroy];



  //  [self performSegueWithIdentifier:@"processingSegue" sender:self];
    Settings *modalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"processingSegue"];
    modalVC.transitioningDelegate = self;
    modalVC.modalPresentationStyle = UIModalPresentationCustom;
    [self.navigationController presentViewController:modalVC animated:YES completion:nil];
    
    

}



-(void) onReadBatteryInfoTimerTicked:(id)timer
{
    
    @try {
        [_drone.smartBattery updateBatteryInfo:^(DJIError *error) {
            if (error.errorCode == ERR_Successed) {
                
                self.battery.title = [NSString stringWithFormat:@"Battery: %ld%%", (long)_drone.smartBattery.remainPowerPercent];
            }
            else
            {
               // NSLog(@"update BatteryInfo Failed %d", error.errorCode);
            }
        }];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
  
}



-(void) dealloc
{
    [_drone destroy];
}


-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _drone.delegate = Nil;
    _groundStation.groundStationDelegate = nil;
    
    [_camera stopCameraSystemStateUpdates];
    [_drone disconnectToDrone];
    [[VideoPreviewer instance] setView:nil];
    [_connectionStatusLabel removeFromSuperview];
    [_drone.mainController stopUpdateMCSystemState];

    [_drone destroy];
    
}




-(IBAction) onOpenButtonClicked:(id)sender
{
    [_groundStation openGroundStation];
}








-(void) SingleShot {
    [_camera startTakePhoto:CameraSingleCapture withResult:^(DJIError *error) {
        if (error.errorCode != ERR_Successed) {
            NSLog(@"Take Photo Error : %@", error.errorDescription);
        } else {
            self.barStatus.title = [NSString stringWithFormat:@"Image taken"];

            
        }
        
    }];
}


#pragma mark - DJICameraDelegate

-(void) camera:(DJICamera*)camera didReceivedVideoData:(uint8_t*)videoBuffer length:(int)length
{
    uint8_t* pBuffer = (uint8_t*)malloc(length);
    memcpy(pBuffer, videoBuffer, length);
    [[VideoPreviewer instance].dataQueue push:pBuffer length:length];
}

-(void) camera:(DJICamera*)camera didUpdateSystemState:(DJICameraSystemState*)systemState
{
//    if (!systemState.isTimeSynced) {
//        [_camera syncTime:nil];
//    }
    if (systemState.isUSBMode) {
        NSLog(@"Camera mode USB");
        [_camera setCamerMode:CameraCameraMode withResultBlock:^(DJIError *error) {
            if (error.errorCode == ERR_Successed) {

            } else {
                NSLog(@"Cant set USB mode");
            }
            
        }];
        
    }
}

#pragma mark - Gimbal movement

-(void) onGimbalAttitudeScrollUp
{
    
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
         DJIGimbalRotation pitch = {YES, 50, RelativeAngle, RotationForward};
    DJIGimbalRotation roll = {NO, 0, RelativeAngle, RotationForward};
    DJIGimbalRotation yaw = {YES, 0, RelativeAngle, RotationForward};
    while (_gimbalAttitudeUpdateFlag) {
        [_drone.gimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:^(DJIError *error) {
            if (error.errorCode == ERR_Successed) {
              //  NSLog(@"gimbal moved up ");

            }
        }];
        // usleep(40000);
    }
    // stop rotation.
    pitch.angle = 0;
    roll.angle = 0;
    yaw.angle = 0;
    [_drone.gimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:^(DJIError *error) {
    }];
      
    });
    

    
    
   
}

-(void) onGimbalAttitudeScrollDown{
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
         DJIGimbalRotation pitch = {YES, 50, RelativeAngle, RotationBackward};
    DJIGimbalRotation roll = {NO, 0, RelativeAngle, RotationBackward};
    DJIGimbalRotation yaw = {YES, 0, RelativeAngle, RotationBackward};
    while (_gimbalAttitudeUpdateFlag) {
        [_drone.gimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:^(DJIError *error) {
            if (error.errorCode == ERR_Successed) {
              //  NSLog(@"gimbal moved down ");
            }
        }];
        //usleep(40000);
    }
    
    // stop rotation.
    pitch.angle = 0;
    roll.angle = 0;
    yaw.angle = 0;
    [_drone.gimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:^(DJIError *error) {
        if (error.errorCode == ERR_Successed) {
            
        }
        else
        {
            NSLog(@"Set GimbalAttitude Failed");
            self.barStatus.title  = @"Set GimbalAttitude Failed";
        }
    }];

      
    });
    

   }




-(IBAction) onGimbalScrollUpTouchDown:(id)sender
{
    
    _gimbalAttitudeUpdateFlag = YES;
    [self onGimbalAttitudeScrollUp];

}

-(IBAction) onGimbalScrollUpTouchUp:(id)sender
{
    _gimbalAttitudeUpdateFlag = NO;
    NSLog(@"stop gimbal updates");

  //  dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [_drone.gimbal stopGimbalAttitudeUpdates];
    //});
    
}

-(IBAction) onGimbalScroollDownTouchDown:(id)sender
{
    _gimbalAttitudeUpdateFlag = YES;
    [self onGimbalAttitudeScrollDown];
}

-(IBAction) onGimbalScroollDownTouchUp:(id)sender
{
    _gimbalAttitudeUpdateFlag = NO;
    NSLog(@"stop gimbal updates");

//    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

        [_drone.gimbal stopGimbalAttitudeUpdates];
  //  });
}






#pragma mark - DJIDroneDelegate

-(void) droneOnConnectionStatusChanged:(DJIConnectionStatus)status
{
    switch (status) {
        case ConnectionStartConnect:
        {
            NSLog(@"Connection Started");
         //   self.navigationItem.title = @"Start Reconnect...";
            //self.connectionStatus.title = @"Start Reconnect...";
            connection = false;

            break;
        }
        case ConnectionSuccessed:
        {
            NSLog(@"connected");
          //  self.navigationItem.title = @"Connected";
           // self.connectionStatus.title = @"Connected";
            connection = true;
            break;
        }
        case ConnectionFailed:
        {
            NSLog(@"Connect Failed...");
           // self.navigationItem.title = @"Connection Failed";
            connection = false;

            //self.connectionStatus.title = @"Connect Failed";
            break;
        }
        case ConnectionBroken:
        {
          //  self.navigationItem.title = @"Disconnected";
            connection = false;

            NSLog(@"Connect Broken...");
          //  self.connectionStatus.title = @"Disconnected";
            break;
        }
        default:
            break;
    }
}

#pragma mark - DJIGimbalDelegate

-(void) gimbalController:(DJIGimbal*)controller didGimbalError:(DJIGimbalError)error
{
    if (error == GimbalClamped) {
        NSLog(@"Gimbal Clamped");
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Gimbal Clamped" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    if (error == GimbalErrorNone) {
        NSLog(@"Gimbal Error None");
        
    }
    if (error == GimbalMotorAbnormal) {
        NSLog(@"Gimbal Motor Abnormal");
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Gimbal Motor Abnormal" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}




-(IBAction) onDownloadTaskClicked:(id)sender
{
    [_groundStation downloadGroundStationTask];
}

-(IBAction) onStartTaskButtonClicked:(id)sender
{
    
    if (!shootPan) {
        shootPan = true;
        [self.captureBtn setTitle:@"X" forState:UIControlStateNormal];
        self.barStatus.title = @"Shooting Pano";

        [self SDCardOperations];
       
    } else {
        
        [self.captureBtn setTitle:@"Pano" forState:UIControlStateNormal];
        self.barStatus.title = @"Pano Cancelled";
        [self.cirlce setStrokeEnd:0 animated:NO];
        [_groundStation pauseGroundStationTask];
        shootPan = false;

    }
    
    
}

-(IBAction) onPauseTaskButtonClicked:(id)sender
{
    [_groundStation pauseGroundStationTask];
}

-(IBAction) onContinueTaskButtonClicked:(id)sender
{
    [_groundStation continueGroundStationTask];
}

-(IBAction) onGoHomeButtonClicked:(id)sender
{
    [_groundStation gohome];
}

#pragma mark - GroundStation Result

-(void) onGroundStationOpenWithResult:(GroundStationExecuteResult*)result
{
    if (result.executeStatus == GSExecStatusBegan) {
       // self.logLabel.text = @"Ground Station Open Began";
    }
    else if (result.executeStatus == GSExecStatusSuccessed)
    {
        //self.logLabel.text = @"Ground Station Open Successed";
        
    }
    else
    {
        //self.logLabel.text = [NSString stringWithFormat: @"Ground Station Open Failed:%d", (int)result.error];
        
    }
}


-(void) onGroundStationUploadTaskWithResult:(GroundStationExecuteResult*)result
{
    if (result.executeStatus == GSExecStatusBegan) {
        
        self.barStatus.title = @"Uploading WPs";

        
        //self.logLabel.text = @"Upload Task Began";
        
    }
    else if (result.executeStatus == GSExecStatusSuccessed)
    {
        
        //self.logLabel.text = @"Upload Task Success";
        
        self.barStatus.title = @"Uploaded WPs";

    }
    else
    {
        self.barStatus.title = [NSString stringWithFormat:@"Upload Task Failed: %d", (int)result.error];
        
    }
}

-(void) onGroundStationDownloadTaskWithResult:(GroundStationExecuteResult*)result
{
    if (result.executeStatus == GSExecStatusBegan) {
        NSLog(@"Download Task Began");
    }
    else if (result.executeStatus == GSExecStatusSuccessed)
    {
        NSLog(@"Download Task Success: waypoint:%d", _groundStation.groundStationTask.waypointCount);
    }
    else
    {
        NSLog(@"Download Task Failed: %d", (int)result.error);
    }
}

-(void) onGroundStationStartTaskWithResult:(GroundStationExecuteResult*)result
{
    
    if (result.executeStatus == GSExecStatusBegan) {
      //  self.logLabel.text = @"Task Start Began";
       // [self takeContinousPictures];
        self.barStatus.title = @"Pano Started";

        
    }
    else if (result.executeStatus == GSExecStatusSuccessed)
    {
       // self.logLabel.text = @"Task Start Success";
        self.barStatus.title = @"Task Started";
        
    }
    else
    {
       NSLog(@"%@",[NSString stringWithFormat:@"Task Start Failed : %d", (int)result.error]);
        self.barStatus.title = [NSString stringWithFormat:@"Task Start Failed : %d", (int)result.error];
        
    }
}


-(void) onGroundStationGpsStatusChanged:(GroundStationGpsStatus)status
{
    switch (status) {
        case GSGpsGood:
        {
            //NSLog(@"GPS Good");
            break;
        }
        case GSGpsWeak:
        {
        //    NSLog(@"GPS Weak");
            break;
        }
        case GSGpsBad:
        {
          //  NSLog(@"GPS Bad");

            break;
        }
        default:
            break;
    }
}

#pragma mark - DJIGroundStationDelegate

-(void) groundStation:(id<DJIGroundStation>)gs didExecuteWithResult:(GroundStationExecuteResult*)result
{
    
    
    switch (result.currentAction) {
        case GSActionOpen:
        {
            [self onGroundStationOpenWithResult:result];
            break;
        }
        case GSActionClose:
        {
          //  [self onGroundStationCloseWithResult:result];
            break;
        }
        case GSActionUploadTask:
        {
            [self onGroundStationUploadTaskWithResult:result];
            break;
        }
        case GSActionDownloadTask:
        {
        //    [self onGroundStationDownloadTaskWithResult:result];
            break;
        }
        case GSActionStart:
        {
            [self onGroundStationStartTaskWithResult:result];
            break;
        }
        case GSActionPause:
        {
        //    [self onGroundStationPauseTaskWithResult:result];
            break;
        }
        case GSActionContinue:
        {
         //   [self onGroundStationContinueTaskWithResult:result];
            break;
        }
        case GSActionGoHome:
        {
          //  [self onGroundStationGoHomeWithResult:result];
            break;
        }
        default:
            break;
    }
}


-(void) mainController:(DJIMainController*)mc didUpdateSystemState:(DJIMCSystemState*)state
{
    
   // NSLog(@"DJIaltitude  = {%d, %d , %d}\n", state.attitude.pitch ,state.attitude.roll , state.attitude.yaw);
    currentYaw = state.attitude.yaw + 180;
    
}



-(void) groundStation:(id<DJIGroundStation>)gs didUpdateFlyingInformation:(DJIGroundStationFlyingInfo*)flyingInfo
{
    
   // [self onGroundStationControlModeChanged:flyingInfo.controlMode];
    [self onGroundStationGpsStatusChanged:flyingInfo.gpsStatus];
    
    _homeLocation = flyingInfo.homeLocation;
    _CurrentDroneLocation = flyingInfo.droneLocation;
   
    if (flyingInfo.targetWaypointIndex != -1) {
        if (wp_idx != flyingInfo.targetWaypointIndex) {
            [self SingleShot];
            self.barStatus.title = [NSString stringWithFormat:@"%d images taken", flyingInfo.targetWaypointIndex];
            
            [self.cirlce setStrokeEnd:((1.0/15.0)*flyingInfo.targetWaypointIndex) animated:YES];
            
            if (flyingInfo.targetWaypointIndex == 15) {
                //self.captureBtn.enabled = true;
                [self.captureBtn tap];
                shootPan = false;
                
                [self.captureBtn setTitle:@"Pano" forState:UIControlStateNormal];
                self.barStatus.title = @"";
                [self.cirlce setStrokeEnd:0 animated:NO];

                [self performSegueWithIdentifier:@"processingSegue" sender:self];

                
            }

            
        }
    }
    
    wp_idx = flyingInfo.targetWaypointIndex;
   // DJIAttitude att = flyingInfo.attitude;
   // currentYaw = att.yaw;//100.0;
//    currentAltitude = flyingInfo.altitude;
    
    self.satCount.title = [NSString stringWithFormat:@"S:%d", flyingInfo.satelliteCount];

}

//-(void)continousShots {
//    
//    
//    [_camera setCameraExposureCompensation:CameraExposureCompensationN00 withResultBlock:^(DJIError *error) {
//        if (error.errorCode == ERR_Successed) {
//            NSLog(@"Set Exposure Compensation Success");
//        }
//        else{
//            NSLog(@"Set Exposure Compensation Failed");
//        }
//    }];
//    
//    [_camera startTakePhoto:CameraSingleCapture withResult:^(DJIError *error) {
//        if (error.errorCode != ERR_Successed) {
//            NSLog(@"Take Photo Error : %@", error.errorDescription);
//        } else {
//        
//        }
//        self.barStatus.title = [NSString stringWithFormat:@"Image taken"];
//        total_images = total_images + 1;
//        [self.cirlce setStrokeEnd:((1.0/PANO_SHOTS)*total_images) animated:YES];
//        self.barStatus.title = [NSString stringWithFormat:@"%d Image taken", total_images];
//        
//        
//        if (total_images <= PANO_SHOTS) {
//            if(shootPan) {
//                sleep(2);
//                [_groundStation setAircraftJoystickWithPitch:0 Roll:0 Yaw:YAW_180 Throttle:0];
//
//                [self continousShots];
//            }
//        } else {
//            //stop the Yaw
//            shootPan = false;
//            [_groundStation setAircraftJoystickWithPitch:0 Roll:0 Yaw:0 Throttle:0];
//            [self.captureBtn tap];
//            shootPan = false;
//            [self.cirlce setStrokeEnd:0 animated:NO];
//
//            [self.captureBtn setTitle:@"Pano" forState:UIControlStateNormal];
//            self.barStatus.title = @"";
//            [self.cirlce setStrokeEnd:0 animated:NO];
//            
//            [self performSegueWithIdentifier:@"processingSegue" sender:self];
//            
//        }
//
//    }];
//    
//}

-(void) processOperations {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        sleep(2);
        [_groundStation openGroundStation];
        NSLog(@"ground station started");
        sleep(2);
        [_groundStation pauseGroundStationTask];
        NSLog(@"ground station paused");
        
        
        
        //[_groundStation startGroundStationTask];
        for (int i=1; i<=PANO_SHOTS; i++) {
            [_groundStation setAircraftJoystickWithPitch:0 Roll:0 Yaw:YAW_180 Throttle:0];
            sleep(2);
            [self SingleShot];
            sleep(2);
            [_groundStation setAircraftJoystickWithPitch:0 Roll:0 Yaw:0 Throttle:0];
            sleep(2);
            
            [self.cirlce setStrokeEnd:((1.0/PANO_SHOTS)*(i)) animated:YES];
            
            if (i == PANO_SHOTS) {
                //self.captureBtn.enabled = true;
                [self.captureBtn tap];

                
                [self.cirlce setStrokeColor:[UIColor colorWithRed:240/255.0 green:173/255.0 blue:78/255.0 alpha:1]];
                [self.cirlce setStrokeEnd:0.0 animated:NO];
                
                shootPan = false;
                
                [self.captureBtn setTitle:@"Pano" forState:UIControlStateNormal];
                self.barStatus.title = @"";
                
                [self presentProcessingView:nil];
                
                
            }
            
            
        }
        
    });
}

#pragma SD Card Operations

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
       //CANCEL
    if (alertView.tag == 10) {
        if (buttonIndex == 0) {
            [self.captureBtn setTitle:@"Pano" forState:UIControlStateNormal];
            self.barStatus.title = @"Pano Cancelled";
            [self.cirlce setStrokeEnd:0 animated:NO];
            [_groundStation pauseGroundStationTask];
            [self.captureBtn tap];
            shootPan = false;

        //Take PANO
        } else {
            [_camera formatSDCard:^(DJIError *error) {
                NSLog(@"error %@", error.errorDescription);
                if (error.errorCode == ERR_Successed) {
                    // NSLog(@"Formated CD card");
                    self.barStatus.title = @"SD erased";
                    
                }
            }];
            
            [self processOperations];
            
        }
    }
}


-(void)SDCardOperations {
    
//    if (!connection) {
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
//                                                        message:@"Connect to Phantom"
//                                                       delegate:self
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
//        
//        [self.captureBtn setTitle:@"Pano" forState:UIControlStateNormal];
//        self.barStatus.title = @"Pano Cancelled";
//        [self.cirlce setStrokeEnd:0 animated:NO];
//        [_groundStation pauseGroundStationTask];
//        [self.captureBtn tap];
//        shootPan = false;
//        
//        return;
//        
//    }

    
    
    [_camera getSDCardInfo:^(DJICameraSDCardInfo *sdInfo, DJIError *error)
     {
         if (error.errorCode == ERR_Successed)
         {

             if (sdInfo.isInserted == 1) {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                                 message:@"This App needs to ERASE the SD card. You will lose all data on the card"
                                                                delegate:self
                                                       cancelButtonTitle:@"Cancel"
                                                       otherButtonTitles:@"Ok", nil];
                 alert.tag = 10;
                 [alert show];
                 
             } else {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                                 message:@"SD not detected"
                                                                delegate:self
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
                 
                 [self.captureBtn setTitle:@"Pano" forState:UIControlStateNormal];
                 self.barStatus.title = @"Pano Cancelled";
                 [self.cirlce setStrokeEnd:0 animated:NO];
                 [_groundStation pauseGroundStationTask];
                 [self.captureBtn tap];
                 shootPan = false;


             }
             
         }
         else
         {
             
             NSLog(@"Get SDCard Info Failed\n");
         }
         
     }];

    
    
    

}



@end
