//
//  RootTableViewController.h
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/1/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface RootTableViewController : UITableViewController <CPTPlotDataSource, CPTPlotSpaceDelegate> {
    
    IBOutlet UITableView *tableMain;
}


@end
