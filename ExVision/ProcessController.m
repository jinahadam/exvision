//
//  MediaTestViewController.m
//  DJISdkDemo
//
//  Created by Ares on 14-7-19.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import "ProcessController.h"
//#import "MediaPreviewViewController.h"
#import <DJISDK/DJISDK.h>






#define TOPCUT 150
#define ADJUST_EXPOSURE 1.2f
#define ADJUST_SAT 1.4f


#define ThrowWandException(wand) { \
char * description; \
ExceptionType severity; \
\
description = MagickGetException(wand,&severity); \
(void) fprintf(stderr, "%s %s %lu %s\n", GetMagickModule(), description); \
description = (char *) MagickRelinquishMemory(description); \
exit(-1); \
}



@implementation ProcessController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _drone = [[DJIDrone alloc] initWithType:DJIDrone_Phantom];
    _drone.camera.delegate = self;
    _drone.delegate = self;
    _loadingManager = [[MediaLoadingManager alloc] initWithThreadsForImage:4 threadsForVideo:4];
    _fetchingMedias = NO;
    
    self.imagesForProcessing = [[NSMutableArray alloc] init];
    
//    UIImage *t = [UIImage imageNamed:@"image.jpg"];
//   
//    CIImage *inputImage = [[CIImage alloc] initWithImage:t];
//    
//    
//    
//    CIFilter *exposureAdjustmentFilter = [CIFilter filterWithName:@"CIExposureAdjust"];
//    [exposureAdjustmentFilter setDefaults];
//    [exposureAdjustmentFilter setValue:inputImage forKey:@"inputImage"];
//    [exposureAdjustmentFilter setValue:[NSNumber numberWithFloat:1.3f] forKey:@"inputEV"];
//    CIImage *outputImage = [exposureAdjustmentFilter valueForKey:@"outputImage"];
//    //saturation
//    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
//    [filter setValue:outputImage forKey:kCIInputImageKey];
//    [filter setValue:@1.5f forKey:kCIInputSaturationKey];
//    
//    CIImage *outp = [filter valueForKey:@"outputImage"];
//    
//    
//    
//    CIContext *context = [CIContext contextWithOptions:nil];
//    self.image.image = [UIImage imageWithCGImage:[context createCGImage:outp fromRect:outp.extent]];
//    
//    
//    pano =self.image.image;
    
    self.barStatus.title = @"Preparing for download...";
    
    
//    self.image.image =[UIImage imageNamed:@"image.jpg"];
//
//    self.scrollview.hidden = true;
//    self.scrollview = [[UIScrollView alloc]initWithFrame:self.view.bounds];
//    [self.scrollview addSubview:self.image];
//    self.scrollview.contentSize = pano.size;
//    self.scrollview.minimumZoomScale = 0.25f;
//    self.scrollview.maximumZoomScale = 3.0f;
//    self.scrollview.delegate = self;
//    [self.view addSubview:self.scrollview];
//    
//    
//    [self performSelector:@selector(timeout) withObject:nil afterDelay:0.5];
//
    
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight = self.view.frame.size.height;
    
    CGFloat x = 0;
    CGFloat y = 0;
    
    if(viewWidth < screenWidth) {
        x = screenWidth / 2;
    }
    if(viewHeight < screenHeight) {
        y = screenHeight / 3 ;
    }
    
    self.scrollview.contentInset = UIEdgeInsetsMake(y, x, y, x);
}


-(void)timeout {
    self.scrollview.zoomScale = 0.25;
    sleep(1);
    self.scrollview.hidden = false;

}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
  //  NSLog(@"viewForZoomingInScrollView");
  //  NSLog(@"%f", self.scrollview.zoomScale);
    return self.image;
    
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
    
    downloadStatus = [[NSMutableDictionary alloc] initWithCapacity:_mediasList.count];
    
    if (_mediasList.count > 0) {
    for (int i = 0; i < _mediasList.count; i++) {
        [downloadStatus setObject:[NSNumber numberWithInt:0] forKey:[NSNumber numberWithInt:i]];
    }
    
    [self downloadImageOfIndex:0];
    }

}


-(void)downloadImageOfIndex:(int)idx {

    DJIMedia *m = [_mediasList objectAtIndex:idx];
    NSMutableData* mediaData = [[NSMutableData alloc] init];
    
    
    [m fetchMediaData:^(NSData *data, BOOL *stop, NSError *error) {
        if (*stop) {
            if (error) {
             NSLog(@"failed :%d index, %@ %ld", idx, error.description, (long)error.code);
                [self downloadImageOfIndex:idx];
   
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    CGSize imageSize = CGSizeMake(2192/1.5, 1644/1.5);
                    UIImage *unwarped = [self unwarpVisionImage:[self resizedImage:[UIImage imageWithData:mediaData] to:imageSize interpolationQuality:kCGInterpolationHigh]];
                    
                    CGRect boundsToCrop = CGRectMake(0, TOPCUT, [unwarped size].width, [unwarped size].height);
                    
                    UIImage *TopCutOff = [self croppedImage:boundsToCrop image:unwarped];
                    [self.imagesForProcessing addObject:TopCutOff];
                    
                    if (idx < _mediasList.count - 1)
                        [self downloadImageOfIndex:idx+1];
                    
                    
                    int images_remaining = _mediasList.count - self.imagesForProcessing.count;
                    
                    self.barStatus.title  = [NSString stringWithFormat:@"Downloading: %d of %lu ",idx + 1, (unsigned long)_mediasList.count];
                    
                    if (images_remaining == 0) {
                        self.barStatus.title  = @"Processing Pano";
                        
                        
                        
                        
                        
                        [self processImages];
                    }
                });
            }
        }
        else
        {
            if (data && data.length > 0) {
                [mediaData appendData:data];
            }
        }
    }];

}





-(void) processImages {
    __block UIImage *result;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        
        
        UIImage *uncropped =[CVWrapper processWithArray:self.imagesForProcessing];
        
        
    CGRect boundsToCrop = CGRectMake(200, 100, [uncropped size].width - 400, [uncropped size].height-250);
        //CGRect boundsToCrop = CGRectMake(0, 0, [uncropped size].width, [uncropped size].height);
        
       // NSLog(@"%f %f SIZE", [uncropped size].width-20, [uncropped size].height-100);
        
        
        //exposure adjustment
        CIImage *inputImage = [[CIImage alloc] initWithImage:[self croppedImage:boundsToCrop image:uncropped]];
        
        
        
        CIFilter *exposureAdjustmentFilter = [CIFilter filterWithName:@"CIExposureAdjust"];
        [exposureAdjustmentFilter setDefaults];
        [exposureAdjustmentFilter setValue:inputImage forKey:@"inputImage"];
        [exposureAdjustmentFilter setValue:[NSNumber numberWithFloat:ADJUST_EXPOSURE] forKey:@"inputEV"];
        CIImage *outputImage = [exposureAdjustmentFilter valueForKey:@"outputImage"];
        //saturation
        CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
        [filter setValue:outputImage forKey:kCIInputImageKey];
        [filter setValue:[NSNumber numberWithFloat:ADJUST_SAT] forKey:kCIInputSaturationKey];
        
        CIImage *outp = [filter valueForKey:@"outputImage"];

        
        
        CIContext *context = [CIContext contextWithOptions:nil];
        result = [UIImage imageWithCGImage:[context createCGImage:outp fromRect:outp.extent]];
        
        
        
        UIImageWriteToSavedPhotosAlbum(result, nil, nil, nil);
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            self.image.image = result;
            pano = result;
            self.barStatus.title  = @"Done";
            
            self.scrollview = [[UIScrollView alloc]initWithFrame:self.view.bounds];
            [self.scrollview addSubview:self.image];
            self.scrollview.contentSize = pano.size;
            self.scrollview.minimumZoomScale = 0.25f;
            self.scrollview.maximumZoomScale = 3.0f;
            self.scrollview.delegate = self;
            [self.view addSubview:self.scrollview];
            
            
            [self performSelector:@selector(timeout) withObject:nil afterDelay:0.5];
            
        });
    });
}



-(void) updateMedias
{
    if (_mediasList) {
        return;
    }
    
    if (_fetchingMedias) {
        return;
    }

    self.barStatus.title = @"Start Fetch Medias";
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


#pragma "Wand and CV"


- (UIImage *)croppedImage:(CGRect)bounds
                    image:(UIImage*) src {
    CGFloat scale = MAX(src.scale, 1.0f);
    CGRect scaledBounds = CGRectMake(bounds.origin.x * scale, bounds.origin.y * scale, bounds.size.width * scale, bounds.size.height * scale);
    CGImageRef imageRef = CGImageCreateWithImageInRect([src CGImage], scaledBounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:src.scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    return croppedImage;
}



- (CGImageRef)resizedImage:(UIImage*)src
                        to:(CGSize)newSize
      interpolationQuality:(CGInterpolationQuality)quality {
    
    
    
    CGFloat scale = MAX(1.0f, src.scale);
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width*scale, newSize.height*scale));
    //    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = src.CGImage;
    
    // Fix for a colorspace / transparency issue that affects some types of
    // images. See here: http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/comment-page-2/#comment-39951
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmap = CGBitmapContextCreate(
                                                NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                8, /* bits per channel */
                                                (newRect.size.width * 4), /* 4 channels per pixel * numPixels/row */
                                                colorSpace,
                                                (CGBitmapInfo)kCGImageAlphaPremultipliedLast
                                                );
    CGColorSpaceRelease(colorSpace);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    // UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:src.scale orientation:UIImageOrientationUp];
    
    // Clean up
    CGContextRelease(bitmap);
    //CGImageRelease(newImageRef);
    
    return newImageRef;
}




- (UIImage *)unwarpVisionImage:(CGImageRef)srcCGImage {
    
    const unsigned long width = CGImageGetWidth(srcCGImage);
    const unsigned long height = CGImageGetHeight(srcCGImage);
    const char *map = "ARGB"; // hard coded
    const StorageType inputStorage = CharPixel;
    CGImageRef standardized = createStandardImage(srcCGImage);
    NSData *srcData = (NSData *) CFBridgingRelease(CGDataProviderCopyData(CGImageGetDataProvider(standardized)));
    CGImageRelease(standardized);
    const void *bytes = [srcData bytes];
    MagickWandGenesis();
    MagickWand * magick_wand_local= NewMagickWand();
    MagickBooleanType status = MagickConstituteImage(magick_wand_local, width, height, map, inputStorage, bytes);
    if (status == MagickFalse) {
        ThrowWandException(magick_wand_local);
    }
    double points[8];
    points[0] = 0.1194435;
    points[1] = -0.354597;
    points[2] = -0.018339;
    
    status = MagickDistortImage(magick_wand_local, BarrelDistortion, 3, points, MagickFalse);
    
    if (status == MagickFalse) {
        ThrowWandException(magick_wand_local);
    }
    const int bitmapBytesPerRow = (int)(width * strlen(map));
    const int bitmapByteCount = (int)(bitmapBytesPerRow * height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    char *trgt_image = malloc(bitmapByteCount);
    status = MagickExportImagePixels(magick_wand_local, 0, 0, width, height, map, CharPixel, trgt_image);
    if (status == MagickFalse) {
        ThrowWandException(magick_wand_local);
    }
    magick_wand_local = DestroyMagickWand(magick_wand_local);
    MagickWandTerminus();
    CGContextRef context = CGBitmapContextCreate (trgt_image,
                                                  width,
                                                  height,
                                                  8, // bits per component
                                                  bitmapBytesPerRow,
                                                  colorSpace,
                                                  (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    CGImageRef cgimage = CGBitmapContextCreateImage(context);
    UIImage *image = [[UIImage alloc] initWithCGImage:cgimage];
    CGImageRelease(cgimage);
    CGContextRelease(context);
    free(trgt_image);
    return image;
}


CGImageRef createStandardImage(CGImageRef image) {
    const size_t width = CGImageGetWidth(image);
    const size_t height = CGImageGetHeight(image);
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, 4*width, space,
                                             kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(space);
    CGContextDrawImage(ctx, CGRectMake(0, 0, width, height), image);
    CGImageRef dstImage = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    return dstImage;
}

-(IBAction)share:(id)sender {
    [self shareText:@"Vision+ Pano" andImage:pano andUrl:[NSURL
                                                          URLWithString:@"http://google.com"]];
}


- (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url
{
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    if (text) {
        [sharingItems addObject:text];
    }
    if (image) {
        [sharingItems addObject:image];
    }
    if (url) {
        [sharingItems addObject:url];
    }
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
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

