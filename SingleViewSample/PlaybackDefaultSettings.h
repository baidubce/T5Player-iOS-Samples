//
//  PlaybackDefaultSettings.h
//
//  Created by hudapeng on 12/7/15.
//  Copyright © 2015 Baidu. All rights reserved.
//

// Configuration of playback kit behavior
// defaults to NO
#define CYBERPLAYER_BACKGROUND_PLAYBACK_ENABLE  @"cyberplayer.isBackgroundPlaybackEnabled"

// defaults to 3 seconds
#define CYBERPLAYER_DELAY_BEFORE_HIDING_VIEW_ON_IDLE @"cyberplayer.delayBeforeHidingViewsOnIdle";

// defaults to YES
#define CYBERPLAYER_FULL_SCREEN_EXPAND_SHRINK_BUTTON_ENABLE @"cyberplayer.isShowFullscreenExpandAndShrinkButtonsEnabled"

// defaults to YES
#define CYBERPLAYER_HIDE_CONTROLS_ON_IDLE @"cyberplayer.isHideControlsOnIdleEnabled"

#define CYBERPLAYER_ACCESS_KEY @"cyberplayer.AccessKey"

#define CYBERPLAYER_NIB_FILE_NAME @"cyberplayer.nibfilename"

#pragma mark - UI Macro

#define SCREEN_HEIGHT                    MAX([[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height)
#define SCREEN_WIDTH                     MIN([[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height)
#define Screen35in                      (SCREEN_HEIGHT==480)
#define Screen40in                      (SCREEN_HEIGHT==568)
#define Screen47in                      (SCREEN_HEIGHT==667)
#define Screen55in                      (SCREEN_HEIGHT==736)
#define iPad                            (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define iPadPro                         ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) && (ScreenHeight==1366))


