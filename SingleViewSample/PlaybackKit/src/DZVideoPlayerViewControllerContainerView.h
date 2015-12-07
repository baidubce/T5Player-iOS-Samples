//
//  DZVideoPlayerViewControllerContainerView.h
//  Pods
//
//  Created by Denis Zamataev on 01/06/15.
//
//

#import <UIKit/UIKit.h>
#import "DZVideoPlayerViewController.h"

typedef NS_ENUM(NSInteger, DZVideoPlayerViewControllerStyle) {
    DZVideoPlayerViewControllerStyleDefault = 0,
    DZVideoPlayerViewControllerStyleSimple = 1
};


@class DZVideoPlayerViewController;




@interface DZVideoPlayerViewControllerContainerView : UIView
/*
 The controller will be created on Init, get it using this property.
 */
@property (strong, nonatomic) DZVideoPlayerViewController *videoPlayerViewController;


/*
 Use this property to pick one of the suggested styles.
 One of the existing nib's will be used.
 */
@property (assign, nonatomic) DZVideoPlayerViewControllerStyle style;

/*
 Set this property to provide your own nib to provide custom view.
 Setting this property will result in ignoring 'style' property
 */
@property (strong, nonatomic) NSString *nibNameToInitControllerWith;

/*
 Access Key for each registered user on Baidu Open Cloud
 Defaults to nil
 */
@property (strong, nonatomic) NSString* ak;

@end

