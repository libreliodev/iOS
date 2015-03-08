#import "WARSSParser.h"
#import "WAUtilities.h"
#import "NSBundle+WAAdditions.h"
#import "NSString+WAURLString.h"



@implementation WARSSParser


@synthesize intParam;



- (NSString *) urlString
{
    return urlString;
}

- (void) setUrlString: (NSString *) theString
{
    //SLog(@"Started RSS parser");
    urlString = [[NSString alloc]initWithString: theString];
	NSData * feedData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathOfFileWithUrl:urlString]];
	doc = xmlReadMemory([feedData bytes], (int)[feedData length], "", NULL, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
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
    NSString *ret =@"";
	xmlXPathObjectPtr xPathMainTitle = xmlXPathEvalExpression(xPathExp, xpathCtx);//Find all entries
    if (xPathMainTitle->nodesetval->nodeTab[0]->children==NULL){
        
    }
    else{
        ret = [NSString stringWithCString:(const char *)xPathMainTitle->nodesetval->nodeTab[0]->children->content encoding:NSUTF8StringEncoding];
        xmlXPathFreeObject(xPathMainTitle);
        ret = [ret stringByReplacingOccurrencesOfString:@"&#039;" withString:@"'"];//Hack
        ret = [ret stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];//Hack
        
    }

	return ret;
	
}

- (NSString*) getStringForXPath:(xmlChar *)xPathExp2 inHtmlNodeForXpath:(xmlChar *)xPathExp1{
	//Get the HTML
	xmlXPathObjectPtr xpathObjHtml = xmlXPathEvalExpression(xPathExp1, xpathCtx);
 
    xmlChar * Html = (xmlChar *)xpathObjHtml->nodesetval->nodeTab[0]->children->content;
    //xmlChar * Html = (xmlChar *)"<div><div2>qqq</div2><img2/>essai00</div>";

    
	//Create a new doc with the HTML and apply XPath expression
	xmlDocPtr htmlDoc = htmlReadDoc(Html, "", "utf-8", HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
	//In case coder needs to access html, here is how:
	xmlChar *xmlbuff;
	 int buffersize;
	 xmlDocDumpFormatMemory(htmlDoc, &xmlbuff, &buffersize, 1);
     //SLog(@"html: %s", xmlbuff);
	 xmlFree(xmlbuff);
	xmlXPathContextPtr xpathCtx2 = xmlXPathNewContext(htmlDoc);
	xmlXPathObjectPtr xpathImg = xmlXPathEvalExpression(xPathExp2, xpathCtx2);
	NSString* ret = @"";
	if(xpathImg == NULL) {
	}
    else if (xpathImg->nodesetval==NULL){
        
    }
	else {
		if (xpathImg->nodesetval->nodeNr){
            
            
            int i = 0;
            for(xmlNodePtr node = xpathImg->nodesetval->nodeTab[0]->children;node;node = node->next){
                i++;
                xmlChar * cRet = node->content;
                //SLog(@"cRet:%s",cRet);
                if (cRet) ret = [ret stringByAppendingString:[NSString stringWithCString:(const char *)cRet encoding:NSUTF8StringEncoding]];

            }
            //SLog(@"Nb nodes %i",i );
            
  			
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
	NSString * xPathBegin = [NSString stringWithFormat: @"//rss/channel/item[position()=%i]",row];
	switch (dataCol) {
		case DataColTitle:{
			NSString * xPath = [xPathBegin stringByAppendingString:@"/title"];
			NSString * ret = [self getStringForXPath:(xmlChar *)[xPath cStringUsingEncoding: NSASCIIStringEncoding ]];
            //SLog(@"title found:%@",ret);
            
			
			return ret;
		}
           
 		case DataColSubTitle:{
			NSString * xPath = [xPathBegin stringByAppendingString:@"/description"];
           NSString* ret = [self getStringForXPath:(xmlChar *)"//body" inHtmlNodeForXpath:(xmlChar *)[xPath cStringUsingEncoding: NSASCIIStringEncoding ]];
 			//NSString * ret = [self getStringForXPath:(xmlChar *)[xPath cStringUsingEncoding: NSASCIIStringEncoding ]];
            

             //SLog(@"subtitle found:%@",ret);
            
			
			return ret;
		}
			

		case DataColDate:{
            NSString * xPath = [xPathBegin stringByAppendingString:@"/pubDate"];
			NSString * dateString = [self getStringForXPath:(xmlChar *)[xPath cStringUsingEncoding: NSASCIIStringEncoding ]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss Z"];
            NSDate *dateDate = [dateFormatter dateFromString:dateString];
            [dateFormatter release];
            
            
              NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
             [formatter setDateStyle:NSDateFormatterMediumStyle];
             [formatter setTimeStyle:NSDateFormatterNoStyle];
             NSString * ret = [formatter stringFromDate:dateDate];
             [formatter release];
            //SLog(@"ret:%@",ret);
            if ([ret length]<7) ret = @"";//Hack, we want to avoid (null) value

			return ret;
		}
		case DataColImage: {
			//Get the first image in the HTML
			NSString * xPath = [xPathBegin stringByAppendingString:@"/description"];
			NSString* ret = [self getStringForXPath:(xmlChar *)"//@src" inHtmlNodeForXpath:(xmlChar *)[xPath cStringUsingEncoding: NSASCIIStringEncoding ]];
			if (!ret) ret= nil;
            else {
                ret = [ret  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                 //Use a local url to force image storage
                NSString * ext = [[ret noArgsPartOfUrlString] pathExtension];
                NSString * imageName = [NSString stringWithFormat:@"%@/img%lu.%@",[urlString nameOfFileWithoutExtensionOfUrlString],(unsigned long)[ret hash],ext];
                ret = [imageName urlByAddingParameterInUrlStringWithKey:@"waurl" withValue:ret];
                
            }
            //SLog(@"image found:%@",ret);

			return ret;
			
		}
        case DataColDetailLink:{
            //Get the link
            NSString * xPath = [xPathBegin stringByAppendingString:@"/link"];
 			NSString * ret = [self getStringForXPath:(xmlChar *)[xPath cStringUsingEncoding: NSASCIIStringEncoding ]];
			if (!ret) ret= nil;
            //SLog(@"link found:%@",ret);

			return ret;

        }
  		case DataColHTML:{
            NSString *ret = nil;
			return ret;
		}
			
		default:
			return nil;
	}
}
- (int) countData{
	xmlXPathObjectPtr xpathEntries = xmlXPathEvalExpression((xmlChar *)"//rss/channel/item", xpathCtx);//Find all entries
	int size = xpathEntries->nodesetval->nodeNr;
    //SLog(@"entries found %i",size);
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



