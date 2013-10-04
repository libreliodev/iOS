#import "WAPListParser.h"
#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.h"




@implementation WAPListParser

@synthesize intParam,dataArray,headerDic;

- (NSString *) urlString
{
    return urlString;
}

- (void) setUrlString: (NSString *) theString
{
    urlString = [[NSString alloc]initWithString: theString];
	NSString *plistName = [urlString noArgsPartOfUrlString];
	NSString * plistPath = [[NSBundle mainBundle] pathOfFileWithUrl:plistName];
    //SLog(@"plistname:%@, plistpath:%@",plistName,plistPath);
	dataArray = [[NSArray alloc ]initWithContentsOfFile:plistPath];
    //SLog(@"plist dataArray %@",dataArray);
    //If dataArray count is zero, it means that the root level of the plist is a dictionary, with a "Lines" key
    if(![dataArray count]){
        //SLog(@"dataArray count is null");
        [dataArray release];
        dataArray = [[NSArray alloc ] initWithArray:[[NSDictionary dictionaryWithContentsOfFile:plistPath] valueForKey:@"Lines"]];
    }
    headerDic = [[NSDictionary alloc ] initWithDictionary:[[NSDictionary dictionaryWithContentsOfFile:plistPath] valueForKey:@"Headers"]];
	
    
        

}

- (void)dealloc
{
	[urlString release];
	[dataArray release];
    [headerDic release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Parser protocol



- (UIImage *) getCoverImage{
	return nil;
}
- (NSString*) getDataAtRow:(int)row forDataCol:(DataCol)dataCol{
    //SLog(@"getDataAtRow:%i forDataCol:%i",row,dataCol);
	NSDictionary * tempDic = [dataArray objectAtIndex:row-1];//Array rows start at 0, rows here start at 1
    //SLog(@"tempDic %@",tempDic);
	NSString * absUrlString = [WAUtilities absoluteUrlOfRelativeUrl:[tempDic objectForKey:@"FileName"] relativeToUrl:urlString] ;
	NSString *noUnderscoreUrlString = [absUrlString urlByRemovingFinalUnderscoreInUrlString];//Remove the final underscore
	NSString * ret = nil;


	switch (dataCol) {
		case DataColTitle:
			ret= [tempDic objectForKey:@"Title"];
			break;
		case DataColSubTitle:
			ret= [tempDic objectForKey:@"Subtitle"];
			break;
		case DataColImage:{
			NSString * imgUrl = [WAUtilities urlByChangingExtensionOfUrlString:noUnderscoreUrlString toSuffix:@".png"];
			NSString * imgPath = [[NSBundle mainBundle] pathOfFileWithUrl:imgUrl];
			ret = imgPath;
			break;}
		case DataColDetailLink:{
			//Here, we want to return the link to the paid file if downloaded, or the link to the sample
			NSString * filePath = [[NSBundle mainBundle] pathOfFileWithUrl:absUrlString];
			if (!filePath){
				//If the file with underscore is not present, 2 cases:
				if ([tempDic objectForKey:@"Description"]){
					//If there is a description in the plist, call buy module directly
					//ret= [absUrlString urlByChangingSchemeOfUrlStringToScheme:@"buy"];
                    ret= nil;
				}
				else{
					//Otherwise, remove the underscore in the file name 
					ret = [absUrlString urlByRemovingFinalUnderscoreInUrlString];
					NSString * sampleTitle = [[tempDic objectForKey:@"Title"] stringByAppendingString:NSLocalizedString(@" (Sample)",@"")];
                    if ([noUnderscoreUrlString isEqualToString:absUrlString]) sampleTitle = [tempDic objectForKey:@"Title"];
					ret = [ret urlByAddingParameterInUrlStringWithKey:@"watitle" withValue:sampleTitle];//Add the watitle arg to the url
					ret = [ret urlByAddingParameterInUrlStringWithKey:@"wasubtitle" withValue:[tempDic objectForKey:@"Subtitle"]];//Add the wasubtitle arg to the url

				}
			}
			else{
				ret = absUrlString;
                if (![ret valueOfParameterInUrlStringforKey:@"watitle"]){
                    ret = [ret urlByAddingParameterInUrlStringWithKey:@"watitle" withValue:[tempDic objectForKey:@"Title"]];//Add the watitle arg to the url
                }
                 if ((![ret valueOfParameterInUrlStringforKey:@"wasubtitle"])&&([tempDic objectForKey:@"Subtitle"])){
                     ret = [ret urlByAddingParameterInUrlStringWithKey:@"wasubtitle" withValue:[tempDic objectForKey:@"Subtitle"]];//Add the wasubtitle arg to the url
                 }

			}

			break;}

		case DataColIcon:{
            if ([tempDic objectForKey:@"Icon"]) return [tempDic objectForKey:@"Icon"];
			NSString * initialFilePath = [[NSBundle mainBundle] pathOfFileWithUrl:absUrlString];
			NSString * noUnderscoreFilePath = [[NSBundle mainBundle] pathOfFileWithUrl:noUnderscoreUrlString];
			if ((!initialFilePath)&&(!noUnderscoreFilePath)) ret= @"Download.png";//Show the download icon only if neither main file nor sample have been downloaded	
			break;
			}
		case DataColDownload:{
			//Check if the file has already been downloaded
			if ([[NSBundle mainBundle] pathOfFileWithUrl:absUrlString]){
				ret = nil;//File has already been downloaded, return nil

			}
			else {
				//Check if this is a protected or free file; protected files have a name ending with underscore
				if ([noUnderscoreUrlString isEqualToString:absUrlString]){
					//This is a free file, return the url with the text "Free Download"
					NSString * txt = NSLocalizedString(@"Free Download",@"");
					ret = [NSString stringWithFormat:@"%@;%@",txt, absUrlString]; 					
				}
				else {
					//This is a paying file, return buy URL with  the text "Download ..."
					NSString * txt = NSLocalizedString(@"Download ...",@"");
					NSString * buyUrlString = [absUrlString urlByChangingSchemeOfUrlStringToScheme:@"buy"];
					ret = [NSString stringWithFormat:@"%@;%@",txt,buyUrlString]; 					
					
				}
				//Add the title and date to the url
				ret = [ret urlByAddingParameterInUrlStringWithKey:@"watitle" withValue:[tempDic objectForKey:@"Title"]];//Get complete URL with title
				ret = [ret urlByAddingParameterInUrlStringWithKey:@"wasubtitle" withValue:[tempDic objectForKey:@"Subtitle"]];//Add the wasubtitle arg to the url
                ret = [ret urlByAddingParameterInUrlStringWithKey:@"wadate" withValue:[tempDic objectForKey:@"IssueDate"]];//Add the wadate arg to the url

			}
			break;
		}
		case DataColHTML:
			ret= [tempDic objectForKey:@"HTML"];
			break;
		case DataColSample:{
			//Check if this is a protected or free file; protected files have a name ending with underscore
			if ([noUnderscoreUrlString isEqualToString:absUrlString]){
                //This is a free file, let us see if we need to show the free subscription button
                NSString * credentials = [[NSBundle mainBundle] pathOfFileWithUrl:@"Application_.plist"];
                
                //Create actionSheet
                NSString * freeSubscription = [[NSDictionary dictionaryWithContentsOfFile:credentials]objectForKey:@"FreeSubscription"];
                if (freeSubscription){
                    //Check wether the user is already a subscriber
                    NSString * receipt = [[NSUserDefaults standardUserDefaults] objectForKey:@"FreeSubscription-receipt"];
                    if (receipt){
                        ret = nil; //User is already a free subscriber
                    }
                    else{
                        NSString * txt = NSLocalizedString(@"Free subscription",@"");
                        NSString * buyUrlString = [absUrlString urlByChangingSchemeOfUrlStringToScheme:@"buy"];
                        ret = [NSString stringWithFormat:@"%@;%@",txt,buyUrlString]; 					

                        
                    }
                    
                }
                else{
                    ret = nil;//This is a free file, no sample is provided and no free subscriptino is availalable

                }

			}
			else{
				if ([tempDic objectForKey:@"Description"]){
					//If there is a description in the plist, there is no sample
					ret = nil;
				}
				else{
					//Check wether the paid file has been donwloaded 
					if ([[NSBundle mainBundle] pathOfFileWithUrl:absUrlString]){
						ret = nil;//The file has been downloaded, no need to show the sample
					}
					else{
						NSString * txt = NSLocalizedString(@"Free sample",@"");
						NSString * sampleTitle = [[tempDic objectForKey:@"Title"] stringByAppendingString:NSLocalizedString(@" (Sample)",@"")];

						NSString * urlStringWithTitle = [noUnderscoreUrlString urlByAddingParameterInUrlStringWithKey:@"watitle" withValue:sampleTitle];
						ret = [NSString stringWithFormat:@"%@;%@",txt,urlStringWithTitle]; 					
						ret = [ret urlByAddingParameterInUrlStringWithKey:@"wasubtitle" withValue:[tempDic objectForKey:@"Subtitle"]];//Add the wasubtitle arg to the url
					}
				}
				
			}
			break;
		}
		case DataColRead:{
			if ([[NSBundle mainBundle] pathOfFileWithUrl:absUrlString]){
                NSString * extension =  [[absUrlString noArgsPartOfUrlString] pathExtension];
                if ([extension isEqualToString:@"plist"]){
                    //This is a sublibrary, don't add the read button
                    ret = nil;
                }
                else{
                    NSString * txt = NSLocalizedString(@"Read",@"");
                    NSString * urlStringWithTitle = [absUrlString urlByAddingParameterInUrlStringWithKey:@"watitle" withValue:[tempDic objectForKey:@"Title"]];
                    urlStringWithTitle = [urlStringWithTitle urlByAddingParameterInUrlStringWithKey:@"wasubtitle" withValue:[tempDic objectForKey:@"Subtitle"]];//Add the wasubtitle arg to the url
                    ret = [NSString stringWithFormat:@"%@;%@",txt,urlStringWithTitle];

                }
                
			}
			else{
				ret = nil;//File has not been downloaded, nothing to read!
			}
			break;
		}
		default:
            if (dataCol>100.0) ret =[tempDic objectForKey:[NSString stringWithFormat:@"%@%i",@"Col",dataCol]];
			
	}
    //SLog(@"Will return %@", ret);
   	return ret;
}
- (int) countData{
	return [dataArray count];
	
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
    //SLog (@"Will get resources for plist parser");
    NSString *plistName = [urlString noArgsPartOfUrlString];
    NSString * plistPath = [[NSBundle mainBundle] pathOfFileWithUrl:plistName];
    NSArray * tempArray = [NSArray arrayWithContentsOfFile:plistPath];
    NSEnumerator *enumerator = [tempArray reverseObjectEnumerator];

    NSMutableArray *tempArray2= [NSMutableArray array];
    
    for (NSDictionary * dic in enumerator){
        NSString *pdfUrl = [dic objectForKey: @"FileName"];
        pdfUrl = [pdfUrl urlByRemovingFinalUnderscoreInUrlString];//Remove underscore
        NSString *coverUrl = [WAUtilities urlByChangingExtensionOfUrlString:pdfUrl toSuffix:@".png"];
        [tempArray2 addObject:coverUrl];
    }	
    
    return tempArray2;

}

- (CGFloat) cacheProgress{
    return 1.0 ;
    
}




@end
