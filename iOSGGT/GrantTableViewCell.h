//
//  GrantTableViewCell.h
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/1/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GrantTableViewCell : UITableViewCell {
    __weak IBOutlet UILabel *labelNameOfGrant;
    __weak IBOutlet UILabel *labelEndDate;
    __weak IBOutlet UILabel *labelTotal; //placeholder
    __weak IBOutlet UILabel *labelRemaining; //placeholder
}

-(NSString *)setName:(NSString *)name;
-(NSString *)setDate:(NSString *)date;
-(NSString *)setTotal:(NSString *)name;
-(NSString *)setRemaining:(NSString *)name;

-(void)initWithCSVArray:(NSArray *)csvFile;
@end
