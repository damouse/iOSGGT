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
}

@end

@implementation LandscapeMainGraphViewController
@synthesize grants;

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
    
    minimumValueForXAxis = 0;
    maximumValueForXAxis = 40;
    minimumValueForYAxis = -10000;
    maximumValueForYAxis = 100000;
    
    majorIntervalLengthForX = 1;
    majorIntervalLengthForY = 10000;
    
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated
{
    [self initPlot];
}

#pragma mark - Chart behavior
-(void)initPlot {
    [self configureHost];
    [self configureGraph];
    [self configureXYChart];
    [self configureLegend];
}

-(void)configureHost {
	// 1 - Set up view frame
	CGRect parentRect = self.view.bounds;
	parentRect = CGRectMake(parentRect.origin.x,
							parentRect.origin.y,
							parentRect.size.width,
							parentRect.size.height);
    
	// 2 - Create host view
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
	textStyle.color = [CPTColor blackColor];
	textStyle.fontName = @"Helvetica-Bold";
	textStyle.fontSize = 20.0f;
    
	// 3 - Configure title
	NSString *title = @"TEST";
	graph.title = title;
	graph.titleTextStyle = textStyle;
	graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
	graph.titleDisplacement = CGPointMake(0.0f, -12.0f);
    
    //graph padding
    graph.paddingLeft   = 0.0;
    graph.paddingTop    = 0.0;
    graph.paddingRight  = 0.0;
    graph.paddingBottom = 0.0;
    
    graph.plotAreaFrame.paddingLeft   = 70.0;
    graph.plotAreaFrame.paddingTop    = 20.0;
    graph.plotAreaFrame.paddingRight  = 20.0;
    graph.plotAreaFrame.paddingBottom = 35.0;
    
    //remove that weird line area
    graph.plotAreaFrame.borderLineStyle = nil;
    graph.plotAreaFrame.cornerRadius    = 0.0;
    
	// 4 - Set theme
	self.selectedTheme = [CPTTheme themeNamed:kCPTSlateTheme];
	[graph applyTheme:self.selectedTheme];
}


-(void) configureXYChart
{
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(minimumValueForXAxis) length:CPTDecimalFromDouble(ceil( (maximumValueForXAxis - minimumValueForXAxis) / majorIntervalLengthForX ) * majorIntervalLengthForX)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(minimumValueForYAxis) length:CPTDecimalFromDouble(ceil( (maximumValueForYAxis - minimumValueForYAxis) / majorIntervalLengthForY ) * majorIntervalLengthForY)];
    
    test = plotSpace.yRange;
    
    // this allows the plot to respond to mouse events
    [plotSpace setDelegate:self]; //set delegate form other file
    [plotSpace setAllowsUserInteraction:YES];
    
    //set up x axis
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    
    CPTXYAxis *x = axisSet.xAxis;
    x.minorTicksPerInterval = 1;
    x.majorIntervalLength   = CPTDecimalFromDouble(majorIntervalLengthForX);
    x.labelOffset           = 5.0;
    x.axisConstraints       = [CPTConstraints constraintWithLowerOffset:0.0];
    x.orthogonalCoordinateDecimal = [[NSNumber numberWithInt:20] decimalValue];
    x.labelOffset = 10.0f;
    x.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    
    
    // Date Formatting!
    NSDate *refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:31556926 * 10];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = refDate;
    axisSet.xAxis.labelFormatter = timeFormatter;
    x.labelFormatter = timeFormatter;
    
    //set up y axis
    CPTXYAxis *y = axisSet.yAxis;
    y.minorTicksPerInterval = 1;
    y.majorIntervalLength   = CPTDecimalFromDouble(majorIntervalLengthForY);
    y.labelOffset           = 5.0;
    y.axisConstraints       = [CPTConstraints constraintWithLowerOffset:0.0];
    
    // Create the main plot for the delimited data
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] initWithFrame:graph.bounds];
    dataSourceLinePlot.identifier = @"Grant 1";
    
    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 1.0;
    lineStyle.lineColor              = [CPTColor whiteColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
}

-(void)configureLegend
{
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
	CGFloat legendPadding = -(self.view.bounds.size.width / 8);
	graph.legendDisplacement = CGPointMake(legendPadding, 0.0);
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    GrantObject *grant = [grants objectAtIndex:0];
    NSLog(@"Number of records: %i", [grant accountEntries].count);
    return  [grant accountEntries].count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    GrantObject *grant = [grants objectAtIndex:0];
    AccountEntryObject *entry = [[grant accountEntries] objectAtIndex:index];
    
    if(fieldEnum == CPTScatterPlotFieldY) {
        NSLog(@"amount: %i", [entry amount]);
        return [NSNumber numberWithInt:[entry amount]];
    }
    else
        return [entry dateAsTimeInterval];
}

#pragma mark Plot Customization Methods
-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
    //CPTPlotRange *new = [CPTPlotRange plotRangeWithLocation:[[[NSDecimalNumber alloc] initWithInt:10] decimalValue] length:[[[NSDecimalNumber alloc] initWithInt:1] decimalValue]];
    
    if(coordinate == 0)
        return newRange;
    else
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

-(IBAction)zoomIn
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    CPTPlotArea *plotArea     = graph.plotAreaFrame.plotArea;
    
    // convert the dragStart and dragEnd values to plot coordinates
    //CGPoint dragStartInPlotArea = [graph convertPoint:dragStart toLayer:plotArea];
    //CGPoint dragEndInPlotArea   = [graph convertPoint:dragEnd toLayer:plotArea];
    
    double start[2], end[2];
    
    // obtain the datapoints for the drag start and end
    //[plotSpace doublePrecisionPlotPoint:start forPlotAreaViewPoint:dragStartInPlotArea];
    //[plotSpace doublePrecisionPlotPoint:end forPlotAreaViewPoint:dragEndInPlotArea];
    
    // recalculate the min and max values
    minimumValueForXAxis = MIN(start[CPTCoordinateX], end[CPTCoordinateX]);
    maximumValueForXAxis = MAX(start[CPTCoordinateX], end[CPTCoordinateX]);
    minimumValueForYAxis = MIN(start[CPTCoordinateY], end[CPTCoordinateY]);
    maximumValueForYAxis = MAX(start[CPTCoordinateY], end[CPTCoordinateY]);
    
    // now adjust the plot range and axes
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(minimumValueForXAxis)
                                                    length:CPTDecimalFromDouble(maximumValueForXAxis - minimumValueForXAxis)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(minimumValueForYAxis)
                                                    length:CPTDecimalFromDouble(maximumValueForYAxis - minimumValueForYAxis)];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
}

-(IBAction)zoomOut
{
    double xval, yval;
    
    minimumValueForXAxis = MAXFLOAT;
    maximumValueForXAxis = -MAXFLOAT;
    
    minimumValueForYAxis = MAXFLOAT;
    maximumValueForYAxis = -MAXFLOAT;
    
    // get the ful range min and max values
    for ( NSDictionary *xyValues in grants ) {
        xval = [[xyValues valueForKey:@"x"] doubleValue];
        
        minimumValueForXAxis = fmin(xval, minimumValueForXAxis);
        maximumValueForXAxis = fmax(xval, maximumValueForXAxis);
        
        yval = [[xyValues valueForKey:@"y"] doubleValue];
        
        minimumValueForYAxis = fmin(yval, minimumValueForYAxis);
        maximumValueForYAxis = fmax(yval, maximumValueForYAxis);
    }
    
    minimumValueForXAxis = floor(minimumValueForXAxis / majorIntervalLengthForX) * majorIntervalLengthForX;
    minimumValueForYAxis = floor(minimumValueForYAxis / majorIntervalLengthForY) * majorIntervalLengthForY;
    
    // now adjust the plot range and axes
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(minimumValueForXAxis)
                                                    length:CPTDecimalFromDouble(ceil( (maximumValueForXAxis - minimumValueForXAxis) / majorIntervalLengthForX ) * majorIntervalLengthForX)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(minimumValueForYAxis)
                                                    length:CPTDecimalFromDouble(ceil( (maximumValueForYAxis - minimumValueForYAxis) / majorIntervalLengthForY ) * majorIntervalLengthForY)];
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
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
