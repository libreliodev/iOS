#import "WAKMLParser.h"
#import "WAUtilities.h"

#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.h"



@implementation WAKMLParser

@synthesize intParam;


- (NSString *) urlString
{
    return urlString;
}

- (void) setUrlString: (NSString *) theString
{
    urlString = [[NSString alloc]initWithString: theString];
	NSData * feedData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathOfFileWithUrl:urlString]];
	doc = xmlReadMemory([feedData bytes], [feedData length], "", NULL, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
	xpathCtx = xmlXPathNewContext(doc); 
	xmlXPathRegisterNs(xpathCtx, (xmlChar *)"k", (xmlChar *)"http://earth.google.com/kml/2.2");
}

- (void)dealloc
{
	xmlXPathFreeContext(xpathCtx); 
	xmlFreeDoc(doc); 
	[urlString release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark XPath functions



- (NSString*) getStringForXPath:(xmlChar *)xPathExp{
	xmlXPathObjectPtr xPathMainTitle = xmlXPathEvalExpression(xPathExp, xpathCtx);//Find all entries
	if (xPathMainTitle->nodesetval){
		NSString *ret = [NSString stringWithCString:(const char *)xPathMainTitle->nodesetval->nodeTab[0]->children->content encoding:NSUTF8StringEncoding];
		xmlXPathFreeObject(xPathMainTitle);
		return ret;
	}
	else {
		xmlXPathFreeObject(xPathMainTitle);
		return nil;
		
	}

	
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
	return ret;
	
}




#pragma mark -
#pragma mark Parser protocol



- (UIImage *) getCoverImage{
    return nil;
}
- (NSString*) getDataAtRow:(int)row forDataCol:(DataCol)dataCol{
	NSString * xPathBegin = [NSString stringWithFormat: @"//k:kml/k:Document/k:Placemark[position()=%i]",row];
	switch (dataCol) {
		case DataColTitle:{
			NSString * xPath = [xPathBegin stringByAppendingString:@"/k:name"];
			NSString * ret = [self getStringForXPath:(xmlChar *)[xPath cStringUsingEncoding: NSASCIIStringEncoding ]];
			return ret;
		}
		case DataColSubTitle:{
			//If waSubtitle is specified, take its value, otherwise, return nil
			NSString * xPath = [xPathBegin stringByAppendingString:@"/k:ExtendedData/k:Data[@name='waSubtitle']/k:value"];
			NSString * ret = [self getStringForXPath:(xmlChar *)[xPath cStringUsingEncoding: NSASCIIStringEncoding ]];
			if (!ret) ret= nil;
			return ret;
		}
		case DataColDetailLink:{
			//If waLink is specified, take its value, otherwise, link to detailview
			NSString * xPath = [xPathBegin stringByAppendingString:@"/k:ExtendedData/k:Data[@name='waLink']/k:value"];
			NSString * ret = [self getStringForXPath:(xmlChar *)[xPath cStringUsingEncoding: NSASCIIStringEncoding ]];
			if (!ret){
				ret = [urlString urlByAddingParameterInUrlStringWithKey:@"waline" withValue:[NSString stringWithFormat:@"%i",row]];
				ret = [urlString urlByAddingParameterInUrlStringWithKey:@"waview" withValue:@"14"];
				ret = [urlString urlByAddingParameterInUrlStringWithKey:@"warect" withValue:@"full"];
			}
			return ret;
		}
		case DataColImage: {
			//If waThumbnail is specified, take its value, otherwise, return nil
			NSString * xPath = [xPathBegin stringByAppendingString:@"/k:ExtendedData/k:Data[@name='waThumbnail']/k:value"];
			NSString * ret = [self getStringForXPath:(xmlChar *)[xPath cStringUsingEncoding: NSASCIIStringEncoding ]];
			if (!ret) ret= nil;
			return ret;
			
		}
		case DataColHTML:{
			NSString * xPath = [xPathBegin stringByAppendingString:@"/k:name"];
			NSString * title = [self getStringForXPath:(xmlChar *)[xPath cStringUsingEncoding: NSASCIIStringEncoding ]];

			xPath = [xPathBegin stringByAppendingString:@"/k:description"];
			NSString * htmlBody = [self getStringForXPath:(xmlChar *)[xPath cStringUsingEncoding: NSASCIIStringEncoding ]];

			//Get the template html
			NSString * templatePath = [[NSBundle mainBundle] pathOfFileWithUrl:[WAUtilities urlByChangingExtensionOfUrlString:urlString toSuffix:@".html"]];
			if (!templatePath) templatePath = [[NSBundle mainBundle] pathOfFileWithUrl:@"HTMLTemplate.html"];
			NSString * templateString = [NSString stringWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:nil];
			NSString * ret = [NSString stringWithFormat:templateString,title,htmlBody]; 
			return ret;
		}
			
		case DataColLongitude:{
			NSString * xPath = [xPathBegin stringByAppendingString:@"/k:Point/k:coordinates"];
			NSString * coords = [self getStringForXPath:(xmlChar *)[xPath cStringUsingEncoding: NSASCIIStringEncoding ]];
			NSArray * parts = [coords componentsSeparatedByString:@","];
			NSString * ret = [parts objectAtIndex:0];
			return ret;
		}
		case DataColLatitude:{
			NSString * xPath = [xPathBegin stringByAppendingString:@"/k:Point/k:coordinates"];
			NSString * coords = [self getStringForXPath:(xmlChar *)[xPath cStringUsingEncoding: NSASCIIStringEncoding ]];
			NSArray * parts = [coords componentsSeparatedByString:@","];
			NSString * ret = [parts objectAtIndex:1];
			return ret;
		}
		default:
			return nil;
	}
}
- (int) countData{
	xmlXPathObjectPtr xpathEntries = xmlXPathEvalExpression((xmlChar *)"//k:kml/k:Document", xpathCtx);//Find all entries
	int size = xpathEntries->nodesetval->nodeNr;
    //SLog(@"Found %i placemarks",size);

	return size;
	
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
    
    return 0;
}

- (NSString*) getDataAtRow:(int)row forQueryDic:(NSDictionary*)queryDic forDataCol:(DataCol)dataCol{
    
	/*NSString * ret = [self getStringForXPath:(xmlChar *)[queryString cStringUsingEncoding: NSASCIIStringEncoding ]];*/
	return nil;
}

- (NSArray*) getRessources{
    return nil;
}

- (CGFloat) cacheProgress{
    return 1.0 ;
    
}



@end
