//
//  RootViewController.h
//  iOSGGT
//
//  Created by Mihnea Barboi on 5/3/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController {
    
    __weak IBOutlet UITableView *tableMain;
}
- (IBAction)buttonRefresh:(id)sender;
- (IBAction)landscapePressed:(id)sender;



@end
