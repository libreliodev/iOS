//
//  WABarButtonItemWithLink.m
//  Librelio
//
//  Copyright (c) 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import "WABarButtonItemWithLink.h"

@implementation WABarButtonItemWithLink

@synthesize link;

- (void)dealloc {
	[link release];
    [super dealloc];
	
}

@end
