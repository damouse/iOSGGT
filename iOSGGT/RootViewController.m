//
//  RootViewController.m
//  iOSGGT
//
//  Created by Mihnea Barboi on 5/3/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import "RootViewController.h"
#import "MainGraphViewController.h"
#import "CHCSVParser.h"
#import "GrantObject.h"

#import "LandscapeMainGraphViewController.h"
#import "AccountEntryObject.h"
#import "GrantTableCell.h"


@interface RootViewController () {
    NSMutableData *jsonResponse;
}

@end

@implementation RootViewController {
    NSMutableArray *grants; //holds all grants
    NSArray *parsed;
    
    int numberOfGrants; //the number f grants expected
    BOOL isShowingLandscapeView;
    
    LandscapeMainGraphViewController *landscape;
    
    CPTGraph *graph;
    NSMutableArray *newData;
}

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
    
    //ui customization
    [self.navigationController setNavigationBarHidden:YES];
    tableMain.backgroundColor = [UIColor clearColor];

    //make API calls here
    /*jsonResponse = [NSMutableData data];
    
    NSURL *url = [NSURL URLWithString:@"http://pages.cs.wisc.edu/~mihnea/login.php?user=mickey&pass=mickeypass"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:req delegate:self];
    
    [connection start];*/
    
    grants = [self parseCSVFiles:nil];

    [landscape initWithGrantArray:grants];
    [tableMain reloadData];
}

#pragma mark Parsing Methods
//Given an array of the csv files from the API call, create grant objects for them and return the array of objects
//when each grant is made, cache it in NSUserDefaults
//NOTE: This code is just a jumble of stuff, it should not all be in this method. Its here just so i have somewhere to write it down for now
- (NSMutableArray *) parseCSVFiles:(NSMutableArray *)documents {
    NSMutableArray *temp = [NSMutableArray array];
    
    //parse documents  THIS IS HERE FOR DEBUGGING PURPOSES ONLY
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *myFile = [mainBundle pathForResource: @"sample" ofType: @"csv"];
    
    parsed = [NSArray arrayWithContentsOfCSVFile:myFile];
    GrantObject *tempGrant = [[GrantObject alloc] initWithCSVArray:parsed];
    

    //this is real code
    [temp addObject:tempGrant];
    numberOfGrants = temp.count;
    
    //cache the grants
    NSArray *savedGrants;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *save = [[NSUserDefaults standardUserDefaults] objectForKey:@"cache"];
    
    if(save == nil) { //nothing was saved, no cache
        
    }
    else { //if there was a cache, unindex the save and check the dates. The save is a dictionary of update dates keyed by their grants
        [NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:save]];
        
        //make the updateCheck API call, compare the recieved dates with the cached dates. Update grants as necesary if a spreadsheet was changed since last launch
        
    }
    
    
    return temp;
}

#pragma mark Helper
//given a grant, return the end date properly formatted
- (NSString *) formatEndDate:(GrantObject *)grant {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"mm/dd/YYYY"];
    NSDate *endDate = [formatter dateFromString:[[grant getMetadata] objectForKey:@"endDate"]];
    [formatter setDateFormat:@"MMMM dd, yyyy"];
    
    return [formatter stringFromDate:endDate];
}

//given a string of currency, format it correctly and return it as an int
- (NSDecimalNumber *) formatCurrency:(NSString *)amount {
    NSString *ret = [[amount stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingOccurrencesOfString:@"," withString:@""];
    ret = [[ret componentsSeparatedByString:@"."] objectAtIndex:0];
    
    return [NSDecimalNumber decimalNumberWithString:ret];
}

//given a grant, format balance and budget so it reads: "balance$ out of budget$ remaining"
- (NSString *) formatBalance:(GrantObject *)grant {
    NSDecimalNumber *budget = [self formatCurrency:[[grant getBudgetRow] objectForKey:@"Amount"]];
    NSDecimalNumber *balance = [self formatCurrency:[[grant getBalanceRow] objectForKey:@"Amount"]];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    NSString *balanceString = [numberFormatter stringFromNumber:balance];
    NSString *budgetString = [numberFormatter stringFromNumber:budget];
    
    balanceString = [balanceString stringByReplacingOccurrencesOfString:@".00" withString:@""];
    budgetString = [budgetString stringByReplacingOccurrencesOfString:@".00" withString:@""];
    
    return [NSString stringWithFormat:@"%@ of %@ remainng", balanceString, budgetString];
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
    
    GrantObject *grant = [grants objectAtIndex:indexPath.row];
    
    cell.name.text = [[grant getMetadata] objectForKey:@"title"];
    cell.date.text = [self formatEndDate:grant];

    //set up and run the progress bar
    NSDecimalNumber *budget = [self formatCurrency:[[grant getBudgetRow] objectForKey:@"Amount"]];
    NSDecimalNumber *balance = [self formatCurrency:[[grant getBalanceRow] objectForKey:@"Amount"]];
    NSDecimalNumber *percent = [balance decimalNumberByDividingBy:budget];
    [cell setCompletion:[percent floatValue]];
    
    //set up the progress bar note
    cell.labelRemaining.text = [self formatBalance:grant];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    MainGraphViewController *mainGraph = [mainStoryboard instantiateViewControllerWithIdentifier: @"MainGraphic"];
    GrantObject *grant = [grants objectAtIndex:indexPath.row];
    
    [mainGraph setGrantObject:grant];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton; //need this, else name too long for nav bar
    
    [self.navigationController pushViewController:mainGraph animated:YES];
}


#pragma mark NSURLConnection Methods

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
    NSString *responseString = [[NSString alloc] initWithData:jsonResponse encoding:NSUTF8StringEncoding];
    NSLog(@"Response: %@",responseString);
    
    NSData *jsonData = [responseString dataUsingEncoding:NSUTF32BigEndianStringEncoding];
	NSError *error = nil;
    
    //NSDictionary *parsedData = [[CJSONDeserializer deserializer] deserialize:jsonData error:&error];
    
    if (error != nil)
    {
        NSLog(@"CJSONDeserializer Error: %@", [error description]);
        
        NSString *jsonDataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF32BigEndianStringEncoding];
        
        NSString *fullError = [NSString stringWithFormat:@"%@",jsonDataString];
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error" message: fullError delegate:self
                              cancelButtonTitle:@"OK" otherButtonTitles:nil]; //@"Connection error! Are you connected to the internet?"
        [alert show];
    }
    /*else if([parsedData objectForKey:@"status"] && [[parsedData objectForKey:@"status"] isEqualToString:@"success"] && [[parsedData objectForKey:@"data"] objectForKey:@"token"]){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"loggedIn"];
        [defaults setObject:[[parsedData objectForKey:@"data"] objectForKey:@"token"] forKey:@"token"];
        [defaults setObject:[[parsedData objectForKey:@"data"] objectForKey:@"email"] forKey:@"email"];
        [defaults setObject:[[parsedData objectForKey:@"data"] objectForKey:@"city" ] forKey:@"city" ];
        [defaults setObject:[[parsedData objectForKey:@"data"] objectForKey:@"state"] forKey:@"state"];
        [defaults synchronize];
        
        NSLog(@"Token: %@", [[parsedData objectForKey:@"data"] objectForKey:@"token"]);
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if([parsedData objectForKey:@"status"] && [[parsedData objectForKey:@"status"] isEqualToString:@"fail"] && [parsedData objectForKey:@"message"]){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error" message: [parsedData objectForKey:@"message"] delegate:self
                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error" message:@"Log in failed." delegate:self
                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    */
    [connection cancel];
    //connectionInProgress = NO;
    //[activityIndicator stopAnimating];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Error During Connection: %@", [error description]);
    
    NSString *responseString = [[NSString alloc] initWithData:jsonResponse encoding:NSUTF8StringEncoding];
    //   NSLog(@"Response: %@",responseString);
    
    NSData *jsonData = [responseString dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    
    NSString *jsonDataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF32BigEndianStringEncoding];
    
    NSString *fullError = [NSString stringWithFormat:@"%@\n\n%@", [error description], jsonDataString];
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Error" message: fullError delegate:self
                          cancelButtonTitle:@"OK" otherButtonTitles:nil]; //@"Connection error! Are you connected to the internet?"
    [alert show];
    
    [connection cancel];
    //connectionInProgress = NO;
    //[activityIndicator stopAnimating];
}

@end
