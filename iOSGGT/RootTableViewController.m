//
//  RootTableViewController.m
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/1/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import "RootTableViewController.h"
#import "MainGraphViewController.h"
#import "CHCSVParser.h"
#import "GrantObject.h"

#import "LandscapeMainGraphViewController.h"
#import "AccountEntryObject.h"
#import "GrantTableCell.h"

@interface RootTableViewController () {
    NSMutableArray *grants; //holds all grants
    NSArray *parsed;
    
    int numberOfGrants; //the number f grants expected
    BOOL isShowingLandscapeView;
    
    LandscapeMainGraphViewController *landscape;
    
    CPTGraph *graph;
    NSMutableArray *newData;
}

@end

@implementation RootTableViewController

#pragma mark Standard Methods
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

- (void)awakeFromNib
{
    isShowingLandscapeView = NO;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}


- (void)orientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    if (UIDeviceOrientationIsLandscape(deviceOrientation) && !isShowingLandscapeView) {
        [self presentViewController:landscape animated:NO completion:nil];
        isShowingLandscapeView = YES;
    }
    
    else if (UIDeviceOrientationIsPortrait(deviceOrientation) && isShowingLandscapeView) {
        [self dismissViewControllerAnimated:NO completion:nil];
        isShowingLandscapeView = NO;
    }
}

#pragma mark View Did Load
- (void)viewDidLoad
{
    [super viewDidLoad];

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    landscape = [mainStoryboard instantiateViewControllerWithIdentifier: @"rootLandscape"];
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *myFile = [mainBundle pathForResource: @"sample" ofType: @"csv"];
    
    //make API calls here
    
    
    //init array of grants
    grants = [NSMutableArray array];
    
    //parse documents
    parsed = [NSArray arrayWithContentsOfCSVFile:myFile];
    GrantObject *tempGrant = [[GrantObject alloc] initWithCSVArray:parsed];
    numberOfGrants = 1;
    
    [grants addObject:tempGrant];
    [landscape setGrants:grants];
    
    [tableMain reloadData];
    grants = [NSMutableArray array];
}

/*- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // If you make sure your dates are calculated at noon, you shouldn't have to
    // worry about daylight savings. If you use midnight, you will have to adjust
    // for daylight savings time.
    NSDate *refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:31556926 * 10];
    NSTimeInterval oneDay = 24 * 60 * 60;
    
    // Invert graph view to compensate for iOS coordinates
    //CGAffineTransform verticalFlip = CGAffineTransformMakeScale(1,-1);
    //self.view.transform = verticalFlip;
    
    // allocate the graph within the current view bounds
    graph = [[CPTXYGraph alloc] initWithFrame: self.view.bounds];
    
    // assign theme to graph
    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [graph applyTheme:theme];
    
    // Setting the graph as our hosting layer
    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:hostingView];
    
    hostingView.hostedGraph = graph;
    
    graph.paddingLeft = 20.0;
    graph.paddingTop = 20.0;
    graph.paddingRight = 20.0;
    graph.paddingBottom = 150.0;
    
    // setup a plot space for the plot to live in
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    NSTimeInterval xLow = 0.0f;
    // sets the range of x values
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xLow)
                                                    length:CPTDecimalFromFloat(oneDay*5.0f)];
    // sets the range of y values
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0)
                                                    length:CPTDecimalFromFloat(5)];
    
    // plotting style is set to line plots
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor blackColor];
    lineStyle.lineWidth = 2.0f;
    
    // X-axis parameters setting
    CPTXYAxisSet *axisSet = (id)graph.axisSet;
    axisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneDay);
    axisSet.xAxis.minorTicksPerInterval = 0;
    axisSet.xAxis.orthogonalCoordinateDecimal = CPTDecimalFromString(@"1"); //added for date, adjust x line
    axisSet.xAxis.majorTickLineStyle = lineStyle;
    axisSet.xAxis.minorTickLineStyle = lineStyle;
    axisSet.xAxis.axisLineStyle = lineStyle;
    axisSet.xAxis.minorTickLength = 5.0f;
    axisSet.xAxis.majorTickLength = 7.0f;
    axisSet.xAxis.labelOffset = 3.0f;
    
    // added for date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = refDate;
    axisSet.xAxis.labelFormatter = timeFormatter;
    
    // Y-axis parameters setting
    axisSet.yAxis.majorIntervalLength = CPTDecimalFromString(@"0.5");
    axisSet.yAxis.minorTicksPerInterval = 2;
    axisSet.yAxis.orthogonalCoordinateDecimal = CPTDecimalFromFloat(oneDay); // added for date, adjusts y line
    axisSet.yAxis.majorTickLineStyle = lineStyle;
    axisSet.yAxis.minorTickLineStyle = lineStyle;
    axisSet.yAxis.axisLineStyle = lineStyle;
    axisSet.yAxis.minorTickLength = 5.0f;
    axisSet.yAxis.majorTickLength = 7.0f;
    axisSet.yAxis.labelOffset = 3.0f;
    
    
    // This actually performs the plotting
    CPTScatterPlot *xSquaredPlot = [[CPTScatterPlot alloc] init];
    
    CPTMutableLineStyle *dataLineStyle = [CPTMutableLineStyle lineStyle];
    //xSquaredPlot.identifier = @"X Squared Plot";
    xSquaredPlot.identifier = @"Date Plot";
    
    dataLineStyle.lineWidth = 1.0f;
    dataLineStyle.lineColor = [CPTColor redColor];
    xSquaredPlot.dataLineStyle = dataLineStyle;
    xSquaredPlot.dataSource = self;
    
    CPTPlotSymbol *greenCirclePlotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    greenCirclePlotSymbol.fill = [CPTFill fillWithColor:[CPTColor greenColor]];
    greenCirclePlotSymbol.size = CGSizeMake(2.0, 2.0);
    xSquaredPlot.plotSymbol = greenCirclePlotSymbol;
    
    // add plot to graph
    [graph addPlot:xSquaredPlot];
    
    // Add some data
    newData = [NSMutableArray array];
    NSUInteger i;
    for ( i = 0; i < 5; i++ ) {
        NSTimeInterval x = oneDay*i;
        id y = [NSDecimalNumber numberWithFloat:1.2*rand()/(float)RAND_MAX + 1.2];
        [newData addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSDecimalNumber numberWithFloat:x], [NSNumber numberWithInt:CPTScatterPlotFieldX], y, [NSNumber numberWithInt:CPTScatterPlotFieldY],
          nil]];
        NSLog(@"%@",newData);
    }
    
}

#pragma mark - Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return newData.count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSDecimalNumber *num = [[newData objectAtIndex:index] objectForKey:[NSNumber numberWithInt:fieldEnum]];
    return num;
}*/

#pragma mark Parsing Methods
//Given an array of the csv files from the API call, create grant objects for them and return the array of objects
- (NSMutableArray *) parseCSVFiles:(NSMutableArray *)documents {
 
}


#pragma mark Table Style
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return numberOfGrants; //hardcoded for testing
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GrantTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AccountCell" forIndexPath:indexPath];

    if (cell == nil) {
        cell = [[GrantTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AccountCell"];
    }

    
    cell.name.text = [NSString stringWithFormat:@"Grant #%i", indexPath.row];
    cell.date.text = @"2/16/24";
    cell.remaining.text = @"23,000";
    cell.total.text = @"234,134";
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];    
    MainGraphViewController *mainGraph = [mainStoryboard instantiateViewControllerWithIdentifier: @"MainGraphic"];
    GrantObject *cell = [tableView dequeueReusableCellWithIdentifier:@"AccountCell" forIndexPath:indexPath];
    
    [grants addObject:cell];
    
    [mainGraph setGrantObject:cell];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton; //need this, else name too long for nav bar
    
    [self.navigationController pushViewController:mainGraph animated:YES];
}

@end
