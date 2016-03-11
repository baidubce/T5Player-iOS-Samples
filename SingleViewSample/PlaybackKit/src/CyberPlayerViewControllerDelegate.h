//
//  CyberPlayerViewControllerDelegate.h
//
//  Created by hudapeng on 12/7/15.
//  Copyright © 2015 Baidu. All rights reserved.

#import <Foundation/Foundation.h>

@protocol CyberPlayerViewControllerDelegate <NSObject>

@optional

- (void)playerDidPlay;

- (void)playerDidPause;

- (void)playerDidStop;

/*
 Check isFullscreen property and animate view controller's view appropriately.
 If you don't want to support fullscreen please provide custom user interface which does not have fullscreenExpandButton and fullscreenShrinkButton, or hide the buttons in default user interface.
 */
- (void)playerToggleFullscreen;

@end
