//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import <UIKit/UIKit.h>
#import "WAModuleProtocol.h"
#import <MediaPlayer/MediaPlayer.h>



@interface WAVideoView : UIView <WAModuleProtocol> {
	NSString *urlString;
	UIViewController* currentViewController;
    BOOL      playFullScreen;
	MPMoviePlayerViewController * movieViewController;
}
@property (assign) BOOL playFullScreen;
@property (nonatomic, retain) MPMoviePlayerViewController * movieViewController;

- (void) didStopMovie;

@end
