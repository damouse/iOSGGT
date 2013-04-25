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
    
    //dictionary
    NSMutableArray *budgetAllocations;
    NSMutableArray *accountEntries;

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
    budgetAllocations = [NSMutableArray array];
    accountEntries = [NSMutableArray array];
    
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
    BOOL searching = YES; //keep going until it spills over into the next section
    i = 6; //budget allocations start on row 7 of the spreadsheet
    
    NSString *name;
    NSString *date;
    CGFloat amount;

    NSArray *line = [csvFile objectAtIndex:i];
    NSString *cell = [line objectAtIndex:1];
    
    while(![cell isEqualToString:@"Current Budget:"]) {
        if([[line objectAtIndex:1] isEqualToString:@"Budget Allocation"]) {
            AccountEntryObject *entry = [AccountEntryObject alloc];
            line = [csvFile objectAtIndex:i]; //get the next line
            cell = [line objectAtIndex:1];
        
            //get the date, amount, and label of the entry. 
            [entry initWithDate:[line objectAtIndex:0] name:cell andAmount:[[line objectAtIndex:6] floatValue]];
            [budgetAllocations addObject:[csvFile objectAtIndex:i]];
        
            //get the next line
            i++;
            line = [csvFile objectAtIndex:i];
            cell = [line objectAtIndex:1];
        }
    }
    
    //set the index to the first account withdrawl. New index references the first line with a withdrawl
    cell = [line objectAtIndex:0];
    while([cell isEqualToString:@""]) {
        i++;
        line = [csvFile objectAtIndex:i];
        cell = [line objectAtIndex:1];
    }
    
    while([cell isEqualToString:@"Current Budget:"]) {
        AccountEntryObject *entry = [AccountEntryObject alloc];
        line = [csvFile objectAtIndex:i]; //get the next line
        cell = [line objectAtIndex:1];
        
        //get the date, amount, and label of the entry.
        [entry initWithDate:[line objectAtIndex:0] name:cell andAmount:[[line objectAtIndex:6] floatValue]];
        [accountEntries addObject:[csvFile objectAtIndex:i]];
        
        //get the next line
        i++;
        line = [csvFile objectAtIndex:i];
        cell = [line objectAtIndex:1];
    }
}

//We have the total budget and the remaining balance, but it would be nice to have a historical representation of the balance.
//This method takes in the budget allocations and the account entries and then rebuilds the balance history
- (NSMutableArray *) reconstructBalanceHistory
{
    
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