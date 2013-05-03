//
//  AccountEntryTableCell.h
//  iOSGGT
//
//  Created by Mihnea Barboi on 5/2/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountEntryTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelAmount;
@property (weak, nonatomic) IBOutlet UILabel *labelAccountName;

@end
