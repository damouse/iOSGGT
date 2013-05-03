//
//  AccountTableViewController.m
//  iOSGGT
//
//  Created by Mihnea Barboi on 5/2/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import "AccountTableViewController.h"
#import "GrantObject.h"
#import "AccountEntryTableCell.h"
#import "AccountEntryObject.h"

@interface AccountTableViewController () {
    NSMutableArray *accountEntries;
}

@end

@implementation AccountTableViewController

#pragma mark Stock Class Methods
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Data 
//init the account table, reload table
- (void) setGrantObject:(GrantObject *)grant withAccount:(NSString *)account {
    accountEntries = [NSMutableArray array];
    
    // spin through every entry in this column, build an array of the cells
    for(AccountEntryObject *entry in [grant getEntriesWithAccountNames]) {
        if([[entry accountName] isEqualToString:account])
           [accountEntries addObject:entry];
    }
    
    [self.tableView reloadData];
}

- (IBAction)buttonBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return accountEntries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AccountEntryTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"entryCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[AccountEntryTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"entryCell"];
    }
    AccountEntryObject *entry = [accountEntries objectAtIndex:indexPath.row];
    
    cell.labelAccountName.text = [entry accountName];
    cell.labelAmount.text = [NSString stringWithFormat:@"%i", [entry amount]];
    cell.labelName.text = [entry label];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
