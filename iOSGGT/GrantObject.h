//
//  GrantObject.h
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/25/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GrantObject : NSObject

-(NSString *)setName:(NSString *)name;
-(NSString *)setDate:(NSString *)date;
-(NSString *)setTotal:(NSString *)name;
-(NSString *)setRemaining:(NSString *)name;

-(void)initWithCSVArray:(NSArray *)csvFile;
-(NSDecimalNumber *)getBalance;
-(NSDecimalNumber *)getBudget;
@end
