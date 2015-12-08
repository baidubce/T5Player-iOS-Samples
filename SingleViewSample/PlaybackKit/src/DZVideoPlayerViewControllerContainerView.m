//
//  DZVideoPlayerViewControllerContainerView.m
//
//

#import "DZVideoPlayerViewControllerContainerView.h"
#import "DZVideoPlayerViewController.h"


@interface DZVideoPlayerViewControllerContainerView ()

- (void)initPlaybackViewController;

@end



@implementation DZVideoPlayerViewControllerContainerView

- (void)awakeFromNib {
    [super awakeFromNib];
    // sync nib file name
    NSLog(@"DZVideoPlayerViewControllerContainerView.awakeFromNib");
    NSLog(@"nibNameToInitControllerWith = %@", self.nibNameToInitControllerWith);
    NSLog(@"style = %li", self.style);
    NSLog(@"ak = %@", self.ak);
    
    if (!self.nibNameToInitControllerWith) {
        NSString *classString = NSStringFromClass([DZVideoPlayerViewController class]);
        switch (self.style) {
            case DZVideoPlayerViewControllerStyleDefault:
                self.nibNameToInitControllerWith = classString;
                break;
                
            case DZVideoPlayerViewControllerStyleSimple:
                self.nibNameToInitControllerWith = [NSString stringWithFormat:@"%@_%@", classString, @"simple"];
                break;
                
            default:
                self.style = DZVideoPlayerViewControllerStyleDefault;
                self.nibNameToInitControllerWith = classString;
                break;
        }
    }

    [self initPlaybackViewController];
}

/*
 * Instantiate videoPlayerViewController with user defined style or nib
 * Bind playback view with container view's size
 */
- (void)initPlaybackViewController {
    NSLog(@"DZVideoPlayerViewControllerContainerView create PlaybackViewController with nib: %@", self.nibNameToInitControllerWith);
    NSBundle *bundle = [DZVideoPlayerViewController bundle];
    
    // init videoPlayerViewController with user defined nib.
    self.videoPlayerViewController =
         [[DZVideoPlayerViewController alloc] initWithNibName:self.nibNameToInitControllerWith
                                                       bundle:bundle
                                                    parrent:self];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    // videoPlayerViewController is loaded from nib, fit its size to container view.
    // set playback's frame to the containers's bounds
    [self addSubview:self.videoPlayerViewController.view];
    
    // bind the size of player's view to parrent view
    NSDictionary *viewsDictionary = @{@"playerView":self.videoPlayerViewController.view, @"parrentView":self};
    NSMutableArray *constraintsArray = [[NSMutableArray alloc] init];
    [constraintsArray addObjectsFromArray:[NSLayoutConstraint
                                           constraintsWithVisualFormat:@"H:[playerView(==parrentView)]"
                                           options:0 metrics:nil
                                           views:viewsDictionary]];
    [constraintsArray addObjectsFromArray:[NSLayoutConstraint
                                           constraintsWithVisualFormat:@"V:[playerView(==parrentView)]"
                                           options:0 metrics:nil
                                           views:viewsDictionary]];
    [self addConstraints:constraintsArray];

}

@end
