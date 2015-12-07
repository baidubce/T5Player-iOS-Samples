//
//  DZVideoPlayerViewController.m
//  OhMyTube
//
//  Created by Denis Zamataev on 29/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "DZVideoPlayerViewController.h"
#import "CyberPlayerController.h"
#import "CyberplayerUtils.h"

static const NSString *ItemStatusContext;
static const NSString *PlayerRateContext;
static const NSString *PlayerStatusContext;

@interface DZVideoPlayerViewController ()
{
    BOOL _isFullscreen;
}

#pragma mark - Player Engine properties
//@property (strong, nonatomic) CyberPlayerController* cyberPlayer;
//@property (strong, nonatomic) AVPlayer *player;
//@property (strong, nonatomic) AVPlayerItem *playerItem;

@property (assign, nonatomic) CGRect initialFrame;
@property (weak, nonatomic) DZVideoPlayerViewControllerContainerView* parrentView;

@property (assign, nonatomic) BOOL isSeeking;
@property (assign, nonatomic) BOOL isControlsHidden;

@property (strong, nonatomic) NSTimer *autoHideTImer;

// Player time observer target
@property (strong, nonatomic) id playerTimeObservationTarget;

// Remote command center targets
@property (strong, nonatomic) id playCommandTarget;
@property (strong, nonatomic) id pauseCommandTarget;

// has topToolbarView and bottomToolbarView by default
@property (strong, nonatomic) NSMutableArray *viewsToHideOnIdle;

- (NSString *)stringFromTimeInterval:(NSTimeInterval)time;

/*
 * Sync playback state with GUI.
 * This method must be called in main thread.
 */
- (void)syncUI;
- (void)doPlay;
- (void)doPause;
- (void)doStop;

@end


@implementation DZVideoPlayerViewController

#pragma mark - ViewController Lifecycle Override

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                      parrent:(DZVideoPlayerViewControllerContainerView*) parrentView {
    NSLog(@"DZVideoPlayerViewController begin with initWithNibName: %@", nibNameOrNil);

    // set default configuration properties before loading nib
    _parrentView = parrentView;
    _viewsToHideOnIdle = [[NSMutableArray alloc] init];
    _delayBeforeHidingViewsOnIdle = 3.0;
    _isShowFullscreenExpandAndShrinkButtonsEnabled = YES;
    _isHideControlsOnIdleEnabled = YES;
    _isBackgroundPlaybackEnabled = NO;
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    NSLog(@"DZVideoPlayerViewController end with initWithNibName: %@", nibNameOrNil);
    return self;
}

/*
 * ViewController is loaded from nib file. it is not added in main storyboard yet.
 * So its view's size doesn't fit environment
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"DZVideoPlayerViewController viewDidLoad.");
    [self setupFrameWithParrentView];
    
    if (self.topToolbarView) {
        [self.viewsToHideOnIdle addObject:self.topToolbarView];
    }
    if (self.bottomToolbarView) {
        [self.viewsToHideOnIdle addObject:self.bottomToolbarView];
    }
    
    [self setupActions];
//    [self setupAudioSession];
    [self setupCyberPlayer];
    [self setupRemoteCommandCenter];
    [self registerGestureRecognizer];
    [self syncUI];
}

- (void)setupFrameWithParrentView {
    self.view.frame = self.parrentView.bounds;
    [self.parrentView addSubview:self.view];
    self.initialFrame = self.view.frame;
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    // bind playback's frame to the containers's boundary
    NSDictionary *viewsDictionary = @{@"localRoot":self.view};
    NSMutableArray *constraintsArray = [[NSMutableArray alloc] init];
    [constraintsArray addObjectsFromArray:[NSLayoutConstraint
                                           constraintsWithVisualFormat:@"H:|[localRoot]|"
                                           options:0 metrics:nil
                                           views:viewsDictionary]];
    [constraintsArray addObjectsFromArray:[NSLayoutConstraint
                                           constraintsWithVisualFormat:@"V:|[localRoot]|"
                                           options:0 metrics:nil
                                           views:viewsDictionary]];
    
    [self.parrentView addConstraints:constraintsArray];
    NSLog(@"DZVideoPlayerViewController viewDidLoad(), bind with container's view");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupRemoteControlEvents];
}

- (void)viewWillDisappear:(BOOL)animated {
    // stop playback, save current time,
    // unregister notification, KVO,
    //
    NSLog(@"DZVideoPlayerViewController viewWillDisappear(), \n %@", [NSThread callStackSymbols]);
    [self resignNotifications];
    [self resignRemoteCommandCenter];
    [self resignPlaybackProgress];
    [self resetNowPlayingInfo];
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    NSLog(@"DZVideoPlayerViewController dealloc(), \n %@", [NSThread callStackSymbols]);
    [self resignNotifications];
    [self resignRemoteCommandCenter];
    [self resignPlaybackProgress];
    [self resetNowPlayingInfo];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - Kit Management
/*
 * This method should be called in main thread
 */
- (void) syncUI {
    // ensure this method is called in main thread.
    if (![[NSThread currentThread] isMainThread]) {
        DZVideoPlayerViewController* __weak welf = self;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [welf syncUI];
        });
        
    } else {
        
        if ([self isPlaying]) {
            if (self.activityIndicatorView.isAnimating) {
                [self.activityIndicatorView stopAnimating];
            }
            self.playButton.hidden = YES;
            self.playButton.enabled = NO;
            
            self.pauseButton.hidden = NO;
            self.pauseButton.enabled = YES;
        }
        else {
            self.playButton.hidden = NO;
            self.playButton.enabled = YES;
            
            self.pauseButton.hidden = YES;
            self.pauseButton.enabled = NO;
        }
        
        if (self.isShowFullscreenExpandAndShrinkButtonsEnabled) {
            if (self.isFullscreen) {
                self.fullscreenExpandButton.hidden = YES;
                self.fullscreenExpandButton.enabled = NO;
                
                self.fullscreenShrinkButton.hidden = NO;
                self.fullscreenShrinkButton.enabled = YES;
            }
            else {
                self.fullscreenExpandButton.hidden = NO;
                self.fullscreenExpandButton.enabled = YES;
                
                self.fullscreenShrinkButton.hidden = YES;
                self.fullscreenShrinkButton.enabled = NO;
            }
        }
        else {
            self.fullscreenExpandButton.hidden = YES;
            self.fullscreenExpandButton.enabled = NO;
            
            self.fullscreenShrinkButton.hidden = YES;
            self.fullscreenShrinkButton.enabled = NO;
        }
    }
    
}

#pragma mark - internal play commands

- (void) doPlay {
    
    if(self.videoURL != nil) {
        switch (self.cyberPlayer.playbackState) {
                
            case CBPMoviePlaybackStateStopped:
            case CBPMoviePlaybackStateInterrupted:
                self.cyberPlayer.contentURL = self.videoURL;
                self.cyberPlayer.shouldAutoplay = YES;
                
                [self.cyberPlayer prepareToPlay];
                [self.activityIndicatorView startAnimating];
                [self syncUI];
                break;
                
            case CBPMoviePlaybackStatePaused:
            case CBPMoviePlaybackStatePrepared:
                [self.cyberPlayer start];
                [self syncUI];
                break;
                
            case CBPMoviePlaybackStatePlaying:
                break;
                
            default:
                break;
        }
    }
}

- (void) doPause {
    if(self.cyberPlayer.playbackState == CBPMoviePlaybackStatePlaying) {
        [self.cyberPlayer pause];
        [self syncUI];
    }
}

- (void) doStop {
    if (self.cyberPlayer.playbackState != CBPMoviePlaybackStateStopped) {
        [self.cyberPlayer stop];
        [self syncUI];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue: segue sender: sender];
}

#pragma mark - Helpers

- (NSString *)stringFromTimeInterval:(NSTimeInterval)time {
    NSString *string = [NSString stringWithFormat:@"%02li:%02li:%02li",
                        lround(floor(time / 3600.)) % 100,
                        lround(floor(time / 60.)) % 60,
                        lround(floor(time)) % 60];
    
    NSString *extraZeroes = @"00:";
    
    if ([string hasPrefix:extraZeroes]) {
        string = [string substringFromIndex:extraZeroes.length];
    }
    
    return string;
}

@end


@implementation DZVideoPlayerViewController (VideoEngine)

// create and setup CyberPlayer
- (void)setupCyberPlayer {
    
    // init CyberPlayer
    if (self.cyberPlayer == nil) {
        self.cyberPlayer = [[CyberPlayerController alloc] init];
        [self.cyberPlayer setAccessKey:self.parrentView.ak];
    }
    
    // setup CyberPlayer's View
    self.cyberPlayer.view.translatesAutoresizingMaskIntoConstraints = NO;

    [self.cyberPlayer.view setFrame: self.view.bounds];
    [self.view insertSubview:self.cyberPlayer.view aboveSubview:self.backgroundView];

    // register notification handler
    [self setupNotifications];

//    self.player = [[AVPlayer alloc] initWithPlayerItem:nil];
//

    [self setupPlaybackProgress];
    
//    self.playerView.player = self.player;
//    self.playerView.videoFillMode = AVLayerVideoGravityResizeAspect;
    
}

- (void)setupAudioSession {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *setCategoryError = nil;
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    if (!success) { /* handle the error condition */ }
    
    NSError *activationError = nil;
    success = [audioSession setActive:YES error:&activationError];
    if (!success) { /* handle the error condition */ }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAVAudioSessionInterruptionNotification:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:audioSession];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAVAudioSessionRouteChangeNotification:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:audioSession];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAVAudioSessionMediaServicesWereLostNotification:)
                                                 name:AVAudioSessionMediaServicesWereLostNotification
                                               object:audioSession];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAVAudioSessionMediaServicesWereResetNotification:)
                                                 name:AVAudioSessionMediaServicesWereResetNotification
                                               object:audioSession];
}


@end


#pragma mark - Remote Control Events

@implementation DZVideoPlayerViewController (LockScreenControl)

- (void)setupRemoteControlEvents {
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)setupRemoteCommandCenter {
    DZVideoPlayerViewController __weak *welf = self;
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    self.playCommandTarget = [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
        [welf play];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    self.pauseCommandTarget = [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
        [welf pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
}

- (void)resignRemoteCommandCenter {
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    [commandCenter.playCommand removeTarget:self.playCommandTarget];
    [commandCenter.pauseCommand removeTarget:self.pauseCommandTarget];
    self.playCommandTarget = nil;
    self.pauseCommandTarget = nil;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    //if it is a remote control event handle it correctly
    if (event.type == UIEventTypeRemoteControl) {
        if (event.subtype == UIEventSubtypeRemoteControlPlay) {
            [self play];
        } else if (event.subtype == UIEventSubtypeRemoteControlPause) {
            [self pause];
        } else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
            [self togglePlayPause];
        } else if (event.subtype == UIEventSubtypeRemoteControlNextTrack) {
            [self onRequireNextTrack];
        } else if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack) {
            [self onRequirePreviousTrack];
        }
    }
}

- (void)updateNowPlayingInfo {
    NSMutableDictionary *nowPlayingInfo = [self gatherNowPlayingInfo];
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nowPlayingInfo;
}

- (void)resetNowPlayingInfo {
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nil;
}

- (NSMutableDictionary *)gatherNowPlayingInfo {
    NSMutableDictionary *nowPlayingInfo = [[NSMutableDictionary alloc] init];
//    [nowPlayingInfo setObject:[NSNumber numberWithDouble:self.player.rate] forKey:MPNowPlayingInfoPropertyPlaybackRate];
//    [nowPlayingInfo setObject:[NSNumber numberWithDouble:self.currentPlaybackTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
//    [self onGatherNowPlayingInfo:nowPlayingInfo];
    return nowPlayingInfo;
}

@end


@implementation DZVideoPlayerViewController (PlaybackKitActions)
- (void)setupActions {

    [self.playButton addTarget:self
                        action:@selector(play)
              forControlEvents:UIControlEventTouchUpInside];
    
    [self.pauseButton addTarget:self
                         action:@selector(pause)
               forControlEvents:UIControlEventTouchUpInside];
    
    [self.fullscreenShrinkButton addTarget:self
                                    action:@selector(toggleFullscreen:)
                          forControlEvents:UIControlEventTouchUpInside];
    
    [self.fullscreenExpandButton addTarget:self
                                    action:@selector(toggleFullscreen:)
                          forControlEvents:UIControlEventTouchUpInside];

    [self.progressIndicator addTarget:self
                               action:@selector(seek:)
                     forControlEvents:UIControlEventValueChanged];
    
    [self.progressIndicator addTarget:self
                               action:@selector(startSeeking:)
                     forControlEvents:UIControlEventTouchDown];
    
    [self.progressIndicator addTarget:self
                               action:@selector(endSeeking:)
                     forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];

    [self.doneButton addTarget:self
                        action:@selector(onDoneButtonTouched)
              forControlEvents:UIControlEventTouchUpInside];

}

- (IBAction)play {
    [self doPlay];
    [self startAutoHideTimerCountdown];
    [self onPlay];
    [self updateNowPlayingInfo];
}

- (IBAction)pause {
    [self doPause];
    [self stopAutoHideTimerCountdown];
    [self onPause];
    [self updateNowPlayingInfo];
}

- (IBAction)togglePlayPause {
    if ([self isPlaying]) {
        [self pause];
    }
    else {
        [self play];
    }
}

- (IBAction)seek:(UISlider *)slider {
//    int timescale = self.playerItem.asset.duration.timescale;
//    float time = slider.value * (self.playerItem.asset.duration.value / timescale);
//    [self.player seekToTime:CMTimeMakeWithSeconds(time, timescale)];
}

- (IBAction)startSeeking:(id)sender {
    [self stopAutoHideTimerCountdown];
    self.isSeeking = YES;
}

- (IBAction)endSeeking:(id)sender {
    [self startAutoHideTimerCountdown];
    self.isSeeking = NO;
}

- (IBAction)onDoneButtonTouched {
    if ([self.delegate respondsToSelector:@selector(playerDoneButtonTouched)]) {
        [self.delegate playerDoneButtonTouched];
    }
}

- (IBAction)toggleFullscreen:(id)sender {
    _isFullscreen = !_isFullscreen;
    [self onToggleFullscreen];
    [self syncUI];
    [self startAutoHideTimerCountdown];
}

@end


@implementation DZVideoPlayerViewController (KitConfiguration)

+ (NSBundle *)bundle {
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                 pathForResource:@"DZVideoPlayerViewController"
                                                 ofType:@"bundle"]];
    return bundle;
}


@end


@implementation DZVideoPlayerViewController (PlaybackStatus)

- (NSTimeInterval)availableDuration {
    NSTimeInterval result = 0;
//    NSArray *loadedTimeRanges = self.player.currentItem.loadedTimeRanges;
//    
//    if ([loadedTimeRanges count] > 0) {
//        CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
//        Float64 startSeconds = CMTimeGetSeconds(timeRange.start);
//        Float64 durationSeconds = CMTimeGetSeconds(timeRange.duration);
//        result = startSeconds + durationSeconds;
//    }
    
    return result;
}

- (NSTimeInterval)currentPlaybackTime {
    NSTimeInterval time = self.cyberPlayer.currentPlaybackTime;
//    if (CMTIME_IS_VALID(time)) {
//        return time.value / time.timescale;
//    }
    return 0;
}

- (BOOL)isPlaying {
    
    return self.cyberPlayer.playbackState == CBPMoviePlaybackStatePlaying;
}

- (BOOL)isFullscreen {
    return _isFullscreen;
}

@end



@implementation DZVideoPlayerViewController (NotificationHandle)

- (void)setupNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCyberPlayerGotAVSyncDiffNotification:)
                                                 name:CyberPlayerGotAVSyncDiffNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCyberPlayerGotCachePercentNotification:)
                                                 name:CyberPlayerGotCachePercentNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCyberPlayerGotNetworkBitrateNotification:)
                                                 name:CyberPlayerGotNetworkBitrateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCyberPlayerGotPlayQualityNotification:)
                                                 name:CyberPlayerGotPlayQualityNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCyberPlayerLoadDidPreparedNotification:)
                                                 name:CyberPlayerLoadDidPreparedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCyberPlayerPlaybackDidFinishNotification:)
                                                 name:CyberPlayerPlaybackDidFinishNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCyberPlayerPlaybackErrorNotification:)
                                                 name:CyberPlayerPlaybackErrorNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCyberPlayerPlaybackStateDidChangeNotification:)
                                                 name:CyberPlayerPlaybackStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCyberPlayerMeidaTypeAudioOnlyNotification:)
                                                 name:CyberPlayerMeidaTypeAudioOnlyNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCyberPlayerSeekingDidFinishNotification:)
                                                 name:CyberPlayerSeekingDidFinishNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCyberPlayerStartCachingNotification:)
                                                 name:CyberPlayerStartCachingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCBPUOnSniffCompletionNotification:)
                                                 name:CBPUOnSniffCompletionNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCBPUOnSniffErrorNotification:)
                                                 name:CBPUOnSniffErrorNotification
                                               object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(handleEnteredBackground:)
//                                                 name:UIApplicationDidEnterBackgroundNotification
//                                               object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(handleEnteredBackground:)
//                                                 name:UIApplicationDidEnterBackgroundNotification
//                                               object:nil];

}

- (void)resignNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) onCyberPlayerGotAVSyncDiffNotification: (NSNotification*)notification {
#ifdef __DEBUG__
    NSLog(@"onCyberPlayerGotAVSyncDiffNotification: %@, CyberPlayer's status = %li", notification, self.cyberPlayer.playbackState);
#endif
}

- (void) onCyberPlayerGotCachePercentNotification: (NSNotification*)notification {
    NSLog(@"onCyberPlayerGotCachePercentNotification: %@, CyberPlayer's status = %i", notification, self.cyberPlayer.playbackState);
}

- (void) onCyberPlayerGotNetworkBitrateNotification: (NSNotification*)notification {
    NSLog(@"onCyberPlayerGotNetworkBitrateNotification: %@, CyberPlayer's status = %li", notification, (long)self.cyberPlayer.playbackState);
    
}

- (void) onCyberPlayerGotPlayQualityNotification: (NSNotification*)notification {
    NSLog(@"onCyberPlayerGotPlayQualityNotification: %@, CyberPlayer's status = %i", notification, self.cyberPlayer.playbackState);
    
}

- (void) onCyberPlayerLoadDidPreparedNotification: (NSNotification*)notification {
    NSLog(@"onCyberPlayerLoadDidPreparedNotification: %@, CyberPlayer's status = %li", notification, self.cyberPlayer.playbackState);
    [self syncUI];
        // start progress timer
        // timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerHandler:) userInfo:nil repeats:YES];

}

- (void) onCyberPlayerPlaybackDidFinishNotification: (NSNotification*)notification {
    NSLog(@"onCyberPlayerPlaybackDidFinishNotification: %@, CyberPlayer's status = %li", notification, self.cyberPlayer.playbackState);
}

- (void) onCyberPlayerPlaybackErrorNotification: (NSNotification*)notification {
    NSLog(@"onCyberPlayerPlaybackErrorNotification: %@, CyberPlayer's status = %i", notification, self.cyberPlayer.playbackState);
}

- (void) onCyberPlayerPlaybackStateDidChangeNotification: (NSNotification*)notification {
    NSLog(@"onCyberPlayerPlaybackStateDidChangeNotification: %@, CyberPlayer's status = %li", notification, self.cyberPlayer.playbackState);
    [self syncUI];

}

- (void) onCyberPlayerMeidaTypeAudioOnlyNotification: (NSNotification*)notification {
    NSLog(@"onCyberPlayerMeidaTypeAudioOnlyNotification: %@, CyberPlayer's status = %li", notification, self.cyberPlayer.playbackState);
    
}

- (void) onCyberPlayerSeekingDidFinishNotification: (NSNotification*)notification {
    NSLog(@"onCyberPlayerSeekingDidFinishNotification: %@, CyberPlayer's status = %li", notification, self.cyberPlayer.playbackState);
}

- (void) onCyberPlayerStartCachingNotification: (NSNotification*)notification {
    NSLog(@"onCyberPlayerStartCachingNotification: %@, CyberPlayer's status = %li", notification, self.cyberPlayer.playbackState);
}

- (void) onCBPUOnSniffCompletionNotification: (NSNotification*)notification {
    NSLog(@"onCBPUOnSniffCompletionNotification: %@, CyberPlayer's status = %li", notification, self.cyberPlayer.playbackState);
    
}

- (void) onCBPUOnSniffErrorNotification: (NSNotification*)notification {
    NSLog(@"onCBPUOnSniffErrorNotification: %@, CyberPlayer's status = %li", notification, self.cyberPlayer.playbackState);
    
}

- (void)handleAVPlayerItemDidPlayToEndTime:(NSNotification *)notification {
    [self stop];
    [self onDidPlayToEndTime];
}

- (void)handleAVPlayerItemFailedToPlayToEndTime:(NSNotification *)notification {
    [self stop];
    [self onFailedToPlayToEndTime];
}

- (void)handleAVPlayerItemPlaybackStalled:(NSNotification *)notification {
    [self pause];
    [self.activityIndicatorView startAnimating];
    [self onPlaybackStalled];
}

- (void)handleApplicationDidEnterBackground:(NSNotification *)notification {
    if (self.isBackgroundPlaybackEnabled) {
//        self.playerView.player = nil;
    }
}

- (void)handleApplicationDidBecomeActive:(NSNotification *)notification {
    if (self.isBackgroundPlaybackEnabled) {
//        self.playerView.player = self.player;
    }
}

@end



@implementation DZVideoPlayerViewController (DelegateInvocation)

- (void)onFailedToLoadAssetWithError:(NSError*)error {
    if ([self.delegate respondsToSelector:@selector(playerFailedToLoadAssetWithError:)]) {
        [self.delegate playerFailedToLoadAssetWithError:error];
    }
}

- (void)onPlay {
    if ([self.delegate respondsToSelector:@selector(playerDidPlay)]) {
        [self.delegate playerDidPlay];
    }
}

- (void)onPause {
    if ([self.delegate respondsToSelector:@selector(playerDidPause)]) {
        [self.delegate playerDidPause];
    }
}

- (void)onStop {
    if ([self.delegate respondsToSelector:@selector(playerDidStop)]) {
        [self.delegate playerDidStop];
    }
}

- (void)onDidPlayToEndTime {
    if ([self.delegate respondsToSelector:@selector(playerDidPlayToEndTime)]) {
        [self.delegate playerDidPlayToEndTime];
    }
}

- (void)onFailedToPlayToEndTime {
    if ([self.delegate respondsToSelector:@selector(playerFailedToPlayToEndTime)]) {
        [self.delegate playerFailedToPlayToEndTime];
    }
}

- (void)onRequireNextTrack {
    if ([self.delegate respondsToSelector:@selector(playerRequireNextTrack)]) {
        [self.delegate playerRequireNextTrack];
    }
}

- (void)onRequirePreviousTrack {
    if ([self.delegate respondsToSelector:@selector(playerRequirePreviousTrack)]) {
        [self.delegate playerRequirePreviousTrack];
    }
}

- (void)onToggleFullscreen {
    if ([self.delegate respondsToSelector:@selector(playerDidToggleFullscreen)]) {
        [self.delegate playerDidToggleFullscreen];
    }
}

- (void)onPlaybackStalled {
    if ([self.delegate respondsToSelector:@selector(playerPlaybackStalled)]) {
        [self.delegate playerPlaybackStalled];
    }
}

- (void)onGatherNowPlayingInfo:(NSMutableDictionary *)nowPlayingInfo {
    if ([self.delegate respondsToSelector:@selector(playerGatherNowPlayingInfo:)]) {
        [self.delegate playerGatherNowPlayingInfo:nowPlayingInfo];
    }
}

@end



@implementation DZVideoPlayerViewController (PlaybackProgroess)

- (void)updateProgressIndicator:(id)sender {
//    CGFloat duration = CMTimeGetSeconds(self.playerItem.asset.duration);
//    
//    if (duration == 0 || isnan(duration)) {
//        // Video is a live stream
//        self.progressIndicator.hidden = YES;
//        [self.currentTimeLabel setText:nil];
//        [self.remainingTimeLabel setText:nil];
//    }
//    else {
//        self.progressIndicator.hidden = NO;
//        
//        CGFloat current;
//        if (self.isSeeking) {
//            current = self.progressIndicator.value * duration;
//        }
//        else {
//            // Otherwise, use the actual video position
//            current = CMTimeGetSeconds(self.player.currentTime);
//        }
//        
//        CGFloat left = duration - current;
//        
//        [self.progressIndicator setValue:(current / duration)];
//        [self.progressIndicator setSecondaryValue:([self availableDuration] / duration)];
//        
//        // Set time labels
//        
//        NSString *currentTimeString = current > 0 ? [self stringFromTimeInterval:current] : @"00:00";
//        NSString *remainingTimeString = left > 0 ? [self stringFromTimeInterval:left] : @"00:00";
//        
//        [self.currentTimeLabel setText:currentTimeString];
//        [self.remainingTimeLabel setText:[NSString stringWithFormat:@"-%@", remainingTimeString]];
//        
//    }
}

- (void)setupPlaybackProgress {
    DZVideoPlayerViewController __weak *welf = self;
//    self.playerTimeObservationTarget = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1)  queue:nil usingBlock:^(CMTime time) {
//        [welf updateProgressIndicator:welf];
//        [welf syncUI];
//    }];
    
}

- (void)resignPlaybackProgress {
//    [self.player removeTimeObserver:self.playerTimeObservationTarget];
//    self.playerTimeObservationTarget = nil;
}

@end

@implementation DZVideoPlayerViewController (Gesture)

-(void) registerGestureRecognizer {
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(singleTapOnPlaybackView)];
    tap.numberOfTapsRequired = 1;
    [self.cyberPlayer.view addGestureRecognizer:tap];
    
}

-(void) singleTapOnPlaybackView {
    if (self.isControlsHidden) {
        [self showControls];
    } else {
        [self startAutoHideTimerCountdown];
    }
}
@end



@implementation DZVideoPlayerViewController (PlaybackKitAutoHide)

- (void)startAutoHideTimerCountdown {
    if (self.autoHideTImer) {
        [self.autoHideTImer invalidate];
    }
    if (self.isHideControlsOnIdleEnabled) {
        self.autoHideTImer = [NSTimer scheduledTimerWithTimeInterval:self.delayBeforeHidingViewsOnIdle
                                                          target:self
                                                        selector:@selector(hideControls)
                                                        userInfo:nil
                                                         repeats:NO];
    }
}

- (void)stopAutoHideTimerCountdown {
    if (self.autoHideTImer) {
        [self.autoHideTImer invalidate];
        self.autoHideTImer = nil;
    }
}

- (void)hideControls {
    NSArray *views = self.viewsToHideOnIdle;
    [UIView animateWithDuration:0.3f animations:^{
        for (UIView *view in views) {
            view.alpha = 0.0;
        }
    }];
    self.isControlsHidden = YES;
}

- (void)showControls {
    NSArray *views = self.viewsToHideOnIdle;
    [UIView animateWithDuration:0.3f animations:^{
        for (UIView *view in views) {
            view.alpha = 1.0;
        }
    }];
    self.isControlsHidden = NO;
    [self startAutoHideTimerCountdown];
}

@end


@implementation DZVideoPlayerViewController (PlaybackAPI)

- (void)prepareAndPlayAutomatically:(BOOL)playAutomatically {
    [self play];
}

- (void)stop {
    [self.cyberPlayer pause];
    [self.cyberPlayer stop];
    [self stopAutoHideTimerCountdown];
    [self syncUI];
    [self onStop];
    [self updateNowPlayingInfo];
}


@end