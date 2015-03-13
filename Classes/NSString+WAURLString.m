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
#import "NSBundle+WAAdditions.h"


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
    NSURL * url = [NSURL URLWithString:self];
    if (![[url scheme] length])
    {
        return @"http";
    }
    else {
        return [url scheme];
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
    return([[NSBundle mainBundle]stringForKey:tempTitle]);
 
    
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

- (NSString*) urlBySubstitutingHyphensWithResolutionForOrientation:(UIInterfaceOrientation)orientation{
    if ([self rangeOfString:@"--x--"].location == NSNotFound){
        return self;
    }
    else{
        CGFloat height = [[ UIScreen mainScreen ]bounds].size.height;
        CGFloat width = [[ UIScreen mainScreen ]bounds].size.width;
        NSString*resolution;
        switch(orientation)
        {
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown:
                resolution =  [NSString stringWithFormat:@"--%fx%fpx",width,height];
            default:
                resolution =  [NSString stringWithFormat:@"--%fx%fpx",height,width];
        }
        NSString * ret = [self stringByReplacingOccurrencesOfString:@"--x--" withString:resolution];
        return ret;
        
    }
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

- (NSString*) urlByChangingExtensionOfUrlStringToSuffix:(NSString*)newSuffix{
    NSString *fileName = [self noArgsPartOfUrlString];
    NSString *newFileName = [NSString stringWithFormat:@"%@%@", [fileName nameOfFileWithoutExtensionOfUrlString],newSuffix];
    return [WAUtilities absoluteUrlOfRelativeUrl:newFileName relativeToUrl:self];
    
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

- (NSString*) urlOfCacheFileWithName:(NSString*)fileName {
	NSString * urlWithoutArg = [self noArgsPartOfUrlString];
	NSString * pdfNameWithoutExt =  [[urlWithoutArg lastPathComponent] stringByDeletingPathExtension];
	NSString *pdfDirUrl = [WAUtilities directoryUrlOfUrlString:self];
	return [NSString stringWithFormat:@"%@/%@_cache/%@",pdfDirUrl,pdfNameWithoutExt,fileName];
	
}


- (NSString*) urlOfMainFileOfPackageWithUrlString{
    //If extension is .plugin, change url string.
    NSString* extension = [self pathExtension];
    if ([extension isEqualToString:@"plugin"]){
        NSString * fileName = [self nameOfFileWithoutExtensionOfUrlString];
        return ([NSString stringWithFormat:@"%@/%@.pdf",self,fileName]);
        
    }
    else if ([extension isEqualToString:@"rtfd"]){
        return ([NSString stringWithFormat:@"%@/index.html",self]);
    }
    else{
        return self;
    }
    
}



-   (NSString *) urlOfUnzippedFolder{
    //If there is a waroot arg, use it
    NSString * baseUrl = [self valueOfParameterInUrlStringforKey:@"waroot"];
    if (!baseUrl) baseUrl = self;
    NSString * fileName = [self nameOfFileWithoutExtensionOfUrlString];
    return [baseUrl urlOfCacheFileWithName:fileName];
    
}


- (LinkType) typeOfLinkOfUrlString{
    
    //If self starts with file:///, remove the dir path to make a distinction between real local file links, and the local:// prefix we use for our local module
    NSString * cacheDirUrlString = [NSString stringWithFormat:@"file://%@",[[WAUtilities cacheFolderPath]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString * urlString = [self stringByReplacingOccurrencesOfString:cacheDirUrlString withString:@""];

    NSString * scheme = [urlString schemePartOfUrlString];
	NSString * extension = [[urlString noArgsPartOfUrlString] pathExtension];
    //SLog(@"scheme:%@ for url %@",scheme,self);
	NSRange RSSrange = [urlString rangeOfString :@"feeds"];
	NSRange MAPrange = [urlString rangeOfString :@"maps.google"];
	NSRange iTunesRange = [urlString rangeOfString :@"itunes.apple"];
	NSSet * externalSchemes = [NSSet setWithObjects:@"mailto",@"tel",@"librelio",nil];
	NSString * linkTypeString = [urlString valueOfParameterInUrlStringforKey:@"waview"];
    NSString * lores = [urlString valueOfParameterInUrlStringforKey:@"walowres"];
    
	if (linkTypeString) return [linkTypeString intValue];
    else if (lores) return LinkTypeZoomImage;//If the walores arg is set, it means it is a ZoomImage
	else if ([scheme isEqualToString:@"self"]) return LinkTypeSelf;
	else if ([scheme isEqualToString:@"buy"]) return LinkTypeBuy;
    else if ([scheme isEqualToString:@"search"]) return LinkTypeSearch;
    else if ([scheme isEqualToString:@"share"]) return LinkTypeShare;
    else if ([scheme isEqualToString:@"ad"]) return LinkTypeAds;
	else if ([externalSchemes containsObject:scheme]) return LinkTypeExternal;
	else if ([scheme isEqualToString:@"file"]) return LinkTypeFileManager;
	else if ([extension isEqualToString:@"mov"]||[extension isEqualToString:@"mp4"]) return LinkTypeVideo; 
	else if ([extension isEqualToString:@"png"]||[extension isEqualToString:@"jpg"]) return LinkTypeSlideShow;
	else if ([extension isEqualToString:@"mp3"]||[extension isEqualToString:@"mp3"]) return LinkTypeMusic;
	else if ([extension isEqualToString:@"pdf"]||[extension isEqualToString:@"folio"]) return LinkTypePaginated;
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
        case LinkTypeAds:{
            ret = @"WAAdView";
            break;
        }


            

            
        default:
            break;
    }
    //SLog(@"ret:%@",ret);
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
	else if ([extension isEqualToString:@"oam"]) return ParserTypeOAM;
    else if ([extension isEqualToString:@"zip"]) return ParserTypeZip;
    else if ([extension isEqualToString:@"folio"]) return ParserTypeFolio;
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
			ret = @"WARSSParser";
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
        case ParserTypeOAM:{
			ret = @"WAOAMParser";
			break;
		}
        case ParserTypeZip:{
            ret = @"WAZippedHtmlParser";
            break;
        }
        case ParserTypeFolio:{
            ret = @"WAFolioParser";
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
            if ((moduleType == LinkTypePaginated)||(moduleType == LinkTypeSearch)){
                 //SLog(@"will return yes for url:%@",self);
                return YES;
            }
        }
     }
    //SLog(@"will return no");
    return NO;
}

- (NSString*) appStoreProductIDForLibrelioProductID{
    NSString * ret = [NSString stringWithFormat:@"com.%@.%@.%@",[[NSBundle mainBundle] getLibrelioClientId],[[NSBundle mainBundle] getLibrelioAppId],self];
    
    //Check if we have specific IDs
    NSDictionary * app_Dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathOfFileWithUrl:@"Application_.plist"]];
    NSDictionary * specificIds = [app_Dic objectForKey:@"SpecificAppStoreIDs"];
    if (specificIds) {
        NSString * specificId = [specificIds objectForKey:self];
        if (specificId) ret = specificId;
    }
    

    
    return ret;

    
}


- (NSSet*) relevantLibrelioProductIDsForUrlString{
    NSString * shortID = [[self urlByRemovingFinalUnderscoreInUrlString] nameOfFileWithoutExtensionOfUrlString];
	NSSet * ret = [NSSet setWithObjects:shortID,@"MonthlySubscription",@"WeeklySubscription",@"QuarterlySubscription",@"YearlySubscription",@"HalfYearlySubscription",@"YearlySubscription2",@"HalfYearlySubscription2",@"HalfYearlySubscription3",@"FreeSubscription",nil];
    return ret;

}

- (NSString *) titleWithSubscriptionLengthForId:(NSString*)theId{
	NSArray *parts = [theId componentsSeparatedByString:@"."];
	theId = [parts objectAtIndex:[parts count]-1];
    NSString * ret = self;
    if ([theId isEqualToString:@"WeeklySubscription"] ) ret = [NSString stringWithFormat:@"%@ 1 %@",ret,[[NSBundle mainBundle]stringForKey:@"week"]];
    if ([theId isEqualToString:@"MonthlySubscription"] ) ret = [NSString stringWithFormat:@"%@ 1 %@",ret,[[NSBundle mainBundle]stringForKey:@"month"]];
    if ([theId isEqualToString:@"QuarterlySubscription"] ) ret = [NSString stringWithFormat:@"%@ 3 %@",ret,[[NSBundle mainBundle]stringForKey:@"months"]];
    if ([theId isEqualToString:@"HalfYearlySubscription"]||[theId isEqualToString:@"HalfYearlySubscription2"]||[theId isEqualToString:@"HalfYearlySubscription3"] ) ret = [NSString stringWithFormat:@"%@ 6 %@",ret,[[NSBundle mainBundle]stringForKey:@"months"]];
    if ([theId isEqualToString:@"YearlySubscription"]||[theId isEqualToString:@"YearlySubscription2"]  ) ret = [NSString stringWithFormat:@"%@ 1 %@",ret,[[NSBundle mainBundle]stringForKey:@"year"]];
    return ret;
    
}

- (NSString*) receiptForUrlString{
    //Check whether we have active subscriptions, or if we already bought this product, or if a subscription code was provided earlier
    NSSet * relevantIDs = [self relevantLibrelioProductIDsForUrlString];
    NSString * receipt = nil;
    for(NSString * currentID in relevantIDs){
        NSString *tempKey = [NSString stringWithFormat:@"%@-receipt",currentID];
        NSString * tempReceipt = [[NSUserDefaults standardUserDefaults] objectForKey:tempKey];
        if (tempReceipt && ![tempReceipt isEqualToString:@""]){
            receipt = tempReceipt;
        }
    }
    //If no receipt was found, check whether user has entered a Subscription code
	if (!receipt) receipt = [[NSUserDefaults standardUserDefaults] objectForKey:@"Subscription-code"];
    //If no receipt was found, finally check whether user has entered a username and password
	if (!receipt) receipt = [[NSUserDefaults standardUserDefaults] objectForKey:@"Username"];
    
    return (receipt);


}


- (NSString*) completeAdUnitCodeForShortCode:(NSString*)shortAdUnitCode{
    
    //Check if there are several languages in the app; in this case, load ad in preferred language
    NSDictionary * app_Dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathOfFileWithUrl:@"Application_.plist"]];
    NSString * language;
    NSString * preferredLanguage;

    if ([app_Dic objectForKey:@"Languages"]){
        NSString * preferredPlist = [[NSUserDefaults standardUserDefaults] objectForKey:@"PreferredLanguagePlist"];
        if (preferredPlist){
            //Find the language corresponding to the prefered plist; the language name is after the last "_"
            NSString * plistFileName = [preferredPlist nameOfFileWithoutExtensionOfUrlString];
            NSArray *parts = [plistFileName componentsSeparatedByString:@"_"];
            language = [parts objectAtIndex:[parts count]-1];
            
        }
        else  language = [[NSLocale preferredLanguages] objectAtIndex:0];//If language has not been chosen by user yet, choose the default language
        preferredLanguage = [language stringByAppendingString:@"_"];
        
    }
    else{
        preferredLanguage = @"";
    }
    return [NSString stringWithFormat:@"%@%@%@",self,preferredLanguage,shortAdUnitCode];

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

- (NSString*) gaScreenForModuleWithName:(NSString*)moduleName withPage:(NSString*)pageName{
    NSString * fileName = [self nameOfFileWithoutExtensionOfUrlString];
    
    NSString * completeUrl = [NSString stringWithFormat:@"%@/%@",moduleName,fileName];
    if (pageName) completeUrl = [NSString stringWithFormat:@"%@/%@",completeUrl,pageName];
    return completeUrl;

}

- (NSString *)stringFormattedRTF

{
    NSMutableString *result = [NSMutableString string];
    
    for ( int index = 0; index < [self length]; index++ ) {
        NSString *temp = [self substringWithRange:NSMakeRange( index, 1 )];
        unichar tempchar = [self characterAtIndex:index];
        
        if ( tempchar > 127) {
            [result appendFormat:@"\\\'%02x", tempchar];
        } else {
            [result appendString:temp];
        }
    }
    return result;
}

- (NSString*)stringWithRTFHeaderAndFooter{
    NSString * rtfHeader = @"{\\rtf1\\ansi\\ansicpg1252\\cocoartf1344\\cocoasubrtf720\n{\\fonttbl\\f0\\fswiss\\fcharset0 Helvetica;}\n{\\colortbl;\\red255\\green255\\blue255;}\n\\paperw11900\\paperh16840\\margl1440\\margr1440\\vieww10800\\viewh8400\\viewkind0\n\\pard\\tx560\\tx1120\\tx1680\\tx2240\\tx2800\\tx3360\\tx3920\\tx4480\\tx5040\\tx5600\\tx6160\\tx6720\\pardirnatural\n\n\\f0 ";
    return [NSString stringWithFormat:@"%@%@}",rtfHeader,self];

}


@end
