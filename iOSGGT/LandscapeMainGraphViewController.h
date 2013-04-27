//
//  LandscapeMainGraphViewController.h
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/19/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface LandscapeMainGraphViewController : UIViewController <CPTPlotDataSource, CPTPlotSpaceDelegate>


@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (nonatomic, strong) CPTTheme *selectedTheme;

-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate;
- (void) initWithGrantArray:(NSMutableArray *)grantArray; //method takes in the array of grant objects, then performs some magic
@end
