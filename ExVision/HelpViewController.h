//
//  HelpViewControlleer.h
//  ExVision
//
//  Created by Jinah Adam on 7/4/15.
//  Copyright (c) 2015 Jinah Adam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+Bootstrap.h"
#import "PageContentViewController.h"


@interface HelpViewController : UIViewController <UIPageViewControllerDataSource>

- (IBAction)startWalkthrough:(id)sender;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageDescriptions;
@property (strong, nonatomic) NSArray *pageImages;

-(IBAction)dismiss:(id)sender;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *close;

@end
