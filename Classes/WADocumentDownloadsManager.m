//
//  WAIssuesManager.m
//  Librelio
//
//

#import "WADocumentDownloadsManager.h"
#import "NSString+WAURLString.h"


static WADocumentDownloadsManager *sharedWAIssuesManager = nil;

@implementation WADocumentDownloadsManager

@synthesize issuesQueue;

#pragma mark Singleton Methods
+ (id)sharedManager {
	@synchronized(self) {
		if(sharedWAIssuesManager == nil)
			sharedWAIssuesManager = [[super allocWithZone:NULL] init];
	}
    //SLog(@"sharedManager in singleton %@,%@",sharedWAIssuesManager,[sharedWAIssuesManager issuesQueue]);
	return sharedWAIssuesManager;
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
		issuesQueue = [[NSMutableArray alloc] init];
		
	}
	return self;
}
- (void)dealloc {
	// Should never be called, but just here for clarity really.
	[issuesQueue release];
	[super dealloc];
}

- (BOOL) isAlreadyInQueueIssueWithUrlString:(NSString*)theString{
    NSString * noArgsUrlString = [theString noArgsPartOfUrlString];
    for (WADocumentDownloader* issue in issuesQueue){
        if ([noArgsUrlString isEqualToString:[[issue urlString] noArgsPartOfUrlString]]) return YES;
    }
    return NO;
}

- (WADocumentDownloader*) issueWithUrlString:(NSString*)theString{
    NSString * noArgsUrlString = [theString noArgsPartOfUrlString];
    for (WADocumentDownloader* issue in issuesQueue){
        if ([noArgsUrlString isEqualToString:[[issue urlString] noArgsPartOfUrlString]]) return issue;
    }
    return nil;
}

@end
