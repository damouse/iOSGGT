//
//  RootViewController.m
//  iOSGGT
//
//  Created by Mihnea Barboi on 5/3/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import "RootViewController.h"
#import "MainGraphViewController.h"
#import "GrantObject.h"

#import "LandscapeMainGraphViewController.h"
#import "AccountEntryObject.h"
#import "GrantTableCell.h"
#import "MBProgressHUD.h"
#import "TutorialViewController.h"
#import "LandscapeTransferViewController.h"

#import <CommonCrypto/CommonDigest.h>

@interface RootViewController () {
    NSMutableArray *grants; //holds all grants
    NSArray *parsed;
    
    int numberOfGrants; //the number f grants expected
    BOOL isShowingLandscapeView;
    
    //LandscapeMainGraphViewController *landscape;
    
    CPTGraph *graph;
    NSMutableArray *newData;
    
    NSMutableData *jsonResponse;
    NSMutableDictionary *directory; //an array of all the directory objects, each containing grants
    
    NSString *currentlyActiveURL; //the URL currently being API called.
    NSMutableArray *grantsThatNeedRefreshing;
    NSMutableArray *directoriesThatNeedRefreshing;
    
    MBProgressHUD *hud;
    BOOL needsRefresh;
    BOOL hubRunning;
}

@end

@implementation RootViewController 

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

#pragma mark View Did Load
- (void)viewDidLoad
{
    [super viewDidLoad];

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    //landscape = [mainStoryboard instantiateViewControllerWithIdentifier: @"rootLandscape"];
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"firstlogin"] isEqualToString:@"true"]){
        TutorialViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"tutorial"];
        
        [self presentViewController:vc animated:YES completion:nil];
        [[NSUserDefaults standardUserDefaults] setObject:@"true" forKey:@"firstlogin"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buttonRefresh:) name:@"refresh" object:nil];
    
    //ui customization
    [self.navigationController setNavigationBarHidden:YES];
    tableMain.backgroundColor = [UIColor clearColor];
    
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.view addSubview:hud];
	hud.dimBackground = YES;
    hud.labelText = @"Loading";
	hud.detailsLabelText = @"Querying API...";
	hud.square = YES;
    
    [hud show:YES];
    [self loadCachedGrants];
}

//check to make sure no new directories were added since last time we were here
-(void)viewWillAppear:(BOOL)animated
{
    NSData *save = [[NSUserDefaults standardUserDefaults] objectForKey:@"directories"]; //note: init this in rootviewcontroller
    
    [hud show:YES];
    currentlyActiveURL = [NSString stringWithFormat:@"http://pages.cs.wisc.edu/~%@/ggt/sheets/ggt_handler.php", [directory objectForKey:@"url"]];
    [self queryAPI:@"mod" url:currentlyActiveURL file:nil]; // this triggers a API_mod callback, which populates the grantsthatneedref list
    
    if(save != nil) {
        NSArray *grantArray = [directory objectForKey:@"grants"];
        if([grantArray count] == 0) {
            hud.detailsLabelText = @"Querying API...";
            [hud show:YES];
            
            if(!hubRunning)
                [self loadCachedGrants];
        }
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark Saved Directory
//load and unarchive the cached grants. If this is the first time the app launched, include a temporary directory
-(void) loadCachedGrants
{
    hubRunning = YES;
    //remember to remove grants that are no longer present!
    
    NSData *save = [[NSUserDefaults standardUserDefaults] objectForKey:@"directories"]; //note: init this in rootviewcontroller
    
    //if nothing exists, then this is the first time this has launched; add in my url for testing
    if(save == nil) {        
        directory = [self createNewTutorialDirectory];
    }
    else
        directory = [NSKeyedUnarchiver unarchiveObjectWithData:save];
    
    [self grantRefreshHub];
}

//this is the stateless, hub method for all the action that happens upon refresh or download. This method is called at the end of every
//download call, mod call, and login; it establishes what happens next.
-(void)grantRefreshHub
{
    //If the directoriesthatneedrefreshing and grantsthatneedrefreshing are empty, we are done
    NSLog(@"Hub: grantsRereshing: %i directoriesRefreshing: %i", [grantsThatNeedRefreshing count], [directoriesThatNeedRefreshing count]);
    
    if([grantsThatNeedRefreshing count] == 0){            
        //we are done refreshing, load the table and landscape and resume normal operation
        grants = [directory objectForKey:@"grants"];
        
        NSData* save = [NSKeyedArchiver archivedDataWithRootObject:directory];
        [[NSUserDefaults standardUserDefaults] setObject:save forKey:@"directories"];
        [[NSUserDefaults standardUserDefaults] synchronize];
                    
        [hud hide:YES];
        NSLog(@"Hub Finished. Grants: %i", [grants count]);
        
        //[landscape initWithGrantArray:grants];
        
        hubRunning = NO;
        [tableMain reloadData];
    }
    else { //if here, then there are still items in grantsthatneedrefreshing. Make an download call for each

        NSString *grantFileName = [grantsThatNeedRefreshing objectAtIndex:0];
        [grantsThatNeedRefreshing removeObjectAtIndex:0];
        
        [self queryAPI:@"download" url:currentlyActiveURL file:grantFileName];
    }
}

//this method is a modified copy from the directoryeditor class; make a new dir
//directories have the following items: {nickname, dateAdded, url, NSArray grants}
-(NSMutableDictionary *) createNewTutorialDirectory
{
    NSMutableDictionary *dir = [NSMutableDictionary dictionary];
    
    //[dir setObject:@"Temporary Tutorial Directory" forKey:@"nickname"];
    //[dir setObject:date forKey:@"dateAdded"];
    [dir setObject:@"mihnea" forKey:@"url"];
    [dir setObject:@"test" forKey:@"pass"];
    
    return dir;
}

#pragma mark Helper
//given a grant, return the end date properly formatted
- (NSString *) formatEndDate:(GrantObject *)grant
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"mm/dd/YYYY"];
    NSDate *endDate = [formatter dateFromString:[[grant getMetadata] objectForKey:@"endDate"]];
    [formatter setDateFormat:@"MMMM dd, yyyy"];
    
    return [formatter stringFromDate:endDate];
}

//given a string of currency, format it correctly and return it as an int
- (NSDecimalNumber *) formatCurrency:(NSString *)amount
{
    NSString *ret = [[amount stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingOccurrencesOfString:@"," withString:@""];
    ret = [[ret componentsSeparatedByString:@"."] objectAtIndex:0];
    
    return [NSDecimalNumber decimalNumberWithString:ret];
}

//given a grant, format balance and budget so it reads: "balance$ out of budget$ remaining"
- (NSString *) formatBalance:(GrantObject *)grant
{
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

#pragma mark IBAction
- (IBAction)buttonRefresh:(id)sender
{
    hud.detailsLabelText = @"Querying API...";
    [hud show:YES];
    [self loadCachedGrants];
}

- (IBAction)landscapePressed:(id)sender
{
    //try pushing on an intermediate view controller and seeing if it goes to landscape
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    LandscapeTransferViewController *transfer = [mainStoryboard instantiateViewControllerWithIdentifier: @"landTransfer"];
    
    [self.navigationController pushViewController:transfer animated:NO];
    [transfer initWithGrantArray:grants];
    //manually present the landscape controller
    //[self.navigationController pushViewController:landscape animated:YES];
}

#pragma mark Table Style
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [grants count]; //hardcoded for testing
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
    NSDecimalNumber *percent = /*[[NSDecimalNumber alloc] initWithFloat:0.4f];*/[balance decimalNumberByDividingBy:budget];
    [cell setCompletion:[percent floatValue]];
    
    //set up the progress bar note
    cell.labelRemaining.text = [self formatBalance:grant];
    cell.labelGrantFileName.text = [[[grant fileName] componentsSeparatedByString:@".xls"] objectAtIndex:0];
    
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
- (NSString *) hashKey:(NSString *)key {
    //has the string using sha2
    //CC_sh
}

- (NSString *) SHA2HashWithString:(NSString *)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    // This is an iOS5-specific method.
    // It takes in the data, how much data, and then output format, which in this case is an int array.
    CC_SHA256(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    // Parse through the CC_SHA256 results (stored inside of digest[]).
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

//callback methods from the API call. Recieves the files and times last accessed
-(void)API_mod:(NSDictionary *)data {
    NSLog(@"API_mod starting...");
    NSMutableArray *newGrantArray = [NSMutableArray array];
    
    data = [data objectForKey:@"data"];
    grantsThatNeedRefreshing = [NSMutableArray array];

    
    NSMutableArray *grantArray = [directory objectForKey:@"grants"];

    //if this is the first time this directory is being loaded, must create array of grants
    if(grantArray == nil ) {
        grantArray = [NSMutableArray array];
        [directory setObject:grantArray forKey:@"grants"];
    }
    
    for(NSString *filename in [data keyEnumerator]) {
        BOOL grantExists = NO;
        //check each grant's filename against the returned filenames/times, add to refresh list if needed
        for(GrantObject *grant in grantArray) {
            
            //check if this grant is the one referenced by the filename
            if([[grant fileName] isEqualToString:filename]) {
                
                //add the grants to a new array to get rid of grants that are no longer present in the directory
                [newGrantArray addObject:grant];
                grantExists = YES;
                
                NSString *modTime = [data objectForKey:grant.fileName];
                if(![grant.timeLastAccessed isEqualToString:modTime])
                    [grantsThatNeedRefreshing addObject:grant.fileName];
            }
        }
        
        //if this grant has never been loaded, must refresh it now
        #pragma mark DEBUG LINE HERE forces download of every grant
        if(grantExists == NO)
            [grantsThatNeedRefreshing addObject:filename];
    }
    [directory setObject:newGrantArray forKey:@"grants"];
    
    
    NSLog(@" finished");
    [self grantRefreshHub];
}

-(void)API_login:(NSDictionary *)data {
    NSLog(@"API_login starting...");
    if([[data objectForKey:@"status"] isEqualToString:@"success"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"loggedIn"];
        
        NSLog(@"API_login success");
        [self grantRefreshHub];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:@"no" forKey:@"loggedIn"];
        
        //popup here to show that the login failed. What about logging in to multiple servers?
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error" message: @"Login incorrect." delegate:self
                              cancelButtonTitle:@"OK" otherButtonTitles:nil]; //@"Connection error! Are you connected to the internet?"
        [alert show];
    }
}

//this method is called when a grant is downloaded. Save the grant's information, update the time last accessed, etc,
//and then callback to the hub to figure out what to do next
-(void)API_download:(NSDictionary *)data {
    NSLog(@"API_Download starting...");
    BOOL makeNewGrant = YES;
    
    NSMutableArray *grantArray = [directory objectForKey:@"grants"];
        
    //find the appropriate grant
    for(int i = 0; i < [grantArray count]; i++) {
        GrantObject *grant = [grantArray objectAtIndex:i];
        
        if([[grant fileName] isEqualToString:[data objectForKey:@"fileName"]]) { //found the grant; update not a make
            makeNewGrant = NO;
            
            if([[grant fileName] isEqualToString:@"QU85.xls"])
                NSLog(@"fuckme");
            
            //pass the json into the parse method with this grant as part of this directory
            GrantObject *tempGrant = [[GrantObject alloc] initWithCSVArray:[data objectForKey:@"data"]];
            grant = tempGrant;
            [grant setTimeLastAccessed:[data objectForKey:@"modTime"]];
        }
    }
    
    //the grant did not previously exist, create a new one and add it in
    if(makeNewGrant) {
        //pass the json into the parse method with this grant as part of this directory
        GrantObject *tempGrant = [[GrantObject alloc] initWithCSVArray:[data objectForKey:@"data"]];
        [tempGrant setTimeLastAccessed:[NSString stringWithFormat:@"%@", [data objectForKey:@"modTime"]]];
        [tempGrant setFileName:[data objectForKey:@"fileName"]];
        
        [grantArray addObject:tempGrant];
    }
    
    NSLog(@"API_Download finished");
    [self grantRefreshHub];
}

//this is the API out-going call, based on the callType passed in {mod, download, login}.
//takes in the url to the server-side script, the calltype, the file requested. 
-(void)queryAPI:(NSString *)callType url:(NSString *)path file:(NSString *)file {
    jsonResponse = [NSMutableData data];
    NSURL *url = nil;
    
    if([callType isEqualToString:@"download"]) {
        hud.detailsLabelText = [NSString stringWithFormat:@"Downloading %@", file];
        NSString *key = [self SHA2HashWithString:[directory objectForKey:@"pass"]];
        NSString *tmp = [NSString stringWithFormat:@"%@?type=%@&fname=%@&key=%@", path, callType, file, key];
        url = [NSURL URLWithString:[tmp stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    else {
        hud.detailsLabelText = @"Checking Files in Directory...";
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?type=%@", path, callType]];
    }
    
    NSLog(@"QueryAPI url: %@ ", url);
     NSURLRequest *req = [NSURLRequest requestWithURL:url];
     NSURLConnection *connection = [NSURLConnection connectionWithRequest:req delegate:self];
     
     [connection start];
    //spinner start
}

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
    NSError *error = nil;
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:jsonResponse options:nil error:&error];
    NSLog(@"Connection finished");
    
    //NSString *string = [[NSString alloc] initWithData:jsonResponse encoding:NSASCIIStringEncoding];
    
    if (error != nil)
    {
        NSLog(@"Deserializer Error: %@", [error description]);
        
        NSString *jsonDataString = [[NSString alloc] initWithData:jsonResponse encoding:NSUTF32BigEndianStringEncoding];
        
        NSString *fullError = [NSString stringWithFormat:@"%@",jsonDataString];
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error" message: fullError delegate:self
                              cancelButtonTitle:@"OK" otherButtonTitles:nil]; //@"Connection error! Are you connected to the internet?"
        [alert show];
    }
    else {
        if(![[data objectForKey:@"status"] isEqualToString:@"success"])
            NSLog(@"There was an API error");
        else {
            if([[data objectForKey:@"type"] isEqualToString:@"mod"])
                [self API_mod:data];
            else if([[data objectForKey:@"type"] isEqualToString:@"download"])
                [self API_download:data];
            else
                [self API_login:data];
        }
    }
    
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
    [hud hide:YES];
    [self grantRefreshHub];
}


@end
