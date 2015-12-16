//
//  CyberPlayerSettings.h
//
//  Created by hudapeng on 12/7/15.
//  Copyright © 2015 Baidu. All rights reserved.
//

/*
 * Bool value indicate whether to show control after some idle time
 * defaults value is NO
 */
#define CYBERPLAYER_SHOW_CONTROLS_ON_IDLE @"cyberplayer.isShowControlsOnIdle"

/*
 * Double value indicate the idle time in seconds before hiding control kits
 * defaults value is 3 seconds
 */
#define CYBERPLAYER_DELAY_BEFORE_HIDING_VIEW @"cyberplayer.delayBeforeHidingViewsOnIdle"

#define CYBERPLAYER_DEFAULT_DELAY_BEFORE_HIDING_VIEW 3.0

/*
 * Bool value indicate whether to hide FullScreen Expand and Shrink button
 * defaults value is NO
 */
#define CYBERPLAYER_HIDE_FULL_SCREEN_BUTTON @"cyberplayer.isHideFullscreenButtons"

/*
 * String value indicate Access Key which BCE generats for each account
 */
#define CYBERPLAYER_ACCESS_KEY @"cyberplayer.AccessKey"

/*
 * String value indicate Nib file names which defines the layout of cyberplayer control kit
 */
#define CYBERPLAYER_NIB_FILE_NAME @"cyberplayer.nibfilename"

/*
 *
 * Integer value indicate the video scaling mode in playback view
 * CBPMovieScalingModeNone,        // 无缩放
 * CBPMovieScalingModeAspectFit,   // 同比适配，某个方向会有黑边
 * CBPMovieScalingModeAspectFill,  // 同比填充，某个方向的显示内容可能被裁剪
 * CBPMovieScalingModeAspect_5_4,  // 5:4比例播放
 * CBPMovieScalingModeAspect_4_3,  // 4:3比例播放
 * CBPMovieScalingModeAspect_16_9, // 16:9比例播放
 * CBPMovieScalingModeFill         // 满屏填充，与原始视频比例不一致
 *
 * Default Value is CBPMovieScalingModeAspectFit
 */
#define CYBERPLAYER_SCALING_MODE @"cyberplayer.scalingMode"

/*
 * Bool value indicate whether to clear rendered picture after playback completion.
 * Default value is NO.
 */
#define CYBERPLAYER_SHOULD_CLEAR_RENDER @"cyberplayer.shouldAutoClearRender"


/*
 * Bool value indicate whether to seek accurately in mili-seconds. By default CyberPlay seek in seconds.
 * Default value is NO.
 */
#define CYBERPLAYER_ACCURATE_SEEK @"cyberplayer.accurateSeeking"

