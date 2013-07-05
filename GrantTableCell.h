//
//  GrantTableCell.h
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/25/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KOAProgressBar.h"

@interface GrantTableCell : UITableViewCell {
    

    IBOutlet KOAProgressBar *progressBar;
}
@property (weak, nonatomic) IBOutlet UILabel *labelRemaining;
@property (weak, nonatomic) IBOutlet UILabel *labelGrantFileName;

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *date;

- (void) setCompletion:(float)percent;
@end
