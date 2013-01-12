//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import <UIKit/UIKit.h>
#import "WAModuleProtocol.h"
#import "WAParserProtocol.h"

/**
 *	@warning not finalized
 **/
@interface WAZoomImage : UIView <WAModuleProtocol,UIScrollViewDelegate> {
	NSString *urlString;
	UIViewController* currentViewController;
    
    UIScrollView *imageScrollView;
    UIImageView *imageView;
    UIImage *image;
    NSURLConnection *connection;
    NSMutableData *data;
    
	
	
}


@property (nonatomic, retain) UIScrollView *imageScrollView;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIActivityIndicatorView *activity;


- (void)loadImageFromURLString:(NSString *)theUrlString;


@end
