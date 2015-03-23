//
//  ViewController.h
//  ExVision
//
//  Created by Jinah Adam on 26/1/15.
//  Copyright (c) 2015 Jinah Adam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>



@interface ViewController : UIViewController <DJIDroneDelegate, GroundStationDelegate, DJICameraDelegate>
{
    DJIDrone* _drone;
    DJICamera* _camera;
    

    NSObject<DJIGroundStation>* _groundStation;
    UILabel* _connectionStatusLabel;
    
    CLLocationCoordinate2D _homeLocation;

    NSString *wp_index;


}

@property(nonatomic, strong) IBOutlet UILabel* satelliteLabel;
@property(nonatomic, strong) IBOutlet UILabel* homeLocationLabel;
@property(nonatomic, strong) IBOutlet UILabel* droneLocationLabel;
@property(nonatomic, strong) IBOutlet UILabel* contrlModeLabel;
@property(nonatomic, strong) IBOutlet UILabel* logLabel;
@property(nonatomic, strong) IBOutlet UILabel* targetWp;
@property(nonatomic, strong) IBOutlet UILabel* altitude;
@property(nonatomic, strong) IBOutlet UILabel* targetAltitude;


-(IBAction) onOpenButtonClicked:(id)sender;

-(IBAction) onCloseButtonClicked:(id)sender;


-(IBAction) onDownloadTaskClicked:(id)sender;

-(IBAction) onStartTaskButtonClicked:(id)sender;

-(IBAction) onPauseTaskButtonClicked:(id)sender;

-(IBAction) onContinueTaskButtonClicked:(id)sender;

-(IBAction) onGoHomeButtonClicked:(id)sender;

-(IBAction) onTakePhotoButtonClicked:(id)sender;

@end




