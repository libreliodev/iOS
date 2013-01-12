//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WAButtonWithLink.h"


@implementation WAButtonWithLink 

@synthesize link;

- (void)dealloc {
	[link release];
    [super dealloc];
	
}

@end
