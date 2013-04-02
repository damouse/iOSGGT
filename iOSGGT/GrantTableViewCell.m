//
//  GrantTableViewCell.m
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/1/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//
//  This is a custom object used to handle the data fields within the custom, prototype cells. 

#import "GrantTableViewCell.h"

@implementation GrantTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark change labels
//changes the name and returns the new name, returns the old name if nil is passed in instead
-(NSString *)setName:(NSString *)name
{
    if(name != nil)
        labelNameOfGrant.text = name;
    return labelNameOfGrant.text;
}

-(NSString *)setDate:(NSString *)date
{
    if(date != nil)
        labelEndDate.text = date;
    return labelEndDate.text;
}


//VERY LIKELY TO BE A TEMPORARY METHOD
-(NSString *)setTotal:(NSString *)name
{
    if(name != nil)
        labelTotal.text = name;
    return labelTotal.text;
}

-(NSString *)setRemaining:(NSString *)name
{
    if(name != nil)
        labelRemaining.text = name;
    return labelRemaining.text;
}
@end
