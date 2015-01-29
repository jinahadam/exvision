//
//  SettingsViewController.h
//  ExVision
//
//  Created by Jinah Adam on 29/1/15.
//  Copyright (c) 2015 Jinah Adam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>

@interface SettingsItem : NSObject

@property(nonatomic, retain) NSMutableArray* subSettings;
@property(nonatomic, retain) NSString* itemName;
@property(nonatomic, retain) NSValue* itemValue;
@property(nonatomic, assign) SEL itemAction;
@property(nonatomic, assign) BOOL isSubItem;

-(id) initWithItemName:(NSString*)name;

@end


@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    
    NSMutableArray* _mainSettingItems;
    SettingsItem* _selectedItem;
    DJICamera* _cameraManager;
    
    CameraRecordingFovType _fovType;
    CameraRecordingResolutionType _resolutionType;
}

@property(nonatomic, assign) CameraCaptureMode captureMode;
@property(nonatomic) IBOutlet UITableView* tableView1;
@property(nonatomic) IBOutlet UITableView* tableView2;

-(void) setCamera:(DJICamera*)cameraManager;

@end

