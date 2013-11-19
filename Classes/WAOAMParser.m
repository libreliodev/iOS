#import "WAOAMParser.h"
#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.h"
#import "WAUtilities.h"



@implementation WAOAMParser

@synthesize intParam;

- (NSString *) urlString
{
    return urlString;
}

- (void) setUrlString: (NSString *) theString
{
    urlString = [[NSString alloc]initWithString: theString];

    //Uzip file if needed
    [[NSBundle mainBundle]unzipFileWithUrlString:urlString];
    
    NSString * unzippedFolderUrlString = [urlString urlOfUnzippedFolder];
 

    //Prepare the xml for parsing
    NSString * fileName = [urlString nameOfFileWithoutExtensionOfUrlString];
    NSString * xmlUrl = [NSString stringWithFormat:@"%@/Assets/%@_oam.xml",unzippedFolderUrlString,fileName];
    //NSString * xmlUrl = @"/facebook.atom";
    NSData * xmlData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathOfFileWithUrl:xmlUrl]];
    //SLog(@"Read NSData for path %@ with length %i",[[NSBundle mainBundle] pathOfFileWithUrl:xmlUrl],xmlData.length);
	doc = xmlReadMemory([xmlData bytes], [xmlData length], "", NULL, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
	xpathCtx = xmlXPathNewContext(doc);
    xmlXPathRegisterNs(xpathCtx, (xmlChar *)"a", (xmlChar *)"http://openajax.org/metadata");
    

    
    
    
    
}

- (void)dealloc
{
	[urlString release];
	xmlXPathFreeContext(xpathCtx);
	xmlFreeDoc(doc);
	
	[super dealloc];
}

#pragma mark -
#pragma mark Parser protocol



- (UIImage *) getCoverImage{
	return nil;
}
- (NSString*) getDataAtRow:(int)row forDataCol:(DataCol)dataCol{
	NSString * ret = nil;
    NSString * fileName = [urlString nameOfFileWithoutExtensionOfUrlString];
    
    NSString * unzippedFolderUrlString = [[urlString valueOfParameterInUrlStringforKey:@"waroot"] urlOfCacheFileWithName:fileName];
    
    
	switch (dataCol) {
		case DataColDetailLink:{
            ret= [NSString stringWithFormat:@"%@/Assets/%@.html",unzippedFolderUrlString,fileName];
            //SLog(@"oamurl: %@",ret);
			break;}
        case DataColHTML:{
            //Load the html string
            NSString * htmlUrl = [NSString stringWithFormat:@"%@/Assets/%@.html",unzippedFolderUrlString,fileName];
            NSString * htmlPath = [[NSBundle mainBundle] pathOfFileWithUrl:htmlUrl];
            NSLog(@"Htmlpath:%@",htmlPath);
            NSString * htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];

            //Get the width of the animation
            NSString * xPathString = @"//a:widget/a:properties/a:property[@name='default-width']/@defaultValue";
            NSString * widthString = [self getStringForXPath:(xmlChar *)[xPathString cStringUsingEncoding: NSASCIIStringEncoding ]];
            
            //Insert the viewport meta right before </head>
            NSString * metaAndHeadClose = [NSString stringWithFormat:@"<meta name=\"viewport\" content=\"width=%@; user-scalable=no\" /></head>",widthString];
            //SLog(@"meta:%@",metaAndHeadClose);
            ret = [htmlString stringByReplacingOccurrencesOfString:@"</head>" withString:metaAndHeadClose];

            break;


            
        }
            
        default:
            ret = nil;
			
	}
    //SLog(@"Will return %@", ret);
   	return ret;
}
- (int) countData{
	return 1;
	
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
    /*NSDictionary * tempDic = [dataArray objectAtIndex:row-1];//Array rows start at 0, rows here start at 1
     return[tempDic objectForKey:colName];*/
    return [self getDataAtRow:row forDataCol:dataCol];
    
}

- (NSArray*) getRessources{
    return nil;
}

- (CGFloat) cacheProgress{
    return 1.0 ;
    
}

#pragma mark -
#pragma mark Utility functions

- (NSString*) getStringForXPath:(xmlChar *)xPathExp  {
    NSString *ret =@"";
	xmlXPathObjectPtr xPathMainTitle = xmlXPathEvalExpression(xPathExp, xpathCtx);//Find all entries
    if (xPathMainTitle->nodesetval){
        if (xPathMainTitle->nodesetval->nodeTab[0]->children==NULL){
            
        }
        else{
            ret = [NSString stringWithCString:(const char *)xPathMainTitle->nodesetval->nodeTab[0]->children->content encoding:NSUTF8StringEncoding];
            xmlXPathFreeObject(xPathMainTitle);
            ret = [ret stringByReplacingOccurrencesOfString:@"&#039;" withString:@"'"];//Hack
            ret = [ret stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];//Hack
            
        }
        
    }
    
	return ret;
	
}


@end

