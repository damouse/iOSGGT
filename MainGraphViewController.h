//
//  MainGraphViewController.h
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/1/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "GrantObject.h"

@interface MainGraphViewController : UIViewController <CPTPlotDataSource>{

}

- (IBAction)goToAccountPage:(id)sender;
-(void)setGrantObject:(GrantObject *)grantObject;

//NEWNEWNEW
@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (nonatomic, strong) CPTTheme *selectedTheme;

@end
