//
//  MenuViewController.h
//  iOSGGT
//
//  Created by Mihnea Barboi on 4/1/13.
//  Copyright (c) 2013 Mihnea Barboi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController {
    //references to buttons so they can be propery redrawn
    IBOutletCollection(UIButton) NSArray *buttons;

}
- (IBAction)buttonBack:(id)sender;

@end
