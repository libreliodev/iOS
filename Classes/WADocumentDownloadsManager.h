
//  Copyright (c) 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WADocumentDownloader.h"


/**!
 @description: A singleton to mimic NewsStand on iOS4, also used for non magazine documents in iOS5. Manages the download of documents, eg multiple files
 */
@interface WADocumentDownloadsManager : NSObject {
	NSMutableArray		*issuesQueue;
}

@property (nonatomic, retain) NSMutableArray *issuesQueue;

+ (id)sharedManager;
- (BOOL) isAlreadyInQueueIssueWithUrlString:(NSString*)theString;
- (WADocumentDownloader*) issueWithUrlString:(NSString*)theString;

@end