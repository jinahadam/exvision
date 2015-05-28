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
#import "GHWalkThroughView.h"

static NSString * const sampleDesc1 = @"Here are 3 steps to get you started";

static NSString * const sampleDesc2 = @"Connect your iPhone to the Phantom Wi-Fi.";

static NSString * const sampleDesc3 = @"Keep S1 switch in position 1 (upper).\nFly the Phantom to where you want to shoot.";

static NSString * const sampleDesc4 = @"Press the Start button. Your Phantom will yaw, take photos and generate a panorama automatically.";

static NSString * const sampleDesc5 = @"Your remote controller will not function once pano has started. So when its finished or if the need arises:\n\nRegain Control by Flipping S1 switch from Position 1 to 3";


//120
#define YAW_180 -190
#define YAW_360 120
#define PANO_SHOTS 7

@interface CameraView () <GHWalkThroughViewDataSource>

@property (nonatomic, strong) GHWalkThroughView* ghView ;

@property (nonatomic, strong) NSArray* descStrings;
@property (nonatomic, strong) NSArray* titleStrings;

@property (nonatomic, strong) UILabel* welcomeLabel;

@end

@implementation CameraView

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
    [self helpViewSetup];
    
    [self showHideReprocess];
    
   
    
    
}

-(void)helpViewSetup {
    _ghView = [[GHWalkThroughView alloc] initWithFrame:self.navigationController.view.bounds];
    [_ghView setCloseTitle:@"Close"];
    [_ghView setDataSource:self];
    [[_ghView skipButton] setHidden:true];
    
    [_ghView setWalkThroughDirection:GHWalkThroughViewDirectionVertical];
    UILabel* welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
    welcomeLabel.text = @"Welcome";
    welcomeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:40];
    welcomeLabel.textColor = [UIColor whiteColor];
    welcomeLabel.textAlignment = NSTextAlignmentCenter;
    self.welcomeLabel = welcomeLabel;
    self.titleStrings = @[@"Welcome", @"Connect", @"Fly", @"Pano", @"Caution"];
    self.descStrings = [NSArray arrayWithObjects:sampleDesc1,sampleDesc2, sampleDesc3, sampleDesc4, sampleDesc5, nil];
    
}

-(IBAction)showHelp:(id)sender {
    
    [self presentHelp];
}


-(void)presentHelp {
    self.ghView.isfixedBackground = NO;
    
    [self.ghView setWalkThroughDirection:GHWalkThroughViewDirectionHorizontal];
    
    [self.ghView showInView:self.navigationController.view animateDuration:0.3];

}

#pragma mark - GHDataSource

-(NSInteger) numberOfPages
{
    return 5;
}

- (void) configurePage:(GHWalkThroughPageCell *)cell atIndex:(NSInteger)index
{
    cell.title = [self.titleStrings objectAtIndexedSubscript:index];
    cell.titleImage = [UIImage imageNamed:[NSString stringWithFormat:@"page%ld", index+1]];
    cell.desc = [self.descStrings objectAtIndex:index];
    
}

- (UIImage*) bgImageforPage:(NSInteger)index
{
    NSString* imageName =[NSString stringWithFormat:@"page%d.png", index+1];
    UIImage* image = [UIImage imageNamed:imageName];
    return image;
}



-(void)restartCameraFeed {
    [mask removeFromSuperview];
    
    _drone = [[DJIDrone alloc] initWithType:DJIDrone_Phantom];
    _drone.delegate = self;
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
    
    


    _drone = [[DJIDrone alloc] initWithType:DJIDrone_Phantom];
    _drone.delegate = self;
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
    readyForShoot = false;
    wp_idx = -1;
    connection = false;
    
    
    total_images = 0;
    
    [self.ProcessBtn dangerStyle];
    
    [self.cirlce setStrokeColor:[UIColor colorWithRed:240/255.0 green:173/255.0 blue:78/255.0 alpha:1]];
    [self.cirlce setStrokeEnd:0.0 animated:NO];
    
    
    
    _readBatteryInfoTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(onReadBatteryInfoTimerTicked:) userInfo:nil repeats:YES];
    
    PanoSpanAngle = 26;
    
    [self loadSettings];
    
    [mask setHidden:YES];
    
    
    //
    connectionHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    connectionHud.labelText = @"Connecting..";   // [self manualPanoProcessing];
    [connectionHud show:YES];

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
        
        
        //first time so show help screen aswell
        
        NSLog(@"first time ");
        
        [self performSelector:@selector(presentHelp) withObject:nil afterDelay:2.0];
      
        
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
                
                self.battery.title = [NSString stringWithFormat:@"%ld%%", (long)_drone.smartBattery.remainPowerPercent];
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
    
    //_drone.delegate = Nil;
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
            self.barStatus.title = [NSString stringWithFormat:@"In auto mode. flip S1 to gain control"];

            
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

    if (systemState.isUSBMode) {
        [_camera setCamerMode:CameraCameraMode withResultBlock:^(DJIError *error) {
            if (error.errorCode == ERR_Successed) {

            }
        }];
        
    }
}

#pragma mark - Gimbal movement
-(void) onGimbalAttitudeYawRotationForward
{
    DJIGimbalRotation pitch = {YES, 0, RelativeAngle, RotationForward};
    DJIGimbalRotation roll = {NO, 0, RelativeAngle, RotationForward};
    DJIGimbalRotation yaw = {YES, 16, RelativeAngle, RotationForward};
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
    DJIGimbalRotation yaw = {YES, 16, RelativeAngle, RotationBackward};
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
        usleep(40000);
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
//            NSString* attiString = [NSString stringWithFormat:@"Pitch = %d\nRoll = %d\nYaw = %d\n", attitude.pitch, attitude.roll, attitude.yaw];
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
    //    NSString* attiString = [NSString stringWithFormat:@"Pitch = %d\nRoll = %d\nYaw = %d\n", attitude.pitch, attitude.roll, attitude.yaw];
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
      //  NSString* attiString = [NSString stringWithFormat:@"Pitch = %d\nRoll = %d\nYaw = %d\n", attitude.pitch, attitude.roll, attitude.yaw];
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
    [NSThread detachNewThreadSelector:@selector(onGimbalAttitudeYawRotationForward) toTarget:self withObject:nil];
    NSOperationQueue* asyncQueue = [NSOperationQueue mainQueue];
    asyncQueue.maxConcurrentOperationCount = 1;
    [_drone.gimbal startGimbalAttitudeUpdateToQueue:asyncQueue withResultBlock:^(DJIGimbalAttitude attitude) {
       // NSString* attiString = [NSString stringWithFormat:@"Pitch = %d\nRoll = %d\nYaw = %d\n", attitude.pitch, attitude.roll, attitude.yaw];
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
    [NSThread detachNewThreadSelector:@selector(onGimbalAttitudeYawRotationBackward) toTarget:self withObject:nil];
    NSOperationQueue* asyncQueue = [NSOperationQueue mainQueue];
    asyncQueue.maxConcurrentOperationCount = 1;
    [_drone.gimbal startGimbalAttitudeUpdateToQueue:asyncQueue withResultBlock:^(DJIGimbalAttitude attitude) {
        //NSString* attiString = [NSString stringWithFormat:@"Pitch = %d\nRoll = %d\nYaw = %d\n", attitude.pitch, attitude.roll, attitude.yaw];
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
    NSLog(@"connection ::::");
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
            [connectionHud hide:YES];
            break;
        }
        case ConnectionFailed:
        {
            NSLog(@"Connect Failed...");
            [connectionHud hide:NO];
           // self.navigationItem.title = @"Connection Failed";
            connection = false;

            //self.connectionStatus.title = @"Connect Failed";
            break;
        }
        case ConnectionBroken:
        {
          //  self.navigationItem.title = @"Disconnected";
            connection = false;
            [connectionHud hide:NO];

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
    
    if (flightMode != 3) {
    
        if (!shootPan) {
            shootPan = true;
            [self.captureBtn setBackgroundImage:[UIImage imageNamed:@"panostop.png"] forState:UIControlStateNormal];

            self.barStatus.title = @"Shooting Pano";

            [self SDCardOperations];
           
        } else {
            
            [self.captureBtn setBackgroundImage:[UIImage imageNamed:@"pano.png"] forState:UIControlStateNormal];
            self.barStatus.title = @"Pano Cancelled";
            [self.cirlce setStrokeEnd:0 animated:NO];
            [_groundStation pauseGroundStationTask];
            shootPan = false;

        }

    } else {
        NSLog(@"flip S1 switch to top or tap ? for help");
        self.barStatus.title = @"flip S1 switch to top or tap ? for help";
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
        readyForShoot = false;
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
        //self.barStatus.title = @"Pano Started";

        
    }
    else if (result.executeStatus == GSExecStatusSuccessed)
    {
       // self.logLabel.text = @"Task Start Success";
        self.barStatus.title = @"Task Started";
        shootPan = true;
    }
    else
    {
        shootPan = false;

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
    
    flightMode =  (unsigned long)state.flightMode;
    
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
                shootPan = false;
                
              //  [self.captureBtn setTitle:@"Pano" forState:UIControlStateNormal];
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
    
    self.satCount.title = [NSString stringWithFormat:@"%d", flyingInfo.satelliteCount];
    
    
   // NSLog(@"waypoint index %d", flyingInfo.targetWaypointIndex);
    //NSLog(@"FLIGHT MODE %lu", (unsigned long)flyingInfo.droneStatus);

}

-(void) processOperations {
    
    [self deleteAllFromDisk];
    
    if (!shootPan)
        return;
    
    
    [self.captureBtn setBackgroundImage:[UIImage imageNamed:@"panostop.png"] forState:UIControlStateNormal];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        sleep(2);
        [_groundStation openGroundStation];
        NSLog(@"ground station started");
        sleep(2);
        [_groundStation pauseGroundStationTask];
        NSLog(@"ground station paused");
        
        
        if (!shootPan)
            return;
        
        //[_groundStation startGroundStationTask];
        for (int i=1; i<=PANO_SHOTS; i++) {
            
            if (!shootPan)
                return;
            
            
            [_groundStation setAircraftJoystickWithPitch:0 Roll:0 Yaw:YAW_180 Throttle:0];
            sleep(3);
            [_groundStation setAircraftJoystickWithPitch:0 Roll:0 Yaw:0 Throttle:0];
            sleep(2);
            [self SingleShot];

            if (!shootPan)
                return;
            
            [self.cirlce setStrokeEnd:((1.0/PANO_SHOTS)*(i)) animated:YES];
            
            if (i == PANO_SHOTS) {

                
                
                dispatch_async(dispatch_get_main_queue(), ^(){
                    //Add method, task you want perform on mainQueue
                    //Control UIView, IBOutlet all here
                  //  [self.cirlce setStrokeColor:[UIColor colorWithRed:240/255.0 green:173/255.0 blue:78/255.0 alpha:1]];
                    
                    if (!shootPan)
                        return;
                    
                    
                    shootPan = false;
                    
                    [self.captureBtn setBackgroundImage:[UIImage imageNamed:@"pano.png"] forState:UIControlStateNormal];
                    
                    self.barStatus.title = [NSString stringWithFormat:@"In auto mode. use S1 to gain control"];
                    
                    [self.cirlce setStrokeEnd:0.0f animated:YES];
                    
                    NSLog(@"set curce stroke before processing");
                    
                    [self presentProcessingView:nil];

                    
                });
                
                
                
            }
            
            if (!shootPan)
                return;
            
            
        }
        
    });
}

#pragma SD Card Operations

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
       //CANCEL
    if (alertView.tag == 10) {
        if (buttonIndex == 0) {
           // [self.captureBtn setTitle:@"Pano" forState:UIControlStateNormal];
            [self.captureBtn setBackgroundImage:[UIImage imageNamed:@"pano.png"] forState:UIControlStateNormal];

            self.barStatus.title = @"Pano Cancelled";
            [self.cirlce setStrokeEnd:0 animated:NO];
            [_groundStation pauseGroundStationTask];
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
    
    if (!connection) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                        message:@"Connect to Phantom"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
       // [self.captureBtn setTitle:@"Pano" forState:UIControlStateNormal];
        self.barStatus.title = @"Pano Cancelled";
        [self.cirlce setStrokeEnd:0 animated:NO];
        [_groundStation pauseGroundStationTask];
        shootPan = false;
        
        return;
        
    }
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
                 
               //  [self.captureBtn setTitle:@"Pano" forState:UIControlStateNormal];
                 [self.captureBtn setBackgroundImage:[UIImage imageNamed:@"pano.png"] forState:UIControlStateNormal];

                 self.barStatus.title = @"Pano Cancelled";
                 [self.cirlce setStrokeEnd:0 animated:NO];
                 [_groundStation pauseGroundStationTask];
                 shootPan = false;

             }
             
         }
         else
         {
             
             NSLog(@"Get SDCard Info Failed\n");
             [self.captureBtn setBackgroundImage:[UIImage imageNamed:@"pano.png"] forState:UIControlStateNormal];
             
             self.barStatus.title = @"Can't Access SD Card";
             [self.cirlce setStrokeEnd:0 animated:NO];
             [_groundStation pauseGroundStationTask];
             shootPan = false;
         }
         
     }];

}

#pragma mark - DISK IO -

-(void)deleteAllFromDisk {
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *files = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    while (files.count > 0) {
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
        if (error == nil) {
            for (NSString *path in directoryContents) {
                NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:path];
                BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&error];
                files = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
                if (!removeSuccess) {
                    // Error
                }
            }
        } else {
            // Error
        }
    }
    
}

-(void)showHideReprocess {
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *files = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    if (files.count > 5) {
        NSLog(@"images saved can reprocess");
        [self.reprocessItem setTitle:@""];
    } else {
        [self.reprocessItem setTitle:@"Reprocess Last Flight"];

    }
    
}

@end
