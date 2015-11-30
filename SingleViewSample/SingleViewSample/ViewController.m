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
    // Do any additional setup after loading the view, typically from a nib.
    DZVideoPlayerViewController *videoPlayerViewController = self.playbackContainerView.videoPlayerViewController;
    videoPlayerViewController.delegate = self;

    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"Star_Wars" withExtension:@"mp4"];
    NSString* videoAddress = @"http://mvod.sctv.com:60088/Features/test/shinyv/2015/08/27/d600878c_be8c_49ea_94c3_622ecf312928_676100.mp4";
//    NSString* videoAddress = @"http://hz01-plattech-rdqa00.hz01.baidu.com:8008/caselist/华尔街之狼.m4v";
    NSURL* videoURL = [[NSURL alloc] initWithString:videoAddress];

    videoPlayerViewController.videoURL = videoURL;
    [videoPlayerViewController prepareAndPlayAutomatically:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


@implementation ViewController (ControllerDelegate)

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


