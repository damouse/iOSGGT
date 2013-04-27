//
//  AccountEntryObject.m
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/25/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

// This class represents a change in the balance of a grant. It stores relevant information about that change. 

#import "AccountEntryObject.h"

@implementation AccountEntryObject
@synthesize date, label, amount, runningTotalToDate;

-(id) initWithDate:(NSString *)dateString name:(NSString *)name andAmount:(NSInteger)value
{
    self = [super init];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/YY"];
    date = [formatter dateFromString:dateString];
    
    label = name;
    amount = value;
    
    return self;
}

- (NSComparisonResult) compare:(AccountEntryObject *)other
{
    return [date compare: [other date]];
}

- (AccountEntryObject *) copy {
    AccountEntryObject *new = [AccountEntryObject alloc];
    [new setDate:self.date];
    [new setLabel:self.label];
    [new setAmount:self.amount];
    [new setRunningTotalToDate:self.runningTotalToDate];
    
    return new;
}

//CorePlot doesn't play well with NSDate objects, at least not easily. Use this method to return dates as decimals,
//where each digit represents one second of offset from a referance date. 
- (NSNumber *) dateAsTimeInterval
{
    NSDate *refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:157680000]; //reference date is 2006
    NSTimeInterval difference = [date timeIntervalSinceDate:refDate]; //difference between today and 2006
    
    return [NSNumber numberWithDouble:difference];
}

@end
