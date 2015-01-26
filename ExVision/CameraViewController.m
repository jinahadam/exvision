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
    _drone.gimbal.delegate = self;
    
    
    //Start video data decode thread
    [[VideoPreviewer instance] start];
    
}

-(void) dealloc
{
    [_drone destroy];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
    
    [_drone connectToDrone];
    [_camera startCameraSystemStateUpdates];
    [[VideoPreviewer instance] setView:self.videoPreviewView];
    
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_camera stopCameraSystemStateUpdates];
    [_drone disconnectToDrone];
    [[VideoPreviewer instance] setView:nil];
    [_connectionStatusLabel removeFromSuperview];
    [_drone destroy];
    
}


-(IBAction) onTakePhotoButtonClicked:(id)sender
{
    [_camera startTakePhoto:CameraSingleCapture withResult:^(DJIError *error) {
        if (error.errorCode != ERR_Successed) {
            NSLog(@"Take Photo Error : %@", error.errorDescription);
        } else {
            NSLog(@"picture taken");
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
    if (!systemState.isTimeSynced) {
        [_camera syncTime:nil];
    }
    if (systemState.isUSBMode) {
        [_camera setCamerMode:CameraCameraMode withResultBlock:Nil];
    }
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

@end
