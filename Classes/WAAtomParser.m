#import "WAAtomParser.h"
#import "WAUtilities.h"
#import "NSBundle+WAAdditions.h"
#import "NSString+WAURLString.h"



@implementation WAAtomParser


@synthesize intParam;



- (NSString *) urlString
{
    return urlString;
}

- (void) setUrlString: (NSString *) theString
{
    //SLog(@"Started Atom parser");
    urlString = [[NSString alloc]initWithString: theString];
	NSData * feedData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathOfFileWithUrl:urlString]];
    /*                         FIX : Issue #4
     /  arc4random_uniform expects a 32 bit integer as its argument.
     /  Adding a cast to an unsigned 32 bit integer to covert it.
     */
    doc = xmlReadMemory([feedData bytes], arc4random_uniform((uint32_t)[feedData length]), "", NULL, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
	xpathCtx = xmlXPathNewContext(doc); 
    xmlXPathRegisterNs(xpathCtx, (xmlChar *)"a", (xmlChar *)"http://www.w3.org/2005/Atom");
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
    NSString* ret = nil; 

	xmlXPathObjectPtr xpathObjHtml = xmlXPathEvalExpression(xPathExp1, xpathCtx);
    if (xpathObjHtml->nodesetval->nodeNr){
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

    }
	return ret;
	
}



- (NSDictionary*) getFeedDictionary {
	/*
     //Get the title of the feed
     NSString *feedTitle = [self getStringForXPath:(xmlChar *)[[proxyDic objectForKey:@"TitleXPath"]UTF8String]];
     
     //Get the icon of the feed
     NSString *feedIcon = [self getStringForXPath:(xmlChar *)[[proxyDic objectForKey:@"ImageXPath"]UTF8String]];
     
     //Get the baseURL of the feed
     NSString *baseURL = [self getStringForXPath:(xmlChar *)[[proxyDic objectForKey:@"BaseURLXPath"]UTF8String]];	
     //Get the entries
     xmlXPathObjectPtr xpathEntries = xmlXPathEvalExpression((xmlChar *)[[proxyDic objectForKey:@"ItemsXPath"]UTF8String], xpathCtx);//Find all entries
     */
	
	//Get the title of the feed
	NSString *feedTitle = [self getStringForXPath:(xmlChar *)"//a:feed/a:title"];
	
	//Get the icon of the feed
	NSString *feedIcon = [self getStringForXPath:(xmlChar *)"//a:feed/a:logo"];
	
	//Get the baseURL of the feed
	NSString *baseURL = [self getStringForXPath:(xmlChar *)"//a:feed/a:link/@href"];
	
	//Get the entries
	xmlXPathObjectPtr xpathEntries = xmlXPathEvalExpression((xmlChar *)"//a:feed/a:entry", xpathCtx);//Find all entries
	
    
	NSMutableArray *tempArray= [NSMutableArray array];
	
	if(xpathEntries == NULL) {
	}
	else {
		int size;
		int i;
		size = xpathEntries->nodesetval->nodeNr;
		for(i = 0; i < size; ++i) {
			NSMutableDictionary *tempDictionary = [NSMutableDictionary dictionary];
			xpathCtx->node = xpathEntries->nodesetval->nodeTab[i];//Change the context to the current node
			
			//Get the title 
			NSString *curTitle = [self getStringForXPath:(xmlChar *)".//a:title"];
			[tempDictionary setObject:curTitle forKey:@"ItemTextLabel"];
            
			//Get the link 
			NSString *curLink = [self getStringForXPath:(xmlChar *)".//a:link/@href"];
			NSString *completeLink = ([curLink hasPrefix:@"http://"])?curLink:[NSString stringWithFormat:@"%@%@",baseURL,curLink];
			[tempDictionary setObject:completeLink forKey:@"ItemLink"];
			
			//Get the date 
			NSString *curDate = [self getStringForXPath:(xmlChar *)".//a:published"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZ"];
			[tempDictionary setObject:curDate forKey:@"ItemDetailTextLabel"];
			
			//Get the first image in the HTML
			NSString* imageURL = [self getStringForXPath:(xmlChar *)"//@src" inHtmlNodeForXpath:(xmlChar *)".//a:content"];
			if (imageURL) [tempDictionary setObject:imageURL forKey:@"ImageURL"];
            
			//Get the first paragraph
			NSString* pString = [self getStringForXPath:(xmlChar *)"//a[text()]" inHtmlNodeForXpath:(xmlChar *)".//a:content"];
			if (([curTitle length]<2)&&(pString)) [tempDictionary setObject:pString forKey:@"ItemTextLabel"];//Hack for Facebook (and maybe other feeds) which often returns empty Title elements
			
			[tempArray addObject:tempDictionary];
			
			
			
			
			
		}
		
	}
	
	xmlXPathFreeObject(xpathEntries);
	NSDictionary * ret = [NSDictionary dictionaryWithObjectsAndKeys:feedTitle, @"HeaderTitle",feedIcon,@"HeaderIcon",tempArray,@"ItemsArray",nil];
	return (ret);
    
}






#pragma mark -
#pragma mark Parser protocol



- (UIImage *) getCoverImage{
    return nil;
}
- (NSString*) getDataAtRow:(int)row forDataCol:(DataCol)dataCol{
	NSString * xPathBegin = [NSString stringWithFormat: @"//a:feed/a:entry[position()=%i]",row];
	switch (dataCol) {
		case DataColTitle:{
			NSString * xPath = [xPathBegin stringByAppendingString:@"/a:title"];
			NSString * ret = [self getStringForXPath:(xmlChar *)[xPath cStringUsingEncoding: NSASCIIStringEncoding ]];
            
			//Get the first paragraph if Title element is empty
            //Hack for Facebook (and maybe other feeds) which often returns empty Title elements
            if ([ret length]<2){
                xPath = [xPathBegin stringByAppendingString:@"/a:content"];
                
                ret = [self getStringForXPath:(xmlChar *)"//a[text()]" inHtmlNodeForXpath:(xmlChar *)[xPath cStringUsingEncoding: NSASCIIStringEncoding ]];
              
            }
            
 			if (!ret) ret= nil;			
			return ret;
		}
            
 			
            
		case DataColDate:{
			NSString * xPath = [xPathBegin stringByAppendingString:@"/a:published"];
			NSString * ret = [self getStringForXPath:(xmlChar *)[xPath cStringUsingEncoding: NSASCIIStringEncoding ]];
            //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            //[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZ"];
			if (!ret) ret= nil;
			return ret;
		}
		case DataColImage: {
			//Get the first image in the HTML
			NSString * xPath = [xPathBegin stringByAppendingString:@"/a:content"];
			NSString* ret = [self getStringForXPath:(xmlChar *)"//@src" inHtmlNodeForXpath:(xmlChar *)[xPath cStringUsingEncoding: NSASCIIStringEncoding ]];
			if (!ret) ret= nil;
            
            //Use a local url to force image storage
            else {
                ret = [ret  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                //Use a local url to force image storage
                NSString * ext = [[ret noArgsPartOfUrlString] pathExtension];
                NSString * imageName = [NSString stringWithFormat:@"%@/img%lu.%@",[urlString nameOfFileWithoutExtensionOfUrlString],(unsigned long)[ret hash],ext];
                ret = [imageName urlByAddingParameterInUrlStringWithKey:@"waurl" withValue:ret];
                
            }
			return ret;
             
			
		}
        case DataColDetailLink:{
            //Get the link 
			NSString * xPath = [xPathBegin stringByAppendingString:@"/a:link/@href"];
			NSString * curLink = [self getStringForXPath:(xmlChar *)[xPath cStringUsingEncoding: NSASCIIStringEncoding ]];
            NSString * baseURL = [self getHeaderForDataCol:DataColDetailLink];
			NSString *ret = ([curLink hasPrefix:@"http://"])?curLink:[NSString stringWithFormat:@"%@%@",baseURL,curLink];
			if (!ret) ret= nil;
			return ret;
            
        }
		case DataColHTML:{
			NSString * xPath = [xPathBegin stringByAppendingString:@"/a:content"];
			NSString * ret = [self getStringForXPath:(xmlChar *)[xPath cStringUsingEncoding: NSASCIIStringEncoding ]];
			return ret;
		}
			
		default:
			return nil;
	}
}
- (int) countData{
	xmlXPathObjectPtr xpathEntries = xmlXPathEvalExpression((xmlChar *)"//a:feed/a:entry", xpathCtx);//Find all entries
	int size = xpathEntries->nodesetval->nodeNr;
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
    
    return [self countData];//More general case to be implemented in the future
}

- (NSString*) getDataAtRow:(int)row forQueryDic:(NSDictionary*)queryDic forDataCol:(DataCol)dataCol{
    
	/*NSString * ret = [self getStringForXPath:(xmlChar *)[queryString cStringUsingEncoding: NSASCIIStringEncoding ]];
	return ret;*/
    return nil;
}

- (NSArray*) getRessources{
     NSMutableArray *tempArray2= [NSMutableArray array];
    for (int i = 0; i < [self countData]; i++) {
        NSString * imgUrlString = [self getDataAtRow:(i+1) forDataCol:DataColImage];
        //SLog(@"Image URL: %@",imgUrlString);
        if (imgUrlString) [tempArray2 addObject:imgUrlString];
    }

    //SLog (@"Resources for %@: %@",urlString,tempArray2);
    
    return tempArray2;
}

- (CGFloat) cacheProgress{
    return 1.0 ;
    
}

- (BOOL) shouldGetExtraInformation{
    
    return NO;
}


@end



