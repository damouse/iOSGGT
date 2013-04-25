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
@synthesize date, label, amount;

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

//CorePlot doesn't play well with NSDate objects, at least not easily. Use this method to return dates as decimals,
//where each digit represents one second of offset from a referance date. 
- (NSNumber *) dateAsTimeInterval
{
    NSDate *refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:31556926 * 10];
    NSTimeInterval oneDay = 24 * 60 * 60;
    
    NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    //[calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT-6"]]; //THIS NEEDS TO BE DYNAMIC
    
    NSDateComponents *differenceComponents;
    differenceComponents = [calendar components:unitFlags fromDate:refDate toDate:date options:0];
    
    int secondsDisplacement;
    
    secondsDisplacement = [differenceComponents day] * oneDay;
    secondsDisplacement = secondsDisplacement + [differenceComponents month] * oneDay * 30;
    secondsDisplacement = secondsDisplacement + [differenceComponents year] * oneDay * 30 * 365;
    
    return [NSDecimalNumber numberWithInt:secondsDisplacement];
}

@end
