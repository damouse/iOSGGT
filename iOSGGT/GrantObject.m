//
//  GrantObject.m
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/25/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import "GrantObject.h"
#import "AccountEntryObject.h"

@implementation GrantObject {
    //NOTE: keys WILL NEED TO BE CHANGED. Dynamically add them from the column headers for different spreadsheets
    //contains info from top 5 lines. Keys: {dateLastAccessed, datesOfGrant, name, accountNumber, grantor, title, overhead, awardNumber}
    NSMutableDictionary *metadata;
    
    //contains budget amounts. Keys: {totalBudget, staff, otherPersonnel, fringeBenefits, tuitionRemission, supplies, travel}
    NSMutableDictionary *budget;
    NSMutableDictionary *balance;
    NSMutableDictionary *paid;
    
    //row 6 of the spreadsheets: holds the name of all the columns for reference
    NSArray *columnHeaders;
}

@synthesize accountEntries;

//take the whole slew of arrays from the csv and put all the info in the right places
//NOTE: again, this has to be rewritten to allow for differently styled spreadsheets or different sized columns
//It is currently hardcoded just to test.
-(id)initWithCSVArray:(NSArray *)csvFile
{
    self = [super init];
    metadata = [NSMutableDictionary dictionary];
    budget = [NSMutableDictionary dictionary];
    balance = [NSMutableDictionary dictionary];
    paid = [NSMutableDictionary dictionary];
    accountEntries = [NSMutableArray array];
    
    //metadata
    [metadata setObject:[[csvFile objectAtIndex:0] objectAtIndex:0] forKey:@"dateLastAccessed"];
    [metadata setObject:[[csvFile objectAtIndex:1] objectAtIndex:1] forKey:@"datesOfGrant"];
    [metadata setObject:[[csvFile objectAtIndex:2] objectAtIndex:1] forKey:@"name"];
    [metadata setObject:[[csvFile objectAtIndex:3] objectAtIndex:1] forKey:@"accountNumber"];
    [metadata setObject:[[csvFile objectAtIndex:1] objectAtIndex:4] forKey:@"grantor"];
    [metadata setObject:[[csvFile objectAtIndex:2] objectAtIndex:4] forKey:@"title"];
    [metadata setObject:[[csvFile objectAtIndex:3] objectAtIndex:4] forKey:@"overhead"];
    [metadata setObject:[[csvFile objectAtIndex:4] objectAtIndex:1] forKey:@"awardNumber"];
    
    //column headers, main three
    columnHeaders = [csvFile objectAtIndex:5];
    NSArray *budgetLine = [csvFile objectAtIndex:12]; //these are here so they can be replaced if we need to find them dynamically
    NSArray *balanceLine = [csvFile objectAtIndex:13];
    NSArray *paidLine = [csvFile objectAtIndex:15];
    int i = 0;
    
    for(NSString *header in columnHeaders) {
        if(i > 5) {
            [budget setValue:[[budgetLine objectAtIndex:i] stringByReplacingOccurrencesOfString:@"\"" withString:@""] forKey:header];
            [balance setValue:[[balanceLine objectAtIndex:i] stringByReplacingOccurrencesOfString:@"\"" withString:@""] forKey:header];
            [paid setValue:[[paidLine objectAtIndex:i] stringByReplacingOccurrencesOfString:@"\"" withString:@""] forKey:header];
        }
        i++;
    }
    
    
    //Build an array of account entries
    i = 6; //budget allocations start on row 7 of the spreadsheet
    
    //NSString *name;
    //NSString *date;
    //CGFloat amount;

    NSArray *line = [csvFile objectAtIndex:i];
    NSString *cell = [line objectAtIndex:1];
    
    while(![cell isEqualToString:@"Current Budget:"]) {
        //NSLog(@"Spinning 1: %i", i);
        if([[line objectAtIndex:1] isEqualToString:@"Budget Allocation"]) {
            line = [csvFile objectAtIndex:i]; //get the next line
            cell = [line objectAtIndex:1];
        
            //get the date, amount, and label of the entry. 
            AccountEntryObject *entry = [[AccountEntryObject alloc] initWithDate:[line objectAtIndex:0] name:cell andAmount:[[line objectAtIndex:6] intValue]];
            [accountEntries addObject:entry];
        }
        
        //get the next line
        i++;
        line = [csvFile objectAtIndex:i];
        cell = [line objectAtIndex:1];
    }
    
    //set the index to the first account withdrawl. New index references the first line with a withdrawl
    cell = [line objectAtIndex:0];
    while([cell isEqualToString:@""]) {
        //NSLog(@"Spinning 2: %i", i);
        i++;
        line = [csvFile objectAtIndex:i];
        cell = [line objectAtIndex:0];
    }
    
    //build array of account withdrawls. Keep searching until three cells pass 
    int emptyCells = 0;
    cell = [line objectAtIndex:1];

    while(emptyCells < 3) {
        //NSLog(@"Spinning 3: %i", i);
        if(![cell isEqualToString:@""]) {
            //get the date, amount, and label of the entry
            AccountEntryObject *entry = [[AccountEntryObject alloc] initWithDate:[line objectAtIndex:0] name:cell andAmount:-[[line objectAtIndex:6] intValue]];
            [accountEntries addObject:entry];
        
            emptyCells = 0; //reset empty cell count
        }
        else {
            emptyCells++; //start counting empty cells
        }
        
        //move to the next line. 
        i++;
        line = [csvFile objectAtIndex:i];
        cell = [line objectAtIndex:1];
    }
    
    //sort the entries by date
    [accountEntries sortUsingSelector:@selector(compare:)];
    
    //the account entries have all been added and sorted in order of date. This sets up the "running total" of the grant
    int currentTotal = 0;
    
    for(AccountEntryObject *entry in accountEntries) {
        currentTotal = currentTotal + [entry amount];
        [entry setRunningTotalToDate:currentTotal];
    }
    
    return self;
}


#pragma mark accessor methods
- (NSDictionary *) getMetadata
{
    return metadata;
}

#pragma mark retrieval funtions
-(NSArray *)getDepartments
{
    return nil;
}

-(NSDecimalNumber *)getBudget
{
    return [NSDecimalNumber decimalNumberWithString:[[budget objectForKey:@"Amount"]stringByReplacingOccurrencesOfString:@"," withString:@""]];
}

-(NSDecimalNumber *)getBalance
{
    return [NSDecimalNumber decimalNumberWithString:[[balance objectForKey:@"Amount"]stringByReplacingOccurrencesOfString:@"," withString:@""]];
}



@end
