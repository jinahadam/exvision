//
//  ViewController.m
//  ExVision
//
//  Created by Jinah Adam on 26/1/15.
//  Copyright (c) 2015 Jinah Adam. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end



@implementation ViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    _connectionStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    _connectionStatusLabel.backgroundColor = [UIColor clearColor];
    _connectionStatusLabel.textAlignment = NSTextAlignmentCenter;
    _connectionStatusLabel.text = @"Disconnected";
    
    [self.navigationController.navigationBar addSubview:_connectionStatusLabel];
    
    _drone = [[DJIDrone alloc] initWithType:DJIDrone_Phantom];
    
    
    _camera = _drone.camera;
    _camera.delegate = self;

    
    _groundStation = _drone.mainController;
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    _drone.delegate = self;
    _groundStation.groundStationDelegate = self;
    [_camera startCameraSystemStateUpdates];

    
    [_drone connectToDrone];
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_connectionStatusLabel removeFromSuperview];
    [_drone disconnectToDrone];
    [_drone destroy];
    _drone.delegate = Nil;
    _groundStation.groundStationDelegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Action

-(IBAction) onOpenButtonClicked:(id)sender
{
    [_groundStation openGroundStation];
}

-(IBAction) onCloseButtonClicked:(id)sender
{
    [_groundStation closeGroundStation];
}


-(IBAction) uploadCalculatedPoints:(id)sender

{
    
   
    CGPoint p2 = CGPointMake(0,0);
    CGPoint p3 = CGPointMake(0.00000199,-0.000011);
    CGPoint p4 = CGPointMake(0.00000900,-0.000014);
    CGPoint p5 = CGPointMake(0.00001099,-0.000011);
    CGPoint p6 = CGPointMake(0.00002199,-0.000003);
    CGPoint p7 = CGPointMake(0.00000599,0.0000139);
    CGPoint p8 = CGPointMake(-0.0000050,0.0000179);
    CGPoint p9 = CGPointMake(-0.0000160,0.0000150);
    CGPoint p10 = CGPointMake(-0.0000129,0.0000030);
    CGPoint p11 = CGPointMake(-0.0000240,0.0000049);
    CGPoint p12 = CGPointMake(-0.0000040,-0.000006);
    CGPoint p13 = CGPointMake(-0.0000020,-0.000010);
    
    
    const float height = 10;
    DJIGroundStationTask* newTask = [DJIGroundStationTask newTask];
    //    CLLocationCoordinate2D  point1 = { 22.5351709662 , 113.9419635173 };
    CLLocationCoordinate2D  point2 = { 22.5352549662 , 113.9433645173 };
    CLLocationCoordinate2D  point3 = { 22.5346709662 , 113.9434005173 };
    CLLocationCoordinate2D  point4 = { 22.5346039662 , 113.9418915173 };
    CLLocationCoordinate2D  point5 = { 22.5346039662 , 113.9418915173 };
    CLLocationCoordinate2D  point6 = { 22.5346039662 , 113.9418915173 };
    CLLocationCoordinate2D  point7 = { 22.5346039662 , 113.9418915173 };
    CLLocationCoordinate2D  point8 = { 22.5346039662 , 113.9418915173 };
    CLLocationCoordinate2D  point9 = { 22.5346039662 , 113.9418915173 };
    CLLocationCoordinate2D  point10 = { 22.5346039662 , 113.9418915173 };
    CLLocationCoordinate2D  point11 = { 22.5346039662 , 113.9418915173 };
    CLLocationCoordinate2D  point12 = { 22.5346039662 , 113.9418915173 };
    CLLocationCoordinate2D  point13 = { 22.5346039662 , 113.9418915173 };
    
    if (CLLocationCoordinate2DIsValid(_homeLocation)) {
        
        // point1 = CLLocationCoordinate2DMake(1.287818,103.786205);
        point2 = CLLocationCoordinate2DMake(_homeLocation.latitude+p2.x,_homeLocation.longitude+p2.y);
        point3 = CLLocationCoordinate2DMake(_homeLocation.latitude+p3.x,_homeLocation.longitude+p3.y);
        point4 = CLLocationCoordinate2DMake(_homeLocation.latitude+p4.x,_homeLocation.longitude+p4.y);
        point5 = CLLocationCoordinate2DMake(_homeLocation.latitude+p5.x,_homeLocation.longitude+p5.y);
        point6 = CLLocationCoordinate2DMake(_homeLocation.latitude+p6.x,_homeLocation.longitude+p6.y);
        point7 = CLLocationCoordinate2DMake(_homeLocation.latitude+p7.x,_homeLocation.longitude+p7.y);
        point8 = CLLocationCoordinate2DMake(_homeLocation.latitude+p8.x,_homeLocation.longitude+p8.y);
        point9 = CLLocationCoordinate2DMake(_homeLocation.latitude+p9.x,_homeLocation.longitude+p9.y);
        point10 = CLLocationCoordinate2DMake(_homeLocation.latitude+p10.x,_homeLocation.longitude+p10.y);
        point11 = CLLocationCoordinate2DMake(_homeLocation.latitude+p11.x,_homeLocation.longitude+p11.y);
        point12 = CLLocationCoordinate2DMake(_homeLocation.latitude+p12.x,_homeLocation.longitude+p12.y);
        point13 = CLLocationCoordinate2DMake(_homeLocation.latitude+p13.x,_homeLocation.longitude+p13.y);
        
        
    }
    
    //    DJIGroundStationWaypoint* wp1 = [[DJIGroundStationWaypoint alloc] initWithCoordinate:point1];
    //    wp1.altitude = height;
    //    wp1.horizontalVelocity = 4;
    //    wp1.stayTime = 1.0;
    
    DJIGroundStationWaypoint* wp2 = [[DJIGroundStationWaypoint alloc] initWithCoordinate:point2];
    wp2.altitude = height;
    wp2.horizontalVelocity = 4;
    wp2.stayTime = 1.0;
    
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
    
    DJIGroundStationWaypoint* wp7 = [[DJIGroundStationWaypoint alloc] initWithCoordinate:point7];
    wp7.altitude = height;
    wp7.horizontalVelocity = 4;
    wp7.stayTime = 1.0;
    
    DJIGroundStationWaypoint* wp8 = [[DJIGroundStationWaypoint alloc] initWithCoordinate:point8];
    wp8.altitude = height;
    wp8.horizontalVelocity = 4;
    wp8.stayTime = 1.0;
    
    DJIGroundStationWaypoint* wp9 = [[DJIGroundStationWaypoint alloc] initWithCoordinate:point9];
    wp9.altitude = height;
    wp9.horizontalVelocity = 4;
    wp9.stayTime = 1.0;
    
    DJIGroundStationWaypoint* wp10 = [[DJIGroundStationWaypoint alloc] initWithCoordinate:point10];
    wp10.altitude = height;
    wp10.horizontalVelocity = 4;
    wp10.stayTime =1.0;
    
    DJIGroundStationWaypoint* wp11 = [[DJIGroundStationWaypoint alloc] initWithCoordinate:point11];
    wp11.altitude = height;
    wp11.horizontalVelocity = 4;
    wp11.stayTime = 1.0;
    
    DJIGroundStationWaypoint* wp12 = [[DJIGroundStationWaypoint alloc] initWithCoordinate:point12];
    wp12.altitude = height;
    wp12.horizontalVelocity = 4;
    wp12.stayTime = 1.0;
    
    DJIGroundStationWaypoint* wp13 = [[DJIGroundStationWaypoint alloc] initWithCoordinate:point13];
    wp13.altitude = height;
    wp13.horizontalVelocity = 4;
    wp13.stayTime = 1.0;
    
    
    [newTask removeAllWaypoint];
    
    
    
    // [newTask addWaypoint:wp1];
    [newTask addWaypoint:wp2];
    [newTask addWaypoint:wp3];
    [newTask addWaypoint:wp4];
    [newTask addWaypoint:wp5];
    [newTask addWaypoint:wp6];
    [newTask addWaypoint:wp7];
    [newTask addWaypoint:wp8];
    [newTask addWaypoint:wp9];
    [newTask addWaypoint:wp10];
    [newTask addWaypoint:wp11];
    [newTask addWaypoint:wp12];
    [newTask addWaypoint:wp13];
    
    self.logLabel.text = [NSString stringWithFormat:@"%d",[newTask waypointCount]];
    
    [_groundStation uploadGroundStationTask:newTask];
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
    
    self.contrlModeLabel.text = ctrlMode;
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
    wp_index = self.targetWp.text;
    
    [self onGroundStationControlModeChanged:flyingInfo.controlMode];
    [self onGroundStationGpsStatusChanged:flyingInfo.gpsStatus];
    
    _homeLocation = flyingInfo.homeLocation;
    self.satelliteLabel.text = [NSString stringWithFormat:@"%d", flyingInfo.satelliteCount];
    self.homeLocationLabel.text = [NSString stringWithFormat:@"%f, %f", flyingInfo.homeLocation.latitude, flyingInfo.homeLocation.longitude];
    self.droneLocationLabel.text = [NSString stringWithFormat:@"%f, %f", flyingInfo.droneLocation.latitude, flyingInfo.droneLocation.longitude];
    self.targetWp.text = [NSString stringWithFormat:@"%d", flyingInfo.targetWaypointIndex];
    
    if (![wp_index isEqualToString:[NSString stringWithFormat:@"%d", flyingInfo.targetWaypointIndex]]) {
        [self takePicture];
        self.logLabel.text = @"Picture taken";
    }
    
    self.altitude.text = [NSString stringWithFormat:@"%f", flyingInfo.altitude];
    self.targetAltitude.text = [NSString stringWithFormat:@"%f", flyingInfo.targetAltitude];
   // NSLog(@"target %d", flyingInfo.targetWaypointIndex);
    

}


-(IBAction) onTakePhotoButtonClicked:(id)sender
{
    [self takePicture];

}


-(void)takePicture {
    [_camera startTakePhoto:CameraSingleCapture withResult:^(DJIError *error) {
        if (error.errorCode != ERR_Successed) {
            NSLog(@"Take Photo Error : %@", error.errorDescription);
        } else {
            NSLog(@"picture taken");
        }
        
    }];

}

-(void) camera:(DJICamera*)camera didReceivedVideoData:(uint8_t*)videoBuffer length:(int)length
{
    uint8_t* pBuffer = (uint8_t*)malloc(length);
    memcpy(pBuffer, videoBuffer, length);
   // [[VideoPreviewer instance].dataQueue push:pBuffer length:length];
}

-(void) camera:(DJICamera*)camera didUpdateSystemState:(DJICameraSystemState*)systemState
{
    if (!systemState.isTimeSynced) {
        [_camera syncTime:nil];
    }
    if (systemState.isUSBMode) {
        [_camera setCamerMode:CameraCameraMode withResultBlock:Nil];
    }
    
  

}






#pragma mark - DJIDroneDelegate

-(void) droneOnConnectionStatusChanged:(DJIConnectionStatus)status
{
    switch (status) {
        case ConnectionStartConnect:
            
            break;
        case ConnectionSuccessed:
        {
            _connectionStatusLabel.text = @"Connected";
            break;
        }
        case ConnectionFailed:
        {
            _connectionStatusLabel.text = @"Connect Failed";
            break;
        }
        case ConnectionBroken:
        {
            _connectionStatusLabel.text = @"Disconnected";
            break;
        }
        default:
            break;
    }
}

@end



