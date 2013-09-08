//
//  DirectoryViewController.h
//  iOSGGT
//
//  Created by Mickey Barboi on 9/6/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DirectoryViewController : UIViewController {
    
    __weak IBOutlet UITextField *textLogin;
    __weak IBOutlet UITextField *textPassword;
    __weak IBOutlet UITextView *textviewGrants;
}
- (IBAction)buttonCheckDirectory:(id)sender;
- (IBAction)buttonBack:(id)sender;

@end
