//
//  MainGraphViewController.m
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/1/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import "MainGraphViewController.h"
#import "GrantTableViewCell.h"
#import "AccountViewController.h"

@interface MainGraphViewController ()

@end

@implementation MainGraphViewController
@synthesize grantObject;

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

-(void) viewDidAppear:(BOOL)animated
{
    self.navigationItem.title = [grantObject setName:nil];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToAccountPage:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    AccountViewController *accountGraph = [mainStoryboard instantiateViewControllerWithIdentifier: @"AccountGraphic"];
    
    [accountGraph setGrantObject:grantObject withAccount:@"Service Account"];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton; //need this, else name too long for nav bar
    
    [self.navigationController pushViewController:accountGraph animated:YES];
}
@end
