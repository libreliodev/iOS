//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.



//Singleton class, based on http://iphone.galloway.me.uk/iphone-sdktutorials/singleton-classes/


#import <foundation/Foundation.h>

/**!
 @description: Manages the download of single files
 */

@interface WAFileDownloadsManager : NSObject {
	NSMutableArray		*downloadQueue;
}

@property (nonatomic, retain) NSMutableArray *downloadQueue;

+ (id)sharedManager;

@end