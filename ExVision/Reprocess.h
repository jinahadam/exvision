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
@protocol ReprocessDelegate;


@interface Reprocess : UIViewController <IDMPhotoBrowserDelegate>


@property (nonatomic, weak) id<ReprocessDelegate> delegate;


@end


@protocol ReprocessDelegate <NSObject>

- (void)didCloseReprocessView:(Reprocess*)viewController;

@end