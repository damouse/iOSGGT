//
//  LandscapeTransferViewController.m
//  iOSGGT
//
//  Created by Mickey Barboi on 7/1/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

/**
    This view controller exists only to present a landscape environment for coreplot. The same fix
    that makes this vc present in landscape will not allow allow landscape to draw like it should. 
 
 */

#import "LandscapeTransferViewController.h"
#import "LandscapeMainGraphViewController.h"

@interface LandscapeTransferViewController () {
    LandscapeMainGraphViewController *landscape;
    NSMutableArray *grants; 
}

@end

@implementation LandscapeTransferViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) loadView {    
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void) forceOrientationEvaluation {
    //by presenting and removing modal quickly, we can force the window to check its supported orientations. Not pretty, but it works
    //hack to make the orientation force to landscape
    UIApplication* application = [UIApplication sharedApplication];
    if (application.statusBarOrientation != UIInterfaceOrientationLandscapeLeft)
    {
        UIViewController *c = [[UIViewController alloc]init];
        [self presentModalViewController:c animated:NO];
        [self dismissModalViewControllerAnimated:NO];
    }
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void) initWithGrantArray:(NSMutableArray *)grantsN {
    grants = grantsN;
    [self forceOrientationEvaluation];
    [self pushGraph:nil];
}

- (IBAction)pushGraph:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    landscape = [mainStoryboard instantiateViewControllerWithIdentifier: @"rootLandscape"];
    
    [landscape initWithGrantArray:grants];
    [self.navigationController pushViewController:landscape animated:NO];
}

@end
