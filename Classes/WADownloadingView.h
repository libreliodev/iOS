//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import <UIKit/UIKit.h>
#import <NewsstandKit/NewsstandKit.h>
#import "WAModuleViewController.h"


@interface WADownloadingView : UIView <UIAlertViewDelegate,UIGestureRecognizerDelegate> {
	NSString *urlString;
	WAModuleViewController* currentViewController;
	UILabel * messageLabel;
	UIProgressView * progressView;
	UIImageView * imageView;
    NSTimer * timer;	
    BOOL downloadOnlyMissingResources;
}
@property (assign) BOOL downloadOnlyMissingResources;
@property (nonatomic, retain)	NSString *urlString;
@property (nonatomic, assign) WAModuleViewController* currentViewController;
@property (nonatomic, retain)	UIProgressView * progressView;
@property (nonatomic, retain)	UIImageView * imageView;
@property (nonatomic, retain)	UILabel * messageLabel;

@property (nonatomic, retain) NSTimer * timer;

- (void) startDownloadWithoutNewsstand;
- (void) startDownloadWithNewsstand;


- (void) updateDisplay;

- (void) didFailIssueDownloadWithNotification:(NSNotification *) notification;
- (void) didSucceedIssueDownloadWithNotification:(NSNotification *) notification;

@end

