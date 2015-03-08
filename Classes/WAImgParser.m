//
//  WAImgParser.m
//  Librelio
//
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import "WAImgParser.h"
#import "NSString+WAURLString.h"

@implementation WAImgParser

@synthesize intParam;

- (NSString *) urlString
{
    return urlString;
}

- (void) setUrlString: (NSString *) theString
{
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
    NSString *tempFileUrl = [[WAUtilities arrayOfImageUrlStringsForUrlString:urlString]objectAtIndex:row-1];
	NSString * ret = nil;
    
    
	switch (dataCol) {
		case DataColTitle:{
			ret= [tempFileUrl titleOfUrlString] ;
			break;
		}
		case DataColSubTitle:{
			NSString *tempSubTitle = [tempFileUrl valueOfParameterInUrlStringforKey:@"wasubtitle"];
			if (tempSubTitle) ret= tempSubTitle;
			break;
		}
		case DataColImage:{
			ret = tempFileUrl;
			break;
		}
		case DataColDetailLink:{
			ret = tempFileUrl;
			break;
		}
			
            
		default:
			ret = nil;
	}
	return ret;
}
- (int) countData{
	return (int)[[WAUtilities arrayOfImageUrlStringsForUrlString:urlString] count];
	
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
