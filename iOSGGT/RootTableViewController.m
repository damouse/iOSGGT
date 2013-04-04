//
//  RootTableViewController.m
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/1/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import "RootTableViewController.h"
#import "GrantTableViewCell.h"
#import "MainGraphViewController.h"
#import "CHCSVParser.h"
#import "GrantTableViewCell.h"

@interface RootTableViewController () {
    NSMutableArray *grants; //holds all grants
}

@end

@implementation RootTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *myFile = [mainBundle pathForResource: @"sample" ofType: @"csv"];
    NSArray *parsed = [NSArray arrayWithContentsOfCSVFile:myFile];
    GrantTableViewCell *grantObject = [[GrantTableViewCell alloc] init];
    [grantObject initWithCSVArray:parsed];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5; //hardcoded for testing
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GrantTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AccountCell" forIndexPath:indexPath];
    if (cell ==nil) {
        cell = [[GrantTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AccountCell"];
    }
    
    [cell setName:[NSString stringWithFormat:@"Grant #%i", indexPath.row]];
    [cell setDate:@"2/16/24"];
    [cell setRemaining:@"23,000"];
    [cell setTotal:@"234,134"];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];    
    MainGraphViewController *mainGraph = [mainStoryboard instantiateViewControllerWithIdentifier: @"MainGraphic"];
    GrantTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AccountCell" forIndexPath:indexPath];
    
    [mainGraph setGrantObject:cell];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton; //need this, else name too long for nav bar
    
    [self.navigationController pushViewController:mainGraph animated:YES];
}

@end
