//
//  DirectoryEditorTableViewController.m
//  iOSGGT
//
//  Created by Mihnea Barboi on 5/12/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//
// Loads URL information, allow users to add new URL's pointing to a directory, change existing paths, etc. 

#import "DirectoryEditorTableViewController.h"
#import "DirectoryTableViewCell.h"
#import "GrantObject.h"

@interface DirectoryEditorTableViewController () {
    NSMutableArray *directories; //all of the added URLs
    
}

@end

@implementation DirectoryEditorTableViewController

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

    //load existing information from NSUserDefaults
    NSData *save = [[NSUserDefaults standardUserDefaults] objectForKey:@"directories"]; //note: init this in rootviewcontroller
    directories = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:save]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [directories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cellDirectory";
    DirectoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if(cell == nil ) {
        cell = [[DirectoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *directory = [directories objectAtIndex:indexPath.row];
    
    cell.textfieldNickname.text = [directory objectForKey:@"nickname"];
    cell.labelDate.text = [directory objectForKey:@"dateAdded"];
    cell.textviewURL.text = [directory objectForKey:@"url"];
    
    //loop through grants, get names
    NSString *grants = @"";
    for(GrantObject *grant in [directory objectForKey:@"grants"]) {
        grants = [NSString stringWithFormat:@"%@, %@", grants, [[grant getMetadata] objectForKey:@"title"]];
    }
    
    cell.textfieldGrants.text = grants;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

@end
