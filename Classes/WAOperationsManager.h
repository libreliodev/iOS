//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.



//Singleton class, based on http://iphone.galloway.me.uk/iphone-sdktutorials/singleton-classes/


#import <foundation/Foundation.h>

@interface WAOperationsManager : NSObject {
    NSOperationQueue * defaultQueue;
	
}

@property (nonatomic, retain) NSOperationQueue * defaultQueue;

+ (id)sharedManager;


@end