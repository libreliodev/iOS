//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.
// Although subclassing UIWebView is not recommended, it does not seem to be prohibited: see http://stackoverflow.com/questions/4893135/is-subclassing-uiwebview-frowned-upon

#import <UIKit/UIKit.h>
#import "WAModuleProtocol.h"


@interface WAHTMLView : UIWebView <UIWebViewDelegate,WAModuleProtocol> {
	NSString *urlString;
	UIViewController* currentViewController;
	UIActivityIndicatorView*activityIndicator;
    UIImageView * splashView;
}
@property (nonatomic, retain)	UIActivityIndicatorView*activityIndicator;
@property (nonatomic, retain)	 UIImageView * splashView;

- (void) loadTabFile;


@end
