//
//  MainGraphViewController.h
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/1/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GrantObject.h"
#import "PieSliceView.h"
#import "CorePlot-CocoaTouch.h"

@class PieSliceView;

@interface MainGraphViewController : UIViewController <CPTBarPlotDataSource, CPTBarPlotDelegate> {

    __weak IBOutlet UILabel *labelTitle;
    __weak IBOutlet UITableView *tableSliceLabels;
    
    //details labels
    
    __weak IBOutlet UILabel *labelStartDate;
    __weak IBOutlet UILabel *labelEndDate;
    __weak IBOutlet UILabel *labelLastUpdated;
    __weak IBOutlet UILabel *labelAccountNumber;
    __weak IBOutlet UILabel *labelAgencyNumber;
    __weak IBOutlet UILabel *labelGrantor;
    __weak IBOutlet UILabel *labelOverhead;
    __weak IBOutlet UILabel *labelName;
    
    
    __weak IBOutlet UIView *viewGraph;
}

-(void)setGrantObject:(GrantObject *)grantObject;
- (void) touchFromSlice:(PieSliceView *)slice;
- (IBAction)buttonBack:(id)sender;

//buttons to switch the active bar plot
- (IBAction)buttonBalance:(id)sender;
- (IBAction)buttonBudget:(id)sender;
- (IBAction)buttonPaid:(id)sender;
@end
