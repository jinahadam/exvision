//
//  Settings.m
//  ExVision
//
//  Created by Jinah Adam on 16/4/15.
//  Copyright (c) 2015 Jinah Adam. All rights reserved.
//

#import "Settings.h"


@interface Settings ()

@end

@implementation Settings

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.save warningStyle];
    
    
    settingsArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"settings"]mutableCopy];

    int direction = (int)[[settingsArray objectAtIndex:0] integerValue];
    
    if (direction == 0) {
        [self.direction setSelectedSegmentIndex:0];
    } else {
        [self.direction setSelectedSegmentIndex:1];

    }
    
    NSNumber *scale = [settingsArray objectAtIndex:1];
    if ([scale integerValue] == 180)
    {
        [self.scale setSelectedSegmentIndex:0];
    } else {
        [self.scale setSelectedSegmentIndex:1];
    }
    

    self.view.layer.cornerRadius = 8.f;
    
    
    _drone = [[DJIDrone alloc] initWithType:DJIDrone_Phantom];
    _camera = _drone.camera;
    
    [_camera setCameraExposureCompensation:CameraExposureCompensationP17 withResultBlock:^(DJIError *error) {
        if (error.errorCode == ERR_Successed) {
            NSLog(@"Set Exposure Compensation Success");
        }
        else{
            NSLog(@"Set Exposure Compensation Failed");
        }
    }];
    
    
    
}

-(void)dealloc {
    _camera = nil;
    _drone = nil;
}

-(void) viewWillDisappear:(BOOL)animated
{
    NSLog(@"vuew will disappaer");
    [super viewWillDisappear:animated];
    [_drone.camera stopCameraSystemStateUpdates];
    [_drone disconnectToDrone];
    [_drone destroy];
}

-(IBAction)directionChange:(UISegmentedControl *)sender {
    NSNumber *scale = [NSNumber numberWithInt:(int)[sender selectedSegmentIndex]];
    [settingsArray replaceObjectAtIndex:0 withObject:scale];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:settingsArray forKey:@"settings"];
    [userDefaults synchronize];

}

-(IBAction)scaleChange:(UISegmentedControl *)sender {
    
    int val = 0;
    if ((int)[sender selectedSegmentIndex] == 0) {
        val = 180;
    } else {
        val = 360;
    }
    
    NSNumber *direction = [NSNumber numberWithInt:val];
    
    
    [settingsArray replaceObjectAtIndex:1 withObject:direction];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:settingsArray forKey:@"settings"];
    [userDefaults synchronize];


}

- (IBAction)didClickOnClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
