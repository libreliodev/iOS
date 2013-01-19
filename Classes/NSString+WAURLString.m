//
//  NSString+NSString_WAURLString.m
//  Librelio
//
//  Copyright (c) 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import "NSString+WAURLString.h"
#import "WAParserProtocol.h"
#import "WAModuleProtocol.h"
#import "WAUtilities.h"
#import <NewsstandKit/NewsstandKit.h>

@implementation NSString (WAURLString)


- (BOOL) isLocalUrl {
	NSRange colonRange = [self rangeOfString :@":"];
	NSRange localhostRange = [self rangeOfString :@"http://localhost"];
    if ([self hasPrefix:@"www"]) return NO;//Sometimes, people forget the http:// prefix
	else if (localhostRange.location != NSNotFound) return YES;
	else if (colonRange.location != NSNotFound) return NO;
	else return YES;
	
	
}

- (NSString *) noHashPartOfUrlString{
	NSArray *parts = [self componentsSeparatedByString:@"#"];
	
	return [parts objectAtIndex:0];
	
}



/** 
 *  @return The part of the url before the ? sign

 **/
- (NSString *) noArgsPartOfUrlString{
	NSArray *parts = [[self noHashPartOfUrlString] componentsSeparatedByString:@"?"];
	
	return [parts objectAtIndex:0];
}

- (NSString *) schemePartOfUrlString{
    NSRange range = [self rangeOfString:@"://"];
    if (range.location == NSNotFound) return @"http";
    else{
        return [self substringToIndex:range.location]; 
    }
}
/*! 
  @return The name of the top directory, for example "root" for url root/sub/file.ext
 
 **/
- (NSString *) rootDirectoryNameOfUrlString{
    NSArray * parts = [[self noArgsPartOfUrlString] pathComponents];
    if ([parts count]<2) return nil;
    NSString * ret = [parts objectAtIndex:0];
    if ([ret isEqualToString:@"/"]){
        if ([parts count]>2) return [parts objectAtIndex:1];
        else return nil;
    }
    return ret;
        
}

- (NSString *) nameOfFileWithoutExtensionOfUrlString {
	NSString* ret = [[[self noArgsPartOfUrlString] lastPathComponent] stringByDeletingPathExtension];
	return ret;
}


- (NSString *) titleOfUrlString{
    NSString *tempTitle = [self valueOfParameterInUrlStringforKey:@"watitle"];
    if (!tempTitle){
        tempTitle= [self nameOfFileWithoutExtensionOfUrlString];
        
    }
    //SLog(@"Title for %@:%@",self,tempTitle);
    return(NSLocalizedString(tempTitle,@""));
 
    
}


/*!
 @return The path where file with url should be stored
 @brief: when Newsstand is used, and issueWithName exists, the file should be stored in the Newsstand directory
**/

- (NSString *) pathOfStorageForUrlString{
    NSString * relativeUrl;
    //In case the URL is complete, take the path
    NSRange range = [self rangeOfString:@"://localhost"];
    if (range.location == NSNotFound) relativeUrl=self;
    else{
        relativeUrl = [self substringFromIndex:(range.location+range.length)]; 
    }

    
	NSString *noArgsUrl = [relativeUrl noArgsPartOfUrlString] ;
    NSString * dirPath = [WAUtilities cacheFolderPath];
    
    //Check if Newsstand is available; in this case, the path is given by Newsstand itself
    if (NSClassFromString(@"NKLibrary")){
        //Then check if newsstand is enabled in the app
        NKLibrary *nkLib = [NKLibrary sharedLibrary];
        if (nkLib){
            //Now check if a newsstand issue exists with the directory name
            NKIssue *nkIssue = [nkLib issueWithName:[noArgsUrl rootDirectoryNameOfUrlString]];
            if(nkIssue) {
                //Change dirPath to the directory used  by newssstand
                dirPath = [nkIssue.contentURL path];
                //Remove the directory name from noArgsUrl
                NSRange range = [noArgsUrl rangeOfString:[noArgsUrl rootDirectoryNameOfUrlString]];
                if (range.location != NSNotFound){
                    noArgsUrl = [noArgsUrl substringFromIndex:(range.location+range.length)];
                }
            }
            
            
        }
    }
    return [dirPath stringByAppendingPathComponent:noArgsUrl];
    
    
}


- (NSString*) urlByChangingSchemeOfUrlStringToScheme:(NSString*)newScheme{
	NSRange range = [self rangeOfString:@"://"];
	if (range.location == NSNotFound){
		if ([self hasPrefix:@"/"]) return [NSString stringWithFormat:@"%@://localhost%@",newScheme,self];
		else return [NSString stringWithFormat:@"%@://localhost/%@",newScheme,self];
	}
	NSString * tempS = [self substringFromIndex:range.location];
	return [NSString stringWithFormat:@"%@%@",newScheme,tempS];
	
	
}

- (NSString*) urlByRemovingFinalUnderscoreInUrlString{
	NSRange range = [self rangeOfString:@"_." options:NSBackwardsSearch];
	NSString * ret = self;
	if (range.location != NSNotFound) ret = [NSString stringWithFormat:@"%@%@",[self substringToIndex:range.location],[self substringFromIndex:range.location+1]] ;
	return ret;
	/*NSString * fileName = [self nameOfFileWithoutExtensionOfUrlString:urlString];
     if ([fileName hasPrefix:@"_"]){
     NSString * noUnderscoreFileName = [fileName substringToIndex:fileName.length-1];
     return [urlString stringByReplacingOccurrencesOfString:fileName withString:noUnderscoreFileName];
     }
     else {
     return urlString;
     
     }*/
    
    
}


- (BOOL) isUrlStringOfSameFileAsUrlString:(NSString*) otherUrlString {
    NSString * noLocalHost1 = [self stringByReplacingOccurrencesOfString:@"http://localhost" withString:@""];
    NSString * noLocalHost2 = [otherUrlString stringByReplacingOccurrencesOfString:@"http://localhost" withString:@""];
    NSString * noArgsUrl1 = [noLocalHost1 noArgsPartOfUrlString];
    NSString * noArgsUrl2 = [noLocalHost2 noArgsPartOfUrlString];
    if ([noArgsUrl1 isEqualToString:noArgsUrl2]) return YES;
    return NO;
    
}



/**!
 @return The value of a parameter in a url string, for example xxxx when url is localhost/query.xyz?a=xxx and key is a
 
 **/
- (NSString *) valueOfParameterInUrlStringforKey:(NSString*)key{
	NSArray *parts = [self componentsSeparatedByString:@"?"];
	NSString * query = [parts objectAtIndex:[parts count]-1];
	NSArray *parts2 = [query componentsSeparatedByString:@"&"];
    //SLog(@"part2 for url %@: %@",self,parts2);
	NSString *keyPrefix = [NSString stringWithFormat:@"%@=", key];
	for (NSString* elt in parts2){
		if ([elt hasPrefix:keyPrefix]){
			NSString *encodedValue = [elt substringFromIndex:keyPrefix.length];
			NSString *ret = [encodedValue stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			if ([ret isEqualToString:@"(null)"]) return nil;//HACK: sometimes, a value of (null) has been added
			return ret ;
		}
	}
	return nil;
	
	
}

- (NSString *) urlByAddingParameterInUrlStringWithKey:(NSString*)key withValue:(NSString*)value{
	NSRange slashRange = [self rangeOfString:@"/"];
	NSRange qMarkRange = [self rangeOfString:@"?"];
	NSRange columRange = [self rangeOfString:@":"];
	NSString * prefixToAdd = @"&";
	//This does not encode slashes NSString * encodedValue = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * encodedValue = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)value, NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8 );
	
    //Determine what prefix needs to be added
    if (qMarkRange.location==NSNotFound){
		prefixToAdd = @"?";
		if ((slashRange.location==NSNotFound)&&(columRange.location!=NSNotFound)) prefixToAdd = @"/?";
        
		
	}
    NSString * ret = [NSString stringWithFormat:@"%@%@%@=%@",self,prefixToAdd,key,encodedValue];
    
    //Check if there was already a value with the key in the url
    NSString * oldValue = [self valueOfParameterInUrlStringforKey:key];
    if (oldValue){
        NSString * encodedOldValue = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)oldValue, NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8 );
        NSString * keyWithEqual = [key stringByAppendingString:@"="];
        ret = [self stringByReplacingOccurrencesOfString:[keyWithEqual stringByAppendingString:encodedOldValue] withString:[keyWithEqual stringByAppendingString:encodedValue]];
        [encodedOldValue release];
        
    }
    
    [encodedValue release];
	return ret;
    
}



- (LinkType) typeOfLinkOfUrlString{
    NSString * scheme = [self schemePartOfUrlString];    
	NSString * extension = [[self noArgsPartOfUrlString] pathExtension];
	NSRange RSSrange = [self rangeOfString :@"feeds"];
	NSRange MAPrange = [self rangeOfString :@"maps.google"];
	NSRange iTunesRange = [self rangeOfString :@"itunes.apple"];
	NSSet * externalSchemes = [NSSet setWithObjects:@"mailto",@"tel",@"librelio",nil];
	NSString * linkTypeString = [self valueOfParameterInUrlStringforKey:@"waview"];
    NSString * lores = [self valueOfParameterInUrlStringforKey:@"walowres"];
    
	if (linkTypeString) return [linkTypeString intValue];
    else if (lores) return LinkTypeZoomImage;//If the walores arg is set, it means it is a ZoomImage
	else if ([scheme isEqualToString:@"self"]) return LinkTypeSelf;
	else if ([scheme isEqualToString:@"buy"]) return LinkTypeBuy;
    else if ([scheme isEqualToString:@"search"]) return LinkTypeSearch;
	else if ([scheme isEqualToString:@"share"]) return LinkTypeShare;
	else if ([externalSchemes containsObject:scheme]) return LinkTypeExternal;
	else if ([scheme isEqualToString:@"file"]) return LinkTypeFileManager;
	else if ([extension isEqualToString:@"mov"]||[extension isEqualToString:@"mp4"]) return LinkTypeVideo; 
	else if ([extension isEqualToString:@"png"]||[extension isEqualToString:@"jpg"]) return LinkTypeSlideShow;
	else if ([extension isEqualToString:@"mp3"]||[extension isEqualToString:@"mp3"]) return LinkTypeMusic;
	else if ([extension isEqualToString:@"pdf"]) return LinkTypePaginated;
	else if ([extension isEqualToString:@"gif"]) return LinkTypeAnimation;
	else if ([extension isEqualToString:@"rss"]) return LinkTypeTable;
	else if ([extension isEqualToString:@"atom"]) return LinkTypeTable;
	else if ([extension isEqualToString:@"plist"]) return LinkTypeGrid;
	else if ([extension isEqualToString:@"tab"]) return LinkTypeTable;
	else if ([extension isEqualToString:@"sqlite"])return LinkTypeDatabase;
	else if ([extension isEqualToString:@"kml"]) return LinkTypeMap;
	else if ([extension isEqualToString:@"chart"]) return LinkTypeChart;
	else if ([extension isEqualToString:@"scan"]) return LinkTypeScan;
	else if ([extension isEqualToString:@"txt"]) return LinkTypeText;
	else if (RSSrange.location != NSNotFound) return LinkTypeRSS;//The URL contains the word feed, we assume it is an RSS feed
	else if (MAPrange.location != NSNotFound) return LinkTypeMap; 
	else if (iTunesRange.location != NSNotFound) return LinkTypeExternal; 
	else return LinkTypeHTML;
	
}

- (NSString*) classNameOfModuleOfUrlString{
    NSString * ret;
    LinkType linkType = [self typeOfLinkOfUrlString];
    switch (linkType) {
        case LinkTypeMap:{
            ret = @"WAMapView";
            break;
        }
        case LinkTypeGrid:{
            ret = @"WAGridView";
            break;
            
        }
        case LinkTypeHTML:{
            ret = @"WAHTMLView";
            break;
            
        }
        case LinkTypeVideo:{
            ret = @"WAVideoView";
            break;
            
        }
        case LinkTypePaginated:{
            ret = @"WAPaginatedView";
            break;
            
        }
        case LinkTypeBuy:{
            ret = @"WABuyView";
            break;
            
        }
         case LinkTypeDatabase:{
            ret = @"WATableContainerView";
            break;
            
        }
        case LinkTypeTable:{
            ret= @"WATableView";
            break;
            
        }
        case LinkTypeFileManager:{
            ret = @"WAFileManager";
            break;
        }
        case LinkTypeExternal:{
            ret=@"WAExternalView";
            break;
        }
        case LinkTypeChart:{
            ret = @"WAChartView";
            break;
        }
            
        case LinkTypeSlideShow:{
            ret =@"WASlideShowView";
            break;
        }
        case LinkTypeShare:{
            ret = @"WAShareView";
            break;
        }
            
        case LinkTypeSearch:{
            ret = @"WASearchView";
            break;
        }
            
        case LinkTypePlain:{
            ret = @"WAPlainView";
            break;
        }

        case LinkTypeZoomImage:{
            ret = @"WAZoomImage";
            break;
        }
        case LinkTypeRSS:{
            ret = @"WAPaginated";
            break;
        }
        case LinkTypeScan:{
            ret = @"WAScanView";
            break;
        }
        case LinkTypeOpenCVClient:{
            ret = @"WAOpenCVClientView";
            break;
        }
        case LinkTypeAnalytics:{
            ret = @"WAAnalyticsView";
            break;
        }

            

            
        default:
            break;
    }
    return ret;

}

- (ParserType) typeOfParserOfUrlString{
	NSString * extension = [[self noArgsPartOfUrlString] pathExtension];
    if ([extension isEqualToString:@"pdf"]) return ParserTypePDF;
	else if ([extension isEqualToString:@"plist"]) return ParserTypePList;
	else if ([extension isEqualToString:@"html"]) return ParserTypeHTML;
	else if ([extension isEqualToString:@"kml"]) return ParserTypeKML;
	else if ([extension isEqualToString:@"sqlite"]) return ParserTypeSQLite;
	else if ([extension isEqualToString:@"rss"]) return ParserTypeRSS;
	else if ([extension isEqualToString:@"atom"]) return ParserTypeAtom;
	else if ([extension isEqualToString:@"local"]) return ParserTypeLocal;
	else return ParserTypeHTML;
	
}

- (NSString*) classNameOfParserOfUrlString{

    ParserType parserType = [self typeOfParserOfUrlString];
    NSString * ret;
    switch (parserType) {
		case ParserTypePDF:{
			ret = @"WAPDFParser";
			break;
		}
		case ParserTypePList:{
			ret = @"WAPListParser";
			break;
		}
		case ParserTypeHTML:{
			ret = @"WAHTMLParser";
			break;
		}
		case ParserTypeKML:{
			ret = @"WAKMLParser";
			break;
		}
		case ParserTypeSQLite:{
			ret = @"WASQLiteParser";
			break;
		}
		case ParserTypeRSS:{
			ret = @"RSSParser";
			break;
		}
        case ParserTypeAtom:{
			ret = @"WAAtomParser";
			break;
		}
        case ParserTypeLocal:{
			ret = @"WALocalParser";
			break;
		}


		default:
			break;
	}
    return ret;
    
}





- (BOOL) shouldUseNewsstandForUrlString{
    //First check if Newsstand is available
    if (NSClassFromString(@"NKLibrary")){
        //Then check if newsstand is enabled in the app
        if ([NKLibrary sharedLibrary]){
            //Then check the type of link
            LinkType  moduleType = [self typeOfLinkOfUrlString];
            if ((moduleType == LinkTypePaginated)||(moduleType == LinkTypeSearch)) return YES;
        }
     }
    return NO;
}

- (NSSet*) relevantSKProductIDsForUrlString{
    NSString * shortID = [[self urlByRemovingFinalUnderscoreInUrlString] nameOfFileWithoutExtensionOfUrlString];
	NSSet * ret = [NSSet setWithObjects:shortID,@"MonthlySubscription",@"WeeklySubscription",@"QuarterlySubscription",@"YearlySubscription",@"HalfYearlySubscription",@"YearlySubscription2",@"HalfYearlySubscription2",@"HalfYearlySubscription3",@"FreeSubscription",nil];
    return ret;

}

- (NSString *) titleWithSubscriptionLengthForId:(NSString*)theId{
	NSArray *parts = [theId componentsSeparatedByString:@"."];
	theId = [parts objectAtIndex:[parts count]-1];
    NSString * ret = self;
    if ([theId isEqualToString:@"WeeklySubscription"] ) ret = [NSString stringWithFormat:@"%@ 1 %@",ret,NSLocalizedString(@"week",@"")];
    if ([theId isEqualToString:@"MonthlySubscription"] ) ret = [NSString stringWithFormat:@"%@ 1 %@",ret,NSLocalizedString(@"month",@"")];
    if ([theId isEqualToString:@"QuarterlySubscription"] ) ret = [NSString stringWithFormat:@"%@ 3 %@",ret,NSLocalizedString(@"months",@"")];
    if ([theId isEqualToString:@"HalfYearlySubscription"]||[theId isEqualToString:@"HalfYearlySubscription2"]||[theId isEqualToString:@"HalfYearlySubscription3"] ) ret = [NSString stringWithFormat:@"%@ 6 %@",ret,NSLocalizedString(@"months",@"")];
    if ([theId isEqualToString:@"YearlySubscription"]||[theId isEqualToString:@"YearlySubscription2"]  ) ret = [NSString stringWithFormat:@"%@ 1 %@",ret,NSLocalizedString(@"year",@"")];
    return ret;
    
}

- (NSString*) receiptForUrlString{
    //Check whether we have active subscriptions, or if we already bought this product, or if a subscription code was provided earlier
    NSSet * relevantIDs = [self relevantSKProductIDsForUrlString];
    NSString * receipt = nil;
    for(NSString * currentID in relevantIDs){
        NSString *tempKey = [NSString stringWithFormat:@"%@-receipt",currentID];
        NSString * tempReceipt = [[NSUserDefaults standardUserDefaults] objectForKey:tempKey];
        if (tempReceipt && ![tempReceipt isEqualToString:@""]){
            receipt = tempReceipt;
        }
    }
    //If no receipt was found, finally check wether user has entered a Subscription code
	if (!receipt) receipt = [[NSUserDefaults standardUserDefaults] objectForKey:@"Subscription-code"];
    
    return (receipt);


}

- (NSString*) queryStringByReplacingClause:(NSString*)clause withValue:(NSString*)newValue{
    NSString * oldValue = [self valueOfClause:(NSString*)clause];
    NSString * clauseAndNewValue = [NSString stringWithFormat:@" %@ %@",clause,newValue];
    if (oldValue){
         NSString * clauseAndOldValue = [NSString stringWithFormat:@" %@ %@",clause,oldValue];
        return [self stringByReplacingOccurrencesOfString:clauseAndOldValue withString:clauseAndNewValue];
    }
    else{
        return [self stringByAppendingString:clauseAndNewValue];
    }
    
}

- (NSString*) valueOfClause:(NSString*)clause{
    //If the clause contains 2 words, such as ORDER BY, take only the last word
    NSArray * cParts = [clause componentsSeparatedByString:@" "];
    NSString * lastWordOfClause = [cParts objectAtIndex:([cParts count]-1)];
    NSArray * parts = [self componentsSeparatedByString:@" "];
    NSString * nextWord = nil;
    NSString * nextWord2 = nil;
    NSEnumerator *enumerator = [parts reverseObjectEnumerator];
    for (NSString*part in enumerator){
        if ([[part uppercaseString] isEqualToString:lastWordOfClause]){
            //If the clause is Order By, we should also return  the suffix ASC or DESC
            if ([[clause uppercaseString]isEqualToString:@"ORDER BY"])
                return ([NSString stringWithFormat:@"%@ %@",nextWord,nextWord2]);
            else
                return nextWord;
            
        }
        if (part) {
            nextWord2 = nextWord;
            nextWord = part;
        }
        
    }
    return nil;

    
}

- (NSString*) gaVirtualUrlForModuleWithName:(NSString*)moduleName withPage:(NSString*)pageName{
    NSString * appLongID = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleIdentifier"];
    NSArray *parts = [appLongID componentsSeparatedByString:@"."];
    NSString * appName = [parts objectAtIndex:[parts count]-1];
    //NSString * clientShortID = [parts objectAtIndex:[parts count]-2];
    //if ([clientShortID isEqualToString:@"widgetavenue"]) clientShortID = @"librelio";//this is for back compatibility reasons
    NSString * fileName = [self nameOfFileWithoutExtensionOfUrlString];
    
    NSString * completeUrl = [NSString stringWithFormat:@"%@/ios/%@/%@",appName,moduleName,fileName];
    if (pageName) completeUrl = [NSString stringWithFormat:@"%@/%@",completeUrl,pageName];
    return completeUrl;

}

//Created by Vladimir
- (NSString *)device
{
    NSString * ret = [NSString stringWithFormat:@"%@Ipad", self];//Default
    if (![WAUtilities isBigScreen]) ret = [NSString stringWithFormat:@"%@Iphone", self];
    return ret;
    
    /**Seems to have caused problems with Apple 
    switch(UIDevice.currentDevice.userInterfaceIdiom)
    {
        case UIUserInterfaceIdiomPhone:
            return [NSString stringWithFormat:@"%@Iphone", self];
        default:
            return [NSString stringWithFormat:@"%@Ipad", self];
    }**/
}
//Created by Vladimir
+ (NSString *)orientation
{
    // UIDevice.currentDevice.orientation improperly returns orientation
	// Source: http://stackoverflow.com/a/6680597/124115
	switch ([[UIApplication sharedApplication] statusBarOrientation])
    {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
            return @"Portrait";
        default:
            return @"Landscape";
    }
}


@end
