//
//  AccountTableViewController.h
//  iOSGGT
//
//  Created by Mihnea Barboi on 5/2/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GrantObject.h"

@interface AccountTableViewController : UITableViewController

- (void) setGrantObject:(GrantObject *)grant withAccount:(NSString *)account;
- (IBAction)buttonBack:(id)sender;

@end
