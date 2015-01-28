//
//  LibraryViewController.h
//  ExVision
//
//  Created by Jinah Adam on 28/1/15.
//  Copyright (c) 2015 Jinah Adam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>

@class MediaLoadingManager;


@interface LibraryViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, DJIDroneDelegate, DJICameraDelegate>
{
    DJIDrone* _drone;
    DJIMediaManager* _mediaManager;
    MediaLoadingManager* _loadingManager;
    
    NSArray* _mediasList;
    BOOL _fetchingMedias;
}

@property(nonatomic, strong) IBOutlet UITableView* tableView;
@property(nonatomic, strong) UIActivityIndicatorView* loadingIndicator;

@end

typedef void (^MediaLoadingManagerTaskBlock)();

@interface MediaLoadingManager : NSObject {
    NSArray *_operationQueues;
    NSArray *_taskQueues;
    NSUInteger _imageThreads;
    NSUInteger _videoThreads;
    NSUInteger _mediaIndex;
}

- (id)initWithThreadsForImage:(NSUInteger)imageThreads threadsForVideo:(NSUInteger)videoThreads;

- (void)addTaskForMedia:(DJIMedia *)media withBlock:(MediaLoadingManagerTaskBlock)block;

- (void)cancelAllTasks;


@end
