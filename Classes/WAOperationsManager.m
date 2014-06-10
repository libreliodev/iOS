//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WAOperationsManager.h"

static WAOperationsManager *sharedMyManager = nil;

@implementation WAOperationsManager

@synthesize defaultQueue;

#pragma mark Singleton Methods
+ (id)sharedManager {
	@synchronized(self) {
		if(sharedMyManager == nil)
			sharedMyManager = [[super allocWithZone:NULL] init];
	}
	return sharedMyManager;
}
+ (id)allocWithZone:(NSZone *)zone {
	return [[self sharedManager] retain];
}
- (id)copyWithZone:(NSZone *)zone {
	return self;
}
- (id)retain {
	return self;
}
- (NSUInteger)retainCount {
	return UINT_MAX; //denotes an object that cannot be released
}
- (oneway void)release {
	// never release
}
- (id)autorelease {
	return self;
}
- (id)init {
	if (self = [super init]) {
		defaultQueue = [[NSOperationQueue alloc] init];
		defaultQueue.maxConcurrentOperationCount = 1;

	}
	return self;
}


- (void)dealloc {
	// Should never be called, but just here for clarity really.
	[defaultQueue release];
	[super dealloc];
}

@end