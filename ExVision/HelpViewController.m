//
//  HelpViewController.m
//  phantom2
//
//  Created by Jinah Adam on 10/6/15.
//  Copyright (c) 2015 Jinah Adam. All rights reserved.
//

#import "HelpViewController.h"
#import "GHWalkThroughView.h"

static NSString * const sampleDesc1 = @"Here are 3 steps to get you started";

static NSString * const sampleDesc2 = @"Connect your iPhone to the Phantom Wi-Fi.";

static NSString * const sampleDesc3 = @"Keep S1 switch in position 1 (upper).\nFly the Phantom to where you want to shoot.";

static NSString * const sampleDesc4 = @"Press the Start button. Your Phantom will yaw, take photos and generate a panorama automatically.";

static NSString * const sampleDesc5 = @"Your remote controller will not function once pano has started. So when its finished or if the need arises:\n\nRegain Control by Toggling S1 switch from Position 1 to 3";



@interface HelpViewController () <GHWalkThroughViewDataSource>

@property (nonatomic, strong) GHWalkThroughView* ghView ;

@property (nonatomic, strong) NSArray* descStrings;
@property (nonatomic, strong) NSArray* titleStrings;

@property (nonatomic, strong) UILabel* welcomeLabel;



@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _ghView = [[GHWalkThroughView alloc] initWithFrame:self.navigationController.view.bounds];
    [_ghView setCloseTitle:@"Close"];
    [_ghView setDataSource:self];
    [[_ghView skipButton] setHidden:true];
    
    [_ghView setWalkThroughDirection:GHWalkThroughViewDirectionVertical];
    UILabel* welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
    welcomeLabel.text = @"Welcome";
    welcomeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:40];
    welcomeLabel.textColor = [UIColor whiteColor];
    welcomeLabel.textAlignment = NSTextAlignmentCenter;
    self.welcomeLabel = welcomeLabel;
    self.titleStrings = @[@"Welcome", @"Connect", @"Fly", @"Pano", @"Caution"];
    self.descStrings = [NSArray arrayWithObjects:sampleDesc1,sampleDesc2, sampleDesc3, sampleDesc4, sampleDesc5, nil];
    
    self.ghView.isfixedBackground = NO;
    self.ghView.delegate = self;

    [self.ghView setWalkThroughDirection:GHWalkThroughViewDirectionHorizontal];
    [self.ghView showInView:self.navigationController.view animateDuration:0.3];
    
    
}


#pragma mark - GHDataSource

-(NSInteger) numberOfPages
{
    return 5;
}

- (void) configurePage:(GHWalkThroughPageCell *)cell atIndex:(NSInteger)index
{
    cell.title = [self.titleStrings objectAtIndexedSubscript:index];
    cell.titleImage = [UIImage imageNamed:[NSString stringWithFormat:@"page%ld", index+1]];
    cell.desc = [self.descStrings objectAtIndex:index];
    
}

- (UIImage*) bgImageforPage:(NSInteger)index
{
    NSString* imageName =[NSString stringWithFormat:@"page%d.png", index+1];
    UIImage* image = [UIImage imageNamed:imageName];
    return image;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)walkthroughDidDismissView:(GHWalkThroughView *)walkthroughView {
    NSLog(@"dismiss");
    [self.navigationController popViewControllerAnimated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
