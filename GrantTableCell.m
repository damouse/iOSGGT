//
//  GrantTableCell.m
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/25/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import "GrantTableCell.h"
#import "KOAProgressBar.h"

@implementation GrantTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//sets the completion percentage of the bar, animates
- (void) setCompletion:(float)percent {
    UIColor *myGreen = [UIColor colorWithRed:44.0f/255.0f green:178.0f/255.0f blue:0 alpha:1];
    
    [progressBar setLighterProgressColor:myGreen];
    [progressBar setDarkerProgressColor:myGreen];
    [progressBar setLighterStripeColor:myGreen];
    [progressBar setDarkerStripeColor:myGreen];
    
    //[progressBar setRadius:59.0f];
    [progressBar setMinValue:0.0];
    [progressBar setRealProgress:0.0];
    [progressBar setDisplayedWhenStopped:YES];
    [progressBar setTimerInterval:0.05];
    [progressBar setProgressValue:0.005];
    [progressBar setAnimationDuration:.5];
    [progressBar setMaxValue:percent];
    [progressBar startAnimation:self];
}
@end
