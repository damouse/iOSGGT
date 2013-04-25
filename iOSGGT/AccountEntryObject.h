//
//  AccountEntryObject.h
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/25/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountEntryObject : NSObject

@property (weak, nonatomic) NSDate *date;
@property (weak, nonatomic) NSString *label;
@property int *amount;

-(id) initWithDate:(NSString *)dateString name:(NSString *)name andAmount:(int)value;

@end
