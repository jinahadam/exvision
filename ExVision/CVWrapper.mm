//
//  CVWrapper.m
//  CVOpenTemplate
//
//  Created by Washe on 02/01/2013.
//  Copyright (c) 2013 foundry. All rights reserved.
//

#import "CVWrapper.h"
#import "UIImage+OpenCV.h"
#import "stitching.h"



@implementation CVWrapper


+ (UIImage*) processImageWithOpenCV: (UIImage*) inputImage
{
    NSArray* imageArray = [NSArray arrayWithObject:inputImage];
    UIImage* result = [[self class] processWithArray:imageArray];
    return result;
}

+ (UIImage*) processWithOpenCVImage1:(UIImage*)inputImage1 image2:(UIImage*)inputImage2;
{
    NSArray* imageArray = [NSArray arrayWithObjects:inputImage1,inputImage2,nil];
    UIImage* result = [[self class] processWithArray:imageArray];
    return result;
}

+ (UIImage*) processWithArray:(NSArray*)imageArray
{
    if ([imageArray count]==0){
        NSLog (@"imageArray is empty");
        return 0;
    }
    std::vector<cv::Mat> matImages;
    
    for (id image in imageArray) {
        if ([image isKindOfClass: [UIImage class]]) {
            cv::Mat matImage = [image CVMat3];
          //  NSLog (@"matImage: %@",image);
          //  NSLog(@"channels??? %d", matImage.channels());
            
//            //histogram equilize
//            std::vector<cv::Mat> channels;
//            cv::Mat img_hist_equalized;
//            cvtColor(matImage, img_hist_equalized, cv::COLOR_BGR2YCrCb); //change the color image from BGR to YCrCb format
//            split(img_hist_equalized,channels); //split the image into channels
//            equalizeHist(channels[0], channels[0]); //equalize histogram on the 1st channel (Y)
//            merge(channels,img_hist_equalized); //merge 3 channels including the modified 1st channel into one image
//        
//            cvtColor(img_hist_equalized, img_hist_equalized, cv::COLOR_YCrCb2BGR); //change the color image from YCrCb to BGR format (to display image properly)
//            
            
            
            
            
            matImages.push_back(matImage);
        }
    }
    NSLog (@"stitching...");
    cv::Mat stitchedMat = stitch (matImages);
    UIImage* result =  [UIImage imageWithCVMat:stitchedMat];
    return result;
}

@end
