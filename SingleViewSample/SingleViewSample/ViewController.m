//
//  ViewController.m
//  SingleViewSample
//
//  Created by hudapeng on 11/30/15.
//  Copyright © 2015 Baidu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *playerContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playerContainerViewTopConstraint;

@property (weak, nonatomic) IBOutlet UIButton *starWarButton;
@property (weak, nonatomic) IBOutlet UIButton *yangziButton;

@property (assign, nonatomic) CGRect initPlaybackFrame;
@property (assign, nonatomic) BOOL isFullscreen;
@property (weak, nonatomic) CyberPlayerViewController* playerViewController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // after create container view, customize the internal playback view
    self.isFullscreen = false;
    self.playerViewController.delegate = self;


}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"cyberplayer"]) {
        self.playerViewController = (CyberPlayerViewController*) segue.destinationViewController;
        [self.playerViewController initWithUserDefaults];
    }
}

-(BOOL) shouldAutorotate {
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


//-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    NSLog(@"View Controller: %@", self);
//    
//    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
//        NSLog(@"ViewController: Landscape left");
//    } else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
//        NSLog(@"ViewController: Landscape right");
//    } else if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
//        NSLog(@"ViewController: Portrait");
//    } else if (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
//        NSLog(@"ViewController: Upside down");
//    }
//    NSLog(@"ViewController frame = %@", NSStringFromCGRect(self.view.frame));
//}

- (IBAction)buttonStarWar:(id)sender {
    
    NSURL* localVideo = [[NSBundle mainBundle] URLForResource:@"Star_Wars" withExtension:@"mp4"];
    self.playerViewController.videoURL = localVideo;

    [self.playerViewController play];
}

- (IBAction)buttonYangziRiver:(id)sender {
    NSString* videoAddress = @"http://txj-bucket.bj.bcebos.com/hls/test_commonkey.m3u8";
    NSURL* remoteVideo = [[NSURL alloc] initWithString:videoAddress];
    self.playerViewController.videoURL = remoteVideo;
    [self.playerViewController play];
}

@end


@implementation ViewController (PlaybackDelegate)

/*
 Check isFullscreen property and animate view controller's view appropriately.
 If you don't want to support fullscreen please provide custom user interface which does not have fullscreenExpandButton and fullscreenShrinkButton, or hide the buttons in default user interface.
 */
- (void)playerToggleFullscreen {
    NSLog(@"playerToggleFullscreen");
    NSLog(@"before rotation sreen's frame: %@", NSStringFromCGRect(self.playerContainerView.frame));
    
    if (!self.isFullscreen) {
        self.starWarButton.hidden = YES;
        self.yangziButton.hidden = YES;
        self.playerContainerViewTopConstraint.constant = 0.0;
        
        self.initPlaybackFrame = self.playerContainerView.frame;
        [[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeRight];
        [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        
        // change root view oriention and bounds
        CGRect rect = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
        self.view.bounds = rect;
        self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.playerContainerView.frame = self.view.bounds;
        
    } else {
        self.playerContainerViewTopConstraint.constant = 20.0;
        
        self.playerContainerView.frame = self.initPlaybackFrame;
        self.view.transform = CGAffineTransformIdentity;
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.view.bounds = rect;
        [[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationPortrait];
        self.starWarButton.hidden = NO;
        self.yangziButton.hidden = NO;
    }
    
    self.isFullscreen = !self.isFullscreen;
    [self setNeedsStatusBarAppearanceUpdate];
    NSLog(@"after container view frame: %@ \n", NSStringFromCGRect(self.playerContainerView.frame));

}

-(BOOL) prefersStatusBarHidden {
    return self.isFullscreen;
}

/*
 Provide now playing info like this:
 [nowPlayingInfo setObject:track.artistName forKey:MPMediaItemPropertyArtist];
 [nowPlayingInfo setObject:track.trackTitle forKey:MPMediaItemPropertyTitle];
 */
- (void)playerGatherNowPlayingInfo:(NSMutableDictionary *)nowPlayingInfo {
    NSLog(@"playerGatherNowPlayingInfo : %@", nowPlayingInfo);
}


- (void)playerFailedToLoadAssetWithError:(NSError *)error {
    NSLog(@"playerFailedToLoadAssetWithError : %@", error);
}
- (void)playerDidPlay {
    NSLog(@"playerDidPlay");
}
- (void)playerDidPause {
    NSLog(@"playerDidPause");
}
- (void)playerDidStop {
    NSLog(@"playerDidStop");
}
- (void)playerDidPlayToEndTime {
    NSLog(@"playerDidPlayToEndTime");
}
- (void)playerFailedToPlayToEndTime {
    NSLog(@"playerFailedToPlayToEndTime");
}
- (void)playerPlaybackStalled {
    NSLog(@"playerPlaybackStalled");
}
- (void)playerDoneButtonTouched {
    NSLog(@"playerDoneButtonTouched");
}
- (void)playerRequireNextTrack {
    NSLog(@"playerRequireNextTrack");
}
- (void)playerRequirePreviousTrack {
    NSLog(@"playerRequirePreviousTrack");
}
@end


