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

@interface CameraViewController ()

@end

@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _drone = [[DJIDrone alloc] initWithType:DJIDrone_Phantom];
    _camera = _drone.camera;
    _camera.delegate = self;
    
    //_drone.gimbal.delegate = self;
    
    
    _groundStation = _drone.mainController;

    
    //Start video data decode thread
    [[VideoPreviewer instance] start];
    currentAltitude = 0;
    
    
    shootPan = true;
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

-(IBAction) uploadPanaromaWaypoints:(id)sender

{
    CGPoint p3 = CGPointMake(0.00000199,-0.000011);
    CGPoint p4 = CGPointMake(0.00000900,-0.000014);
    CGPoint p5 = CGPointMake(0.00001099,-0.000011);
    CGPoint p6 = CGPointMake(0.00002199,-0.000003);
    
    const float height = currentAltitude;
    
    self.WaypointAltitude.text = [NSString stringWithFormat:@" %f", height];
    
    DJIGroundStationTask* newTask = [DJIGroundStationTask newTask];
    CLLocationCoordinate2D  point3 = { 22.5346709662 , 113.9434005173 };
    CLLocationCoordinate2D  point4 = { 22.5346039662 , 113.9418915173 };
    CLLocationCoordinate2D  point5 = { 22.5346039662 , 113.9418915173 };
    CLLocationCoordinate2D  point6 = { 22.5346039662 , 113.9418915173 };
    
    if (CLLocationCoordinate2DIsValid(_homeLocation)) {
        
        point3 = CLLocationCoordinate2DMake(_homeLocation.latitude+p3.x,_homeLocation.longitude+p3.y);
        point4 = CLLocationCoordinate2DMake(_homeLocation.latitude+p4.x,_homeLocation.longitude+p4.y);
        point5 = CLLocationCoordinate2DMake(_homeLocation.latitude+p5.x,_homeLocation.longitude+p5.y);
        point6 = CLLocationCoordinate2DMake(_homeLocation.latitude+p6.x,_homeLocation.longitude+p6.y);
        
    }
    
    DJIGroundStationWaypoint* wp3 = [[DJIGroundStationWaypoint alloc] initWithCoordinate:point3];
    wp3.altitude = height;
    wp3.horizontalVelocity = 4;
    wp3.stayTime = 1.0;
    
    DJIGroundStationWaypoint* wp4 = [[DJIGroundStationWaypoint alloc] initWithCoordinate:point4];
    wp4.altitude = height;
    wp4.horizontalVelocity = 4;
    wp4.stayTime = 1.0;
    
    DJIGroundStationWaypoint* wp5 = [[DJIGroundStationWaypoint alloc] initWithCoordinate:point5];
    wp5.altitude = height;
    wp5.horizontalVelocity = 4;
    wp5.stayTime = 1.0;
    
    DJIGroundStationWaypoint* wp6 = [[DJIGroundStationWaypoint alloc] initWithCoordinate:point6];
    wp6.altitude = height;
    wp6.horizontalVelocity = 4;
    wp6.stayTime = 1.0;
    
    
    [newTask removeAllWaypoint];
    
    [newTask addWaypoint:wp3];
    [newTask addWaypoint:wp4];
    [newTask addWaypoint:wp5];
    [newTask addWaypoint:wp6];
    
    
    
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
//    if (systemState.isUSBMode) {
//        [_camera setCamerMode:CameraCameraMode withResultBlock:Nil];
//    }
}

#pragma mark - Gimbal movement





- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}


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
            NSString* attiString = [NSString stringWithFormat:@"Pitch = %d\nRoll = %d\nYaw = %d\n", attitude.pitch, attitude.roll, attitude.yaw];
            self.attitudeLabel.text = attiString;
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
        NSString* attiString = [NSString stringWithFormat:@"Pitch = %d\nRoll = %d\nYaw = %d\n", attitude.pitch, attitude.roll, attitude.yaw];
        self.attitudeLabel.text = attiString;
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
        NSString* attiString = [NSString stringWithFormat:@"Pitch = %d\nRoll = %d\nYaw = %d\n", attitude.pitch, attitude.roll, attitude.yaw];
        self.attitudeLabel.text = attiString;
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
        NSString* attiString = [NSString stringWithFormat:@"Pitch = %d\nRoll = %d\nYaw = %d\n", attitude.pitch, attitude.roll, attitude.yaw];
        self.attitudeLabel.text = attiString;
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
        NSString* attiString = [NSString stringWithFormat:@"Pitch = %d\nRoll = %d\nYaw = %d\n", attitude.pitch, attitude.roll, attitude.yaw];
        self.attitudeLabel.text = attiString;
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
            NSLog(@"Start Reconnect...");
            break;
        }
        case ConnectionSuccessed:
        {
            NSLog(@"Connect Successed...");
            _connectionStatusLabel.text = @"Connected";
            break;
        }
        case ConnectionFailed:
        {
            NSLog(@"Connect Failed...");
            _connectionStatusLabel.text = @"Connect Failed";
            break;
        }
        case ConnectionBroken:
        {
            NSLog(@"Connect Broken...");
            _connectionStatusLabel.text = @"Disconnected";
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
    [_groundStation startGroundStationTask];
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
        self.logLabel.text = @"Ground Station Open Began";
    }
    else if (result.executeStatus == GSExecStatusSuccessed)
    {
        self.logLabel.text = @"Ground Station Open Successed";
        
    }
    else
    {
        self.logLabel.text = [NSString stringWithFormat: @"Ground Station Open Failed:%d", (int)result.error];
        
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
        
        self.logLabel.text = @"Upload Task Began";
        
    }
    else if (result.executeStatus == GSExecStatusSuccessed)
    {
        self.logLabel.text = @"Upload Task Success";
        
    }
    else
    {
        self.logLabel.text = [NSString stringWithFormat:@"Upload Task Failed: %d", (int)result.error];
        
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
        self.logLabel.text = @"Task Start Began";
        [self takeContinousPictures];
        
    }
    else if (result.executeStatus == GSExecStatusSuccessed)
    {
        self.logLabel.text = @"Task Start Success";
        
    }
    else
    {
        self.logLabel.text = [NSString stringWithFormat:@"Task Start Failed : %d", (int)result.error];
        
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

-(void) onGroundStationGoHomeWithResult:(GroundStationExecuteResult*)result
{
    if (result.executeStatus == GSExecStatusBegan) {
        self.logLabel.text = @"GoHome Began";
        
    }
    else if (result.executeStatus == GSExecStatusSuccessed)
    {
        self.logLabel.text = @"GoHome Success";
        
    }
    else
    {
        self.logLabel.text = [NSString stringWithFormat:@"GoHomeFailed : %d", (int)result.error];
        
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
    
//    self.contrlModeLabel.text = ctrlMode;
}

-(void) onGroundStationGpsStatusChanged:(GroundStationGpsStatus)status
{
    switch (status) {
        case GSGpsGood:
        {
            break;
        }
        case GSGpsWeak:
        {
            break;
        }
        case GSGpsBad:
        {
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
   // wp_index = [NSString stringWithFormat:@"%d", flyingInfo.targetWaypointIndex];
    
    [self onGroundStationControlModeChanged:flyingInfo.controlMode];
    [self onGroundStationGpsStatusChanged:flyingInfo.gpsStatus];
    
    _homeLocation = flyingInfo.homeLocation;
    self.logLabel.text = [NSString stringWithFormat:@"Sat: %d", flyingInfo.satelliteCount];
    self.homeLocationLabel.text = [NSString stringWithFormat:@"%f, %f", flyingInfo.homeLocation.latitude, flyingInfo.homeLocation.longitude];
    self.droneLocation.text = [NSString stringWithFormat:@"%f, %f", flyingInfo.droneLocation.latitude, flyingInfo.droneLocation.longitude];
    self.targetWP.text = [NSString stringWithFormat:@"%d", flyingInfo.targetWaypointIndex];
    self.altitude.text = [NSString stringWithFormat:@"%f", flyingInfo.altitude];
    self.targetAltitude.text = [NSString stringWithFormat:@"%f", flyingInfo.targetAltitude];
    
    
    
    
    currentAltitude = flyingInfo.altitude;
    
    
}


@end
