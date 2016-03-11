//
//  CyberPlayerViewController.h
//
//  Created by hudapeng on 12/7/15.
//  Copyright © 2015 Baidu. All rights reserved.

@import UIKit;
@import AVFoundation;
@import MediaPlayer;

#import "CyberPlayerController.h"
#import "CyberplayerUtils.h"

#import "CyberPlayerViewControllerDelegate.h"
#import "TimeFormatter.h"
#import "CyberPlayerSettings.h"

#pragma mark - UI Macro

#define SCREEN_HEIGHT                    MAX([[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height)
#define SCREEN_WIDTH                     MIN([[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height)
#define SCREEN_35in                      (SCREEN_HEIGHT==480)
#define SCREEN_40in                      (SCREEN_HEIGHT==568)
#define SCREEN_47in                      (SCREEN_HEIGHT==667)
#define SCREEN_55in                      (SCREEN_HEIGHT==736)
#define iPad                            (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define iPadPro                         ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) && (SCREEN_HEIGHT==1366))


@interface CyberPlayerViewController : UIViewController

// Interface Builder Outlets
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIView *topToolbarView;
@property (weak, nonatomic) IBOutlet UIView *bottomToolbarView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;

@property (weak, nonatomic) IBOutlet UISlider *sliderProgress;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainingTimeLabel;

@property (weak, nonatomic) IBOutlet UIButton *fullscreenExpandButton;
@property (weak, nonatomic) IBOutlet UIButton *fullscreenShrinkButton;

@property (weak, nonatomic) id<CyberPlayerViewControllerDelegate> delegate;

@property (strong, nonatomic) CyberPlayerController* cyberPlayer;

// Configuration of playback kit behavior
// defaults to 3 seconds
@property (assign, nonatomic) NSTimeInterval delayBeforeHidingViewsOnIdle;
// defaults to YES
@property (assign, nonatomic) BOOL isHideFullscreenButtons;
// defaults to YES
@property (assign, nonatomic) BOOL isShowControlsOnIdle;

@property (strong, nonatomic) NSURL *videoURL;

- (void) initWithUserDefaults;

@end


#pragma mark - playback commands methods
@interface CyberPlayerViewController (PlaybackAPI)

- (void)prepareAndPlayAutomatically:(BOOL)playAutomatically;

@end


#pragma mark - Action methods for control kits
@interface CyberPlayerViewController (PlaybackKitActions)

- (void)setupActions;
- (IBAction)play;
- (IBAction)pause;
- (IBAction)togglePlayPause;
- (IBAction)stop;
- (IBAction)seek:(UISlider *)slider;
- (IBAction)startSeeking:(id)sender;
- (IBAction)endSeeking:(id)sender;
- (IBAction)doneButtonTouched;
- (IBAction)toggleFullscreen:(id)sender;

@end



#pragma mark - methods about playback engine
@interface CyberPlayerViewController (VideoEngine)

- (void)setupCyberPlayer;

@end


#pragma mark - methods for lock screen
@interface CyberPlayerViewController (LockScreenControl)

- (void)setupRemoteControlEvents;
- (void)setupRemoteCommandCenter;
- (void)resignRemoteCommandCenter;
- (void)remoteControlReceivedWithEvent:(UIEvent *)event;
- (void)updateNowPlayingInfo;
- (void)resetNowPlayingInfo;
- (NSMutableDictionary *)gatherNowPlayingInfo;

@end


#pragma mark - methods for configuration
@interface CyberPlayerViewController (KitConfiguration)

+ (NSBundle*)bundle;

@end

#pragma mark - readonly properties
@interface CyberPlayerViewController (PlaybackStatus)

@property (readonly, nonatomic) NSTimeInterval currentPlaybackTime;
@property (readonly, nonatomic) NSTimeInterval availableDuration;
@property (readonly, nonatomic) BOOL isPlaying;
@property (readonly) BOOL isLandscape;
@end


#pragma mark - methods about playback progress
@interface CyberPlayerViewController (PlaybackProgroess)

- (void)setupPlaybackProgress;
- (void)resignPlaybackProgress;
- (void)updateProgressIndicator:(id)sender;

@end


#pragma mark - methods about gestures
@interface CyberPlayerViewController (Gesture)

-(void) registerGestureRecognizer;
-(void) singleTapOnPlaybackView;


@end

#pragma mark - methods about playback control auto hide
@interface CyberPlayerViewController (PlaybackKitAutoHide)

- (void)startAutoHideTimerCountdown;
- (void)stopAutoHideTimerCountdown;
- (void)hideControls;
- (void)showControls;

@end


#pragma mark - methods about notification handler
@interface CyberPlayerViewController (NotificationHandle)

- (void)setupNotifications;
- (void)resignNotifications;

@end


#pragma mark - methods about dispatch delegation
@interface CyberPlayerViewController (DelegateInvocation)

- (void)onPlay;
- (void)onPause;
- (void)onStop;
- (void)onToggleFullscreen;


@end