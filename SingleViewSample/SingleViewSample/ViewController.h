//
//  ViewController.h
//  SingleViewSample
//
//  Created by hudapeng on 11/30/15.
//  Copyright © 2015 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DZVideoPlayerViewController.h"

@interface ViewController : UIViewController {
}
- (IBAction)click:(id)sender;


@end


@interface ViewController (ControllerDelegate) <DZVideoPlayerViewControllerDelegate>
@end

