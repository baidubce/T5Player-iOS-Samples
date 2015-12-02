//
//  DZVideoPlayerViewControllerContainerView.m
//  Pods
//
//  Created by Denis Zamataev on 01/06/15.
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
    NSLog(@"style = %i", self.style);
    NSLog(@"ak = %@", self.ak);
    
    if (self.nibNameToInitControllerWith) {
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
    NSLog(@"DZVideoPlayerViewControllerContainerView initPlaybackViewController, \n %@", [NSThread callStackSymbols]);
    
    NSBundle *bundle = [DZVideoPlayerViewController bundle];
    
    // init videoPlayerViewController with user defined nib.
    self.videoPlayerViewController =
         [[DZVideoPlayerViewController alloc] initWithNibName:self.nibNameToInitControllerWith
                                                       bundle:bundle
                                                           ak:_ak];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    // set playback's frame to the containers's bounds
    self.videoPlayerViewController.view.frame = self.bounds;
    [self addSubview:self.videoPlayerViewController.view];
    
    // bind playback's frame to the containers's boundary
    NSDictionary *viewsDictionary = @{@"view":self.videoPlayerViewController.view};
    NSMutableArray *constraintsArray = [NSMutableArray new];
    [constraintsArray addObjectsFromArray:[NSLayoutConstraint
                                           constraintsWithVisualFormat:@"H:|[view]|"
                                           options:0 metrics:nil
                                           views:viewsDictionary]];
    [constraintsArray addObjectsFromArray:[NSLayoutConstraint
                                           constraintsWithVisualFormat:@"V:|[view]|"
                                           options:0 metrics:nil
                                           views:viewsDictionary]];

    [self addConstraints:constraintsArray];
    
}


@end

@implementation DZVideoPlayerViewControllerContainerView (Test)

- (instancetype)initWithStyle:(DZVideoPlayerViewControllerStyle)style {
    self = [super init];
    if (self) {
        self.style = style;
        [self initPlaybackViewController];
    }
    return self;
}

- (instancetype)initWithNibNameToInitControllerWith:(NSString *)nibNameToInitControllerWith {
    self = [super init];
    if (self) {
        self.nibNameToInitControllerWith = nibNameToInitControllerWith;
        [self initPlaybackViewController];
    }
    return self;
}

@end

