//
//  DirectoryViewController.m
//  iOSGGT
//
//  Created by Mickey Barboi on 9/6/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import "DirectoryViewController.h"
#import "MBProgressHUD.h"

@interface DirectoryViewController () {
    NSMutableDictionary *directory;
    NSMutableData *jsonResponse;
    
    MBProgressHUD *hud;
}

@end

@implementation DirectoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //load existing information from NSUserDefaults
    NSData *save = [[NSUserDefaults standardUserDefaults] objectForKey:@"directories"]; //note: init this in rootviewcontroller
    directory = [NSKeyedUnarchiver unarchiveObjectWithData:save];
    
    [textLogin setText:[directory objectForKey:@"url"]];
    [textPassword setText:[directory objectForKey:@"pass"]];
}


#pragma mark NSURL methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [jsonResponse setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [jsonResponse appendData:data];;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *error = nil;
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:jsonResponse options:nil error:&error];
    NSLog(@"Connection finished");
    
    if (error != nil)
    {
        NSLog(@"Deserializer Error: %@", [error description]);
        
        NSString *jsonDataString = [[NSString alloc] initWithData:jsonResponse encoding:NSUTF32BigEndianStringEncoding];
        
        NSString *fullError = @"URL is invalid. Please try again.";
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error" message: fullError delegate:self
                              cancelButtonTitle:@"OK" otherButtonTitles:nil]; //@"Connection error! Are you connected to the internet?"
        [alert show];
    }
    else {
        if(![[data objectForKey:@"status"] isEqualToString:@"success"])
            NSLog(@"There was an API error");
        else {
            //url is valid. If the given entry is an existing entry, delete its directory listings and reload them. Else, create a new one and archive it in.
            
            NSString *stringURL =[NSString stringWithFormat:@"http://pages.cs.wisc.edu/~%@/ggt/sheets/ggt_handler.php", textLogin.text];
            
            [directory setObject:stringURL forKey:@"url"];
            
            //clear out existing information
            [directory removeObjectForKey:@"grants"]; //MUST FORCE AN UPDATE

            NSData* save = [NSKeyedArchiver archivedDataWithRootObject:directory];
            [[NSUserDefaults standardUserDefaults] setObject:save forKey:@"directories"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Success" message: @"Directory successfully added. Please return to main table to refresh grants" delegate:self
                                  cancelButtonTitle:@"OK" otherButtonTitles:nil]; //@"Connection error! Are you connected to the internet?"
            [alert show];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh" object:self];
        }
    }
    
    [connection cancel];
    [hud hide:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error During Connection: %@", [error description]);
    
    NSString *responseString = [[NSString alloc] initWithData:jsonResponse encoding:NSUTF8StringEncoding];
    //   NSLog(@"Response: %@",responseString);
    
    NSData *jsonData = [responseString dataUsingEncoding:NSUTF32BigEndianStringEncoding];
    
    NSString *jsonDataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF32BigEndianStringEncoding];
    
    NSString *fullError = @"Url is invalid. Please try again.";
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Error" message: fullError delegate:self
                          cancelButtonTitle:@"OK" otherButtonTitles:nil]; //@"Connection error! Are you connected to the internet?"
    [alert show];
    
    [connection cancel];
    //connectionInProgress = NO;
    //[activityIndicator stopAnimating];
}


#pragma mark IBAction
- (IBAction)buttonCheckDirectory:(id)sender {
    NSString *stringURL =[NSString stringWithFormat:@"http://pages.cs.wisc.edu/~%@/ggt/sheets/ggt_handler.php", textLogin.text];
    
    jsonResponse = [NSMutableData data];
    hud.detailsLabelText = @"Checking URL";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?type=ping", stringURL]];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:req delegate:self];
    
    [connection start];

}

- (IBAction)buttonBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
