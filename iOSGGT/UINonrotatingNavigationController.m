//
//  UINonrotatingNavigationController.m
//  iOSGGT
//
//  Created by Mihnea Barboi on 5/13/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import "UINonrotatingNavigationController.h"

@interface UINonrotatingNavigationController ()

@end

@implementation UINonrotatingNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate;
{   
    //if compare is the top view controller, check and see if theere is a modal above it AND if the modal has a preference
    if ([[self topViewController] respondsToSelector:@selector(shouldAutorotate)])
        return [[self topViewController] shouldAutorotate];
    else
        return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[self topViewController] respondsToSelector:@selector(supportedInterfaceOrientations)])
        return [[self topViewController] supportedInterfaceOrientations];
    else
        return UIInterfaceOrientationMaskPortrait;
}

@end
