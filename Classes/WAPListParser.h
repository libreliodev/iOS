//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.

#import "WAParserProtocol.h"
#import "StoreKit/StoreKit.h"

typedef enum {
    Needed,
    Requested,
    Downloaded,
    NotNeeded
} ExtraInformationStatus;


@interface WAPListParser : NSObject <WAParserProtocol,SKProductsRequestDelegate> {
	
	NSString * urlString;
	NSMutableArray *dataArray;
    NSDictionary * headerDic;
    int intParam;
    ExtraInformationStatus extraInfoStatus;
	
	
}

@property (nonatomic, retain)  NSMutableArray *dataArray;
@property (nonatomic, retain)  NSDictionary * headerDic;



@end
