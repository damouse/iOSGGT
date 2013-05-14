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
#import "MBProgressHUD.h"

@interface DirectoryEditorTableViewController () {
    NSMutableArray *directories; //all of the added URLs
    NSMutableDictionary *newDirectory; //dont add it to the archive until it is comfirmed working
    NSMutableDictionary *editingDirectory;
    
    NSMutableData *jsonResponse;
    UITextView *editingTextView;
    MBProgressHUD *hud;
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
    
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gradient_background"]];
    [tempImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = tempImageView;
    
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

- (BOOL)shouldAutorotate
{
    return NO;
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
    NSString *grants = @"Grants: ";
    for(GrantObject *grant in [directory objectForKey:@"grants"]) {
        grants = [NSString stringWithFormat:@"%@ \"%@\"", grants, [[grant getMetadata] objectForKey:@"title"]];
    }
    
    cell.textfieldGrants.text = grants;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [directories removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
        
        NSData* save = [NSKeyedArchiver archivedDataWithRootObject:[NSArray arrayWithArray:directories]];
        [[NSUserDefaults standardUserDefaults] setObject:save forKey:@"directories"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark IBActions
- (IBAction)buttonBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)buttonAddDirectory:(id)sender {
    if(newDirectory == nil) {
        NSMutableDictionary *dir = [NSMutableDictionary dictionary];
            
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/YY"];
        NSString *date = [formatter stringFromDate:[NSDate date]];
            
        [dir setObject:@"Uninitialized Directory" forKey:@"nickname"];
        [dir setObject:date forKey:@"dateAdded"];
        [dir setObject:@"[fill url here]" forKey:@"url"];
        [dir setObject:[NSMutableArray array] forKey:@"grants"];
        
        newDirectory = dir;
        [directories addObject:newDirectory];
        [self.tableView reloadData];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error" message: @"Please enter a valid URL for the newly created directory before making a new one, or go back to undo" delegate:self
                              cancelButtonTitle:@"OK" otherButtonTitles:nil]; 
        [alert show];
    }
}

#pragma mark Text View
//save the contents of the box so we know which cell is being editted
-(void) textViewDidBeginEditing:(UITextView *)textView {
    NSLog(@"Text view editing...");
    if(editingDirectory != nil) {
        
        if (textView != editingTextView) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Error" message: @"Please enter a valid URL for the new entry before editing an existing one, or go back to undo" delegate:self
                                  cancelButtonTitle:@"OK" otherButtonTitles:nil]; //@"Connection error! Are you connected to the internet?"
            [alert show];
        }
    }
    else {
        for(NSMutableDictionary *directory in directories) {
            if([textView.text isEqualToString:[directory objectForKey:@"url"]]) {
                editingDirectory = directory;
                editingTextView = textView;
            }
        }
    }
}

//save the newly given URL, check to see if this is a new
- (void)textViewDidEndEditing:(UITextView *)textView {
    NSLog(@"Text view done editing");
    if(![textView.text isEqualToString:[editingDirectory objectForKey:@"url"]]) { //the URL was changed
    
        editingTextView = textView; //ping the new URL, see if valid. If so, then change the written URL.
        
        NSString *stringURL = textView.text;
        
        jsonResponse = [NSMutableData data];
        hud.detailsLabelText = @"Checking URL";
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?type=ping", stringURL]];
        
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:req delegate:self];
        
        [connection start];
        //spinner start
    }
    else {
        editingDirectory = nil; //clear the memory
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        
        return NO;
    }
    
    return YES;
}

#pragma mark NSURL methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [jsonResponse setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [jsonResponse appendData:data];;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error = nil;
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:jsonResponse options:nil error:&error];
    NSLog(@"Connection finished");
    
    if (error != nil)
    {
        NSLog(@"Deserializer Error: %@", [error description]);
        
        NSString *jsonDataString = [[NSString alloc] initWithData:jsonResponse encoding:NSUTF32BigEndianStringEncoding];
        
        NSString *fullError = @"URL is invalid. Please try again.";
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error" message: fullError delegate:self
                              cancelButtonTitle:@"OK" otherButtonTitles:nil]; //@"Connection error! Are you connected to the internet?"
        [alert show];
    }
    else {
        if(![[data objectForKey:@"status"] isEqualToString:@"success"])
            NSLog(@"There was an API error");
        else {
            //url is valid. If the given entry is an existing entry, delete its directory listings and reload them. Else, create a new one and archive it in.
            [editingDirectory setObject:editingTextView.text forKey:@"url"];
            
            //clear out existing information
            [editingDirectory removeObjectForKey:@"grants"]; //MUST FORCE AN UPDATE
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MM/dd/YY"];
            NSString *date = [formatter stringFromDate:[NSDate date]];
            
            [editingDirectory setObject:date forKey:@"dateAdded"];
            
            NSData* save = [NSKeyedArchiver archivedDataWithRootObject:[NSArray arrayWithArray:directories]];
            [[NSUserDefaults standardUserDefaults] setObject:save forKey:@"directories"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            editingDirectory = nil;
            editingTextView = nil;
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Success" message: @"Directory successfully added. Please return to main table to refresh grants" delegate:self
                                  cancelButtonTitle:@"OK" otherButtonTitles:nil]; //@"Connection error! Are you connected to the internet?"
            [alert show];
        }
    }
    
    [connection cancel];
    [hud hide:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Error During Connection: %@", [error description]);
    
    NSString *responseString = [[NSString alloc] initWithData:jsonResponse encoding:NSUTF8StringEncoding];
    //   NSLog(@"Response: %@",responseString);
    
    NSData *jsonData = [responseString dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    
    NSString *jsonDataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF32BigEndianStringEncoding];
    
    NSString *fullError = @"Url is invalid. Please try again.";
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Error" message: fullError delegate:self
                          cancelButtonTitle:@"OK" otherButtonTitles:nil]; //@"Connection error! Are you connected to the internet?"
    [alert show];
    
    [connection cancel];
    //connectionInProgress = NO;
    //[activityIndicator stopAnimating];
}
@end
