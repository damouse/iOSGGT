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
    
    NSArray *accounts;
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

#define AXIS_START 0
#define AXIS_END 50


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
    [self initBarPlot];
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
    
    for (int i = 0; i < 4 ; i++){
        double position = i*10; //Bars will be 10 pts away from each other
        double height = bar_heights[i];
        
        NSDictionary *bar = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithDouble:position],BAR_POSITION,
                             [NSNumber numberWithDouble:height],BAR_HEIGHT,
                             colors[i],COLOR,
                             categories[i],CATEGORY,
                             nil];
        [data addObject:bar];
        
    }
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
    [self createTestValues];
    
    [self createBarChartSource];
    
    //set the currently active plot before the graph is init so more than one plot does not appear
    currentlyActivePlot = @"budget";
    [self generateBarPlot];
}

- (void) createBarChartSource
{
    //get the corresponding data from the grant. Dont use any special data structures to show it, just do it manually
    accounts = [grant getAccounts];
    barSourceBudget = [grant getBudgetRow];
    barSourceBalance = [grant getBalanceRow];
    barSourcePaid = [grant getPaidRow];
    
    //determine the number of accounts present
    numberOfBars = 0;
    for(NSString *account in accounts) { //TODO: put checks for negative numbers
        if(![account isEqualToString:@""] && ![account isEqualToString:@"Amount"]) {
            numberOfBars++;
            
            //check the maximum numbers
        }
    }
}

- (void)generateBarPlot
{
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
                        CPTDecimalFromFloat(AXIS_START)
                                                    length:CPTDecimalFromFloat((AXIS_END - AXIS_START)+5)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:
                        CPTDecimalFromFloat(AXIS_START)
                                                    length:CPTDecimalFromFloat((AXIS_END - AXIS_START)+5)];
    
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
    
    for(int i = 0; i < 3; i++) {
        // Create bar plot and add it to the graph
        CPTBarPlot *plot = [[CPTBarPlot alloc] init] ;
        plot.dataSource = self;
        plot.delegate = self;
        
        //HAS to be dynamic
        
        plot.barWidth = [[NSDecimalNumber decimalNumberWithString:@"5.0"] decimalValue];
        plot.barOffset = [[NSDecimalNumber decimalNumberWithString:@"10.0"] decimalValue];
        
        plot.barCornerRadius = 2.0;
        
        // Remove bar outlines
        //CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
        //borderLineStyle.lineColor = [CPTColor clearColor];
        //plot.lineStyle = borderLineStyle;

        plot.identifier = [identifiers objectAtIndex:0];
        [identifiers removeObjectAtIndex:0];
        [graph addPlot:plot];
    }
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
    if ( [plot.identifier isEqual:@"balance"] )
        return [data count];
    
    return 0;

}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    if ( [plot.identifier isEqual:@"balance"] )
    {
        NSDictionary *bar = [data objectAtIndex:index];
        
        if(fieldEnum == CPTBarPlotFieldBarLocation)
            return [bar valueForKey:BAR_POSITION];
        else if(fieldEnum ==CPTBarPlotFieldBarTip)
            return [bar valueForKey:BAR_HEIGHT];
    }
    return [NSNumber numberWithFloat:0];
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    if ( [plot.identifier isEqual: @"balance"] )
    {
        CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
        textStyle.fontName = @"Helvetica";
        textStyle.fontSize = 14;
        textStyle.color = [CPTColor whiteColor];
        
        NSDictionary *bar = [data objectAtIndex:index];
        CPTTextLayer *label = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%@", [bar valueForKey:@"CATEGORY"]]];
        label.textStyle =textStyle;
        
        return label;
    }
    
    CPTTextLayer *defaultLabel = [[CPTTextLayer alloc] initWithText:@"Label"];
    return defaultLabel;
    
}

-(CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)index
{
    if ( [barPlot.identifier isEqual:@"balance"] )
    {
        NSDictionary *bar = [data objectAtIndex:index];
        CPTGradient *gradient = [CPTGradient gradientWithBeginningColor:[CPTColor whiteColor]
                                                            endingColor:[bar valueForKey:@"COLOR"]
                                                      beginningPosition:0.0 endingPosition:0.3 ];
        [gradient setGradientType:CPTGradientTypeAxial];
        [gradient setAngle:320.0];
        
        CPTFill *fill = [CPTFill fillWithColor:[bar valueForKey:@"COLOR"]];
        
        return fill;
        
    }
    return [CPTFill fillWithColor:[CPTColor colorWithComponentRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    
}

#pragma mark Pie Chart
- (void) populatePieChart
{
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
    float halfWidth = self.view.frame.size.width  / 3;
    float xOrigin = halfWidth - size / 2 - 2;
    
    float halfHeight = self.view.frame.size.height  / 3;
    float yOrigin = halfHeight - size / 2 + 8;
    
    return CGRectMake(xOrigin, yOrigin, size, size);
}

#pragma mark Slice Delegate
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
