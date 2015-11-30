//
//  DZVideoPlayerViewController.h
//  OhMyTube
//
//  Created by Denis Zamataev on 29/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>

#import "DZVideoPlayerViewController_constants.h"
#import "DZVideoPlayerViewControllerDelegate.h"
#import "DZVideoPlayerViewControllerConfiguration.h"
#import "DZPlayerView.h"
#import "DZProgressIndicatorSlider.h"
#import "DZVideoPlayerViewControllerContainerView.h"


@interface DZVideoPlayerViewController : UIViewController
@property (weak, nonatomic) id<DZVideoPlayerViewControllerDelegate> delegate;

@property (strong, nonatomic) DZVideoPlayerViewControllerConfiguration *configuration;

@property (strong, nonatomic) NSURL *videoURL;

// Interface Builder Outlets
@property (weak, nonatomic) IBOutlet DZPlayerView *playerView;

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
//

@end

@interface DZVideoPlayerViewController (VideoEngine)

- (void)setupPlayer;
- (void)resignPlayer;
- (void)setupAudioSession;

@end


@interface DZVideoPlayerViewController (RemoteControll)

- (void)setupRemoteControlEvents;
- (void)setupRemoteCommandCenter;
- (void)resignRemoteCommandCenter;
- (void)remoteControlReceivedWithEvent:(UIEvent *)event;

@end


@interface DZVideoPlayerViewController (KitConfiguration)

+ (NSBundle*)bundle;
+ (NSString *)nibNameForStyle:(DZVideoPlayerViewControllerStyle)style;
+ (DZVideoPlayerViewControllerConfiguration *)defaultConfiguration;
- (void)setupActions;

@end


// Readonly Playback properties
@interface DZVideoPlayerViewController (PlaybackStatus)

@property (readonly, nonatomic) NSTimeInterval currentPlaybackTime;
@property (readonly, nonatomic) NSTimeInterval availableDuration;
@property (readonly, nonatomic) BOOL isPlaying;
@property (readonly, nonatomic) BOOL isFullscreen;

@end


@interface DZVideoPlayerViewController (PlaybackCommands)

- (void)prepareAndPlayAutomatically:(BOOL)playAutomatically;
- (void)play;
- (void)pause;
- (void)togglePlayPause;
- (void)stop;
- (void)syncUI;
- (void)toggleFullscreen:(id)sender;
- (void)seek:(UISlider *)slider;
- (void)startSeeking:(id)sender;
- (void)endSeeking:(id)sender;
- (void)updateProgressIndicator:(id)sender;
- (void)startIdleCountdown;
- (void)stopIdleCountdown;
- (void)hideControls;
- (void)showControls;
- (void)updateNowPlayingInfo;
- (void)resetNowPlayingInfo;
- (NSMutableDictionary *)gatherNowPlayingInfo;
@end

@interface DZVideoPlayerViewController (NotificationHandle)

- (void)setupNotifications;
- (void)resignNotifications;
- (void)handleAVPlayerItemDidPlayToEndTime:(NSNotification *)notification;
- (void)handleAVPlayerItemFailedToPlayToEndTime:(NSNotification *)notification;
- (void)handleAVPlayerItemPlaybackStalled:(NSNotification *)notification;
- (void)handleApplicationDidEnterBackground:(NSNotification *)notification;
- (void)handleApplicationDidBecomeActive:(NSNotification *)notification;
- (void)handleAVAudioSessionInterruptionNotification:(NSNotification *)notification;
- (void)handleAVAudioSessionRouteChangeNotification:(NSNotification *)notification;
- (void)handleAVAudioSessionMediaServicesWereLostNotification:(NSNotification *)notification;
- (void)handleAVAudioSessionMediaServicesWereResetNotification:(NSNotification *)notification;

@end


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
- (void)onDoneButtonTouched;

@end