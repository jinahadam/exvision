//
//  Reprocess.h
//  ExVision
//
//  Created by Jinah Adam on 28/5/15.
//  Copyright (c) 2015 Jinah Adam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "IDMPhotoBrowser.h"
@protocol RestartCameraFeedDelegate;


@interface Reprocess : UIViewController <IDMPhotoBrowserDelegate> {
    MBProgressHUD *hud;

}


@property (nonatomic, weak) id<RestartCameraFeedDelegate> delegate;


@end


@protocol RestartCameraFeedDelegate <NSObject>

- (void)didCloseReprocessView:(UIViewController*)viewController;

@end