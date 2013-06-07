//
//  BarView.m
//  iOSGGT
//
//  Created by Mickey Barboi on 6/5/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

// This is a custom class meant to represent a single bar in a bar graph. This class should resize itself
// based on the number of bars present and also establish where its label should be.
// The view MAY resize itself.

//NOTE: the actual GRAPH part has to be another view within this one so that this class can handle the label

#import "BarView.h"

@implementation BarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
