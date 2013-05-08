//
//  MainGraphViewController.m
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/1/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
// GSPROJECTVIEWDEMO to do the middle graph

/**
    This class is the main controller for displaying all relevant information about each grant.
    Each account should be displayed with a different gssprogressview, should animate well.
    If a spinner is clicked, we should segue into account details controller
 
    This view should only be used in portrait for now. 
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MainGraphViewController.h"
#import "GrantObject.h"
#import "AccountTableViewController.h"
#import "PieSliceView.h"
#import "AccountLabelTableViewCell.h"

@interface MainGraphViewController () {
    GrantObject *grant;
    NSMutableArray *slices;
    NSMutableArray *sliceColors;
    
    NSMutableArray *labelsAndColors; // slice labels paired with their respective colors
    int currentColor;
}

@end

@implementation MainGraphViewController 

#pragma mark General Class
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES]; //disabled because it throws off the coordinates (come on, apple).
    
    //array of colors used to uniquely color slices
    sliceColors = [NSMutableArray arrayWithObjects:[UIColor redColor], [UIColor brownColor], [UIColor greenColor], [UIColor blueColor], [UIColor cyanColor], [UIColor yellowColor],[UIColor magentaColor],[UIColor orangeColor],[UIColor purpleColor], [UIColor grayColor], [UIColor brownColor], [UIColor greenColor], [UIColor blueColor], [UIColor cyanColor], [UIColor yellowColor],[UIColor magentaColor],[UIColor orangeColor],[UIColor purpleColor], nil];
    
    [self populatePieChart];
    labelTitle.text = [[grant getMetadata] objectForKey:@"title"];
}

#pragma mark Data
-(void)setGrantObject:(GrantObject *)grantObject
{
    grant = grantObject;
    labelTitle.text = [[grant getMetadata] objectForKey:@"title"];
}

#pragma mark Pie Chart
//use the array of slices to populate the pie chart. Slices animate when they are assigned percentFill!
//Note: slices should be added onto a running total of the fraction of total budget.
- (void) populatePieChart {
    NSDictionary *budget = [grant getBudgetRow]; //used to figure out percentFills
    NSDictionary *balance = [grant getBalanceRow]; //consider making an inside slice that expands outward based on remaining balance
    NSArray *accounts = [grant getAccounts];
    labelsAndColors = [NSMutableArray array];
    currentColor = 0; //this index tracks the used colors so they can be used again in the labels later
    
    float totalBudget = [[budget objectForKey:@"Amount"] floatValue]; //should this be dynamic on "amount?"
    float runningTotal = 0; //this is how far into the total budget the accounts have taken us. Should add up to total budget.
    float currentBudget;
    float percentFill;
    
    PieSliceView *slice;
    slices = [NSMutableArray array];
    
    for(NSString *account in accounts) { //TODO: put checks for negative numbers
        if(![account isEqualToString:@""] && ![account isEqualToString:@"Amount"]) {
            NSLog(@"creating slice for %@", account);
            slice = [self createNewSlice: account];
            
            currentBudget = [[budget objectForKey:account] floatValue]; //fetch value
            percentFill = (currentBudget + runningTotal) / totalBudget; //divide it by total (with current total)
            runningTotal += currentBudget; //increment total
            
            [slice setPercentFill:percentFill];
            [slices insertObject:slice atIndex:0];
        }
    }
    
    //[slices sortedArrayUsingSelector:@selector(compare:)];
    
    for(PieSliceView *slice in slices) {
        NSLog(@"Slice Percent %f", [slice percentFill]);
        [self.view bringSubviewToFront:slice]; //im not sure why this wasn't working... this should not have to be here. 
        [slice animateSlice];
    }
}

//create a new pieslice centered at the middle of the screen. Add the label to 
-(PieSliceView *) createNewSlice:(NSString *)accountName {
    PieSliceView *slice = [[PieSliceView alloc] initWithFrame:[self getCenteredRect:200]]; //this defines the size of the slice
    
    [slice setAccountName:accountName];
    slice.color = [sliceColors objectAtIndex:currentColor];
    [labelsAndColors insertObject:accountName atIndex:0];
    
    currentColor++; //go to next color
    
    [self.view addSubview:slice];
    
    return slice;
}

//return a rect that is centered at the hardcoded coordinates
-(CGRect) getCenteredRect:(float)size {
    float halfWidth = self.view.frame.size.width  / 3;
    float xOrigin = halfWidth - size / 2;
    
    float halfHeight = self.view.frame.size.height  / 3;
    float yOrigin = halfHeight - size / 2;
    
    return CGRectMake(xOrigin, yOrigin, size, size);
}

#pragma mark Slice Delegate
//This method checks incoming touches against the boundraries of present slices. Consider disabling when animations are running. 
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event  {
    UITouch *touch = [touches anyObject];
    int numSlicesThatRecievedTouch = 0; //use this to decide which slice was touched (since underlying slices also recieve touches)
    
    for(PieSliceView *slice in slices) {
        if([slice.path containsPoint:[touch locationInView:slice]]) {
            CGPoint point = [touch locationInView:slice];
            NSLog(@"X: %.0f Y: %.0f color: %@", point.x, point.y, slice.color);
            
            numSlicesThatRecievedTouch++;
        }
    }
    
    //the index of the slice that recieved the touch is length - numSlices. NOTE: slices is in reverse order
    int index = numSlicesThatRecievedTouch - 1;
    NSLog(@"touch on slice index: %i", index);

    if(index >= 0 && index < slices.count) {
        NSString *account = [[slices objectAtIndex:index] accountName];
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
        AccountTableViewController *detail = [mainStoryboard instantiateViewControllerWithIdentifier: @"accountGraphic"];
    
        [detail setGrantObject:grant withAccount:account];
        detail.labelGrantName.text = [[grant getMetadata] objectForKey:@"title"];
        [self.navigationController pushViewController:detail animated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return labelsAndColors.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AccountLabelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"accountLabel" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[AccountLabelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"accountLabel"];
    }
    
    int index = slices.count - indexPath.row - 1; //colors array is in increasing order (in terms of relative index), slices and names are NOT
    cell.viewColor.backgroundColor = [sliceColors objectAtIndex:indexPath.row];
    cell.labelName.text = [labelsAndColors objectAtIndex:index]; //matching is correct, just need to switch the order
    //cell.labelName.text =
    
    return cell;
}

/*- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 20;
}*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark IBOutlet
- (IBAction)buttonBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
