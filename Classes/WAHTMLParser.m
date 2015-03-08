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
    
    
	switch (dataCol) {
		case DataColDetailLink:{
            ret= urlString;
			break;}
            
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

- (BOOL) shouldGetExtraInformation{
    
    return NO;
}



@end



