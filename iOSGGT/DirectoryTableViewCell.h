//
//  DirectoryTableViewCell.h
//  iOSGGT
//
//  Created by Mihnea Barboi on 5/12/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DirectoryTableViewCell : UITableViewCell 

@property (weak, nonatomic) IBOutlet UITextField *textfieldNickname;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UITextView *textviewURL;
@property (weak, nonatomic) IBOutlet UITextView *textfieldGrants;
@end
