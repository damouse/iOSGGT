//
//  AccountViewController.h
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/1/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GrantObject.h"

@interface AccountViewController : UIViewController {
    __weak IBOutlet UILabel *labelAccountName;
}

-(void)setGrantObject:(GrantObject *)grant withAccount:(NSString *)account;
@end
