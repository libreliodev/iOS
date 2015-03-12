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
    //SLog(@"Will init parser %@ with UrlString %@",self, urlString);

    NSString *plistName = [urlString noArgsPartOfUrlString];
	NSString * plistPath = [[NSBundle mainBundle] pathOfFileWithUrl:plistName];
    //SLog(@"plistname:%@, plistpath:%@",plistName,plistPath);
	dataArray = [[NSMutableArray alloc ]initWithContentsOfFile:plistPath];
    //SLog(@"plist dataArray %@",dataArray);
    //If dataArray count is zero, it means that the root level of the plist is a dictionary, with a "Lines" key
    if(![dataArray count]){
        //SLog(@"dataArray count is null");
        [dataArray release];
        dataArray = [[NSMutableArray alloc ] initWithArray:[[NSDictionary dictionaryWithContentsOfFile:plistPath] valueForKey:@"Lines"]];
    }
    headerDic = [[NSDictionary alloc ] initWithDictionary:[[NSDictionary dictionaryWithContentsOfFile:plistPath] valueForKey:@"Headers"]];
    
    
    //Check if we need to chache prices
    NSString * credentials = [[NSBundle mainBundle] pathOfFileWithUrl:@"Application_.plist"];
     NSString * boolString = [[NSDictionary dictionaryWithContentsOfFile:credentials]objectForKey:@"CachePrices"];
    if (boolString) extraInfoStatus = Needed;
    else extraInfoStatus = NotNeeded;
	
 
    
        

}

- (void)dealloc
{
    //SLog(@"Will dealloc parser %@ with UrlString %@",self, urlString);

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
    
    NSString * urlStringWithTitle = [absUrlString urlByAddingParameterInUrlStringWithKey:@"watitle" withValue:[tempDic objectForKey:@"Title"]];
    urlStringWithTitle = [urlStringWithTitle urlByAddingParameterInUrlStringWithKey:@"wasubtitle" withValue:[tempDic objectForKey:@"Subtitle"]];//Add the wasubtitle arg to the url

 
    NSString * buyUrlString = [urlStringWithTitle urlByChangingSchemeOfUrlStringToScheme:@"buy"];

	NSString * ret = nil;
    
 
	switch (dataCol) {
		case DataColTitle:
			ret= [tempDic objectForKey:@"Title"];
			break;
		case DataColSubTitle:
			ret= [tempDic objectForKey:@"Subtitle"];
			break;
		case DataColImage:{
			NSString * imgUrl = [noUnderscoreUrlString urlByChangingExtensionOfUrlStringToSuffix:@".png"];
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
					NSString * sampleTitle = [[tempDic objectForKey:@"Title"] stringByAppendingString:[[NSBundle mainBundle]stringForKey:@" (Sample)"]];
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
					NSString * txt = [[NSBundle mainBundle]stringForKey:@"Free Download"];
					ret = [NSString stringWithFormat:@"%@;%@",txt, urlStringWithTitle];
				}
				else {
					//This is a paying file, return buy URL with  the text "Download ..."
					NSString * txt = [[NSBundle mainBundle]stringForKey:@"Download ..."];
					ret = [NSString stringWithFormat:@"%@;%@",txt,buyUrlString];
					
				}
                
 
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
                        NSString * txt = [[NSBundle mainBundle]stringForKey:@"Free subscription"];
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
						NSString * txt = [[NSBundle mainBundle]stringForKey:@"Free sample"];
						NSString * sampleTitle = [[tempDic objectForKey:@"Title"] stringByAppendingString:[[NSBundle mainBundle]stringForKey:@" (Sample)"]];

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
                 /**NSString * extension =  [[absUrlString noArgsPartOfUrlString] pathExtension];
               if ([extension isEqualToString:@"plist"]){
                    //This is a sublibrary, don't add the read button
                    ret = nil;
                }
                else{**/
                    NSString * txt = [[NSBundle mainBundle]stringForKey:@"Read"];
                     ret = [NSString stringWithFormat:@"%@;%@",txt,urlStringWithTitle];

                //}
                
			}
			else{
				ret = nil;//File has not been downloaded, nothing to read!
			}
			break;
        case DataColDetail:
            ret= [NSString stringWithFormat:@";detail://%i",row];
            break;
        case DataColDismiss:
            ret= @";dismiss://";
            break;
        case  DataColUnitPrice:
            if ([[NSBundle mainBundle] pathOfFileWithUrl:absUrlString]){
                //File already downloaded, don't show price
               }
            else{
                NSString * price = [tempDic objectForKey:@"Price"];
            
                if (price) ret = [NSString stringWithFormat:@"%@;%@",price,buyUrlString];
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
    //SLog(@"Will count data array: %@",dataArray);
	return (int)[dataArray count];
	
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
    NSString * ret;
    switch (dataCol) {
        case DataColAd:
            ret= @"b000";
            break;
        default:
            ret=nil;
            
    }
	
    
    
    return ret;
	
}

- (int)countSearchResultsForQueryDic:(NSDictionary*)queryDic{
    
    return [self countData];//More general case to be implemented in the future
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
        pdfUrl = [WAUtilities absoluteUrlOfRelativeUrl:pdfUrl relativeToUrl:urlString];
        pdfUrl = [pdfUrl stringByReplacingOccurrencesOfString:@"TempWa//" withString:@""];//hack
        NSString * coverUrl = [pdfUrl urlByChangingExtensionOfUrlStringToSuffix:@".png"];
        [tempArray2 addObject:coverUrl];
    }	
    
    return tempArray2;

}

- (CGFloat) cacheProgress{
    //SLog(@"Cache finished %i",cacheFinished);
    return 1.0 ;
    
}

# pragma mark -
# pragma mark SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    
    NSLog(@"Products received: valid %@ , invalid %@ urlString:%@",response.products,response.invalidProductIdentifiers,urlString);
    extraInfoStatus = Downloaded;

    //Parse response
    NSArray * products = response.products;
    NSMutableDictionary * parsedResponse = [NSMutableDictionary dictionary];
    for (SKProduct *product in products) {
        
        //Format the price
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:product.priceLocale];
        NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
        [numberFormatter release];
        //SLog(@"formattted price %@ for product id %@ to include in dic %@",formattedPrice,product.productIdentifier,parsedResponse);
        
        [parsedResponse setObject:formattedPrice forKey:product.productIdentifier];
        
     }
    NSLog(@"parsedResponse:%@, dataarray:%@",parsedResponse,dataArray);
    
    //Add prices to plist
    NSMutableArray * newDataArray= [NSMutableArray arrayWithArray:dataArray];
    NSString * nullString = @"null";
    NSSet * subscriptionIds = [nullString relevantLibrelioProductIDsForUrlString];//This will return subscription IDs

    [dataArray enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL *stop) {
        //Find the unit price
        NSString *pdfUrl = [dic objectForKey: @"FileName"];
        NSString * librelioId = [[pdfUrl urlByRemovingFinalUnderscoreInUrlString] nameOfFileWithoutExtensionOfUrlString];
        NSString * appStoreId = [librelioId appStoreProductIDForLibrelioProductID];
        NSString * priceString = [parsedResponse objectForKey:appStoreId];
        NSMutableDictionary * newDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        if (priceString)  [newDic setObject:priceString forKey:@"Price"];
        for (NSString * subscriptionId in subscriptionIds){
            NSString * appStoreSubscriptionId = [subscriptionId appStoreProductIDForLibrelioProductID];
            NSString * subscriptionPriceString = [parsedResponse objectForKey:appStoreSubscriptionId];
            if (subscriptionPriceString)  [newDic setObject:subscriptionPriceString forKey:subscriptionId];
        }
        [newDataArray replaceObjectAtIndex:idx withObject:newDic];
        
        //Add subscription ids
        
                                     

    }];
    [dataArray removeAllObjects];
    [dataArray addObjectsFromArray:newDataArray];

    
      NSLog(@"dataarray:%@",dataArray);
     //Store plist with metadata and list of resources for this download
     NSString * filePath = [[NSBundle mainBundle] pathOfFileWithUrl:urlString];
     [dataArray writeToFile:filePath atomically:YES];

    
    //fire notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didGetExtraInformation" object:urlString];

    
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    //SLog(@"Products not received: %@",error);
    extraInfoStatus = Downloaded;
    //fire notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didGetExtraInformation" object:urlString];
   
    
}

- (BOOL) shouldGetExtraInformation{
    if (extraInfoStatus == Needed){
        
        //Start by adding subscriptions
        NSString * nullString = @"null";
        NSSet * acceptableLibrelioIDs = [nullString relevantLibrelioProductIDsForUrlString];//This will return subscription IDs
        NSMutableSet * productIdentifiers = [NSMutableSet set];
        for (NSString * curentID in acceptableLibrelioIDs){
            NSString * appStoreID =  [curentID appStoreProductIDForLibrelioProductID];
            [productIdentifiers addObject:appStoreID];
        }

        //Now add individual ids
        for (NSDictionary * dic in dataArray){
            NSString *pdfUrl = [dic objectForKey: @"FileName"];
            NSString * librelioId = [[pdfUrl urlByRemovingFinalUnderscoreInUrlString] nameOfFileWithoutExtensionOfUrlString];
            NSString * appStoreId = [librelioId appStoreProductIDForLibrelioProductID];
            [productIdentifiers addObject:appStoreId];
        }	

         SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
        
        request.delegate = self;
        extraInfoStatus = Requested;
        //SLog(@"Will loaunch request %@",request );
        [request start];
        return YES;

        
        
    }
    else if (extraInfoStatus == Requested) return YES;
    
    else return NO;
}



@end
