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

#import "CorePlot-CocoaTouch.h"
#import "CPTBarPlot.h"

@interface MainGraphViewController () {
    GrantObject *grant;
    NSMutableArray *slices;
    NSMutableArray *sliceColors;
    
    NSMutableArray *labelsAndColors; // slice labels paired with their respective colors
    int currentColor;
    
    PieSliceView *currentlyAnimatingSlice;
    int currentlyAnimatingSliceIndex;
    
    
    //bar chart
    NSMutableArray *data;
    CPTGraphHostingView *hostingView;
    CPTXYGraph *graph;
    
    NSMutableArray *accounts;
    NSDictionary *barSourceBudget;
    NSDictionary *barSourceBalance;
    NSDictionary *barSourcePaid;
    
    int numberOfBars;
    NSString *currentlyActivePlot;
}

@end

@implementation MainGraphViewController

//Constants for the "tutorial" bar chart
#define BAR_POSITION @"POSITION"
#define BAR_HEIGHT @"HEIGHT"
#define COLOR @"COLOR"
#define CATEGORY @"CATEGORY"
/*
#define AXIS_START 0
#define AXIS_END 50*/


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
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM dd, yyyy"];
    
    labelTitle.text = [[grant getMetadata] objectForKey:@"title"];
    labelStartDate.text = [[grant getMetadata] objectForKey:@"startDate"];
    labelEndDate.text = [[grant getMetadata] objectForKey:@"endDate"];
    labelLastUpdated.text = [formatter stringFromDate:[[grant getMetadata] objectForKey:@"dateLastAccessed"]];
    labelAccountNumber.text = [[grant getMetadata] objectForKey:@"accountNumber"];
    labelAgencyNumber.text = [[grant getMetadata] objectForKey:@"awardNumber"];
    labelGrantor.text = [[grant getMetadata] objectForKey:@"grantor"];
    labelOverhead.text = [[grant getMetadata] objectForKey:@"overhead"];
    labelName.text = [[grant getMetadata] objectForKey:@"name"];
    
    //[self populatePieChart]
    //[self createTestValues];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self initBarPlot];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {    // Or whatever orientation it will be presented in.
        return YES;
    }
    return NO;
}

#pragma mark Graph Init
- (void) initBarPlot
{
    //[self createTestValues];
    
    float max = [self createBarChartSource];
    
    //set the currently active plot before the graph is init so more than one plot does not appear
    currentlyActivePlot = @"budget";
    [self generateBarPlot:max];
}

- (void) createTestValues
{
    data = [NSMutableArray array];
    
    int bar_heights[] = {20,30,10,40};
    UIColor *colors[] = {
        [UIColor redColor],
        [UIColor blueColor],
        [UIColor orangeColor],
        [UIColor purpleColor]};
    NSString *categories[] = {@"Plain Milk", @"Milk + Caramel", @"White", @"Dark"};
    
    NSLog(@"Building test values...");
    for (int i = 0; i < 4 ; i++){

        double position = i; //Bars will be 10 pts away from each other
        double height = bar_heights[i];
        
        NSDictionary *bar = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithDouble:position],BAR_POSITION,
                             [NSNumber numberWithDouble:height],BAR_HEIGHT,
                             colors[i],COLOR,
                             categories[i],CATEGORY,
                             nil];
        [data addObject:bar];
        
    }
    
    NSLog(@"Building test values done");
    /*
     $1 = 0x07232df0 <__NSArrayM 0x7232df0>(
     {
         CATEGORY = "Plain Milk";
         COLOR = "UIDeviceRGBColorSpace 1 0 0 1";
         HEIGHT = 20;
         POSITION = 0;
     },
     {
         CATEGORY = "Milk + Caramel";
         COLOR = "UIDeviceRGBColorSpace 0 0 1 1";
         HEIGHT = 30;
         POSITION = 10;
     },
     {
         CATEGORY = White;
         COLOR = "UIDeviceRGBColorSpace 1 0.5 0 1";
         HEIGHT = 10;
         POSITION = 20;
     },
     {
         CATEGORY = Dark;
         COLOR = "UIDeviceRGBColorSpace 0.5 0 0.5 1";
         HEIGHT = 40;
         POSITION = 30;
     }
     )*/
}

- (float) createBarChartSource
{
    //get the corresponding data from the grant. Dont use any special data structures to show it, just do it manually
    //returns the highest value times a constant
    
    //remove all the empty accounts and the "Amount" column
    accounts = [NSMutableArray array];
    for(NSString *account in [grant getAccounts]) {
        if(![account isEqualToString:@""] && ![account isEqualToString:@"Amount"])
           [accounts addObject:account];
    }

    barSourceBudget = [grant getBudgetRow];
    barSourceBalance = [grant getBalanceRow];
    barSourcePaid = [grant getPaidRow];
    
    float max = 0;
    float temp;
    
    //determine the number of accounts present
    numberOfBars = 0;
    
    NSLog(@"building real values...");
    for(NSString *account in accounts) { //TODO: put checks for negative numbers
        numberOfBars++;
        
        //check the maximum numbers from each account to set the max height of the graph
        if([[barSourceBudget objectForKey:account] floatValue] > max)
            max = [[barSourceBudget objectForKey:account] floatValue];
        
        if([[barSourceBalance objectForKey:account] floatValue] > max)
            max = [[barSourceBudget objectForKey:account] floatValue];
        
        if([[barSourcePaid objectForKey:account] floatValue] > max)
            max = [[barSourceBudget objectForKey:account] floatValue];
    }
    
    NSLog(@"building real values done");
    
    //creat a little buffer on the top edge of the graph
    return max * 1.2;
}

- (void) generateBarPlot:(float) max
{
    NSLog(@"building bar plot...");
    
    //Create host view
    hostingView = [[CPTGraphHostingView alloc]
                   initWithFrame:viewGraph.frame];
    [self.view addSubview:hostingView];
    
    //Create graph and set it as host view's graph
    graph = [[CPTXYGraph alloc] initWithFrame:hostingView.bounds];
    [hostingView setHostedGraph:graph];
    
    //graph padding
    graph.paddingLeft   = 0.0;
    graph.paddingTop    = 0.0;
    graph.paddingRight  = 0.0;
    graph.paddingBottom = 0.0;
    
    //set graph padding and theme
    graph.plotAreaFrame.paddingTop = 0;
    graph.plotAreaFrame.paddingRight = 0;
    graph.plotAreaFrame.paddingBottom = 0;
    graph.plotAreaFrame.paddingLeft = 0;
    [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    
    //set axes ranges
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:
                        CPTDecimalFromFloat(0)
                                                    length:CPTDecimalFromFloat(numberOfBars  * 2)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:
                        CPTDecimalFromFloat(0)
                                                    length:CPTDecimalFromFloat(max)];
    
    //remove that weird line area
    graph.plotAreaFrame.borderLineStyle = nil;
    graph.plotAreaFrame.cornerRadius    = 0.0;
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    
    //set axes' title, labels and their text styles
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.fontName = @"Helvetica";
    textStyle.fontSize = 14;
    textStyle.color = [CPTColor whiteColor];
    //axisSet.xAxis.title = @"CHOCOLATE";
    //axisSet.yAxis.title = @"AWESOMENESS";
    axisSet.xAxis.titleTextStyle = textStyle;
    axisSet.yAxis.titleTextStyle = textStyle;
    axisSet.xAxis.titleOffset = 30.0f;
    axisSet.yAxis.titleOffset = 40.0f;
    axisSet.xAxis.labelTextStyle = textStyle;
    axisSet.xAxis.labelOffset = 3.0f;
    axisSet.yAxis.labelTextStyle = textStyle;
    axisSet.yAxis.labelOffset = 3.0f;
    
    //set axes' line styles and interval ticks
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor grayColor];
    lineStyle.lineWidth = 3.0f;
    
    //set line style for y axis: none
    CPTMutableLineStyle *lineStyleX = [CPTMutableLineStyle lineStyle];
    lineStyleX.lineColor = [CPTColor clearColor];
    
    axisSet.xAxis.axisLineStyle = lineStyleX;
    axisSet.yAxis.axisLineStyle = lineStyle;
    
    axisSet.xAxis.majorTickLineStyle = lineStyleX;
    axisSet.yAxis.majorTickLineStyle = lineStyle;
    
    axisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(5.0f);
    axisSet.yAxis.majorIntervalLength = CPTDecimalFromFloat(5.0f);
    axisSet.xAxis.majorTickLength = 7.0f;
    axisSet.yAxis.majorTickLength = 7.0f;
    axisSet.xAxis.minorTickLineStyle = lineStyleX;
    axisSet.yAxis.minorTickLineStyle = lineStyle;
    axisSet.xAxis.minorTicksPerInterval = 1;
    axisSet.yAxis.minorTicksPerInterval = 1;
    axisSet.xAxis.minorTickLength = 5.0f;
    axisSet.yAxis.minorTickLength = 5.0f;
    
    NSMutableArray *identifiers = [NSMutableArray arrayWithObjects:@"balance", @"budget", @"paid", nil];
    float width = viewGraph.frame.size.width;

    for(int i = 0; i < 3; i++) {
        // Create bar plot and add it to the graph
        CPTBarPlot *plot = [[CPTBarPlot alloc] init] ;
        plot.dataSource = self;
        plot.delegate = self;
        
        //HAS to be dynamic
        plot.barWidth = [[NSDecimalNumber decimalNumberWithString:@"1.0"] decimalValue];
        plot.barOffset = [[NSDecimalNumber decimalNumberWithString:@"0.0"] decimalValue];
        
        plot.barCornerRadius = 2.0;
        
        // Remove bar outlines
        //CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
        //borderLineStyle.lineColor = [CPTColor clearColor];
        //plot.lineStyle = borderLineStyle;

        plot.identifier = [identifiers objectAtIndex:0];
        [identifiers removeObjectAtIndex:0];
        [graph addPlot:plot];
    }
    
    NSLog(@"building bar plot done");
}

#pragma mark Data
-(void)setGrantObject:(GrantObject *)grantObject
{
    grant = grantObject;
    labelTitle.text = [[grant getMetadata] objectForKey:@"title"];
}

#pragma mark Graph Delegate and DataSource
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    NSLog(@"number of records for plot");

    if ( [plot.identifier isEqual:@"balance"] )
        return [accounts count];
    
    return 0;

}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSLog(@"number for plot");
    
    if ( [plot.identifier isEqual:@"balance"] )
    {
        //NSDictionary *bar = [data objectAtIndex:index];
        
        NSString *accountName = [accounts objectAtIndex:index];
        NSString *value = [barSourceBudget objectForKey:accountName];

        if(fieldEnum == CPTBarPlotFieldBarLocation)
            return [NSNumber numberWithInt:(index * 2 + 1)];
        else if(fieldEnum ==CPTBarPlotFieldBarTip)
            return value;
    }
    return [NSNumber numberWithFloat:0];
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    NSLog(@"data label for plot");
    
    if ( [plot.identifier isEqual: @"balance"] )
    {
        CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
        textStyle.fontName = @"Helvetica";
        textStyle.fontSize = 14;
        textStyle.color = [CPTColor whiteColor];
        
        //NSDictionary *bar = [data objectAtIndex:index];
        CPTTextLayer *label = [[CPTTextLayer alloc] initWithText:[accounts objectAtIndex:index]];
        label.textStyle =textStyle;
        
        return label;
    }
    
    CPTTextLayer *defaultLabel = [[CPTTextLayer alloc] initWithText:@"Label"];
    return defaultLabel;
    
}

-(CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)index
{
    NSLog(@"bar fill for plot");
    return [CPTFill fillWithColor:[sliceColors objectAtIndex:index]];
}

- (void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"Bar was selected at index %i", index);
}

#pragma mark Pie Chart
- (void) populatePieChart
{
    NSLog(@"!");
    
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
            
            
            [slices addObject:slice];
        }
    }

    [self animateSlice]; //now animates all slices
}

-(PieSliceView *) createNewSlice:(NSString *)accountName
{
    NSLog(@"!");

    
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

-(CGRect) getCenteredRect:(float)size
{
    NSLog(@"!");

    
    float halfWidth = self.view.frame.size.width  / 3;
    float xOrigin = halfWidth - size / 2 - 2;
    
    float halfHeight = self.view.frame.size.height  / 3;
    float yOrigin = halfHeight - size / 2 + 8;
    
    return CGRectMake(xOrigin, yOrigin, size, size);
}

#pragma mark Slice Delegate
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"!");

    
    UITouch *touch = [touches anyObject];
    int i = 0;
    int indexOfTouchedSlice = -1; //use this to decide which slice was touched (since underlying slices also recieve touches)
    
    for(PieSliceView *slice in slices) {
        if([slice.path containsPoint:[touch locationInView:slice]]) {
            CGPoint point = [touch locationInView:slice];
            NSLog(@"X: %.0f Y: %.0f color: %@", point.x, point.y, slice.color);
            
            indexOfTouchedSlice = i;
        }
        i++;
    }

    NSLog(@"touch on slice index: %i", indexOfTouchedSlice);

    if(indexOfTouchedSlice >= 0 && indexOfTouchedSlice < slices.count) {
        NSString *account = [[slices objectAtIndex:indexOfTouchedSlice] accountName];
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
        AccountTableViewController *detail = [mainStoryboard instantiateViewControllerWithIdentifier: @"accountGraphic"];
    
        [detail setGrantObject:grant withAccount:account];
        detail.labelGrantName.text = [[grant getMetadata] objectForKey:@"title"];
        [self.navigationController pushViewController:detail animated:YES];
    }
}

- (void) animateSlice
{
    NSLog(@"!");

    
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
    NSLog(@"!");

    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"!");

    
    return labelsAndColors.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"!");

    
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
    NSLog(@"!");

    
    NSString *account = [[slices objectAtIndex:indexPath.row] accountName];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    AccountTableViewController *detail = [mainStoryboard instantiateViewControllerWithIdentifier: @"accountGraphic"];
    
    [detail setGrantObject:grant withAccount:account];
    detail.labelGrantName.text = [[grant getMetadata] objectForKey:@"title"];
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark IBOutlet
- (IBAction)buttonBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
