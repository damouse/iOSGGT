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
    NSIndexPath *selectedRowIndex; //this remembers the cell that was touched to dynamically expand tapped cells
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

    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gradient_background"]];
    [self.navigationController setNavigationBarHidden:YES];
    
    labelAccountName.text = [[accountEntries objectAtIndex:0] accountName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

#pragma mark Data 
//init the account table, reload table
- (void) setGrantObject:(GrantObject *)grant withAccount:(NSString *)account {
    accountEntries = [NSMutableArray array];
    
    // spin through every entry in this column, build an array of the cells
    for(AccountEntryObject *entry in [grant getEntriesWithAccountNames]) {

        if([[entry accountName] isEqualToString:account]) {
           [accountEntries addObject:entry];
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark Helper Methods
//given a string of currency, format it correctly and return it as an int
- (NSString *) formatCurrency:(int)amount {    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    
    NSNumber *temp = [NSDecimalNumber numberWithInt:amount];
    NSString *ret = [numberFormatter stringFromNumber:temp];
    
    ret = [ret stringByReplacingOccurrencesOfString:@".00" withString:@""];
    
    return ret;
}

- (NSString *) formatDate:(AccountEntryObject *)entry {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM dd, yyyy"];
    
    return [formatter stringFromDate:[entry date]];
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
    cell.labelAmount.text = [self formatCurrency:[entry amount]]; //sloppy, please fix
    cell.labelName.text = [entry label];
    
    NSString *description = [entry description];
     
    if(description == nil)
        description = [NSString stringWithFormat:@"Details not entered"];
    else
        description = [NSString stringWithFormat:@"Details: %@", description];
    
    cell.labelDetail.text = description;
    cell.labelDate.text = [self formatDate:entry];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(selectedRowIndex && indexPath.row == selectedRowIndex.row) {
        return 109;
    }
    return 54;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([selectedRowIndex isEqual:indexPath])
        selectedRowIndex = nil;
    else 
        selectedRowIndex = indexPath;
    
    [tableView beginUpdates];
    [tableView endUpdates];
}

#pragma mark IBOutlet
- (IBAction)buttonBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
