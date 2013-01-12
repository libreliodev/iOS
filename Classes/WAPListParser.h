//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.

#import "WAParserProtocol.h"

@interface WAPListParser : NSObject <WAParserProtocol> {
	
	NSString * urlString;
	NSArray *dataArray; 
    NSDictionary * headerDic;
    int intParam;
	
	
}

@property (nonatomic, retain)  NSArray *dataArray;
@property (nonatomic, retain)  NSDictionary * headerDic;



@end
