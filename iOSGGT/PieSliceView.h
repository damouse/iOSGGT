//
//  PieSliceView.h
//  iOSGGT
//
//  Created by Mihnea Barboi on 5/2/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainGraphViewController.h"

@interface PieSliceView : UIView

@property (nonatomic) CGFloat angleEnd; //from 0 to 1, how filled the slice should be
@property (nonatomic) CGFloat angleStart; //from 0 to 1, how filled the slice should be
@property (nonatomic) CGFloat progress; //from 0 to 1, how filled the slice should be

@property (strong, nonatomic) UIColor *color UI_APPEARANCE_SELECTOR;
@property (strong, readonly)  UIBezierPath *path; //here so parent can check for touches
@property (strong, nonatomic) NSString *accountName;

- (NSComparisonResult)compare:(PieSliceView *)other;
- (void) animateSlice ; //explode the slice out
@end
