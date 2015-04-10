//
//  CameraViewController.m
//  ExVision
//
//  Created by Jinah Adam on 26/1/15.
//  Copyright (c) 2015 Jinah Adam. All rights reserved.
//

#import "CameraViewController.h"
#import "VideoPreviewer.h"
#import <DJISDK/DJISDK.h>
#import <DJISDK/DJISDCardOperation.h>


@interface CameraViewController ()

@end

@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _drone = [[DJIDrone alloc] initWithType:DJIDrone_Phantom];
    _camera = _drone.camera;
    _camera.delegate = self;
    _groundStation = _drone.mainController;

    [[VideoPreviewer instance] start];
    currentAltitude = 0;
    shootPan = true;
    wp_idx = -1;
    
    
    [self.captureBtn primaryStyle];
    [self.panDownBtn warningStyle];
    [self.panUpBtn warningStyle];
    [self.ProcessBtn dangerStyle];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self // put here the view controller which has to be notified
                                             selector:@selector(orientationChanged:)
                                                 name:@"UIDeviceOrientationDidChangeNotification"
                                               object:nil];
    
}


- (void)orientationChanged:(NSNotification *)notification{
    [self stopStream:nil];
    [self startStream:nil];
}


-(void) dealloc
{
    [_drone destroy];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    _drone.delegate = self;
    _groundStation.groundStationDelegate = self;

    
    [_drone connectToDrone];
    [_camera startCameraSystemStateUpdates];
    [[VideoPreviewer instance] setView:self.videoPreviewView];
    
    
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
    [_drone destroy];
    
}

-(void) calculateAndUploadWPsForDirection:(int)direction {
    
   
    const float height = currentAltitude;
    
    DJIGroundStationTask* newTask = [DJIGroundStationTask newTask];
    [newTask removeAllWaypoint];
    float _yaw = currentYaw;
    
     if (direction == 0) {
        for (int i = 0; i < 15; i++) {
            CLLocationCoordinate2D step = [self coordinateFromCoord:_CurrentDroneLocation atDistanceKm:(0.5/1000) atBearingDegrees: _yaw];
            
            DJIGroundStationWaypoint* wp = [[DJIGroundStationWaypoint alloc] initWithCoordinate:step];
            wp.altitude = height;
            wp.horizontalVelocity = 2;
            wp.stayTime = 1.0;
            
            [newTask addWaypoint:wp];
            _yaw = _yaw + 12;
            
        }
     } else {
         for (int i = 0; i < 15; i++) {
             CLLocationCoordinate2D step = [self coordinateFromCoord:_CurrentDroneLocation atDistanceKm:(0.5/1000) atBearingDegrees: _yaw];
             
             DJIGroundStationWaypoint* wp = [[DJIGroundStationWaypoint alloc] initWithCoordinate:step];
             wp.altitude = height;
             wp.horizontalVelocity = 2;
             wp.stayTime = 1.0;
             
             [newTask addWaypoint:wp];
             _yaw = _yaw - 12;
             
         }
         
     }
    [_groundStation uploadGroundStationTask:newTask];
}




-(IBAction) onOpenButtonClicked:(id)sender
{
    [_groundStation openGroundStation];
}


-(IBAction) onTakePhotoButtonClicked:(id)sender
{
    shootPan = true;
    [self takeContinousPictures];
}



-(IBAction)startStream:(id)sender {
    [[VideoPreviewer instance] start];
    [[VideoPreviewer instance] setView:self.videoPreviewView];

}


-(IBAction)stopStream:(id)sender {

    [[VideoPreviewer instance] setView:nil];

}


-(void) takeContinousPictures {
    
    [_camera startTakePhoto:CameraSingleCapture withResult:^(DJIError *error) {
        if (error.errorCode != ERR_Successed) {
            NSLog(@"Take Photo Error : %@", error.errorDescription);
        } else {
            NSLog(@"picture taken");
            
            if (shootPan) {
                [self performSelector:@selector(takeContinousPictures) withObject:nil afterDelay:2];
            }
            
            
            
        }
        
    }];
    
}

-(void) SingleShot {
    [_camera startTakePhoto:CameraSingleCapture withResult:^(DJIError *error) {
        if (error.errorCode != ERR_Successed) {
            NSLog(@"Take Photo Error : %@", error.errorDescription);
        } else {
            
            
        }
        
    }];
}

-(IBAction)stopPan:(id)sender {
    shootPan  = false;
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
        [_camera setCamerMode:CameraCameraMode withResultBlock:Nil];
    }
}

#pragma mark - Gimbal movement
-(void) onGimbalAttitudeYawRotationForward
{
    DJIGimbalRotation pitch = {YES, 0, RelativeAngle, RotationForward};
    DJIGimbalRotation roll = {NO, 0, RelativeAngle, RotationForward};
    DJIGimbalRotation yaw = {YES, 60, RelativeAngle, RotationForward};
    while (_gimbalAttitudeUpdateFlag) {
        [_drone.gimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:^(DJIError *error) {
            if (error.errorCode == ERR_Successed) {
                
            }
        }];
        usleep(40000);
    }
    // stop rotation.
    pitch.angle = 0;
    roll.angle = 0;
    yaw.angle = 0;
    [_drone.gimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:^(DJIError *error) {
    }];
}

-(void) onGimbalAttitudeYawRotationBackward
{
    DJIGimbalRotation pitch = {YES, 0, RelativeAngle, RotationBackward};
    DJIGimbalRotation roll = {NO, 0, RelativeAngle, RotationBackward};
    DJIGimbalRotation yaw = {YES, 60, RelativeAngle, RotationBackward};
    while (_gimbalAttitudeUpdateFlag) {
        [_drone.gimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:^(DJIError *error) {
            if (error.errorCode == ERR_Successed) {
                NSLog(@"YAW left moved");
            } else {
                // NSLog(@"YAW ERROR %d", error.errorCode);
            }
        }];
        //    usleep(40000);
    }
    // stop rotation.
    pitch.angle = 0;
    roll.angle = 0;
    yaw.angle = 0;
    [_drone.gimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:^(DJIError *error) {
    }];
}

-(void) onGimbalAttitudeScrollUp
{
    DJIGimbalRotation pitch = {YES, 150, RelativeAngle, RotationForward};
    DJIGimbalRotation roll = {NO, 0, RelativeAngle, RotationForward};
    DJIGimbalRotation yaw = {YES, 0, RelativeAngle, RotationForward};
    while (_gimbalAttitudeUpdateFlag) {
        [_drone.gimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:^(DJIError *error) {
            if (error.errorCode == ERR_Successed) {
                
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
}

-(void) onGimbalAttitudeScrollDown
{
    DJIGimbalRotation pitch = {YES, 150, RelativeAngle, RotationBackward};
    DJIGimbalRotation roll = {NO, 0, RelativeAngle, RotationBackward};
    DJIGimbalRotation yaw = {YES, 0, RelativeAngle, RotationBackward};
    while (_gimbalAttitudeUpdateFlag) {
        [_drone.gimbal setGimbalPitch:pitch Roll:roll Yaw:yaw withResult:^(DJIError *error) {
            if (error.errorCode == ERR_Successed) {
                
            }
        }];
        usleep(40000);
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
        }
    }];
}

-(IBAction) onGimbalAttitudeUpdateTest:(id)sender
{
    static BOOL s_startUpdate = NO;
    if (s_startUpdate == NO) {
        s_startUpdate = YES;
        NSOperationQueue* asyncQueue = [NSOperationQueue mainQueue];
        asyncQueue.maxConcurrentOperationCount = 1;
        [_drone.gimbal startGimbalAttitudeUpdateToQueue:asyncQueue withResultBlock:^(DJIGimbalAttitude attitude) {
        //    NSString* attiString = [NSString stringWithFormat:@"Pitch = %d\nRoll = %d\nYaw = %d\n", attitude.pitch, attitude.roll, attitude.yaw];
        }];
        //        [_drone.gimbalManager startGimbalAttitudeUpdates];
        //        [NSThread detachNewThreadSelector:@selector(readGimbalAttitude) toTarget:self withObject:Nil];
    }
    else
    {
        [_drone.gimbal stopGimbalAttitudeUpdates];
        s_startUpdate = NO;
    }
}

-(void) readGimbalAttitude
{
    while (true) {
        DJIGimbalAttitude attitude = _drone.gimbal.gimbalAttitude;
        NSLog(@"Gimbal Atti Pitch:%d, Roll:%d, Yaw:%d", attitude.pitch, attitude.roll, attitude.yaw);
        
        [NSThread sleepForTimeInterval:0.2];
    }
}

-(IBAction) onGimbalScrollUpTouchDown:(id)sender
{
    _gimbalAttitudeUpdateFlag = YES;
    [NSThread detachNewThreadSelector:@selector(onGimbalAttitudeScrollUp) toTarget:self withObject:nil];
    NSOperationQueue* asyncQueue = [NSOperationQueue mainQueue];
    asyncQueue.maxConcurrentOperationCount = 1;
    [_drone.gimbal startGimbalAttitudeUpdateToQueue:asyncQueue withResultBlock:^(DJIGimbalAttitude attitude) {
//        NSString* attiString = [NSString stringWithFormat:@"Pitch = %d\nRoll = %d\nYaw = %d\n", attitude.pitch, attitude.roll, attitude.yaw];
//        self.attitudeLabel.text = attiString;
    }];
}

-(IBAction) onGimbalScrollUpTouchUp:(id)sender
{
    _gimbalAttitudeUpdateFlag = NO;
    [_drone.gimbal stopGimbalAttitudeUpdates];
}

-(IBAction) onGimbalScroollDownTouchDown:(id)sender
{
    _gimbalAttitudeUpdateFlag = YES;
    [NSThread detachNewThreadSelector:@selector(onGimbalAttitudeScrollDown) toTarget:self withObject:nil];
    NSOperationQueue* asyncQueue = [NSOperationQueue mainQueue];
    asyncQueue.maxConcurrentOperationCount = 1;
    [_drone.gimbal startGimbalAttitudeUpdateToQueue:asyncQueue withResultBlock:^(DJIGimbalAttitude attitude) {
//        NSString* attiString = [NSString stringWithFormat:@"Pitch = %d\nRoll = %d\nYaw = %d\n", attitude.pitch, attitude.roll, attitude.yaw];
//        self.attitudeLabel.text = attiString;
    }];
}

-(IBAction) onGimbalScroollDownTouchUp:(id)sender
{
    _gimbalAttitudeUpdateFlag = NO;
    [_drone.gimbal stopGimbalAttitudeUpdates];
}

-(IBAction) onGimbalYawRotationForwardTouchDown:(id)sender
{
    _gimbalAttitudeUpdateFlag = YES;
    NSLog(@"change yaw right");
    [NSThread detachNewThreadSelector:@selector(onGimbalAttitudeYawRotationForward) toTarget:self withObject:nil];
    NSOperationQueue* asyncQueue = [NSOperationQueue mainQueue];
    asyncQueue.maxConcurrentOperationCount = 1;
    [_drone.gimbal startGimbalAttitudeUpdateToQueue:asyncQueue withResultBlock:^(DJIGimbalAttitude attitude) {
//        NSString* attiString = [NSString stringWithFormat:@"Pitch = %d\nRoll = %d\nYaw = %d\n", attitude.pitch, attitude.roll, attitude.yaw];
//        self.attitudeLabel.text = attiString;
    }];
}

-(IBAction) onGimbalYawRotationForwardTouchUp:(id)sender
{
    _gimbalAttitudeUpdateFlag = NO;
    [_drone.gimbal stopGimbalAttitudeUpdates];
}

-(IBAction) onGimbalYawRotationBackwardTouchDown:(id)sender
{
    _gimbalAttitudeUpdateFlag = YES;
    NSLog(@"change yaw left");
    
    [NSThread detachNewThreadSelector:@selector(onGimbalAttitudeYawRotationBackward) toTarget:self withObject:nil];
    NSOperationQueue* asyncQueue = [NSOperationQueue mainQueue];
    asyncQueue.maxConcurrentOperationCount = 1;
    [_drone.gimbal startGimbalAttitudeUpdateToQueue:asyncQueue withResultBlock:^(DJIGimbalAttitude attitude) {
//        NSString* attiString = [NSString stringWithFormat:@"Pitch = %d\nRoll = %d\nYaw = %d\n", attitude.pitch, attitude.roll, attitude.yaw];
//        self.attitudeLabel.text = attiString;
    }];
}

-(IBAction) onGimbalYawRotationBackwardTouchUp:(id)sender
{
    _gimbalAttitudeUpdateFlag = NO;
    [_drone.gimbal stopGimbalAttitudeUpdates];
}

#pragma mark - DJIDroneDelegate

-(void) droneOnConnectionStatusChanged:(DJIConnectionStatus)status
{
    switch (status) {
        case ConnectionStartConnect:
        {
         //   NSLog(@"Connection Started");
            self.navigationItem.title = @"Start Reconnect...";
            //self.connectionStatus.title = @"Start Reconnect...";

            break;
        }
        case ConnectionSuccessed:
        {
           // NSLog(@"connected");
            self.navigationItem.title = @"Connected";
           // self.connectionStatus.title = @"Connected";
            break;
        }
        case ConnectionFailed:
        {
            //NSLog(@"Connect Failed...");
            self.navigationItem.title = @"Connection Failed";

            //self.connectionStatus.title = @"Connect Failed";
            break;
        }
        case ConnectionBroken:
        {
            self.navigationItem.title = @"Disconnected";

           // NSLog(@"Connect Broken...");
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
    
    self.barStatus.title = @"Starting GS";

    
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        [self clear];
        sleep(2);
        [_groundStation openGroundStation];
        sleep(2);
        [self calculateAndUploadWPsForDirection:1];
        sleep(5);
        [_groundStation startGroundStationTask];
        
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            self.barStatus.title = @"GS On";

        });
    });
    
    
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

-(void) onGroundStationCloseWithResult:(GroundStationExecuteResult*)result
{
    if (result.executeStatus == GSExecStatusBegan) {
        
    }
    else if (result.executeStatus == GSExecStatusSuccessed)
    {
        
    }
    else
    {
        
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
        //self.logLabel.text = [NSString stringWithFormat:@"Upload Task Failed: %d", (int)result.error];
        
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
        
    }
    else if (result.executeStatus == GSExecStatusSuccessed)
    {
       // self.logLabel.text = @"Task Start Success";
        
    }
    else
    {
       NSLog(@"%@",[NSString stringWithFormat:@"Task Start Failed : %d", (int)result.error]);
        
    }
}

-(void) onGroundStationPauseTaskWithResult:(GroundStationExecuteResult*)result
{
    if (result.executeStatus == GSExecStatusBegan) {
        NSLog(@"Task Start Began");
    }
    else if (result.executeStatus == GSExecStatusSuccessed)
    {
        NSLog(@"Task Start Success");
    }
    else
    {
        NSLog(@"Task Start Failed : %d", (int)result.error);
    }
}

-(void) onGroundStationContinueTaskWithResult:(GroundStationExecuteResult*)result
{
    if (result.executeStatus == GSExecStatusBegan) {
        //NSLog(@"Task Start Began");
        self.barStatus.title = @"Pano Started";

    }
    else if (result.executeStatus == GSExecStatusSuccessed)
    {
        NSLog(@"Task Start Success");
    }
    else
    {
        NSLog(@"Task Start Failed : %d", (int)result.error);
    }
}

-(void) onGroundStationGoHomeWithResult:(GroundStationExecuteResult*)result
{
    if (result.executeStatus == GSExecStatusBegan) {
     //   self.logLabel.text = @"GoHome Began";
        
    }
    else if (result.executeStatus == GSExecStatusSuccessed)
    {
      //  self.logLabel.text = @"GoHome Success";
        
    }
    else
    {
       // self.logLabel.text = [NSString stringWithFormat:@"GoHomeFailed : %d", (int)result.error];
        
    }
}

-(void) onGroundStationControlModeChanged:(GroundStationControlMode)mode
{
    NSString* ctrlMode = @"N/A";
    switch (mode) {
        case GSModeAtti:
        {
            ctrlMode = @"ATTI";
            //            NSLog(@"GSModeAtti");
            break;
        }
        case GSModeGpsAtti:
        {
            ctrlMode = @"GPS";
            //            NSLog(@"GSModeGps_Atti");
            break;
        }
        case GSModeGpsCruise:
        {
            ctrlMode = @"GPS";
            //            NSLog(@"GSModeGps_Cruise");
            break;
        }
        case GSModeWaypoint:
        {
            ctrlMode = @"WAYPOINT";
            //            NSLog(@"GSModeWaypoint");
            break;
        }
        case GSModeGohome:
        {
            ctrlMode = @"GOHOME";
            //            NSLog(@"GSModeGohome");
            break;
        }
        case GSModeLanding:
        {
            ctrlMode = @"LANDING";
            //            NSLog(@"GSModeLanding");
            break;
        }
        case GSModePause:
        {
            ctrlMode = @"PAUSE";
            //            NSLog(@"GSModePause");
            break;
        }
        case GSModeTakeOff:
        {
            ctrlMode = @"TAKEOFF";
            //            NSLog(@"GSModeTakeOff");
            break;
        }
            
        case GSModeManual:
        {
            ctrlMode = @"MANUAL";
            NSLog(@"GSModeManual");
            break;
        }
        default:
            break;
    }
    
   // self.contrlModeLabel.text = ctrlMode;
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
            [self onGroundStationCloseWithResult:result];
            break;
        }
        case GSActionUploadTask:
        {
            [self onGroundStationUploadTaskWithResult:result];
            break;
        }
        case GSActionDownloadTask:
        {
            [self onGroundStationDownloadTaskWithResult:result];
            break;
        }
        case GSActionStart:
        {
            [self onGroundStationStartTaskWithResult:result];
            break;
        }
        case GSActionPause:
        {
            [self onGroundStationPauseTaskWithResult:result];
            break;
        }
        case GSActionContinue:
        {
            [self onGroundStationContinueTaskWithResult:result];
            break;
        }
        case GSActionGoHome:
        {
            [self onGroundStationGoHomeWithResult:result];
            break;
        }
        default:
            break;
    }
}


-(void) groundStation:(id<DJIGroundStation>)gs didUpdateFlyingInformation:(DJIGroundStationFlyingInfo*)flyingInfo
{
    
    [self onGroundStationControlModeChanged:flyingInfo.controlMode];
    [self onGroundStationGpsStatusChanged:flyingInfo.gpsStatus];
    
    _homeLocation = flyingInfo.homeLocation;
    _CurrentDroneLocation = flyingInfo.droneLocation;
   
    if (flyingInfo.targetWaypointIndex != -1) {
        if (wp_idx != flyingInfo.targetWaypointIndex) {
            [self SingleShot];
            self.barStatus.title = [NSString stringWithFormat:@"%d images taken", flyingInfo.targetWaypointIndex];
        }
    }
    
    wp_idx = flyingInfo.targetWaypointIndex;
    DJIAttitude att = flyingInfo.attitude;
    currentYaw = att.yaw/10000.0;
    currentAltitude = flyingInfo.altitude;
    
    self.satCount.title = [NSString stringWithFormat:@"Sats: %d", flyingInfo.satelliteCount];
    self.barAlt.title = [NSString stringWithFormat:@"Alt: %f", currentAltitude];
}

-(void)clear {
    
  //  NSLog(@"clearing Memory Card");
    [_camera formatSDCard:^(DJIError *error) {
        NSLog(@"error %@", error.errorDescription);
        if (error.errorCode == ERR_Successed) {
           // NSLog(@"Formated CD card");
            self.barStatus.title = @"SD erased";
        }
    }];
    

}




#pragma GPS Calculations

- (double)radiansFromDegrees:(double)degrees
{
    return degrees * (M_PI/180.0);
}

- (double)degreesFromRadians:(double)radians
{
    return radians * (180.0/M_PI);
}


- (CLLocationCoordinate2D)coordinateFromCoord:
(CLLocationCoordinate2D)fromCoord
                                 atDistanceKm:(double)distanceKm
                             atBearingDegrees:(double)bearingDegrees
{
    double distanceRadians = distanceKm / 6371.0;
    //6,371 = Earth's radius in km
    double bearingRadians = [self radiansFromDegrees:bearingDegrees];
    double fromLatRadians = [self radiansFromDegrees:fromCoord.latitude];
    double fromLonRadians = [self radiansFromDegrees:fromCoord.longitude];
    
    double toLatRadians = asin( sin(fromLatRadians) * cos(distanceRadians)
                               + cos(fromLatRadians) * sin(distanceRadians) * cos(bearingRadians) );
    
    double toLonRadians = fromLonRadians + atan2(sin(bearingRadians)
                                                 * sin(distanceRadians) * cos(fromLatRadians), cos(distanceRadians)
                                                 - sin(fromLatRadians) * sin(toLatRadians));
    
    // adjust toLonRadians to be in the range -180 to +180...
    toLonRadians = fmod((toLonRadians + 3*M_PI), (2*M_PI)) - M_PI;
    
    CLLocationCoordinate2D result;
    result.latitude = [self degreesFromRadians:toLatRadians];
    result.longitude = [self degreesFromRadians:toLonRadians];
    return result;
}

@end
