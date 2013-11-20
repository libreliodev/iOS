#import "WAZippedHtmlParser.h"
#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.h"
#import "WAUtilities.h"



@implementation WAZippedHtmlParser

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

    
    
    
    
}

- (void)dealloc
{
	[urlString release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Parser protocol



- (UIImage *) getCoverImage{
	return nil;
}
- (NSString*) getDataAtRow:(int)row forDataCol:(DataCol)dataCol{
	NSString * ret = nil;
    
    NSString * unzippedFolderUrlString = [urlString urlOfUnzippedFolder];
    NSString * fileName = [urlString nameOfFileWithoutExtensionOfUrlString];
    
    
	switch (dataCol) {
		case DataColDetailLink:{
            ret= [NSString stringWithFormat:@"%@/%@/index.html",unzippedFolderUrlString,fileName];
            //SLog(@"oamurl: %@",ret);
			break;}
        case DataColHTML:{
            //Load the html string
            NSString * htmlUrl = [NSString stringWithFormat:@"%@/%@/index.html",unzippedFolderUrlString,fileName];
            NSString * htmlPath = [[NSBundle mainBundle] pathOfFileWithUrl:htmlUrl];
            //SLog(@"Htmlpath:%@ for Url:%@",htmlPath,htmlUrl);
            NSString * htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];

            
            /**Insert the viewport meta right before </head>
           // NSString * metaAndHeadClose = [NSString stringWithFormat:@"<meta name=\"viewport\" content=\"width=%@; user-scalable=no\" /></head>",widthString];
            //SLog(@"meta:%@",metaAndHeadClose);
            ret = [htmlString stringByReplacingOccurrencesOfString:@"</head>" withString:metaAndHeadClose];**/
            ret = htmlString;

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



@end

