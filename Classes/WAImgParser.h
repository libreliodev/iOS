//
//  WAImgParser.h
//  Librelio
//
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import <Foundation/Foundation.h>
# import "WAParserProtocol.h"

@interface WAImgParser: NSObject <WAParserProtocol> {
	
	NSString * urlString;
    int intParam;
	
	
}


@end
