//
//  CSVTestingViewController.m
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/4/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import "CSVTestingViewController.h"
#import "CHCSVParser.h"

@interface CSVTestingViewController () {
    CHCSVParser *parser;
}

@end

@implementation CSVTestingViewController

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
    //create a new parser instance and load the file. Then play with it
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *myFile = [mainBundle pathForResource: @"sample" ofType: @"csv"];

    NSArray *parsed = [NSArray arrayWithContentsOfCSVFile:myFile];
    
    labelOne.text = @"loaded";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
