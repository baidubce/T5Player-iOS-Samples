//
//  ViewController.m
//  SingleViewSample
//
//  Created by hudapeng on 11/30/15.
//  Copyright © 2015 Baidu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet DZVideoPlayerViewControllerContainerView *playbackContainerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // after create container view, customize the internal playback view
    // get configuration from playbackContainerView. instantiate DZVideoPlayerViewController and add constraints.
    // set video address and AK if need
    
    DZVideoPlayerViewController *videoPlayerViewController = self.playbackContainerView.videoPlayerViewController;
    videoPlayerViewController.delegate = self;

    NSString* videoAddress = @"http://txj-bucket.bj.bcebos.com/hls/test_commonkey.m3u8";
//    NSString* videoAddress = @"http://hz01-plattech-rdqa00.hz01.baidu.com:8008/caselist/华尔街之狼.m4v";
    NSURL* remoteVideo = [[NSURL alloc] initWithString:videoAddress];

    NSURL* localVideo = [[NSBundle mainBundle] URLForResource:@"Star_Wars" withExtension:@"mp4"];
    videoPlayerViewController.videoURL = remoteVideo;
    
//    NSString* ak = @"sssssssssssssssssssssssssss";
//    [videoPlayerViewController.cyberPlayer setAccessKey:ak];
//    [videoPlayerViewController prepareAndPlayAutomatically:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"ViewController viewWillDisappear(), \n %@", [NSThread callStackSymbols]);
}

- (void) dealloc {
    NSLog(@"ViewController dealloc(), \n %@", [NSThread callStackSymbols]);
}
@end


@implementation ViewController (PlaybackDelegate)

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

/*
 Check isFullscreen property and animate view controller's view appropriately.
 If you don't want to support fullscreen please provide custom user interface which does not have fullscreenExpandButton and fullscreenShrinkButton, or hide the buttons in default user interface.
 */
- (void)playerDidToggleFullscreen {
    NSLog(@"playerDidToggleFullscreen");
}

/*
 Provide now playing info like this:
 [nowPlayingInfo setObject:track.artistName forKey:MPMediaItemPropertyArtist];
 [nowPlayingInfo setObject:track.trackTitle forKey:MPMediaItemPropertyTitle];
 */
- (void)playerGatherNowPlayingInfo:(NSMutableDictionary *)nowPlayingInfo {
    NSLog(@"playerGatherNowPlayingInfo : %@", nowPlayingInfo);
}

@end


