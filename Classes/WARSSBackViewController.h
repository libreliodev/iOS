//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.

#import <UIKit/UIKit.h>
#import "WARSSViewController.h"


@interface WARSSBackViewController : UIViewController {
	NSString *URLString;
	UIActivityIndicatorView *activityIndicator;
	WARSSViewController *rssTableViewController;
	NSMutableData *feedData;


}
@property (nonatomic, retain) WARSSViewController *rssTableViewController;
@property (nonatomic, retain) NSString *URLString;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) NSMutableData *feedData;


@end
