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
    float explodeProgress;
    float explodeX; //use sin to get proper mutation
    float explodeY; //use cos
    float explodeAngleX;
    float explodeAngleY;
}

@synthesize path, angleEnd, angleStart, progress;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor]; //consider creating a frame here?
    }
    explodeProgress = 0;
    explodeX = 0;
    explodeY = 0;
    return self;
}

//this should EITHER be changed to draw for given radians OR we have to detect what overlaying hubs are active
- (void)drawRect:(CGRect)rect {
    if ([self color] == nil)
        [self setColor:[UIColor whiteColor]];
    
    if(progress != angleStart) {
        //only animate explode stuff if explodeProgress != 0
        if(explodeProgress != 0) {
            explodeX = explodeProgress * explodeAngleX;
            explodeY = explodeProgress * explodeAngleY;
        }
        
        CGPoint center = CGPointMake(rect.size.width/2 + explodeX, rect.size.height/2 + explodeY);
        CGFloat radius = MIN(rect.size.width, rect.size.height)/2 - 10; //pull this back 15 so it doesnt draw outside of its frame

        //NSLog(@"x %.0f y %.0f ", center.x, center.y);
        
        path = [UIBezierPath bezierPath];
    
        // Move to centre and draw an arc.
        [path moveToPoint:center];
        [path addArcWithCenter:center radius:radius startAngle:2 * M_PI * angleStart - M_PI_2 // zero degrees is east, not north, so subtract pi/2
                  endAngle:2 * M_PI * progress - M_PI_2 // ditto
                 clockwise:YES];
        [path closePath];
    
        path.usesEvenOddFillRule = YES;
    
        [[self color] setFill];
        [path fill];
        
        [self.layer setShadowOpacity:0.8];
        [self.layer setShadowRadius:3.0f];
    }
    
    
}

//animate the slice outwards a bit
- (void) animateSlice {
    //intialize with the first slice
    
    //if this is the first time this method is being called, then calculate the correct angle to explode through
    if(explodeProgress == 0) {
        explodeAngleX = sin(((angleStart + angleEnd) / 2) * 2 * M_PI); //this is the direction of the explosion
        explodeAngleY = -cos(((angleStart + angleEnd) / 2) * 2 * M_PI);
        
        NSLog(@"slice %@ angle %.3f x %.3f y%.3f", [self accountName], ((angleStart + angleEnd) / 2), explodeAngleX, explodeAngleY);
    }
    //NSLog(@"pi %f cos(pi) %f sin(pi) %f", M_PI, cos(M_PI), sin(M_PI));
    
    if(explodeProgress < 5) { //continue animating this slice if its not yet finished
        explodeProgress += 1;
        [self setNeedsDisplay];
        [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(animateSlice) userInfo:nil repeats:NO];
    }
}

#pragma mark Class specific
//custom compare method so array can be sorted. The larger object goes first.
- (NSComparisonResult)compare:(PieSliceView *)other {
    if(angleEnd > [other angleEnd])
        return NSOrderedAscending;
    if(angleEnd < [other angleEnd])
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
    return [NSString stringWithFormat:@"%d%%", (int)round([self angleEnd] * 100.0)];
}

- (UIAccessibilityTraits)accessibilityTraits {
    return UIAccessibilityTraitUpdatesFrequently;
}



@end
