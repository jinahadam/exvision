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

static NSString * const sampleDesc5 = @"Your remote controller will not function once pano has started. So when its finished or if the need arises:\n\nRegain Control by Toggling S1 switch from Position 1 to 3";


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
    
    [self toggleReprocessBarButtonItem];
    
   
    
    
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
    NSString* imageName =[NSString stringWithFormat:@"page%ld.png", index+1];
    UIImage* image = [UIImage imageNamed:imageName];
    return image;
}




-(IBAction)toggleCameraSettingsView:(id)sender {
    
    
    
    
    if (!cameraSettingsShown) {
    NSLog(@"animate camera view");
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.cameraSettingsView.frame = CGRectMake(0, self.view.frame.size.height - 85, self.view.frame.size.width+50, 120);
//                        / self.cameraSettingsView.frame = CGRectMake(0, 50, self.view.frame.size.width+50, 100);

                     }
                     completion:^(BOOL finished){
                     }];
        cameraSettingsShown = true;
    } else {
        [UIView animateWithDuration:0.5
                              delay:0.1
                            options: UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.cameraSettingsView.frame = CGRectMake(0, self.view.frame.size.height + 100, self.view.frame.size.width+50, 80);
                         }
                         completion:^(BOOL finished){
                         }];
        cameraSettingsShown = false;
    }
}


-(void)restartCameraFeed {
    
    NSLog(@"restart camera feed");
    self.barStatus.title = @"";
    [self toggleReprocessBarButtonItem];
    
    sleep(1);
    
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
    cameraSettingsShown = false;
    
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
    connectionHud.labelText = @"Connecting...";   // [self manualPanoProcessing];
    [connectionHud show:YES];
    
    self.navigationController.toolbar.barTintColor = [UIColor colorWithRed:44/255.0 green:44/255.0 blue:51/255.0 alpha:1];

    
   
    [self setUpCameraSettingsView];
    

    
    ExposureSettingString = [[NSArray alloc] initWithObjects:@"-1.3ev",@"-1.0ev",@"-0.7ev",@"-0.3ev",@"0.0ev",@"+0.3ev",@"+0.7ev", @"+1.0ev", @"+1.3ev",@"+1.7ev", nil];
    currentExposure = 4;
    
    ContrastSettingString = [[NSArray alloc] initWithObjects:@"Standard", @"Hard", @"Soft", nil];
    SharpnessSettingString = [[NSArray alloc] initWithObjects:@"Standard", @"Hard", @"Soft", nil];
    WhiteBalanceString = [[NSArray alloc] initWithObjects:@"Auto",@"Sunny",@"Cloudy",@"Indoor", nil];
    
    
    
    currentWB = 0;
    currentContrast = 0;
    currentSharpness = 0;
    
    self.settingValue.hidden = YES;
}


-(void)cycleThroughtCameraWB {
    
    if (currentWB < ([WhiteBalanceString count])) {
        [_camera setCameraWhiteBalance:(CameraWhiteBalanceType)currentWB withResultBlock:^(DJIError *error) {
            if (error.errorCode == ERR_Successed) {
                self.barStatus.title = [NSString stringWithFormat:@"White Balance : %@", [WhiteBalanceString objectAtIndex:currentWB]];
                currentWB = currentWB + 1;
                
                if (currentWB == (int)[WhiteBalanceString count]) {
                    //reset
                    currentWB = 0;
                }
            }
            else{
                NSLog(@"Set WP Failed");
            }
        }];
        
    }
    
}

-(void)cycleThroughtCameraSharpness {
    
    if (currentSharpness < ([SharpnessSettingString count])) {
        NSLog(@"setting contrast %d", currentSharpness);
        [_camera setCameraSharpness:(CameraSharpnessType)currentSharpness withResultBlock:^(DJIError *error) {
            if (error.errorCode == ERR_Successed) {
                NSLog(@"Set Exposure Sharpness Success");
                
                self.barStatus.title = [NSString stringWithFormat:@"Sharpness : %@", [SharpnessSettingString objectAtIndex:currentSharpness]];
                currentSharpness = currentSharpness + 1;
                
                if (currentSharpness == (int)[ContrastSettingString count]) {
                    //reset
                    currentSharpness = 0;
                }
            }
            else{
                NSLog(@"Set Exposure Sharpness Failed");
            }
        }];
        
    }
    
}

-(void)cycleThroughtCameraContrast {
    
    if (currentContrast < ([ContrastSettingString count])) {
        NSLog(@"setting contrast %d", currentContrast);
        [_camera setCameraContrast:(CameraContrastType)currentContrast withResultBlock:^(DJIError *error) {
            if (error.errorCode == ERR_Successed) {
                NSLog(@"Set Exposure Contrast Success");
                
                self.barStatus.title = [NSString stringWithFormat:@"Contrast : %@", [ContrastSettingString objectAtIndex:currentContrast]];
                currentContrast = currentContrast + 1;

                if (currentContrast == (int)[ContrastSettingString count]) {
                    //reset
                    currentContrast = 0;
                }
            }
            else{
                NSLog(@"Set Exposure Contrast Failed");
            }
        }];
        
    }
    
}



-(IBAction)exposureIncrease:(id)sender {

    
    
    NSLog(@"%d %lu", currentExposure, (unsigned long)[ExposureSettingString count]);
    if (currentExposure < ([ExposureSettingString count] - 1)) {
        NSLog(@"increase exp");

    currentExposure = currentExposure + 1;
//    [self ShowSettingValue:[ExposureSettingString objectAtIndex:currentExposure]];
        
        
    [_camera setCameraExposureCompensation:(CameraExposureCompensationType)currentExposure withResultBlock:^(DJIError *error) {
        if (error.errorCode == ERR_Successed) {
            NSLog(@"Set Exposure Compensation Success");

            self.barStatus.title = [NSString stringWithFormat:@"Exposure : %@", [ExposureSettingString objectAtIndex:currentExposure]];
        }
        else{
            NSLog(@"Set Exposure Compensation Failed");
        }
    }];
        
    }
    

    
}

-(IBAction)exposureDecrease:(id)sender {

    
    if (currentExposure > 0) {
        currentExposure = currentExposure - 1;
      //  [self ShowSettingValue:[ExposureSettingString objectAtIndex:currentExposure]];

        [_camera setCameraExposureCompensation:(CameraExposureCompensationType)currentExposure withResultBlock:^(DJIError *error) {
            if (error.errorCode == ERR_Successed) {
                NSLog(@"Set Exposure Compensation Success");
                self.barStatus.title = [NSString stringWithFormat:@"Exposure : %@", [ExposureSettingString objectAtIndex:currentExposure]];

            }
            else{
                NSLog(@"Set Exposure Compensation Failed");
            }
        }];
    }
    
}

-(void)setUpCameraSettingsView {
    
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(exposureIncrease:)
     forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont systemFontOfSize:20];
    [button setTitle:@"+" forState:UIControlStateNormal];
    button.frame = CGRectMake(20, 0, 50, 50);
    [self.cameraSettingsView addSubview:button];
    
    UIButton *buttonEx = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [buttonEx addTarget:self
                 action:@selector(resetCameraSettings:)
       forControlEvents:UIControlEventTouchUpInside];
    buttonEx.titleLabel.font = [UIFont systemFontOfSize:20];
    [buttonEx setTitle:@"Exp" forState:UIControlStateNormal];
    buttonEx.frame = CGRectMake(60, 0, 50, 50);
    [self.cameraSettingsView addSubview:buttonEx];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button2 addTarget:self
                action:@selector(exposureDecrease:)
      forControlEvents:UIControlEventTouchUpInside];
    button2.titleLabel.font = [UIFont systemFontOfSize:20];
    [button2 setTitle:@"-" forState:UIControlStateNormal];
    button2.frame = CGRectMake(100, 0, 50, 50);
    [self.cameraSettingsView addSubview:button2];
    
    UIButton *contrastButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [contrastButton addTarget:self
                action:@selector(cycleThroughtCameraContrast)
      forControlEvents:UIControlEventTouchUpInside];
    contrastButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [contrastButton setTitle:@"Con" forState:UIControlStateNormal];
    contrastButton.frame = CGRectMake(170, 0, 50, 50);
    [self.cameraSettingsView addSubview:contrastButton];
    
    UIButton *sharpnessButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sharpnessButton addTarget:self
                       action:@selector(cycleThroughtCameraSharpness)
             forControlEvents:UIControlEventTouchUpInside];
    sharpnessButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [sharpnessButton setTitle:@"Shp" forState:UIControlStateNormal];
    sharpnessButton.frame = CGRectMake(240, 0, 50, 50);
    [self.cameraSettingsView addSubview:sharpnessButton];
    
    UIButton *wbButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [wbButton addTarget:self
                        action:@selector(cycleThroughtCameraWB)
              forControlEvents:UIControlEventTouchUpInside];
    wbButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [wbButton setTitle:@"WB" forState:UIControlStateNormal];
    wbButton.frame = CGRectMake(310, 0, 50, 50);
    [self.cameraSettingsView addSubview:wbButton];

}

-(IBAction)resetCameraSettings:(id)sender {
    currentExposure = 4;

    
    [_camera setCameraExposureCompensation:CameraExposureCompensationDefault withResultBlock:^(DJIError *error) {
        if (error.errorCode == ERR_Successed) {
            NSLog(@"Set Exposure Compensation Success");
        }
        else{
            NSLog(@"Set Exposure Compensation Failed");
        }
    }];
    
    [_camera setCameraExposureMetering:CameraExposureMeteringAverage withResultBlock:^(DJIError *error) {
        if (error.errorCode == ERR_Successed) {
            NSLog(@"Set CameraExposureMeteringAverage  Success");
        }
        else{
            NSLog(@"Set CameraExposureMeteringAverage Failed");
        }
    }];
    
    [_camera setCameraWhiteBalance:CameraWhiteBalanceCloudy withResultBlock:^(DJIError *error) {
        if (error.errorCode == ERR_Successed) {
            NSLog(@"Set White Balance");
        }
        else{
            NSLog(@"Set White Balance Fail");
        }
    }];

}

-(void)didDismissReprocessView {

    NSLog(@"DELEGATE");
    [self performSelector:@selector(restartCameraFeed) withObject:nil afterDelay:0.5];

}

-(void) viewWillAppear:(BOOL)animated
{
    

    [super viewWillAppear:animated];

    
    [self toggleReprocessBarButtonItem];

    
    [_drone connectToDrone];
    [[VideoPreviewer instance] setView:self.videoPreviewView];
    
    self.navigationController.toolbarHidden = NO;

    
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
    NSLog(@"restart camera DElegate");
    
   [self performSelector:@selector(restartCameraFeed) withObject:nil afterDelay:2.5];
  //  [self restartCameraFeed];
    return [[DismissingAnimationController alloc] init];
}




-(IBAction)presentProcessingView:(id)sender
{
    

    
//     mask = [[UIView alloc] initWithFrame:self.view.frame];
//    [mask setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.95]];
//    [self.view addSubview:mask];
  
    _drone.delegate = Nil;
    _groundStation.groundStationDelegate = nil;
    
    [_camera stopCameraSystemStateUpdates];
    [_drone disconnectToDrone];
    [[VideoPreviewer instance] setView:nil];
    [_connectionStatusLabel removeFromSuperview];
    [_drone.mainController stopUpdateMCSystemState];
    
    [_drone destroy];
    
    self.barStatus.title = @"Toggle S1 switch to gain control.";

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



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   // [segue.destinationViewController setDelegate:self];
}

- (void)didCloseReprocessView:(Reprocess*)viewController {
    [self restartCameraFeed];
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
           // [self restartCameraFeed];
            [connectionHud hide:YES];
            
          //  [self restartCameraFeed];
            break;
        }
        case ConnectionFailed:
        {
            NSLog(@"Connect Failed...");
            [connectionHud show:YES];
           // self.navigationItem.title = @"Connection Failed";
            connection = false;

            //self.connectionStatus.title = @"Connect Failed";
            break;
        }
        case ConnectionBroken:
        {
          //  self.navigationItem.title = @"Disconnected";
            connection = false;
            [connectionHud show:YES];

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

            self.barStatus.title = @"Starting Pano...";

            [self SDCardOperations];
           
        } else {
            
            [self.captureBtn setBackgroundImage:[UIImage imageNamed:@"pano.png"] forState:UIControlStateNormal];
            self.barStatus.title = @"Pano Cancelled";
            [self.cirlce setStrokeEnd:0 animated:NO];
            [_groundStation pauseGroundStationTask];
            shootPan = false;

        }

    } else {
        NSLog(@"1 Toggle S1 switch to top or tap ? for help");
        self.barStatus.title = @"Toggle S1 switch to top or tap ? for help";
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
          //  self.barStatus.title = [NSString stringWithFormat:@"In auto mode. Toggle S1 to gain control"];
            
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
    
    self.barStatus.title = [NSString stringWithFormat:@"In auto mode. Toggle S1 to gain control"];

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
                    
                    
                    [self.cirlce setStrokeEnd:0.0f animated:YES];
                    
                    self.barStatus.title = @"Toggle S1 Switch to gain control.";

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
            self.barStatus.title = @"Erasing SD Card..";
            [_camera formatSDCard:^(DJIError *error) {
                
                if (error.errorCode == ERR_Successed) {
                    // NSLog(@"Formated CD card");
                    self.barStatus.title = @"SD card erased";
                     [self processOperations];
                } else {
                    NSLog(@"error %@", error.errorDescription);
                    sleep(5);
                    [self eraseSDCardRetry];
                }
            }];
            
           
            
        }
    }
}

-(void)eraseSDCardRetry {
    self.barStatus.title = @"Erasing SD Card..(retry)";
    [_camera formatSDCard:^(DJIError *error) {
       
        if (error.errorCode == ERR_Successed) {
            // NSLog(@"Formated CD card");
            self.barStatus.title = @"SD card erased";
            [self processOperations];
        } else {
            NSLog(@"error %@", error.errorDescription);
            sleep(5);
            [self eraseSDCardRetry];
        }
    }];
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
                 
                 
                 [self processOperations];

                 
//                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
//                                                                 message:@"This App needs to ERASE the SD card. You will lose all data on the card"
//                                                                delegate:self
//                                                       cancelButtonTitle:@"Cancel"
//                                                       otherButtonTitles:@"Ok", nil];
//                 alert.tag = 10;
//                 [alert show];
                 
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

-(void)toggleReprocessBarButtonItem {
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *files = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    

    if (files.count > 5) {
        NSLog(@"images saved can reprocess");
        self.reprocessItem.enabled = YES;
    } else {
        self.reprocessItem.enabled = NO;

    }
    
}

@end
