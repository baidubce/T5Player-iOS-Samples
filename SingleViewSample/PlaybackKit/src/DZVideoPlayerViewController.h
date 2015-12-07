//
//  DZVideoPlayerViewController.h
//  OhMyTube
//
//  Created by Denis Zamataev on 29/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

@import UIKit;
@import AVFoundation;
@import AudioToolbox;
@import MediaPlayer;

#import "CyberPlayerController.h"
#import "CyberplayerUtils.h"

#import "DZVideoPlayerViewControllerDelegate.h"
#import "DZProgressIndicatorSlider.h"
#import "DZVideoPlayerViewControllerContainerView.h"

@class DZVideoPlayerViewControllerContainerView;

@interface DZVideoPlayerViewController : UIViewController

// Interface Builder Outlets
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIView *topToolbarView;
@property (weak, nonatomic) IBOutlet UIView *bottomToolbarView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet DZProgressIndicatorSlider *progressIndicator;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainingTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *fullscreenExpandButton;
@property (weak, nonatomic) IBOutlet UIButton *fullscreenShrinkButton;

@property (weak, nonatomic) id<DZVideoPlayerViewControllerDelegate> delegate;

@property (strong, nonatomic) CyberPlayerController* cyberPlayer;

// Configuration of playback kit behavior
// defaults to NO
@property (assign, nonatomic) BOOL isBackgroundPlaybackEnabled;
// defaults to 3 seconds
@property (assign, nonatomic) NSTimeInterval delayBeforeHidingViewsOnIdle;
// defaults to YES
@property (assign, nonatomic) BOOL isShowFullscreenExpandAndShrinkButtonsEnabled;
// defaults to YES
@property (assign, nonatomic) BOOL isHideControlsOnIdleEnabled;

@property (strong, nonatomic) NSURL *videoURL;

//@property (strong, nonatomic) NSString * ak;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parrent:(DZVideoPlayerViewControllerContainerView *)parrentView ;
@end


#pragma mark - playback commands methods
@interface DZVideoPlayerViewController (PlaybackAPI)

- (void)prepareAndPlayAutomatically:(BOOL)playAutomatically;
- (void)stop;

@end


#pragma mark - Action methods for control kits
@interface DZVideoPlayerViewController (PlaybackKitActions)

-  (void)setupActions;
- (IBAction)play;
- (IBAction)pause;
- (IBAction)togglePlayPause;
- (IBAction)seek:(UISlider *)slider;
- (IBAction)startSeeking:(id)sender;
- (IBAction)endSeeking:(id)sender;
- (IBAction)onDoneButtonTouched;
- (IBAction)toggleFullscreen:(id)sender;

@end



#pragma mark - methods about playback engine
@interface DZVideoPlayerViewController (VideoEngine)

- (void)setupCyberPlayer;
- (void)setupAudioSession;

@end


#pragma mark - methods for lock screen
@interface DZVideoPlayerViewController (LockScreenControl)

- (void)setupRemoteControlEvents;
- (void)setupRemoteCommandCenter;
- (void)resignRemoteCommandCenter;
- (void)remoteControlReceivedWithEvent:(UIEvent *)event;
- (void)updateNowPlayingInfo;
- (void)resetNowPlayingInfo;
- (NSMutableDictionary *)gatherNowPlayingInfo;

@end


#pragma mark - methods for configuration
@interface DZVideoPlayerViewController (KitConfiguration)

+ (NSBundle*)bundle;

@end

#pragma mark - readonly properties
@interface DZVideoPlayerViewController (PlaybackStatus)

@property (readonly, nonatomic) NSTimeInterval currentPlaybackTime;
@property (readonly, nonatomic) NSTimeInterval availableDuration;
@property (readonly, nonatomic) BOOL isPlaying;
@property (readonly, nonatomic) BOOL isFullscreen;

@end


#pragma mark - methods about playback progress
@interface DZVideoPlayerViewController (PlaybackProgroess)

- (void)setupPlaybackProgress;
- (void)resignPlaybackProgress;
- (void)updateProgressIndicator:(id)sender;

@end


#pragma mark - methods about gestures
@interface DZVideoPlayerViewController (Gesture)

-(void) registerGestureRecognizer;
-(void) singleTapOnPlaybackView;


@end

#pragma mark - methods about playback control auto hide
@interface DZVideoPlayerViewController (PlaybackKitAutoHide)

- (void)startAutoHideTImerCountdown;
- (void)stopAutoHideTImerCountdown;
- (void)hideControls;
- (void)showControls;

@end


#pragma mark - methods about notification handler
@interface DZVideoPlayerViewController (NotificationHandle)

- (void)setupNotifications;
- (void)resignNotifications;

- (void)onCyberPlayerLoadDidPreparedNotification: (NSNotification*)aNotification;

- (void)handleApplicationDidEnterBackground:(NSNotification *)notification;
- (void)handleApplicationDidBecomeActive:(NSNotification *)notification;

@end


#pragma mark - methods about dispatch delegation
@interface DZVideoPlayerViewController (DelegateInvocation)

- (void)onFailedToLoadAssetWithError:(NSError*)error;
- (void)onPlay;
- (void)onPause;
- (void)onStop;
- (void)onDidPlayToEndTime;
- (void)onFailedToPlayToEndTime;
- (void)onRequireNextTrack;
- (void)onRequirePreviousTrack;
- (void)onToggleFullscreen;
- (void)onPlaybackStalled;
- (void)onGatherNowPlayingInfo:(NSMutableDictionary *)nowPlayingInfo;

@end