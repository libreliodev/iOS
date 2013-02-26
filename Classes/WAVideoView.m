//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WAVideoView.h"
#import "WAUtilities.h"
#import "WAModuleViewController.h"
#import "WAOperationsManager.h"
#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.h"



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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStopMovie) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
	
	
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
	
	if (url){
			
		
			movieViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
			
			if (playFullScreen){
				[currentViewController presentMoviePlayerViewControllerAnimated:movieViewController];
			}
			else{
                movieViewController.moviePlayer.controlStyle =  MPMovieControlStyleEmbedded;

                movieViewController.moviePlayer.view.frame = CGRectMake (0,0,self.frame.size.width,self.frame.size.height);
				movieViewController.moviePlayer.view.backgroundColor = [UIColor blackColor];
				movieViewController.moviePlayer.backgroundView.backgroundColor = [UIColor blackColor];
				movieViewController.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
				movieViewController.moviePlayer.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin);
				[self addSubview:movieViewController.moviePlayer.view];

			}
			
			[movieViewController.moviePlayer play];		
        //SLog(@"Did start playing");
			
		
		
	}
	
	

}



- (void) didStopMovie{
	//SLog(@"Did stop movie");
	if ((playFullScreen)&&(movieViewController.moviePlayer.playbackState==MPMoviePlaybackStateStopped)) [self removeFromSuperview];//This will deallocate this instance

}
- (void)dealloc {
    //NSLog(@"Will dealloc");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [movieViewController.moviePlayer stop];
	[movieViewController release];
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
   [movieViewController.moviePlayer pause];
}



- (void) moduleWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
}

- (void) moduleWillAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
}

- (void) jumpToRow:(int)row{
    
}


@end

