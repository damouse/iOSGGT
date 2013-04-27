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
-(NSDecimalNumber *)getBalance;
-(NSDecimalNumber *)getBudget;

//Keys: {dateLastAccessed, datesOfGrant, name, accountNumber, grantor, title, overhead, awardNumber}
- (NSDictionary *) getMetadata;
@end
