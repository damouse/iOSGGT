//
//  PieSliceView.h
//  iOSGGT
//
//  Created by Mihnea Barboi on 5/2/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PieSliceView : UIView

@property (nonatomic) CGFloat percentFill; //from 0 to 1, how filled the slice should be
@property (strong, nonatomic) UIColor *color UI_APPEARANCE_SELECTOR;
@property (strong, readonly)  UIBezierPath *path; //here so parent can check for touches
@property (strong, nonatomic) NSString *accountName;

-(void) animateSlice; //begin animations
- (NSComparisonResult)compare:(PieSliceView *)other;
@end
