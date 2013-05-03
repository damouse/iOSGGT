//
//  PieSliceView.m
//  iOSGGT
//
//  Created by Mihnea Barboi on 5/2/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//
/**
    Spinner class used to implement the pie chart functionality. 
 
    This is used instead of the stock corePlot pie charts because its more simple, 
    allows for nice animations, and gets rid of a lot of code. Coreplot labels are
    also very cumbersome to deal with. 
 
    When given a radian, view will animate the circle to that radian. 
    Class has an method to determine if a touch occured within its borders
 */

#import "PieSliceView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PieSliceView {
    float progress;
}

@synthesize path;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor]; //consider creating a frame here?
    }
    
    return self;
}

- (void)setPercentFill:(CGFloat)percentFill {
    NSLog(@"percentFill: %f", percentFill);
    progress = 0;
    
    if (percentFill != _percentFill) {
        _percentFill = percentFill;
    }
}

//this should EITHER be changed to draw for given radians OR we have to detect what overlaying hubs are active
- (void)drawRect:(CGRect)rect {
    if ([self color] == nil)
        [self setColor:[UIColor whiteColor]];
    
    CGPoint center = CGPointMake(rect.size.width/2, rect.size.height/2);
    CGFloat radius = MIN(rect.size.width, rect.size.height)/2;

    path = [UIBezierPath bezierPath];
    
    // Move to centre and draw an arc.
    [path moveToPoint:center];
    [path addArcWithCenter:center radius:radius startAngle:0 - M_PI_2 // zero degrees is east, not north, so subtract pi/2
                  endAngle:2 * M_PI * progress - M_PI_2 // ditto
                 clockwise:YES];
    [path closePath];
    
    path.usesEvenOddFillRule = YES;
    
    [[self color] setFill];
    [path fill];
}

//Recursive call to animate the slice open. TODO: make a logarithmic timer so the animation is smoother. 
- (void) animateSlice {
    if(progress < _percentFill) {
        progress += .005;
        [self setNeedsDisplay];
        [NSTimer scheduledTimerWithTimeInterval:0.005 target:self selector:@selector(animateSlice) userInfo:nil repeats:NO];
    }
}

#pragma mark Class specific
//custom compare method so array can be sorted. The larger object goes first.
- (NSComparisonResult)compare:(PieSliceView *)other {
    if(_percentFill > [other percentFill])
        return NSOrderedAscending;
    if(_percentFill < [other percentFill])
        return NSOrderedDescending;
    return NSOrderedSame;
}
#pragma mark - Accessibility
- (BOOL)isAccessibilityElement {
    return YES;
}

- (NSString *)accessibilityLabel {
    return NSLocalizedString(@"percentFill", @"Accessibility label for GSpercentFillView");
}

- (NSString *)accessibilityValue {
    // Report percentFill as a percentage, same as UISlider, UIpercentFillView
    return [NSString stringWithFormat:@"%d%%", (int)round([self percentFill] * 100.0)];
}

- (UIAccessibilityTraits)accessibilityTraits {
    return UIAccessibilityTraitUpdatesFrequently;
}



@end
