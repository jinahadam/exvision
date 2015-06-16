//
//  Reprocess.m
//  ExVision
//
//  Created by Jinah Adam on 28/5/15.
//  Copyright (c) 2015 Jinah Adam. All rights reserved.
//

#import "Reprocess.h"
#import "CVWrapper.h"


#define CROP_TOP 0
#define CROP_WIDTH 20
#define ADJUST_EXPOSURE 1.0f
#define ADJUST_SAT 1.04f


@interface Reprocess ()

@end

@implementation Reprocess

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self reprocessFromDisk];
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}



-(void)reprocessFromDisk {
    NSArray *filenames = @[@"1.JPG",@"2.JPG",@"3.JPG",@"4.JPG",@"5.JPG",@"6.JPG",@"7.JPG"];
    NSMutableArray *images = [NSMutableArray array];
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText  = @"Reprocessing Pano";
  //  hud.detailsLabelText = @"Please don't switch off the Phantom/Wifi Extendor";
    
    
    [hud show:YES];
    
    for (NSString *name in filenames) {
        NSString *workSpacePath=[[self applicationDocumentsDirectory] stringByAppendingPathComponent:name];
        [images addObject: [UIImage imageWithData:[NSData dataWithContentsOfFile:workSpacePath]]];
    }
    
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        UIImage *uncropped =[CVWrapper processWithArray:images];
        
        CIImage *inputImage = [[CIImage alloc] initWithImage:uncropped];//[self croppedImage:boundsToCrop image:uncropped]];
        
        
        
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
        UIImage *result = [UIImage imageWithCGImage:[context createCGImage:outp fromRect:outp.extent]];
        
        

        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates

            [hud hide:YES];
            
            UIImageWriteToSavedPhotosAlbum(result, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);


            IDMPhoto *photo = [IDMPhoto photoWithImage:result];
            IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:[NSArray arrayWithObjects:photo, nil]];
            browser.delegate = self;


            
            [self presentViewController:browser animated:YES completion:nil];
            
            
        });
    });
    
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    UIAlertView *alert;
    NSLog(@"Image saved");
    
    if (error)
        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                           message:@"Unable to save image to Camera Roll."
                                          delegate:self cancelButtonTitle:@"Ok"
                                 otherButtonTitles:nil];
    else
        alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                           message:@"Image saved to Camera Roll."
                                          delegate:self cancelButtonTitle:@"Ok"
                                 otherButtonTitles:nil];
    [alert show];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




-(void)photoBrowser:(IDMPhotoBrowser *)photoBrowser didDismissAtPageIndex:(NSUInteger)index {
    
    id<RestartCameraFeedDelegate> strongDelegate = self.delegate;
    
    // Our delegate method is optional, so we should
    // check that the delegate implements it
    if ([strongDelegate respondsToSelector:@selector(didCloseReprocessView:)]) {
        [strongDelegate didCloseReprocessView:self];
    }
    
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
}

@end
