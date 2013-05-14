//
//  DirectoryEditorTableViewController.h
//  iOSGGT
//
//  Created by Mihnea Barboi on 5/12/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DirectoryEditorTableViewController : UITableViewController <UITextViewDelegate> {

    IBOutletCollection(UIButton) NSArray *buttons;
}
- (IBAction)buttonBack:(id)sender;
- (IBAction)buttonAddDirectory:(id)sender;

@end
