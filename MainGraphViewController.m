//
//  MainGraphViewController.m
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/1/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "MainGraphViewController.h"
#import "GrantTableViewCell.h"
#import "AccountViewController.h"
#import "CorePlot-CocoaTouch.h"
#import "GrantTableViewCell.h"

#import "CPDConstants.h"
#import "CPDStockPriceStore.h"
#import "CPTTheme.h"

@interface MainGraphViewController () {
    GrantTableViewCell *grant;
    NSArray *tempValues;
}

@end

@implementation MainGraphViewController 
@synthesize hostView = hostView_;
@synthesize selectedTheme = selectedTheme_;

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
	// Do any additional setup after loading the view.
}

-(void) viewDidAppear:(BOOL)animated
{
    self.navigationItem.title = [grant setName:nil];
}

-(void)setGrantObject:(GrantTableViewCell *)grantObject
{
    grant = grantObject;
    tempValues = [NSArray arrayWithObjects:[grant getBalance], [grant getBudget], nil];
    [self initPlot];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToAccountPage:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    AccountViewController *accountGraph = [mainStoryboard instantiateViewControllerWithIdentifier: @"AccountGraphic"];
    
    [accountGraph setGrantObject:grant withAccount:@"Service Account"];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton; //need this, else name too long for nav bar
    
    [self.navigationController pushViewController:accountGraph animated:YES];
}


#pragma mark NEW CODE
#pragma mark - Rotation
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}


#pragma mark - Chart behavior
-(void)initPlot {
    [self configureHost];
    [self configureGraph];
    [self configureChart];
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
	self.hostView.allowPinchScaling = NO;
	[self.view addSubview:self.hostView];
}

-(void)configureGraph {
	// 1 - Create and initialise graph
	CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
	self.hostView.hostedGraph = graph;
	graph.paddingLeft = 0.0f;
	graph.paddingTop = 0.0f;
	graph.paddingRight = 0.0f;
	graph.paddingBottom = 0.0f;
	graph.axisSet = nil;
    
	// 2 - Set up text style
	CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
	textStyle.color = [CPTColor grayColor];
	textStyle.fontName = @"Helvetica-Bold";
	textStyle.fontSize = 16.0f;
    
	// 3 - Configure title
	NSString *title = @"Portfolio Prices: May 1, 2012";
	graph.title = title;
	graph.titleTextStyle = textStyle;
	graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
	graph.titleDisplacement = CGPointMake(0.0f, -12.0f);
    
	// 4 - Set theme
	self.selectedTheme = [CPTTheme themeNamed:kCPTPlainBlackTheme];
	[graph applyTheme:self.selectedTheme];
}

-(void)configureChart {
	// 1 - Get reference to graph
	CPTGraph *graph = self.hostView.hostedGraph;
    
	// 2 - Create chart
	CPTPieChart *pieChart = [[CPTPieChart alloc] init];
	pieChart.dataSource = self;
	pieChart.delegate = self;
	pieChart.pieRadius = (self.hostView.bounds.size.width * 0.7) / 3;
	pieChart.identifier = graph.title;
	pieChart.startAngle = M_PI_4;
	pieChart.sliceDirection = CPTPieDirectionClockwise;
    
	// 3 - Create gradient
	CPTGradient *overlayGradient = [[CPTGradient alloc] init];
	overlayGradient.gradientType = CPTGradientTypeRadial;
	overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.0] atPosition:0.9];
	overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.4] atPosition:1.0];
	pieChart.overlayFill = [CPTFill fillWithGradient:overlayGradient];
    
	// 4 - Add chart to graph
	[graph addPlot:pieChart];
}

-(void)configureLegend {
	// 1 - Get graph instance
	CPTGraph *graph = self.hostView.hostedGraph;
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
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
	return 2; //FOR TESTING PURPOSES
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	if (CPTPieChartFieldSliceWidth == fieldEnum) {
		return [tempValues objectAtIndex:index];
	}
	return [NSDecimalNumber zero];
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index {
	// 1 - Define label text style
	static CPTMutableTextStyle *labelText = nil;
	if (!labelText) {
		labelText= [[CPTMutableTextStyle alloc] init];
		labelText.color = [CPTColor grayColor];
	}
	// 2 - Calculate portfolio total value
	NSDecimalNumber *portfolioSum = [NSDecimalNumber zero];
	for (NSDecimalNumber *price in tempValues) {
		portfolioSum = [portfolioSum decimalNumberByAdding:price];
	}
    
	// 3 - Calculate percentage value
	NSDecimalNumber *price = [tempValues objectAtIndex:index];
	NSDecimalNumber *percent = [price decimalNumberByDividingBy:portfolioSum];
	// 4 - Set up display label
	NSString *labelValue = [NSString stringWithFormat:@"$%0.2f USD (%0.1f %%)", [price floatValue], ([percent floatValue] * 100.0f)];
	// 5 - Create and return layer with label text
	return [[CPTTextLayer alloc] initWithText:labelValue style:labelText]; //not this
}

-(NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index {
	if (index < [tempValues count]) {
		if(index == 1)
            return @"Budget"; //HACKED FIX HERE
        if(index == 0)
            return @"Remaining"; //HACKED FIX HERE
	}
	return @"N/A";
}

/*
#pragma mark - UIActionSheetDelegate methods
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// 1 - Get title of tapped button
	NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
	// 2 - Get theme identifier based on user tap
	NSString *themeName = kCPTPlainWhiteTheme;
	if ([title isEqualToString:CPDThemeNameDarkGradient] == YES) {
		themeName = kCPTDarkGradientTheme;
	} else if ([title isEqualToString:CPDThemeNamePlainBlack] == YES) {
		themeName = kCPTPlainBlackTheme;
	} else if ([title isEqualToString:CPDThemeNamePlainWhite] == YES) {
		themeName = kCPTPlainWhiteTheme;
	} else if ([title isEqualToString:CPDThemeNameSlate] == YES) {
		themeName = kCPTSlateTheme;
	} else if ([title isEqualToString:CPDThemeNameStocks] == YES) {
		themeName = kCPTStocksTheme;
	}
	// 3 - Apply new theme
	[self.hostView.hostedGraph applyTheme:[CPTTheme themeNamed:themeName]];
}*/


@end
