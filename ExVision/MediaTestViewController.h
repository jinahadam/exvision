//
//  MediaTestViewController.h
//  DJISdkDemo
//
//  Created by Ares on 14-7-19.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>
#import "MagickWand.h"
#import "CVWrapper.h"


@class MediaLoadingManager;

@interface MediaTestViewController : UIViewController <DJIDroneDelegate, DJICameraDelegate>
{
    DJIDrone* _drone;
    DJIMediaManager* _mediaManager;
    MediaLoadingManager* _loadingManager;
    MagickWand * magick_wand;

    
    
    NSArray* _mediasList;
    BOOL _fetchingMedias;
}


@property IBOutlet UIImageView *image;
@property IBOutlet UILabel *status;
@property (retain) NSMutableArray* imagesForProcessing;

- (CGImageRef)resizedImage:(UIImage*)src to:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)croppedImage:(CGRect)bounds image:(UIImage*) src;
- (UIImage *)unwarpVisionImage:(CGImageRef)srcCGImage;

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