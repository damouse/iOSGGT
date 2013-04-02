//
//  MainGraphViewController.h
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/1/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GrantTableViewCell.h"

@interface MainGraphViewController : UIViewController {
    
}

- (IBAction)goToAccountPage:(id)sender;
@property (weak, nonatomic) GrantTableViewCell *grantObject;

@end
