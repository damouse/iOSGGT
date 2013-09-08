//
//  Directory.m
//  iOSGGT
//
//  Created by Mickey Barboi on 9/6/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import "Directory.h"

@implementation Directory


#pragma mark Coder/Archiver
-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_password forKey:@"password"];
    [encoder encodeObject:_cslogin forKey:@"login"];
    
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    
    self.password = [decoder decodeObjectForKey:@"password"];
    self.cslogin = [decoder decodeObjectForKey:@"login"];
   
    
    return self;
}

@end
