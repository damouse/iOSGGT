//
//  AccountViewController.h
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/1/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GrantTableViewCell.h"

@interface AccountViewController : UIViewController {
    __weak IBOutlet UILabel *labelAccountName;
}

-(void)setGrantObject:(GrantTableViewCell *)grant withAccount:(NSString *)account;
@end
