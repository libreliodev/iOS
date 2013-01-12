//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import <UIKit/UIKit.h>
#import "WAModuleProtocol.h"



@interface WAExternalView : UIView <UIAlertViewDelegate,WAModuleProtocol> {
	NSString *urlString;
	UIViewController* currentViewController;

	
}


@end
