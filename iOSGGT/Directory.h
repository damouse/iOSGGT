//
//  Directory.h
//  iOSGGT
//
//  Created by Mickey Barboi on 9/6/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Directory : NSObject  <NSCoding>

@property (strong, nonatomic) NSString *cslogin;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSDate *dateAdded;

@end

