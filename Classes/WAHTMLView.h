//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.
// Although subclassing UIWebView is not recommended, it does not seem to be prohibited: see http://stackoverflow.com/questions/4893135/is-subclassing-uiwebview-frowned-upon

#import <UIKit/UIKit.h>
#import "WAModuleProtocol.h"
#import "WAParserProtocol.h"


@interface WAHTMLView : UIWebView <UIWebViewDelegate,WAModuleProtocol> {
	NSString *urlString;
	UIViewController* currentViewController;
	UIActivityIndicatorView*activityIndicator;
    UIImageView * splashView;
    UIBarButtonItem* backButton;
    NSString * previousPageTitle;
    NSString * currentPageTitle;
    UIBarButtonItem* forwardButton;
    NSObject <WAParserProtocol> *parser;

}
@property (nonatomic, retain)	UIActivityIndicatorView*activityIndicator;
@property (nonatomic, retain)	 UIImageView * splashView;
@property (nonatomic, retain)	 UIBarButtonItem* backButton;
@property (nonatomic, retain)	 NSString * previousPageTitle;
@property (nonatomic, retain)	 NSString * currentPageTitle;
@property (nonatomic, retain)	 UIBarButtonItem* forwardButton;
@property (nonatomic, retain) NSObject <WAParserProtocol> *parser;




@end
