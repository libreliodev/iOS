//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.

#import "WAParserProtocol.h"

@interface WASQLiteParser : NSObject <WAParserProtocol> {
	
	NSString * urlString;
	NSMutableArray *dataArray; 
    int intParam;
    NSDictionary * currentQueryDic;
	
	
}

@property (nonatomic, retain)  NSMutableArray *dataArray;
@property (nonatomic, retain)  NSDictionary * currentQueryDic;

- (NSDictionary*) defaultQueryDic;
- (NSString*) getViewNameFromQueryString:(NSString*)queryString;
- (void) rebuildDataArray;

@end
