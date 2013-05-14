//
//  TutorialViewController.h
//  iOSGGT
//
//  Created by Mihnea Barboi on 5/13/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialViewController : UIViewController <UIScrollViewDelegate>{
    
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UITextView *labelDetails;
    __weak IBOutlet UIPageControl *pageControl;
}
- (IBAction)buttonDone:(id)sender;

@end
