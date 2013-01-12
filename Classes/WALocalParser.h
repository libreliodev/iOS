//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.

#import "WAParserProtocol.h"



@interface WALocalParser : NSObject <WAParserProtocol>{
	
	NSString * urlString;
	NSMutableArray *dataArray; 
    int intParam;
	
	
}

@property (nonatomic, retain)  NSMutableArray *dataArray;



@end
