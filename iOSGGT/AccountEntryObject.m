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

-(id) initWithDate:(NSString *)dateString name:(NSString *)name andAmount:(int)value
{
    self = [super init];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/YY"];
    date = [formatter dateFromString:dateString];
    
    label = name;
    amount = value;
    
    return self;
}

@end
