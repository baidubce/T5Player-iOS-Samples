//
//  ViewController.h
//  SingleViewSample
//
//  Created by hudapeng on 11/30/15.
//  Copyright © 2015 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CyberPlayerViewController.h"

@interface ViewController : UIViewController {
}

@end


@interface ViewController (PlaybackDelegate) <CyberPlayerViewControllerDelegate>
@end

