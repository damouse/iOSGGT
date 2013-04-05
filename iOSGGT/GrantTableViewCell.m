//
//  GrantTableViewCell.m
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/1/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//
//  This is a custom object used to handle the data fields within the custom, prototype cells.
//  NOTE: this is also the abstract, "grant" object. Should change the name. 

#import "GrantTableViewCell.h"

@implementation GrantTableViewCell {
    //NOTE: keys WILL NEED TO BE CHANGED. Dynamically add them from the column headers for different spreadsheets
    //contains info from top 5 lines. Keys: {dateLastAccessed, datesOfGrant, name, accountNumber, grantor, title, overhead, awardNumber}
    NSMutableDictionary *metadata;

    //contains budget amounts. Keys: {totalBudget, staff, otherPersonnel, fringeBenefits, tuitionRemission, supplies, travel}
    NSMutableDictionary *budget;
    NSMutableDictionary *balance;
    NSMutableDictionary *paid;
    
    //row 6 of the spreadsheets: holds the name of all the columns for reference
    NSArray *columnHeaders;
    
    //array of arrays, holds the budget allocations and individual entries
    NSArray *budgetAllocations;
    NSArray *accountEntries;
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

//take the whole slew of arrays from the csv and put all the info in the right places
//NOTE: again, this has to be rewritten to allow for differently styled spreadsheets or different sized columns
//It is currently hardcoded just to test.
-(void)initWithCSVArray:(NSArray *)csvFile
{
    metadata = [NSMutableDictionary dictionary];
    budget = [NSMutableDictionary dictionary];
    balance = [NSMutableDictionary dictionary];
    paid = [NSMutableDictionary dictionary];
    budgetAllocations = [NSArray array];
    accountEntries = [NSArray array];
    
    //metadata
    [metadata setObject:[[csvFile objectAtIndex:0] objectAtIndex:0] forKey:@"dateLastAccessed"];
    [metadata setObject:[[csvFile objectAtIndex:1] objectAtIndex:1] forKey:@"datesOfGrant"];
    [metadata setObject:[[csvFile objectAtIndex:2] objectAtIndex:1] forKey:@"name"];
    [metadata setObject:[[csvFile objectAtIndex:3] objectAtIndex:1] forKey:@"accountNumber"];
    [metadata setObject:[[csvFile objectAtIndex:1] objectAtIndex:4] forKey:@"grantor"];
    [metadata setObject:[[csvFile objectAtIndex:1] objectAtIndex:4] forKey:@"title"];
    [metadata setObject:[[csvFile objectAtIndex:3] objectAtIndex:4] forKey:@"overhead"];
    [metadata setObject:[[csvFile objectAtIndex:4] objectAtIndex:1] forKey:@"awardNumber"];
    
    //column headers, main three
    columnHeaders = [csvFile objectAtIndex:5];
    NSArray *budgetLine = [csvFile objectAtIndex:13]; //these are here so they can be replaced if we need to find them dynamically
    NSArray *balanceLine = [csvFile objectAtIndex:14];
    NSArray *paidLine = [csvFile objectAtIndex:15];
    BOOL beginRecording = NO;
    
    for(NSString *header in columnHeaders) {
        if([header isEqualToString:@"Amount"])
            beginRecording = YES;
        
        if(beginRecording) {
            [budget setObject:<#(id)#> forKey:<#(id<NSCopying>)#>]
        }
    }
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
