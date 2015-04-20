//
//  ConfirmButton.m
//  PopDemo
//
//  Created by Ben Scheirman on 5/18/14.
//  Copyright (c) 2014 Fickle Bits. All rights reserved.
//

#import "CaptureButton.h"
#import "Pop.h"

@interface CaptureButton () {
    BOOL _isToggled;
    CGRect initialBounds;
}

@end

@implementation CaptureButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.layer.backgroundColor = [[UIColor colorWithRed:240/255.0 green:173/255.0 blue:78/255.0 alpha:1] CGColor];
    self.layer.cornerRadius = 45;

    initialBounds = self.bounds;
    
    [self addTarget:self action:@selector(tap)
   forControlEvents:UIControlEventTouchUpInside];
    
   // UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
   // [self addGestureRecognizer:tap];
}

- (void)tap {//:(UITapGestureRecognizer *)recognizer {
 
    NSLog(@"tap ");
    
    
   // NSLog(@"tap");
    
    _isToggled = !_isToggled;
    UIColor *targetColor;
    CGRect targetBounds;
    CGFloat targetRadius;
    
    if (_isToggled) {
        targetColor = [UIColor redColor];
        targetBounds = CGRectMake(initialBounds.origin.x - 0.5 * initialBounds.size.width,
                                  initialBounds.origin.y + 0.5 * initialBounds.size.height,
                                  initialBounds.size.width * 1.1,
                                  initialBounds.size.height * 1.1);
        targetRadius = 45*1.1;
        
    } else {
        targetColor = [UIColor colorWithRed:240/255.0 green:173/255.0 blue:78/255.0 alpha:1];
        targetBounds = initialBounds;
        targetRadius = 45;
    }
    
    // TODO animate
    POPSpringAnimation *colorAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBackgroundColor];
    colorAnim.toValue = (id)[targetColor CGColor];
    colorAnim.springSpeed = 6;
    colorAnim.springBounciness = 20;
    [self.layer pop_addAnimation:colorAnim forKey:@"color"];
    
    POPSpringAnimation *boundsAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    boundsAnim.toValue = [NSValue valueWithCGRect:targetBounds];
    boundsAnim.springSpeed = 6;
    boundsAnim.springBounciness = 20;
    [self.layer pop_addAnimation:boundsAnim forKey:@"bounds"];
    
    POPSpringAnimation *cornerAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerCornerRadius];
    cornerAnim.toValue = @(targetRadius);
    cornerAnim.springSpeed = 6;
    cornerAnim.springBounciness = 20;
    [self.layer pop_addAnimation:cornerAnim forKey:@"corner"];
}

@end
