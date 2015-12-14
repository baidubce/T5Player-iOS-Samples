//
//  CyberPlayerViewController.m
//

#import "CyberPlayerViewController.h"

@interface CyberPlayerViewController ()
{
}

#pragma mark - Player Engine properties

@property (assign, nonatomic) CGRect initialFrame;

@property (assign, nonatomic) BOOL isSeeking;
@property (assign, nonatomic) BOOL isControlsHidden;

@property (strong, nonatomic) NSTimer *autoHideTimer;
@property (strong, nonatomic) NSTimer *progressTimer;

// Player time observer target
@property (strong, nonatomic) id playerTimeObservationTarget;

// Remote command center targets
@property (strong, nonatomic) id playCommandTarget;
@property (strong, nonatomic) id pauseCommandTarget;

@property (nonatomic, assign) NSTimeInterval lastPlayDuration;

// has topToolbarView and bottomToolbarView by default
@property (strong, nonatomic) NSMutableArray *viewsToHideOnIdle;

/*
 * Sync playback state with GUI.
 * This method must be called in main thread.
 */
- (void)syncUI;
- (void)doPlay;
- (void)doPause;
- (void)doStop;

@end

@implementation CyberPlayerViewController

#pragma mark - ViewController Lifecycle Override

- (void) initWithUserDefaults {
    NSBundle *bundle = [CyberPlayerViewController bundle];
    NSString* nibfile = [[NSUserDefaults standardUserDefaults] stringForKey: CYBERPLAYER_NIB_FILE_NAME];
    [super initWithNibName:nibfile bundle:bundle];
}

/*
 * ViewController is loaded from nib file. it is not added in main storyboard yet.
 * So its view's size doesn't fit environment
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set default configuration properties before loading nib
    _viewsToHideOnIdle = [[NSMutableArray alloc] init];
    _delayBeforeHidingViewsOnIdle = 3.0;
    _isShowFullscreenExpandAndShrinkButtonsEnabled = YES;
    _isHideControlsOnIdleEnabled = YES;
    _isBackgroundPlaybackEnabled = NO;

    if (self.topToolbarView) {
        [self.viewsToHideOnIdle addObject:self.topToolbarView];
    }
    if (self.bottomToolbarView) {
        [self.viewsToHideOnIdle addObject:self.bottomToolbarView];
    }
    
    [self setupActions];
    [self setupCyberPlayer];
    [self setupRemoteCommandCenter];
    [self registerGestureRecognizer];
    [self addConstraints];
    [self syncUI];
}

- (void)addConstraints {
    // bind the size of player's view to parrent view
    self.cyberPlayer.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *viewsDictionary = @{
                                      @"playerView":self.cyberPlayer.view,
                                      @"backgroundView":self.backgroundView
                                      };
    
    NSMutableArray *constraintsArray = [[NSMutableArray alloc] init];

    [constraintsArray addObjectsFromArray:[NSLayoutConstraint
                                           constraintsWithVisualFormat:@"H:|[playerView]|"
                                           options:0
                                           metrics:nil
                                           views:viewsDictionary]];
    
    [constraintsArray addObjectsFromArray:[NSLayoutConstraint
                                           constraintsWithVisualFormat:@"V:|[playerView]|"
                                           options:0
                                           metrics:nil
                                           views:viewsDictionary]];
    
    [constraintsArray addObjectsFromArray:[NSLayoutConstraint
                                           constraintsWithVisualFormat:@"H:|[backgroundView]|"
                                           options:0
                                           metrics:nil
                                           views:viewsDictionary]];
    
    [constraintsArray addObjectsFromArray:[NSLayoutConstraint
                                           constraintsWithVisualFormat:@"V:|[backgroundView]|"
                                           options:0
                                           metrics:nil
                                           views:viewsDictionary]];

    self.view.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addConstraints:constraintsArray];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupRemoteControlEvents];
}

- (void)viewWillDisappear:(BOOL)animated {
    // stop playback, save current time,
    // unregister notification, KVO,
    //
    NSLog(@"CyberPlayerViewController viewWillDisappear(), \n %@", [NSThread callStackSymbols]);
    [self resignNotifications];
    [self stop];
    [self resignPlaybackProgress];
    [self resignRemoteCommandCenter];
    [self resetNowPlayingInfo];
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    NSLog(@"CyberPlayerViewController dealloc(), \n %@", [NSThread callStackSymbols]);
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
        CyberPlayerViewController* __weak welf = self;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [welf syncUI];
        });
        
    } else {
        if ([self isPlaying]) {
            if (self.isSeeking) {
                if (! self.activityIndicatorView.isAnimating) {
                    [self.activityIndicatorView startAnimating];
                }
                
            } else {
                if (self.activityIndicatorView.isAnimating) {
                    [self.activityIndicatorView stopAnimating];
                }
            }
            
            self.playButton.hidden = YES;
            self.playButton.enabled = NO;
            
            self.pauseButton.hidden = NO;
            self.pauseButton.enabled = YES;
        }
        else {
            if (self.activityIndicatorView.isAnimating) {
                [self.activityIndicatorView stopAnimating];
            }
            
            self.playButton.hidden = NO;
            self.playButton.enabled = YES;
            
            self.pauseButton.hidden = YES;
            self.pauseButton.enabled = NO;
        }
        
        if (self.isShowFullscreenExpandAndShrinkButtonsEnabled) {
            if (self.isLandscape) {
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

#pragma mark - View Rotation

- (BOOL) shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    NSLog(@"CyberPlayerViewController supportedInterfaceOrientations");
    return UIInterfaceOrientationMaskPortrait;
}

@end


@implementation CyberPlayerViewController (VideoEngine)

// create and setup CyberPlayer
- (void)setupCyberPlayer {
    
    // init CyberPlayer
    if (self.cyberPlayer == nil) {
        self.cyberPlayer = [[CyberPlayerController alloc] init];
        NSString* ak = [[NSUserDefaults standardUserDefaults] stringForKey:CYBERPLAYER_ACCESS_KEY];
        [self.cyberPlayer setAccessKey: (ak == nil) ? @"" : ak];
        [self setupNotifications];
    }
    
    [self.view insertSubview:self.cyberPlayer.view aboveSubview:self.backgroundView];

    [self setupPlaybackProgress];
}

@end


@implementation CyberPlayerViewController (PlaybackKitActions)

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

    [self.sliderProgress addTarget:self
                               action:@selector(seek:)
                     forControlEvents:UIControlEventValueChanged];
    
    [self.sliderProgress addTarget:self
                               action:@selector(startSeeking:)
                     forControlEvents:UIControlEventTouchDown];
    
    [self.sliderProgress addTarget:self
                               action:@selector(endSeeking:)
                     forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];

    [self.doneButton addTarget:self
                        action:@selector(doneButtonTouched)
              forControlEvents:UIControlEventTouchUpInside];

}

- (IBAction)play {
    NSLog(@"play cyberPlayer's frame = %@", NSStringFromCGRect(self.cyberPlayer.view.frame));

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
    NSLog(@" on seek: %f", slider.value);
    if (self.cyberPlayer.playbackState == CBPMoviePlaybackStatePlaying
     || self.cyberPlayer.playbackState == CBPMoviePlaybackStatePaused
     || self.cyberPlayer.playbackState == CBPMoviePlaybackStatePrepared) {
        
        self.isSeeking = YES;
        [self.cyberPlayer seekTo:slider.value * self.cyberPlayer.duration];
        [self.activityIndicatorView startAnimating];
    }
    [self startAutoHideTimerCountdown];
    
}

- (IBAction)startSeeking:(UISlider *)slider {
    [self startAutoHideTimerCountdown];
}

- (IBAction)endSeeking:(UISlider *)slider {
    [self startAutoHideTimerCountdown];
}

- (IBAction)doneButtonTouched {
    [self stop];
    [self startAutoHideTimerCountdown];
    [self onStop];
}

- (IBAction)toggleFullscreen:(id)sender {
    // change to fullscreen
//    if (self.isFullscreen) {
//        NSLog(@"Change back to frame: %@", NSStringFromCGRect(self.initialFrame));
//        self.view.frame = self.initialFrame;
//    } else {
//        CGRect frame = [UIScreen mainScreen].bounds;
//        NSLog(@"Change to full screen frame: %@", NSStringFromCGRect(frame));
//        self.view.frame = frame;
//    }
//    _isFullscreen = !_isFullscreen;
    // change back
    [self onToggleFullscreen];
    [self syncUI];
    [self startAutoHideTimerCountdown];
}

@end


@implementation CyberPlayerViewController (KitConfiguration)

+ (NSBundle *)bundle {
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                 pathForResource:@"CyberPlayerViewController"
                                                 ofType:@"bundle"]];
    return bundle;
}

@end


@implementation CyberPlayerViewController (PlaybackStatus)

- (NSTimeInterval)availableDuration {
    NSTimeInterval result = -1;
    if (self.cyberPlayer.playbackState == CBPMoviePlaybackStatePlaying
        || self.cyberPlayer.playbackState == CBPMoviePlaybackStatePaused
        || self.cyberPlayer.playbackState == CBPMoviePlaybackStatePrepared) {
        result = self.cyberPlayer.duration;
    }

    return result;
}

- (NSTimeInterval)currentPlaybackTime {
    NSTimeInterval result = -1;
    if (self.cyberPlayer.playbackState == CBPMoviePlaybackStatePlaying
        || self.cyberPlayer.playbackState == CBPMoviePlaybackStatePaused
        || self.cyberPlayer.playbackState == CBPMoviePlaybackStatePrepared) {
        result = self.cyberPlayer.currentPlaybackTime;
    }
    
    return result;
}

- (BOOL)isPlaying {
    return self.cyberPlayer.playbackState == CBPMoviePlaybackStatePlaying;
}

- (BOOL)isLandscape {
   return UIInterfaceOrientationIsLandscape(
                    [[UIApplication sharedApplication] statusBarOrientation]);
}

@end



@implementation CyberPlayerViewController (NotificationHandle)

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

// On AV sync difference
- (void) onCyberPlayerGotAVSyncDiffNotification: (NSNotification*)notification {
#ifdef __DEBUG__
    NSLog(@"onCyberPlayerGotAVSyncDiffNotification: %@, CyberPlayer's status = %li", notification, self.cyberPlayer.playbackState);
#endif
}

// On play quality
- (void) onCyberPlayerGotPlayQualityNotification: (NSNotification*)notification {
//    NSLog(@"onCyberPlayerGotPlayQualityNotification: %@, CyberPlayer's status = %li",
//          notification, self.cyberPlayer.playbackState);
}

// On Network Bitrate
- (void) onCyberPlayerGotNetworkBitrateNotification: (NSNotification*)notification {
    NSLog(@"onCyberPlayerGotNetworkBitrateNotification: %@, CyberPlayer's status = %li", notification, (long)self.cyberPlayer.playbackState);
}

// Ready to play
- (void) onCyberPlayerLoadDidPreparedNotification: (NSNotification*)notification {
    NSLog(@"onCyberPlayerLoadDidPreparedNotification: %@, CyberPlayer's status = %li",
          notification, self.cyberPlayer.playbackState);
    [self setupPlaybackProgress];
    [self syncUI];
}

// Finish playing
- (void) onCyberPlayerPlaybackDidFinishNotification: (NSNotification*)notification {
    NSLog(@"onCyberPlayerPlaybackDidFinishNotification: %@, CyberPlayer's status = %li",
          notification, self.cyberPlayer.playbackState);
    [self resignPlaybackProgress];
    [self syncUI];
}

// On error
- (void) onCyberPlayerPlaybackErrorNotification: (NSNotification*)notification {
    NSLog(@"onCyberPlayerPlaybackErrorNotification: %@, CyberPlayer's status = %li",
          notification, self.cyberPlayer.playbackState);
    [self syncUI];
}

// Playback status is changed
- (void) onCyberPlayerPlaybackStateDidChangeNotification: (NSNotification*)notification {
    NSLog(@"onCyberPlayerPlaybackStateDidChangeNotification: %@, CyberPlayer's status = %li",
          notification, self.cyberPlayer.playbackState);
    [self syncUI];
}

// Only Audio
- (void) onCyberPlayerMeidaTypeAudioOnlyNotification: (NSNotification*)notification {
    NSLog(@"onCyberPlayerMeidaTypeAudioOnlyNotification: %@, CyberPlayer's status = %li",
          notification, self.cyberPlayer.playbackState);
}

// Seek Finished
- (void) onCyberPlayerSeekingDidFinishNotification: (NSNotification*)notification {
    NSLog(@"onCyberPlayerSeekingDidFinishNotification: %@, CyberPlayer's status = %li",
          notification, self.cyberPlayer.playbackState);
    self.isSeeking = NO;
    [self syncUI];
}

// Begin Caching
- (void) onCyberPlayerStartCachingNotification: (NSNotification*)notification {
    NSLog(@"onCyberPlayerStartCachingNotification: %@, CyberPlayer's status = %li",
          notification, self.cyberPlayer.playbackState);
}

// On Cache Percent
- (void) onCyberPlayerGotCachePercentNotification: (NSNotification*)notification {
    NSLog(@"onCyberPlayerGotCachePercentNotification: %@, CyberPlayer's status = %li", notification, self.cyberPlayer.playbackState);
}

- (void) onCBPUOnSniffCompletionNotification: (NSNotification*)notification {
    NSLog(@"onCBPUOnSniffCompletionNotification: %@", notification);
}

- (void) onCBPUOnSniffErrorNotification: (NSNotification*)notification {
    NSLog(@"onCBPUOnSniffErrorNotification: %@", notification);
}

@end



@implementation CyberPlayerViewController (DelegateInvocation)

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
    if ([self.delegate respondsToSelector:@selector(playerToggleFullscreen)]) {
        [self.delegate playerToggleFullscreen];
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



@implementation CyberPlayerViewController (PlaybackProgroess)

- (void)updateProgressIndicator:(NSTimer*)timer {
    if (self.isSeeking) {
        return;
    }
    NSTimeInterval currentTime = self.cyberPlayer.currentPlaybackTime;
    NSTimeInterval allSecond = self.cyberPlayer.duration;

    self.currentTimeLabel.text = [TimeFormatter convertSecond2HHMMSS:currentTime];
    self.remainingTimeLabel.text = [TimeFormatter convertSecond2HHMMSS:allSecond - currentTime];
    self.sliderProgress.value = currentTime / allSecond;
}

- (void)setupPlaybackProgress {
    if ([self.progressTimer isValid]) {
        [self.progressTimer invalidate];
        self.progressTimer = nil;
    }
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                          target:self
                                                        selector:@selector(updateProgressIndicator:)
                                                        userInfo:nil
                                                         repeats:YES];
    self.sliderProgress.value = 0;
}

- (void)resignPlaybackProgress {
    if ([self.progressTimer isValid]) {
        [self.progressTimer invalidate];
    }
    self.progressTimer = nil;
}

@end

@implementation CyberPlayerViewController (Gesture)

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



@implementation CyberPlayerViewController (PlaybackKitAutoHide)

- (void)startAutoHideTimerCountdown {
    if (self.autoHideTimer.isValid) {
        [self.autoHideTimer invalidate];
    }
    if (self.isHideControlsOnIdleEnabled) {
        self.autoHideTimer = [NSTimer scheduledTimerWithTimeInterval:self.delayBeforeHidingViewsOnIdle
                                                          target:self
                                                        selector:@selector(hideControls)
                                                        userInfo:nil
                                                         repeats:NO];
    }
}

- (void)stopAutoHideTimerCountdown {
    if (self.autoHideTimer) {
        [self.autoHideTimer invalidate];
        self.autoHideTimer = nil;
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
    for (UIView *view in views) {
        view.alpha = 1.0;
    }
    self.isControlsHidden = NO;
    [self startAutoHideTimerCountdown];
}

@end


@implementation CyberPlayerViewController (PlaybackAPI)

- (void)prepareAndPlayAutomatically:(BOOL)playAutomatically {
    [self play];
}

- (void)stop {
    [self doStop];
    [self stopAutoHideTimerCountdown];
    [self syncUI];
    [self onStop];
    [self updateNowPlayingInfo];
}

@end

#pragma mark - Remote Control Events

@implementation CyberPlayerViewController (LockScreenControl)

- (void)setupRemoteControlEvents {
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)setupRemoteCommandCenter {
    CyberPlayerViewController __weak *welf = self;
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

