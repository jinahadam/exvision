//
//  ViewController.h
//  ExVision
//
//  Created by Jinah Adam on 26/1/15.
//  Copyright (c) 2015 Jinah Adam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>



@interface ViewController : UIViewController <DJIDroneDelegate, GroundStationDelegate>
{
    DJIDrone* _drone;
    NSObject<DJIGroundStation>* _groundStation;
    UILabel* _connectionStatusLabel;
    
    CLLocationCoordinate2D _homeLocation;
}

@property(nonatomic, strong) IBOutlet UILabel* satelliteLabel;
@property(nonatomic, strong) IBOutlet UILabel* homeLocationLabel;
@property(nonatomic, strong) IBOutlet UILabel* droneLocationLabel;
@property(nonatomic, strong) IBOutlet UILabel* contrlModeLabel;

-(IBAction) onOpenButtonClicked:(id)sender;

-(IBAction) onCloseButtonClicked:(id)sender;

-(IBAction) onUploadTaskClicked:(id)sender;

-(IBAction) onDownloadTaskClicked:(id)sender;

-(IBAction) onStartTaskButtonClicked:(id)sender;

-(IBAction) onPauseTaskButtonClicked:(id)sender;

-(IBAction) onContinueTaskButtonClicked:(id)sender;

-(IBAction) onGoHomeButtonClicked:(id)sender;

@end

