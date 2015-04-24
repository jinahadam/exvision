#include "stitching.h"
#include <iostream>
#include <fstream>
#import <opencv2/opencv.hpp>
#import <opencv2/highgui.hpp>
#import <opencv2/stitching.hpp>

//#include "opencv2/highgui/highgui.h"
//#include "opencv2/stitching/stitcher.hpp"

using namespace std;
using namespace cv;

bool try_use_gpu = false;
vector<Mat> imgs;
string result_name = "result.jpg";

int parseCmdArgs(int argc, char** argv);

cv::Mat stitch (vector<Mat>& images)
{
    imgs = images;
    Mat pano;
    Stitcher stitcher = Stitcher::createDefault(try_use_gpu);
    
//    stitcher.setFeaturesFinder(makePtr<detail::OrbFeaturesFinder>(Size(3,1),3000,1.3f,5));
//    stitcher.setRegistrationResol(0.2);
//    stitcher.setSeamEstimationResol(0.3);
//    stitcher.setCompositingResol(1);
//    stitcher.setPanoConfidenceThresh(1);
//    stitcher.setFeaturesMatcher(makePtr<detail::BestOf2NearestMatcher>(false, 0.3f));
//    
//    stitcher.setWaveCorrection(true);
//  //  stitcher.setWaveCorrectKind(detail::WAVE_CORRECT_VERT);

    Stitcher::Status status = stitcher.stitch(imgs, pano);
    
    if (status != Stitcher::OK)
        {
        cout << "Can't stitch images, error code = " << int(status) << endl;
            //return 0;
        }
    return pano;
}


//all input passed in via CVWrapper to stitcher function
int parseCmdArgs(int argc, char** argv)
{
    if (argc == 1)
    {
        return -1;
    }
    for (int i = 1; i < argc; ++i)
    {
        if (string(argv[i]) == "--help" || string(argv[i]) == "/?")
        {
            return -1;
        }
        else if (string(argv[i]) == "--try_use_gpu")
        {
            if (string(argv[i + 1]) == "no")
                try_use_gpu = false;
            else if (string(argv[i + 1]) == "yes")
                try_use_gpu = true;
            else
            {
                cout << "Bad --try_use_gpu flag value\n";
                return -1;
            }
            i++;
        }
        else if (string(argv[i]) == "--output")
        {
            result_name = argv[i + 1];
            i++;
        }
        else
        {
            Mat img = imread(argv[i]);
            if (img.empty())
            {
                cout << "Can't read image '" << argv[i] << "'\n";
                return -1;
            }
            imgs.push_back(img);
        }
    }
    return 0;
}


