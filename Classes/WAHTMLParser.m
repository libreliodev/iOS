#import "WAHTMLParser.h"
#import "WAUtilities.h"
#import "NSBundle+WAAdditions.h"
#import "NSString+WAURLString.h"



@implementation WAHTMLParser


@synthesize intParam;



- (NSString *) urlString
{
    return urlString;
}

- (void) setUrlString: (NSString *) theString
{
    //SLog(@"Started HTML parser");
    urlString = [[NSString alloc]initWithString: theString];
     NSData * htmlData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathOfFileWithUrl:urlString]];
	doc = htmlReadMemory([htmlData bytes], [htmlData length], "", NULL, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
	xpathCtx = xmlXPathNewContext(doc); 
 }

- (void)dealloc
{
	xmlXPathFreeContext(xpathCtx); 
	xmlFreeDoc(doc); 
	[urlString release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Utility functions

- (NSString*) getStringForXPath:(xmlChar *)xPathExp{
	xmlXPathObjectPtr xPathMainTitle = xmlXPathEvalExpression(xPathExp, xpathCtx);//Find all entries
	NSString *ret = [NSString stringWithCString:(const char *)xPathMainTitle->nodesetval->nodeTab[0]->children->content encoding:NSUTF8StringEncoding];
	xmlXPathFreeObject(xPathMainTitle);
    ret = [ret stringByReplacingOccurrencesOfString:@"&#039;" withString:@"'"];//Hack
    ret = [ret stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];//Hack
	return ret;
	
}

- (NSString*) getStringForXPath:(xmlChar *)xPathExp2 inHtmlNodeForXpath:(xmlChar *)xPathExp1{
	//Get the HTML
	xmlXPathObjectPtr xpathObjHtml = xmlXPathEvalExpression(xPathExp1, xpathCtx);
	xmlChar *Html = (xmlChar *)xpathObjHtml->nodesetval->nodeTab[0]->children->content;
	//Create a new doc with the HTML and apply XPath expression
	xmlDocPtr htmlDoc = htmlReadDoc(Html, "", "utf-8", HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
	//In case coder needs to access html, here is how:
	/**xmlChar *xmlbuff;
	 int buffersize;
	 xmlDocDumpFormatMemory(htmlDoc, &xmlbuff, &buffersize, 1);
	 xmlFree(xmlbuff);**/
	xmlXPathContextPtr xpathCtx2 = xmlXPathNewContext(htmlDoc); 
	xmlXPathObjectPtr xpathImg = xmlXPathEvalExpression(xPathExp2, xpathCtx2);
	NSString* ret = nil; 
	if(xpathImg == NULL) {
	}
	else {
		if (xpathImg->nodesetval->nodeNr){
			xmlChar * cRet = xpathImg->nodesetval->nodeTab[0]->children->content;
			if (cRet) ret = [NSString stringWithCString:(const char *)cRet encoding:NSUTF8StringEncoding];
			
		}
		
	}
	xmlXPathFreeContext(xpathCtx2); 
	xmlXPathFreeObject(xpathObjHtml);
    ret = [ret stringByReplacingOccurrencesOfString:@"&#039;" withString:@"'"];//Hack
    ret = [ret stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];//Hack
	return ret;
	
}








#pragma mark -
#pragma mark Parser protocol



- (UIImage *) getCoverImage{
    return nil;
}
- (NSString*) getDataAtRow:(int)row forDataCol:(DataCol)dataCol{
    return nil;
}
- (int) countData{
	return 0;
	
}

- (void) deleteDataAtRow:(int)row{
	
}

- (void) startCacheOperations{
    
}


- (void) cancelCacheOperations{
    
}

- (BOOL) shouldCompleteDownloadResources{
    return NO;
}


- (NSString*) getHeaderForDataCol:(DataCol)dataCol{
    return nil;
}

- (int)countSearchResultsForQueryDic:(NSDictionary*)queryDic{
    
    return [self countData];//More general case to be implemented in the future
}

- (NSString*) getDataAtRow:(int)row forQueryDic:(NSDictionary*)queryDic forDataCol:(DataCol)dataCol{
    return nil;
}

- (NSArray*) getRessources{
    return nil;
}

- (CGFloat) cacheProgress{
    return 1.0 ;
    
}



@end



