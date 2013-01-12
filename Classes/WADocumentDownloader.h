//
//  WAIssueDownloader.h
//  Librelio
//
//  Copyright (c) 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WAParserProtocol.h"



typedef enum {
	AuthenticationTypePassword,
	AuthenticationTypeAppStore
} AuthenticationType;

/**!
 Downloads documents, with multiple resources
 */
@interface WADocumentDownloader : NSObject <NSURLConnectionDelegate>
 {
    NSString *urlString;
    NSObject <WAParserProtocol> * parser;
	NSString *currentUrlString;
	NSMutableData *receivedData;
	NSFileHandle *handle;
	NSNumber * filesize;
	NSArray * nnewResourcesArray;
	NSMutableArray * mutableResourcesArray;
	NSArray * oldResourcesArray;
    NSString *currentMessage;
     CGFloat currentProgress;

    
}
@property (nonatomic, retain)	NSString *urlString;
@property (nonatomic, retain) NSObject <WAParserProtocol> * parser;
@property (nonatomic, retain)	NSString *currentUrlString;
@property (nonatomic, retain)	NSMutableData *receivedData;
@property (nonatomic, retain)	NSFileHandle *handle;
@property (nonatomic,retain) NSNumber * filesize;
@property (nonatomic,retain) NSArray * nnewResourcesArray;
@property (nonatomic,retain) NSMutableArray * mutableResourcesArray;//An array with the url strings of all resources that need to be downloaded
@property (nonatomic,retain) NSArray * oldResourcesArray;
@property (nonatomic,retain) NSString *currentMessage;
@property (nonatomic,assign) CGFloat currentProgress;

- (AuthenticationType) getAuthenticationType;
- (void) downloadMainFile;
- (void) didDownloadMainFile;
- (void) downloadNextResource;
- (void) didDownloadAllResources;
- (void) notifyDownloadFinished;
- (void)didReceiveNotModifiedHeaderForConnection:(NSURLConnection *)connection ;
- (void) deleteUnusedOldResources;

- (void) launchConnectionWithUrlString:completeUrl;

- (void) didEndDrawPageOperationWithNotification:(NSNotification *) notification;



@end
