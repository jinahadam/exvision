//
//  MediaTestViewController.m
//  DJISdkDemo
//
//  Created by Ares on 14-7-19.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import "MediaTestViewController.h"
//#import "MediaPreviewViewController.h"
#import <DJISDK/DJISDK.h>

@implementation MediaTestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _drone = [[DJIDrone alloc] initWithType:DJIDrone_Phantom];
    _drone.camera.delegate = self;
    _drone.delegate = self;
    _loadingManager = [[MediaLoadingManager alloc] initWithThreadsForImage:4 threadsForVideo:4];
    _fetchingMedias = NO;
    
    
    self.status.text = @"Preparing for download...";
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_drone connectToDrone];
    [_drone.camera startCameraSystemStateUpdates];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_drone.camera stopCameraSystemStateUpdates];
    [_drone disconnectToDrone];
    [_drone destroy];
}

-(IBAction)download:(id)sender {
    
   // DJIMedia *m = [_mediasList objectAtIndex:1];
    
    //    [_mediasList enumerateObjectsUsingBlock:^(DJIMedia *media, NSUInteger idx, BOOL *stop) {
    //        NSLog(@"downloading.... %@", media.mediaURL);
    //
    //
    //
    //
    //    }];
   // __block long long totalDownload = 0;
    
//    for (int i = 0; i < _mediasList.count; i++) {
//        DJIMedia *m = [_mediasList objectAtIndex:i];
//        totalDownload = totalDownload + m.fileSize;
//    }
    
    __block long long filesDownloaded = 0;

//
    for (int i = 0; i < _mediasList.count; i++) {
        DJIMedia *m = [_mediasList objectAtIndex:i];
        
        
      //  long long fileSize = m.fileSize;
        NSMutableData* mediaData = [[NSMutableData alloc] init];
        
        [m fetchMediaData:^(NSData *data, BOOL *stop, NSError *error) {
            if (*stop) {
                if (error) {
                    NSLog(@"fetchMediaDataError:%@", error);
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.image.image = [UIImage imageWithData:mediaData];
                        filesDownloaded = filesDownloaded + 1;
                        
                        self.status.text = [NSString stringWithFormat:@"downloading %d of %i", (int)filesDownloaded, _mediasList.count];
                        
                    });
                }
            }
            else
            {
                if (data && data.length > 0) {
                    [mediaData appendData:data];
                  //  fileTotaldownloaded += data.length;
                  //  int progress = (int)(fileTotaldownloaded*100 / fileSize);
                   // NSLog(@"Progress on Image %@ : %d",m.fileName, progress);
                }
            }
        }];
    }


//    NSURL *url = [NSURL URLWithString:m.mediaURL];
//
//    NSURLSessionDownloadTask *downloadPhotoTask = [[NSURLSession sharedSession]
//                                                   downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
//                                                       
//                                                       NSLog(@"download error %@", error.description);
//                                                       
//                                                       NSData *d =  [NSData dataWithContentsOfURL:location];
//                                                       
//                                                       NSLog(@"data %d", d.length);
//
//                                                       
//                                                       UIImage *downloadedImage = [UIImage imageWithData:d];
//                                                       //self.image.image = downloadedImage;
//                                                       
//                                                   }];
//    
//    
//    [downloadPhotoTask resume];
    
//    [_mediasList enumerateObjectsUsingBlock:^(DJIMedia *media, NSUInteger idx, BOOL *stop) {
//        NSLog(@"downloading.... %@", media.mediaURL);
//        
//      
//        
//        
//    }];
}

-(void) updateMedias
{
    if (_mediasList) {
        return;
    }
    
    if (_fetchingMedias) {
        return;
    }
    NSLog(@"Start Fetch Medias");
    _fetchingMedias = YES;
    [_drone.camera fetchMediaListWithResultBlock:^(NSArray *mediaList, NSError *error) {
     //   [self hideLoadingIndicator];
        if (mediaList) {
            _mediasList = mediaList;
            NSLog(@"MediaDirs: %@", _mediasList);
            [self download:nil];
        }
        
        _fetchingMedias = NO;
    }];
    
 
}

#pragma mark - DJIDroneDelegate

-(void) droneOnConnectionStatusChanged:(DJIConnectionStatus)status
{
    if (status == ConnectionSuccessed) {
        [_drone.camera setCamerMode:CameraUSBMode withResultBlock:^(DJIError *error) {
            
        }];
    }
}

-(void) camera:(DJICamera*)camera didReceivedVideoData:(uint8_t*)videoBuffer length:(int)length
{
    
}

-(void) camera:(DJICamera*)camera didUpdateSystemState:(DJICameraSystemState*)systemState
{
    if (!systemState.isUSBMode) {
        NSLog(@"Set USB Mode");
        [_drone.camera setCamerMode:CameraUSBMode withResultBlock:^(DJIError *error) {
            if (error.errorCode == ERR_Successed) {
                NSLog(@"Set USB Mode Successed");
            }
        }];
    }
    if (!systemState.isSDCardExist) {
        NSLog(@"SD Card Not Insert");
        return;
    }
    if (systemState.isConnectedToPC) {
        NSLog(@"USB Connected To PC");
        return;
    }
    
    [self updateMedias];
}
@end

@interface MediaContextLoadingTask : NSObject

@property (strong, nonatomic) DJIMedia *media;
@property (copy, nonatomic) MediaLoadingManagerTaskBlock block;

@end

@implementation MediaContextLoadingTask

@end

@implementation MediaLoadingManager

- (id)initWithThreadsForImage:(NSUInteger)imageThreads threadsForVideo:(NSUInteger)videoThreads {
    self = [super init];
    if (self) {
        NSAssert(imageThreads >= 1, @"number of threads for image must be greater than 0.");
        NSAssert(videoThreads >= 1, @"number of threads for video must be greater than 0.");
        
        _imageThreads = imageThreads;
        _videoThreads = videoThreads;
        _mediaIndex = 0;
        
        NSMutableArray *operationQueues = [NSMutableArray arrayWithCapacity:_imageThreads + _videoThreads];
        for (NSUInteger i = 0; i < _imageThreads; i++) {
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [queue setName:[NSString stringWithFormat:@"MediaDownloadManager image %u", i]];
            [queue setMaxConcurrentOperationCount:1];
            [operationQueues addObject:queue];
        }
        
        for (NSUInteger i = 0; i < _videoThreads; i++) {
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [queue setName:[NSString stringWithFormat:@"MediaDownloadManager video %u", i]];
            [queue setMaxConcurrentOperationCount:1];
            [operationQueues addObject:queue];
        }
        
        _operationQueues = operationQueues;
        
        NSMutableArray *taskQueues = [NSMutableArray arrayWithCapacity:_imageThreads + _videoThreads];
        for (NSUInteger i = 0; i < _imageThreads + _videoThreads; i++) {
            [taskQueues addObject:[NSMutableArray array]];
        }
        
        _taskQueues = taskQueues;
    }
    return self;
}

- (void)addTaskForMedia:(DJIMedia *)media withBlock:(MediaLoadingManagerTaskBlock)block {
    NSUInteger threadIndex;
    if (media.mediaType == MediaTypeJPG) {
        threadIndex = _mediaIndex % _imageThreads;
    }
    else {
        threadIndex = _imageThreads + _mediaIndex % _videoThreads;
    }
    _mediaIndex++;
    
    NSMutableArray *taskQueue = [_taskQueues objectAtIndex:threadIndex];
    @synchronized(taskQueue) {
        MediaContextLoadingTask *task = [[MediaContextLoadingTask alloc] init];
        task.media = media;
        task.block = block;
        
        [taskQueue addObject:task];
    }
    
    NSOperationQueue *operationQueue = [_operationQueues objectAtIndex:threadIndex];
    if (operationQueue.operationCount == 0) {
        [self driveTaskQueue:@(threadIndex)];
    }
}

- (void)driveTaskQueue:(NSNumber *)threadIndex {
    NSMutableArray *taskQueue = [_taskQueues objectAtIndex:threadIndex.integerValue];
    NSOperationQueue *operationQueue = [_operationQueues objectAtIndex:threadIndex.integerValue];
    
    @synchronized(taskQueue) {
        if (taskQueue.count == 0) {
            return;
        }
        
        MediaContextLoadingTask *task = [taskQueue lastObject];
        [taskQueue removeLastObject];
        
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            task.block();
            [self driveTaskQueue:threadIndex];
        }];
        [operationQueue addOperation:operation];
    }
}

- (void)cancelAllTasks {
    for (NSMutableArray *taskQueue in _taskQueues) {
        @synchronized(taskQueue) {
            [taskQueue removeAllObjects];
        }
    }
    
    for (NSOperationQueue *queue in _operationQueues) {
        [queue cancelAllOperations];
    }
}

@end

