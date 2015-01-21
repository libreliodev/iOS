//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import <UIKit/UIKit.h>
#import "WAModuleProtocol.h"
#import "DFPBannerView.h"



@interface WAAdView : DFPBannerView <WAModuleProtocol,GADBannerViewDelegate>{

	NSString *urlString;
	UIViewController* currentViewController;
	
	
	
}


@end

