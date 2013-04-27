//
//  AccountEntryObject.h
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/25/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountEntryObject : NSObject

@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *label;
@property NSInteger amount;
@property NSInteger runningTotalToDate;

-(id) initWithDate:(NSString *)dateString name:(NSString *)name andAmount:(NSInteger)value;
- (NSNumber *) dateAsTimeInterval;
@end
