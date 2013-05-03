//
//  AccountViewController.m
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/1/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.

#import "AccountViewController.h"
#import "GrantObject.h"


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



-(void)setGrantObject:(GrantObject *)grant withAccount:(NSString *)account
{
    self.navigationItem.title = [[grant getMetadata] objectForKey:@"title"]; //or should this be the account name?
    accountName = @"Placeholder text";
    
    //do all the drawing and data representation needed to display the data correctly here
}

#pragma mark IBOutlets
//method recieves a grant object and the name of the account to be displayed
- (IBAction)buttonBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
