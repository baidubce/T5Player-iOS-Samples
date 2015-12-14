//
//  CyberPlayerViewControllerDelegate.h
//
//  Created by hudapeng on 12/7/15.
//  Copyright © 2015 Baidu. All rights reserved.

#import <Foundation/Foundation.h>

@protocol CyberPlayerViewControllerDelegate <NSObject>

@optional

- (void)playerFailedToLoadAssetWithError:(NSError *)error;
- (void)playerDidPlay;
- (void)playerDidPause;
- (void)playerDidStop;
- (void)playerDidPlayToEndTime;
- (void)playerFailedToPlayToEndTime;
- (void)playerPlaybackStalled;
- (void)playerDoneButtonTouched;


- (void)playerRequireNextTrack;
- (void)playerRequirePreviousTrack;

/*
 Check isFullscreen property and animate view controller's view appropriately.
 If you don't want to support fullscreen please provide custom user interface which does not have fullscreenExpandButton and fullscreenShrinkButton, or hide the buttons in default user interface.
 */
- (void)playerToggleFullscreen;

/*
 Provide now playing info like this:
 [nowPlayingInfo setObject:track.artistName forKey:MPMediaItemPropertyArtist];
 [nowPlayingInfo setObject:track.trackTitle forKey:MPMediaItemPropertyTitle];
 */
- (void)playerGatherNowPlayingInfo:(NSMutableDictionary *)nowPlayingInfo;
@end
