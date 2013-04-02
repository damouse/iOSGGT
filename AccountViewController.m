//
//  AccountViewController.m
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/1/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.

#import "AccountViewController.h"

@interface AccountViewController () {
    NSString *accountName;
}

@end

@implementation AccountViewController

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
	
    labelAccountName.text = accountName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//method recieves a grant object and the name of the account to be displayed
-(void)setGrantObject:(GrantTableViewCell *)grant withAccount:(NSString *)account
{
    self.navigationItem.title = [grant setName:nil]; //or should this be the account name?
    accountName = @"Placeholder text";
    
    //do all the drawing and data representation needed to display the data correctly here
}

@end
