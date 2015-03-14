//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import <UIKit/UIKit.h>
#import "WAPDFParser.h"
#import "WATilingView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "WAParserViewProtocol.h"



@interface WAPDFParserView : UIImageView <WAParserViewProtocol>{
	
	NSObject <WAParserProtocol> *pdfDocument;
	int page;
	AVAudioPlayer *audioPlayer;
	UIActivityIndicatorView *activityIndicator;
	
	
}
@property (nonatomic, retain)	UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;

- (void) didChangeVisiblePageViewsWithNotification:(NSNotification *) notification;
- (void) didEndDrawPageOperationWithNotification:(NSNotification *) notification;




- (void) addButtonInRect:(CGRect)rect withLink:(NSString*)urlString atScale:(CGFloat)scale;
- (void) removeButtonsNotNeededForCurrentOrientation;
- (void) addButtons:(BOOL)forCurrentOrientationOnly;
- (BOOL) isOrientationFromUrlStringActive:(NSString*) urlString;

- (void) addTiledView;
- (void) increaseTiledViewDetail;

@end
