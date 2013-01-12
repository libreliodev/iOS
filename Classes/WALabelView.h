//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.

#import <Foundation/Foundation.h>
#import "WAModuleProtocol.h"

/**
 *	@brief Legacy class
 **/
@interface WALabelView : UILabel <WAModuleProtocol> {

	NSString *urlString;
	UIViewController* currentViewController;

	
}


@end
