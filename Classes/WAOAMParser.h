//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import "WAParserProtocol.h"

#import <libxml/xmlmemory.h>
#import <libxml/debugXML.h>
#import <libxml/HTMLtree.h>
#import <libxml/xmlIO.h>
#import <libxml/xinclude.h>
#import <libxml/catalog.h>
#import <libxml/xpathInternals.h>


@interface WAOAMParser : NSObject <WAParserProtocol> {
	
	NSString * urlString;
    int intParam;
	xmlDocPtr doc;
	xmlXPathContextPtr xpathCtx;
	
	
}

- (NSString*) getStringForXPath:(xmlChar *)xPathExp;


@end
