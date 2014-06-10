//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WAFileDownloadsManager.h"

static WAFileDownloadsManager *sharedDownloadManager = nil;

@implementation WAFileDownloadsManager

@synthesize downloadQueue;

#pragma mark Singleton Methods
+ (id)sharedManager {
	@synchronized(self) {
		if(sharedDownloadManager == nil)
			sharedDownloadManager = [[super allocWithZone:NULL] init];
	}
    //SLog(@"sharedManager in WAFileDownloadsManager:%@",[sharedDownloadManager downloadQueue]);

	return sharedDownloadManager;
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
- (id)autorelease {
	return self;
}
- (id)init {
	if (self = [super init]) {
		downloadQueue = [[NSMutableArray alloc] init];
		
	}
	return self;
}
- (void)dealloc {
	// Should never be called, but just here for clarity really.
	[downloadQueue release];
	[super dealloc];
}

@end