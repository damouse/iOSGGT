//
//  GrantObject.h
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/25/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GrantObject : NSObject

//All changes in the value of the account. Array holds accountentryobjects
@property (strong, nonatomic) NSMutableArray *accountEntries;

-(id)initWithCSVArray:(NSArray *)csvFile;

//return column headers, row 6 of the spreadsheet starting with "Amount"
-(NSArray *) getAccounts;
-(NSArray *) getEntriesWithAccountNames;

//retrieve the dictionaries that represent the totals rows in the table. Dictionaries are keyed by column headers
-(NSDictionary *)getBalanceRow;
-(NSDictionary *)getBudgetRow;

//Keys: {dateLastAccessed, startDate, endDate, name, accountNumber, grantor, title, overhead, awardNumber}
- (NSDictionary *) getMetadata;
@end
