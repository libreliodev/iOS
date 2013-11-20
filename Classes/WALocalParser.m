 #import "WALocalParser.h"
#import "WAPDFParser.h"
#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.h"

#import <NewsstandKit/NewsstandKit.h>




@implementation WALocalParser

@synthesize dataArray,intParam;

- (NSString *) urlString
{
    return urlString;
}

- (void) setUrlString: (NSString *) theString
{
    urlString = [[NSString alloc]initWithString: theString];
    
    //Find directory
	NSString * dirName = [urlString valueOfParameterInUrlStringforKey:@"wadir"];
    NSString *dirPath;
    if ([dirName isEqualToString:@"Documents"]){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
         dirPath= [paths objectAtIndex:0];	
     }
	else dirPath = [WAUtilities cacheFolderPath];
    
	NSArray * dirArray;
	NSString * depth = [urlString valueOfParameterInUrlStringforKey:@"wadepth"];
	//If wadepth=0 it means we do not want subdirectories; otherwise it means we do want subdirectories
	if ([depth isEqualToString:@"0"]){
		dirArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:NULL];
	}
	else {
		NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:dirPath];
		dirArray = [dirEnum allObjects];

	}

	
	dataArray = [[NSMutableArray alloc]initWithArray:[NSArray array]];
	NSString * suffix = [urlString valueOfParameterInUrlStringforKey:@"wasuffix"];
	if (!suffix) suffix = @"_metadata.plist";//_metadata.plist is the default suffix
	for (NSString * file in dirArray){
		if ([file hasSuffix:suffix]) {
			if ([suffix isEqualToString:@"_metadata.plist"]){
				//Check that the target file is not a plist
				NSString * targetFileName = [file stringByReplacingOccurrencesOfString:suffix withString:@".plist"];
				if (![[NSFileManager defaultManager] fileExistsAtPath:[dirPath stringByAppendingPathComponent: targetFileName]]){
					//Add the dictionary from ***_metadata.plist to dataArray
					NSDictionary * tempDir = [NSDictionary dictionaryWithContentsOfFile:[dirPath stringByAppendingPathComponent: file]];
					[dataArray addObject:tempDir];
				}
				
			}
			else{
				//We need to create a dictionary to describe the file
                NSString * localUrl = [NSString stringWithFormat:@"file://localhost/%@/%@",dirPath,file];
                localUrl  = [localUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSString * tempUrl = [NSString stringWithFormat:@"/%@",[file lastPathComponent]];
                tempUrl = [tempUrl urlByAddingParameterInUrlStringWithKey:@"waurl" withValue:localUrl];

                //tempUrl = [tempUrl urlByAddingParameterInUrlStringWithKey:@"waupdate" withValue:@"0"];//This permits cached file to be refreshed everytime the main document is changed
                
                //SLog(@"Added local file:%@",tempUrl);
				NSDictionary * tempDir = [NSDictionary dictionaryWithObjectsAndKeys:tempUrl,@"FileUrl",nil];
				[dataArray addObject:tempDir];
			}
		}
		
	}
    //SLog(@"dataArray:%@",dataArray);

    

    
	
	
}

- (void)dealloc
{
	[urlString release];
	[dataArray release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Parser protocol



- (UIImage *) getCoverImage{
	return nil;
}
- (NSString*) getDataAtRow:(int)row forDataCol:(DataCol)dataCol{
    NSDictionary * tempDic;
    NSString* tempFileUrl ;
    NSString * ret = nil;

    if ([dataArray count]>row-1){
        tempDic = [dataArray objectAtIndex:row-1];//Array rows start at 0, rows here start at 1
        tempFileUrl = [tempDic objectForKey:@"FileUrl"];
        
    }


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
			NSString *noUnderscoreUrlString = [tempFileUrl urlByRemovingFinalUnderscoreInUrlString];//Remove the final underscore
			NSString * imgUrl = [WAUtilities urlByChangingExtensionOfUrlString:noUnderscoreUrlString toSuffix:@".png"];
			NSString * imgPath = [[NSBundle mainBundle] pathOfFileWithUrl:imgUrl];
			//If there is no image, generate it or use Default.png
            UIImage * img = [UIImage  imageWithContentsOfFile:imgPath];
			if (!img){
               //Check if the cover image was found; if not, generate it
                NSString * className = [tempFileUrl classNameOfParserOfUrlString];
                Class theClass = NSClassFromString(className);
                if (theClass){
                    NSObject <WAParserProtocol> * parser =  (NSObject <WAParserProtocol> *)[[theClass alloc] init];
                    parser.urlString = tempFileUrl;
                    
                    img = [parser getCoverImage];
                    if (img){
                        NSData *imageData = UIImagePNGRepresentation(img);
                        //SLog(@"Storing cover image");
                        [WAUtilities storeFileWithUrlString:imgUrl withData:imageData];
                     }
                }
 			}
			if (!img) imgPath = [[NSBundle mainBundle] pathOfFileWithUrl:@"/Default.png"];
			ret = imgPath;
			break;
		}
		case DataColDetailLink:{
			ret = tempFileUrl;
            //SLog(@"dtailLink:%@",ret);
			break;
		}
		case DataColDate:{
			NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
			[formatter setDateStyle:NSDateFormatterMediumStyle];
			[formatter setTimeStyle:NSDateFormatterNoStyle];
			NSString * tempText = [formatter stringFromDate:[tempDic objectForKey:@"DownloadDate"]];	
			[formatter release];
			ret = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Downloaded",@""),tempText];
			break;
			
		}
		case DataColDelete:{
			NSString * txt = NSLocalizedString(@"Delete",@"");
			NSString * deleteUrl = [NSString stringWithFormat:@"self://delete/?waline=%i",row];
			ret = [NSString stringWithFormat:@"%@;%@",txt,deleteUrl]; 					
			break;
			
		}
			
	
		default:
			ret = nil;
	}
	return ret;
}
- (int) countData{
	return [dataArray count];
	
}

- (void) deleteDataAtRow:(int)row{
	NSDictionary * tempDic = [dataArray objectAtIndex:row];
	NSString *fileUrl = [tempDic objectForKey:@"FileUrl"];
	NSArray *resourcesArray = [tempDic objectForKey:@"Resources"];
	
    //If the file is a Newsstand Issue, just remove the issue
    if ([fileUrl shouldUseNewsstandForUrlString]){
        NKLibrary *nkLib = [NKLibrary sharedLibrary];
        NSString *noUnderscoreUrlString = [fileUrl urlByRemovingFinalUnderscoreInUrlString];//Remove the final underscore];
        NSString * fileName = [noUnderscoreUrlString nameOfFileWithoutExtensionOfUrlString];
       NKIssue *nkIssue = [nkLib issueWithName:fileName];
        [nkLib removeIssue:nkIssue];
        
    }
    
    //Check if the main has been deleted thanks to Newsstand; otherwise, delete everything "manually"
    if ([[NSBundle mainBundle] pathOfFileWithUrl:fileUrl])
    {
        //Delete resources
        for (NSString *resourceUrlString in resourcesArray){
            NSString * resPath = [[NSBundle mainBundle] pathOfFileWithUrl:resourceUrlString];
            [[NSFileManager defaultManager]removeItemAtPath:resPath error:NULL];
        }
        
        //Delete cache
        NSString * cacheUrlString = [fileUrl urlOfCacheFileWithName:@""];
        cacheUrlString = [cacheUrlString substringToIndex:[cacheUrlString length]-1];//Remove final "/"
        NSString * cachePath = [[NSBundle mainBundle] pathOfFileWithUrl:cacheUrlString];
        [[NSFileManager defaultManager]removeItemAtPath:cachePath error:NULL];
        
        //Delete the main file
        NSString * filePath = [[NSBundle mainBundle] pathOfFileWithUrl:fileUrl];
        [[NSFileManager defaultManager]removeItemAtPath:filePath error:NULL];
        
        //Delete _metadata.plist file
        NSString * metadataUrlString = [WAUtilities urlByChangingExtensionOfUrlString:fileUrl toSuffix:@"_metadata.plist"];
        NSString * metadataPath = [[NSBundle mainBundle] pathOfFileWithUrl:metadataUrlString];
        [[NSFileManager defaultManager]removeItemAtPath:metadataPath error:NULL];

        
    }
    
	
	//Delete preference for file
	NSString *tempKey = [NSString stringWithFormat:@"%@-page",fileUrl];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:tempKey];
	
	
	//Update DataArray
	[dataArray removeObjectAtIndex:row];

	
	
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



@end
