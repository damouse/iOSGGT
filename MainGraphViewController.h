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

@interface MainGraphViewController : UIViewController {

    __weak IBOutlet UILabel *labelTitle;
    __weak IBOutlet UITableView *tableSliceLabels;
}

-(void)setGrantObject:(GrantObject *)grantObject;
- (void) touchFromSlice:(PieSliceView *)slice;
- (IBAction)buttonBack:(id)sender;

@end
