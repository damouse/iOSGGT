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
#import "QuartzCore/QuartzCore.h"

@interface MainGraphViewController () {
    GrantObject *grant;
    NSMutableArray *slices;
    NSMutableArray *sliceColors;
    
    NSMutableArray *labelsAndColors; // slice labels paired with their respective colors
    int currentColor;
    
    PieSliceView *currentlyAnimatingSlice;
    int currentlyAnimatingSliceIndex;

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
    
    labelStartDate.text = @"";
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
    float percentFillEnd;
    float percentFillStart;
    
    PieSliceView *slice;
    slices = [NSMutableArray array];
    
    for(NSString *account in accounts) { //TODO: put checks for negative numbers
        if(![account isEqualToString:@""] && ![account isEqualToString:@"Amount"]) {

            slice = [self createNewSlice: account];
            
            currentBudget = [[budget objectForKey:account] floatValue]; //fetch value
            percentFillEnd = (currentBudget + runningTotal) / totalBudget; //divide it by total (with current total)
            percentFillStart = runningTotal / totalBudget;
            runningTotal += currentBudget; //increment total
            
            [slice setAngleEnd:percentFillEnd];
            [slice setAngleStart:percentFillStart];
            [slice setProgress:percentFillStart];
            
            [slices addObject:slice];
        }
    }

    [self animateSlice]; //now animates all slices
}

//create a new pieslice centered at the middle of the screen. Add the label to 
-(PieSliceView *) createNewSlice:(NSString *)accountName {
    PieSliceView *slice = [[PieSliceView alloc] initWithFrame:[self getCenteredRect:200]]; //this defines the size of the slice
    
    [slice setAccountName:accountName];
    slice.color = [sliceColors objectAtIndex:currentColor];
    [labelsAndColors insertObject:accountName atIndex:0];
    
    NSLog(@"creating slice for %@ color index %i color %@", accountName, currentColor, [sliceColors objectAtIndex:currentColor]);
    
    currentColor++; //go to next color
    
    /*CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 5), 5.0, [[UIColor blackColor]CGColor]);
    CGContextDrawPath(context, kCGPathFill);*/
    
    [self.view addSubview:slice];
    
    return slice;
}

//return a rect that is centered at the hardcoded coordinates
-(CGRect) getCenteredRect:(float)size {
    float halfWidth = self.view.frame.size.width  / 3;
    float xOrigin = halfWidth - size / 2 - 2;
    
    float halfHeight = self.view.frame.size.height  / 3;
    float yOrigin = halfHeight - size / 2 + 8;
    
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


//Recursive call to animate the slice open. TODO: make a logarithmic timer so the animation is smoother.
- (void) animateSlice {    
    //intialize with the first slice
    if(currentlyAnimatingSlice == nil){
        currentlyAnimatingSliceIndex = 0;
        currentlyAnimatingSlice = [slices objectAtIndex:0];
    }
    
    if([currentlyAnimatingSlice progress] < [currentlyAnimatingSlice angleEnd]) { //continue animating this slice if its not yet finished
        currentlyAnimatingSlice.progress += .01;
        [currentlyAnimatingSlice setNeedsDisplay];
        [NSTimer scheduledTimerWithTimeInterval:0.005 target:self selector:@selector(animateSlice) userInfo:nil repeats:NO];
    }
    else { //if this slice has reached its goal, move to the next and continue the calls       
        
        currentlyAnimatingSliceIndex++;
        if(currentlyAnimatingSliceIndex < slices.count){
            currentlyAnimatingSlice = [slices objectAtIndex:currentlyAnimatingSliceIndex];
            
            [self animateSlice];
        }
        else { //if were here, then all slices have been animated. Explode them all out
            for(PieSliceView *slice in slices)
                [slice animateSlice];
        }
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AccountLabelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"accountLabel" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[AccountLabelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"accountLabel"];
    }

    UIColor *temp = [sliceColors objectAtIndex:indexPath.row];
    const CGFloat* components = CGColorGetComponents(temp.CGColor);
    
    if(![temp isEqual:[UIColor grayColor]]) //changing the opacity of gray turns it green for some reason. 
        temp = [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:.6];
    
    cell.labelName.backgroundColor = temp;
    
    [[cell.labelName layer] setCornerRadius:8.0f];
    [[cell.labelName layer] setMasksToBounds:YES];
    //[[cell.labelName layer] setBorderWidth:1.0f];
    
    int index = slices.count - indexPath.row - 1; //colors array is in increasing order (in terms of relative index), slices and names are NOT
    cell.viewColor.backgroundColor = [sliceColors objectAtIndex:indexPath.row];

    cell.labelName.text = [NSString stringWithFormat:@" %@",[labelsAndColors objectAtIndex:index]]; //matching is correct, just need to switch the order
    
    
    NSLog(@"cell index %d name%@ color %@", indexPath.row, cell.labelName.text, [sliceColors objectAtIndex:indexPath.row]);
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark IBOutlet
- (IBAction)buttonBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
