//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import <Foundation/Foundation.h>

#import <libxml/xmlmemory.h>
#import <libxml/debugXML.h>
#import <libxml/HTMLtree.h>
#import <libxml/xmlIO.h>
#import <libxml/xinclude.h>
#import <libxml/catalog.h>
#import <libxml/xpathInternals.h>


@interface WARSSParser : NSObject <WAParserProtocol> {
	
	xmlDocPtr doc;
	xmlXPathContextPtr xpathCtx; 
    
    NSString * urlString;


}



@end
