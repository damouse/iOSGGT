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

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [self.topViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end
