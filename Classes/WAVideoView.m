//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WAVideoView.h"
#import "WAUtilities.h"
#import "WAModuleViewController.h"
#import "WAOperationsManager.h"
#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.h"
//https://github.com/libreliodev/iOS/issues/163
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>


@interface WAVideoView() {
    AVPlayerViewController *avPlayerViewController;
}

@property (nonatomic, retain) AVPlayerViewController *avPlayerViewController;

@end

@implementation WAVideoView

@synthesize currentViewController,playFullScreen;

/**	@property The MPMoviePlayerViewController of the video module
 *	@brief Use a MPMoviePlayerViewController see http://stackoverflow.com/questions/3915076/mpmovieplayercontroller-throws-errors-only-in-universal-app
 **/
@synthesize movieViewController;


- (NSString *) urlString
{
    return urlString;
}

- (void) setUrlString: (NSString *) theString
{
    urlString = [[NSString alloc]initWithString: theString];
    NSString * rectString = [urlString valueOfParameterInUrlStringforKey:@"warect"];
    
    //Stop the queue in order to avoid memory issues
    [[[WAOperationsManager sharedManager] defaultQueue]setSuspended:YES];
    
    //Check whether playf full screen is required
    playFullScreen=NO;
    if ([rectString isEqualToString:@"full"]) playFullScreen=YES;
    
    
    NSRange httpRange = [urlString rangeOfString :@"http"];
    NSURL * url = [NSURL URLWithString:urlString];
    
    if (httpRange.location == NSNotFound){
        NSString * path = [[NSBundle mainBundle] pathOfFileWithUrl:urlString];
        if (path) url = [NSURL fileURLWithPath:path];
        
    }
    
    ///Modified for fixing 163
    
    if (url){
        
        if (playFullScreen){
            //Fix: https://github.com/libreliodev/iOS/issues/163
            if (NSClassFromString(@"AVPlayerViewController")) {
                AVPlayer *player = [[AVPlayer alloc] initWithURL:url];
                AVPlayerViewController *playerController = [[AVPlayerViewController alloc] init];
                playerController.player = player;
                [currentViewController presentViewController:playerController animated:YES completion:^{
                    [playerController.player play];
                }];
                player = nil;
            } else {
                ///Since we are still using iOS 7 as deployment target we can't avoid this.
                [self registerMPMoviePlayerNotification];
                MPMoviePlayerViewController * movieViewController2 = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
                [currentViewController presentMoviePlayerViewControllerAnimated:movieViewController2];
            }
         }
        else{
            if (NSClassFromString(@"AVPlayerViewController")) {
                ///Todo - Something similar here
                //https://github.com/libreliodev/iOS/issues/163
                
                AVPlayerViewController *playerViewController =
                [[AVPlayerViewController alloc] init];
                playerViewController.player = [AVPlayer playerWithURL:url];
                playerViewController.view.frame = self.bounds;
                [self addSubview:playerViewController.view];
                self.autoresizesSubviews = TRUE;
                self.avPlayerViewController = playerViewController;
                [self.avPlayerViewController.player play];
            } else {
                [self registerMPMoviePlayerNotification];
                movieViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
                movieViewController.moviePlayer.controlStyle =  MPMovieControlStyleEmbedded;
                movieViewController.moviePlayer.view.frame = CGRectMake (0,0,self.frame.size.width,self.frame.size.height);
                movieViewController.moviePlayer.view.backgroundColor = [UIColor blackColor];
                movieViewController.moviePlayer.backgroundView.backgroundColor = [UIColor blackColor];
                movieViewController.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
                movieViewController.moviePlayer.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin);
                [self addSubview:movieViewController.moviePlayer.view];
                [movieViewController.moviePlayer play];
            }
        }
        //SLog(@"Did start playing");
        
        
        
    }
    
    
    
}


- (void)registerMPMoviePlayerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStopMovie) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
}


- (void)registerAVPlayerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieStopped) name:AVPlayerItemDidPlayToEndTimeNotification object:self.avPlayerViewController.player.currentItem];
}


- (void)movieStopped:(NSNotification *)aNotification {
    ///Equivalent to below method.
    //When full screen & status of video is either unknown or failed, remove video view.
    if ((playFullScreen)&&(avPlayerViewController.player.currentItem.status != AVPlayerItemStatusReadyToPlay)) {
        [self removeFromSuperview];
    }
}


- (void) didStopMovie{
    //SLog(@"Did stop movie");
    if ((playFullScreen)&&(movieViewController.moviePlayer.playbackState==MPMoviePlaybackStateStopped)) [self removeFromSuperview];//This will deallocate this instance
    
}
- (void)dealloc {
    //SLog(@"Will dealloc");
    ///Fix for 163
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (avPlayerViewController) {
        [avPlayerViewController.player pause];
        [avPlayerViewController release];
        avPlayerViewController = nil;
    }
    
    if (movieViewController) {
        [movieViewController.moviePlayer stop];
        [movieViewController release];
        movieViewController = nil;
    }
    [urlString release];
    [super dealloc];
}

#pragma mark -
#pragma mark ModuleView protocol

- (void)moduleViewWillAppear:(BOOL)animated{
}
- (void) moduleViewDidAppear{
}

- (void) moduleViewWillDisappear:(BOOL)animated{
    ///Fix for 163
    if (movieViewController) {
        [movieViewController.moviePlayer pause];
    }
    
    if (self.avPlayerViewController) {
        [self.avPlayerViewController.player pause];
    }
}



- (void) moduleWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
}

- (void) moduleWillAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
}

- (void) jumpToRow:(int)row{
    
}


@end

