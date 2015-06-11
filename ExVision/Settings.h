//
//  Settings.h
//  ExVision
//
//  Created by Jinah Adam on 16/4/15.
//  Copyright (c) 2015 Jinah Adam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+Bootstrap.h"
#import <DJISDK/DJISDK.h>


@interface Settings : UITableViewController {
    NSMutableArray *settingsArray;
    DJIDrone* _drone;
    DJICamera* _camera;
}

@property (nonatomic,strong) NSArray *data;

@property (strong, nonatomic) IBOutlet UITableView *table;

@property(nonatomic, strong) IBOutlet UIButton *save;
@property(nonatomic, strong) IBOutlet UISegmentedControl *scale;
@property(nonatomic, strong) IBOutlet UISegmentedControl *direction;

- (IBAction)directionChange:(UISegmentedControl *)sender;
- (IBAction)scaleChange:(UISegmentedControl *)sender;


@end
