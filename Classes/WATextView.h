//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.

#import <Foundation/Foundation.h>
#import "WAModuleProtocol.h"


@interface WATextView : UITextView <WAModuleProtocol>{

	NSString *urlString;
    UIViewController* currentViewController;

	
}


@end
