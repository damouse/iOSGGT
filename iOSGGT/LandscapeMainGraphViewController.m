//
//  LandscapeMainGraphViewController.m
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/19/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

/***
    NOTE: there is a method in the dropplot file that handles CSV files directly as input. Likely pointless, but just keep it in mind
 */

#import "LandscapeMainGraphViewController.h"
#import "CorePlot-CocoaTouch.h"

#import "GrantObject.h"
#import "AccountEntryObject.h"
#import "CPTPlotRange.h"

@interface LandscapeMainGraphViewController () {
    CPTGraph *graph;
    double minimumValueForXAxis;
    double maximumValueForXAxis;
    double minimumValueForYAxis;
    double maximumValueForYAxis;
    
    double majorIntervalLengthForX;
    double majorIntervalLengthForY;
    
    CPTPlotRange *test;
    
    NSMutableArray *plots; //array of the plots created, just get the index of each to fetch grants
    NSMutableArray *grants; //array of arrays of dictionarys. Grants[ Accounts {entries}]
    
    NSArray *grantObjects; //saved just to retain metadata
    NSDate *refDate;
    NSTimeInterval oneDay;
}

@end

@implementation LandscapeMainGraphViewController

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
    [self.navigationController setNavigationBarHidden:YES];
    
    refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:157680000]; //reference date is 2006
    plots = [NSMutableArray array];
    
    //set up time stuff    
    NSTimeInterval difference = [[NSDate date] timeIntervalSinceDate:refDate]; //difference between today and 2006

    minimumValueForXAxis = 0;
    maximumValueForXAxis = difference;
    minimumValueForYAxis = 0;
    maximumValueForYAxis = 500000; //do this dynamically. Find the max of all grants
    
    majorIntervalLengthForX = oneDay * 30 * 6; //half a month. Consider a year?
    majorIntervalLengthForY = 100000;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    if(graph == nil)
        [self initPlot];
}


#pragma mark Data Init
//method takes in the grant objects and then makes it "horizontal." If the changes are just plotted by themselves, then each change in the amount of the graph
//has a slope. Each point must therefor get a second, auxilliary point that sits right before the next point in the grant. This auxilliary point
// keeps the changes horizontal. Also, each account entry should be processed as a change in the total balance, not a data point
- (void) initWithGrantArray:(NSMutableArray *)grantArray {
    grants = [NSMutableArray array];
    grantObjects = grantArray;
    oneDay = 24 * 60 * 60;
    
    //iterate over every grant. NOTE: the accounting entries have already been sorted
    //each element of the overarching array is an array representing a grant. Each element of this array is a dictionary
    //with the date as a key and the account entry as the object
    for(GrantObject *grant in grantArray) {
        NSMutableArray *accountEntries = [NSMutableArray array];
        
        AccountEntryObject *lastEntry;
        //for each entry, create the horizontal entry and add it to the new array
        for(AccountEntryObject *entry in [grant accountEntries]) {
            
            //re-add the last entry with the date changed. Copy first.
            if(lastEntry != nil) {
                [lastEntry setDate:[[entry date] dateByAddingTimeInterval:-1]];
                [accountEntries addObject:lastEntry];
            }
            
            //add this entry
            [accountEntries addObject:entry];
            lastEntry = [entry copy];
        }   //END ENTRY LOOP
        
        [lastEntry setDate:[[lastEntry date] dateByAddingTimeInterval:1]]; //add this just so the end of the graph is level
        [accountEntries addObject:lastEntry];
        
        [grants addObject:accountEntries];
    } //END GRANTS LOOP
}

#pragma mark - Chart behavior
-(void)initPlot {
    [self configureHost];
    [self configureGraph];
    [self configureXYChart];
    [self configureLegend];
    
    //add ghost label (testing)
    UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 100, 20)];
    testLabel.text = @"Grant Name";
    [self.view addSubview:testLabel];
}

-(void)configureHost {
	// set up view frame
	CGRect parentRect = self.view.bounds;
	parentRect = CGRectMake(parentRect.origin.x, parentRect.origin.y, parentRect.size.width, parentRect.size.height);
    
	// create host view
	self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
	self.hostView.allowPinchScaling = YES;
	[self.view addSubview:self.hostView];
}

-(void)configureGraph {
	// 1 - Create and initialise graph
	graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    
	self.hostView.hostedGraph = graph;
	graph.paddingLeft = 10.0f;
	graph.paddingTop = 10.0f;
	graph.paddingRight = 10.0f;
	graph.paddingBottom = 10.0f;
    
	// 2 - Set up text style
	CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
	textStyle.color = [CPTColor whiteColor];
	textStyle.fontName = @"Helvetica-Bold";
	textStyle.fontSize = 20.0f;
    
	// 3 - Configure title
	NSString *title = @"All Grants";
	graph.title = title;
	graph.titleTextStyle = textStyle;
	graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
	graph.titleDisplacement = CGPointMake(0.0f, -12.0f);
    
    //graph padding
    graph.paddingLeft   = 0.0;
    graph.paddingTop    = 0.0;
    graph.paddingRight  = 0.0;
    graph.paddingBottom = 0.0;
    
    graph.plotAreaFrame.paddingLeft   = 20.0;
    graph.plotAreaFrame.paddingTop    = 20.0;
    graph.plotAreaFrame.paddingRight  = 20.0;
    graph.plotAreaFrame.paddingBottom = 35.0;
    
    //remove that weird line area
    graph.plotAreaFrame.borderLineStyle = nil;
    graph.plotAreaFrame.cornerRadius    = 0.0;
    
	// 4 - Set theme
	self.selectedTheme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
	[graph applyTheme:self.selectedTheme];
    

}

-(void) configureXYChart {
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(minimumValueForXAxis)
                                                    length:CPTDecimalFromDouble(ceil( (maximumValueForXAxis - minimumValueForXAxis) / majorIntervalLengthForX ) * majorIntervalLengthForX)];
    
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(minimumValueForYAxis)
                                                    length:CPTDecimalFromDouble(ceil( (maximumValueForYAxis - minimumValueForYAxis) / majorIntervalLengthForY ) * majorIntervalLengthForY)];
    
    test = plotSpace.yRange;
    
    // this allows the plot to respond to touch events
    [plotSpace setDelegate:self]; //set delegate fromm other file  ABE: what does this mean?
    [plotSpace setAllowsUserInteraction:YES];
    
    //set up x axis
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;

    CPTXYAxis *x = axisSet.xAxis;
    
    //x.labelOffset           = 5.0; //conflict
    //x.axisConstraints       = [CPTConstraints constraintWithLowerOffset:0.0]; //what is this?
    //x.orthogonalCoordinateDecimal = [[NSNumber numberWithInt:20] decimalValue]; //conflict and i dont know what this is
    //x.labelOffset = 10.0f;
    //x.labelingPolicy = CPTAxisLabelingPolicyAutomatic; //no conflict, please test this
    
    // plotting style is set to line plots
    /*CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle]; //this block changes and sets the color of the axis
    lineStyle.lineColor = [CPTColor blackColor];
    lineStyle.lineWidth = 2.0f;
    x.majorTickLineStyle = lineStyle;
    x.minorTickLineStyle = lineStyle;
    x.axisLineStyle = lineStyle; */
    
    x.majorIntervalLength = CPTDecimalFromDouble(majorIntervalLengthForX * 2);
    x.minorTicksPerInterval = 0;
    x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"1"); //added for date, adjust x line
    x.minorTickLength = 5.0f;
    x.majorTickLength = 7.0f;
    x.labelOffset = 3.0f;

    // Date Formatting
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/YY"];
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = refDate;
    x.labelFormatter = timeFormatter;
    
    //number formatter for y, makes it into thousands. Still need to add a $ sign
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setMaximumFractionDigits:0];
    //[numberFormatter setMultiplier:[NSNumber numberWithDouble:.001]]; //removed the 1/1000 conversion
    
    //set up y axis
    CPTXYAxis *y = axisSet.yAxis;
    y.minorTicksPerInterval = 1;
    y.majorIntervalLength   = CPTDecimalFromDouble(majorIntervalLengthForY);
    y.labelOffset           = 1.0;
    y.axisConstraints       = [CPTConstraints constraintWithLowerOffset:-10.0]; //where is the y axis?
    y.labelFormatter = numberFormatter;
    y.tickDirection = CPTSignPositive; //moves the labels to the inside of the graph instead of the to the left of the y axis
    
    //y axis grid lines
    CPTMutableLineStyle *yGridLines = [CPTMutableLineStyle lineStyle];
    yGridLines.lineColor = [CPTColor darkGrayColor];
    y.majorGridLineStyle = yGridLines;
    
    //TEST

    
    //y axis label
    //y.title = @"(thousands)";
    //y.titleLocation =
    //y.titleRotation = 0.0; //this moves it to the top of the axis
    //y.titleLocation = plotSpace.yRange.maxLimit
    

    
        // Create plots for every grant
    //graph line style 
    CPTMutableLineStyle *dataLineStyle = [CPTMutableLineStyle lineStyle];
    dataLineStyle.lineWidth = 1.0f;
    
    //create array of avaliable colors for coloring plots
    NSMutableArray *colors = [NSMutableArray arrayWithObjects:[CPTColor redColor], [CPTColor greenColor], [CPTColor blueColor], [CPTColor cyanColor], [CPTColor yellowColor],[CPTColor magentaColor],[CPTColor orangeColor],[CPTColor purpleColor], nil];
    
    for(GrantObject *grant in grantObjects) {
        CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] initWithFrame:graph.bounds];
        dataSourceLinePlot.identifier = [[grant getMetadata] objectForKey:@"title"];
        dataSourceLinePlot.dataSource = self;
        dataSourceLinePlot.delegate = self;
        dataSourceLinePlot.plotSymbolMarginForHitDetection = 10;
        
        //assign this plot the color, then remove it. Multiple runs of this loop should retain color pairing
        dataLineStyle.lineColor = [colors objectAtIndex:0];
        [colors removeObjectAtIndex:0];
        dataSourceLinePlot.dataLineStyle = dataLineStyle;
        
        [graph addPlot:dataSourceLinePlot];
        [plots addObject:dataSourceLinePlot]; //the index at which this was added corresponds to the index of this grant in "grants" array
    }
}

-(void)configureLegend {
	// 2 - Create legend
	CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
    
	// 3 - Configure legen
	theLegend.numberOfColumns = 1;
	theLegend.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
	theLegend.borderLineStyle = [CPTLineStyle lineStyle];
	theLegend.cornerRadius = 5.0;
    
	// 4 - Add legend to graph
	graph.legend = theLegend;
	graph.legendAnchor = CPTRectAnchorRight;
	//CGFloat legendPadding = -(self.view.bounds.size.width / 10);
	//graph.legendDisplacement = CGPointMake(legendPadding, 0.0);
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    NSArray *grant = [grants objectAtIndex:0];
    
    return  grant.count;
}

//fetches the index of the appropriate plot, uses that index to retrieve the array of acocunting entries from the grant indexed. 
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    int i = [plots indexOfObject:plot];
    NSArray *grant = [grants objectAtIndex:i];
    AccountEntryObject *entry = [grant objectAtIndex:index];
    
    if(fieldEnum == CPTScatterPlotFieldY) {
        //NSLog(@"amount: %i", [entry runningTotalToDate]);
        return [NSNumber numberWithInt:[entry runningTotalToDate]];
    }
    else {
        //NSLog(@"Date as Time Interval: %@  for entry: %@", [entry dateAsTimeInterval], [entry label]);
        return [entry dateAsTimeInterval];
    }
}

//allows the user to click on individual plot points. Consider a popup, or a transistion to another VC
-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:    (NSUInteger)index
{
    NSLog(@"plotSymbolWasSelectedAtRecordIndex %d", index);
}

#pragma mark Plot Customization Methods
-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate {
    //CPTPlotRange *new = [CPTPlotRange plotRangeWithLocation:[[[NSDecimalNumber alloc] initWithInt:10] decimalValue] length:[[[NSDecimalNumber alloc] initWithInt:1] decimalValue]];
    
    if(coordinate == 0) {//if x coordinate, allow modification
        
        //if the length passes a certain amount, resize the interval ticks to keep them readable
        CPTXYAxisSet *axisSet = (id)graph.axisSet;
        
        if(newRange.lengthDouble > 140000000)
            axisSet.xAxis.majorIntervalLength = CPTDecimalFromDouble(majorIntervalLengthForX*2);
        else if(newRange.lengthDouble < 70000000)
            axisSet.xAxis.majorIntervalLength = CPTDecimalFromDouble(majorIntervalLengthForX/2);
        else
            axisSet.xAxis.majorIntervalLength = CPTDecimalFromDouble(majorIntervalLengthForX);
        
        return newRange;
    }
    else //dont let the y axis zoom or scroll
        return test;
}

/*-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index {
	// 1 - Define label text style
	static CPTMutableTextStyle *labelText = nil;
	if (!labelText) {
		labelText= [[CPTMutableTextStyle alloc] init];
		labelText.color = [CPTColor grayColor];
	}
	// 2 - Calculate portfolio total value
	NSDecimalNumber *portfolioSum = [NSDecimalNumber zero];
	for (NSDecimalNumber *price in dataPoints) {
		portfolioSum = [portfolioSum decimalNumberByAdding:price];
	}
    
	// 3 - Calculate percentage value
	NSDecimalNumber *price = [dataPoints objectAtIndex:index];
	NSDecimalNumber *percent = [price decimalNumberByDividingBy:portfolioSum];
    
	// 4 - Set up display label
	NSString *labelValue = [NSString stringWithFormat:@"$%0.2f USD (%0.1f %%)", [price floatValue], ([percent floatValue] * 100.0f)];
    
	// 5 - Create and return layer with label text
	return [[CPTTextLayer alloc] initWithText:labelValue style:labelText]; //not this
}*/

/*-(NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index {
	if (index < [dataPoints count]) {
		if(index == 1)
            return @"Budget"; //HACKED FIX HERE
        if(index == 0)
            return @"Remaining"; //HACKED FIX HERE
	}
	return @"N/A";
}*/

///////////////////////////////////// CODE from the other project, kepy around for referance on how to change

-(void) initGraphSpace
{
    // Create graph from theme
    graph = [[CPTXYGraph alloc] initWithFrame:self.view.frame];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [graph applyTheme:theme];
    self.hostView.hostedGraph = graph;
    //graphView.hostedGraph = graph;
    
    graph.paddingLeft   = 0.0;
    graph.paddingTop    = 0.0;
    graph.paddingRight  = 0.0;
    graph.paddingBottom = 0.0;
    
    graph.plotAreaFrame.paddingLeft   = 55.0;
    graph.plotAreaFrame.paddingTop    = 40.0;
    graph.plotAreaFrame.paddingRight  = 40.0;
    graph.plotAreaFrame.paddingBottom = 35.0;
    
    graph.plotAreaFrame.plotArea.fill = graph.plotAreaFrame.fill;
    graph.plotAreaFrame.fill          = nil;
    
    graph.plotAreaFrame.borderLineStyle = nil;
    graph.plotAreaFrame.cornerRadius    = 0.0;
    
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(minimumValueForXAxis) length:CPTDecimalFromDouble(ceil( (maximumValueForXAxis - minimumValueForXAxis) / majorIntervalLengthForX ) * majorIntervalLengthForX)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(minimumValueForYAxis) length:CPTDecimalFromDouble(ceil( (maximumValueForYAxis - minimumValueForYAxis) / majorIntervalLengthForY ) * majorIntervalLengthForY)];
    
    // this allows the plot to respond to mouse events
    [plotSpace setDelegate:self]; //set delegate form other file
    [plotSpace setAllowsUserInteraction:YES];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    
    CPTXYAxis *x = axisSet.xAxis;
    x.minorTicksPerInterval = 9;
    x.majorIntervalLength   = CPTDecimalFromDouble(majorIntervalLengthForX);
    x.labelOffset           = 5.0;
    x.axisConstraints       = [CPTConstraints constraintWithLowerOffset:0.0];
    
    CPTXYAxis *y = axisSet.yAxis;
    y.minorTicksPerInterval = 9;
    y.majorIntervalLength   = CPTDecimalFromDouble(majorIntervalLengthForY);
    y.labelOffset           = 5.0;
    y.axisConstraints       = [CPTConstraints constraintWithLowerOffset:0.0];
    
    // Create the main plot for the delimited data
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] initWithFrame:graph.bounds];
    dataSourceLinePlot.identifier = @"Data Source Plot";
    
    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 1.0;
    lineStyle.lineColor              = [CPTColor whiteColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
}

-(BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    return YES;
}


#pragma mark -
#pragma mark Plot Space Delegate Methods

/*-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDraggedEvent:(id)event atPoint:(CGPoint)interactionPoint
{
    if ( zoomAnnotation ) {
        CPTPlotArea *plotArea = graph.plotAreaFrame.plotArea;
        CGRect plotBounds     = plotArea.bounds;
        
        // convert the dragStart and dragEnd values to plot coordinates
        CGPoint dragStartInPlotArea = [graph convertPoint:dragStart toLayer:plotArea];
        CGPoint dragEndInPlotArea   = [graph convertPoint:interactionPoint toLayer:plotArea];
        
        // create the dragrect from dragStart to the current location
        CGFloat endX      = MAX( MIN( dragEndInPlotArea.x, CGRectGetMaxX(plotBounds) ), CGRectGetMinX(plotBounds) );
        CGFloat endY      = MAX( MIN( dragEndInPlotArea.y, CGRectGetMaxY(plotBounds) ), CGRectGetMinY(plotBounds) );
        CGRect borderRect = CGRectMake( dragStartInPlotArea.x, dragStartInPlotArea.y,
                                       (endX - dragStartInPlotArea.x),
                                       (endY - dragStartInPlotArea.y) );
        
        zoomAnnotation.contentAnchorPoint = CGPointMake(dragEndInPlotArea.x >= dragStartInPlotArea.x ? 0.0 : 1.0,
                                                        dragEndInPlotArea.y >= dragStartInPlotArea.y ? 0.0 : 1.0);
        zoomAnnotation.contentLayer.frame = borderRect;
    }
    
    return NO;
}*/


@end
