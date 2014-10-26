//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.

#import "WAUtilities.h"
#import <QuartzCore/QuartzCore.h>

#import "NSString+WAURLString.h"
#import "UIView+WAModuleView.h"
#import "NSBundle+WAAdditions.h"

#import <NewsstandKit/NewsstandKit.h>




#define kDownloadUrl @"http://librelio-europe.s3.amazonaws.com"
#define kCheckAppStoreUrl @"http://download.librelio.com/downloads/appstorev2.php?receipt=%@&sharedsecret=%@&urlstring=%@&userkey=%@"
#define kCheckPasswordUrl @"http://download.librelio.com/downloads/pswd.php?code=%@&service=%@&urlstring=%@&client=%@&app=%@&deviceid=%@"
#define kCheckUsernamePasswordUrl @"http://download.librelio.com/downloads/subscribers.php?user=%@&pswd=%@&urlstring=%@&client=%@&app=%@&service=%@&deviceid=%@"


@implementation WAUtilities

#pragma mark -
#pragma mark URLString modifications






+ (NSString *) hashPartOfUrlString:(NSString*)urlString{
	NSArray *parts = [urlString componentsSeparatedByString:@"#"];
	
	if ([parts count]>1) return [parts objectAtIndex:1];
	return nil;

}




+ (NSString*)directoryUrlOfUrlString:(NSString*)urlString{
    NSString * noLocalHost = [urlString stringByReplacingOccurrencesOfString:@"http://localhost" withString:@""];
    NSString * noArgs = [noLocalHost noArgsPartOfUrlString];
   
	NSRange range = [noArgs rangeOfString:@"/" options:NSBackwardsSearch];
	NSString * dir = @"";
	if (range.location != NSNotFound) dir = [noArgs substringToIndex:range.location];
    
    //Add a / prefix if the dir string is not empty
    if ((![dir isEqualToString:@""])&&(![dir hasPrefix:@"/"])&&(![dir hasPrefix:@"http://"])&&(![dir hasPrefix:@"file://"]))
        dir = [NSString stringWithFormat:@"/%@",dir];
    
    //SLog(@"Dir of %@:%@",urlString,dir);
	return dir;
	
}

+ (NSString*) absoluteUrlOfRelativeUrl:(NSString*)relativeUrl relativeToUrl:(NSString*)baseUrl{
    //SLog(@"start absoluteUrlOfRelativeUrl:%@ relativeToUrl:%@",relativeUrl,baseUrl);
	NSString * urlWithoutLocalHost = [relativeUrl stringByReplacingOccurrencesOfString:@"http://localhost/" withString:@""];
	NSRange slashSlashRange = [urlWithoutLocalHost rangeOfString :@"://"];
	NSString * ret = @"";
	
	if (([relativeUrl hasPrefix:@"/"])||([relativeUrl hasPrefix:@"mailto:"])||([relativeUrl hasPrefix:@"tel:"])||([relativeUrl hasPrefix:@"www"])||(slashSlashRange.location != NSNotFound)){
		//relativeURL is starting with / or with www or with mailto or tel or http without local host: it is already an absolute URL
		ret= relativeUrl;
	}
	else{
		NSString *dir = [self directoryUrlOfUrlString:baseUrl];
		ret = [NSString stringWithFormat:@"%@/%@",dir,urlWithoutLocalHost] ;
 		
	}
    
    //If ret starts with file://, remove the dir path to make a distinction between real local file links, and the local:// prefix we use for our local module
    NSString * cacheDirUrlString = [NSString stringWithFormat:@"file://%@",[[WAUtilities cacheFolderPath]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString * ret2 = [ret stringByReplacingOccurrencesOfString:cacheDirUrlString withString:@""];
    //SLog(@"ret:%@ cacheUrl: %@, ret2:%@",ret,cacheDirUrlString,ret2);

    return ret2;

}

+ (NSString*) urlByChangingExtensionOfUrlString:(NSString*)urlString toSuffix:(NSString*)newSuffix{
	NSString *fileName = [urlString noArgsPartOfUrlString];
	NSString *newFileName = [NSString stringWithFormat:@"%@%@", [fileName nameOfFileWithoutExtensionOfUrlString],newSuffix];
	return [self absoluteUrlOfRelativeUrl:newFileName relativeToUrl:urlString];

}


+ (NSString*) urlByRemovingContainingFolderIfSameNameInUrlString:(NSString*)urlString {
	NSString * fileName = [urlString nameOfFileWithoutExtensionOfUrlString];
	NSString * fileNameRepeated = [NSString stringWithFormat:@"%@/%@",fileName,fileName];
	return [urlString stringByReplacingOccurrencesOfString:fileNameRepeated withString:fileName];
}
+ (NSDate *) dateOfFileWithUrlString:(NSString*)urlString{
	NSString * tempPath = [[NSBundle mainBundle] pathOfFileWithUrl:urlString];
    //SLog(@"finding date of file %@",tempPath);
    NSDate * ret = nil;//Return nil by default
    //Check if the file is in the app bundle, or the cache directory; if it is in the cache bundle, the date does not mean anything, so we return nil;
    if (tempPath &&[tempPath hasPrefix:[self cacheFolderPath]]){
        ret = [[[NSFileManager defaultManager] attributesOfItemAtPath:tempPath error:NULL] objectForKey:NSFileModificationDate] ;
    }

	return ret;

}

+ (NSDate*) creationDateOfFileWithUrlString:(NSString*)urlString{
    NSString * tempPath = [[NSBundle mainBundle] pathOfFileWithUrl:urlString];
    //SLog(@"finding date of file %@",tempPath);
    NSDate * ret = nil;//Return nil by default
    //Check if the file is in the app bundle, or the cache directory; if it is in the cache bundle, the date does not mean anything, so we return nil;
    if (tempPath &&[tempPath hasPrefix:[self cacheFolderPath]]){
        ret = [[[NSFileManager defaultManager] attributesOfItemAtPath:tempPath error:NULL] objectForKey:NSFileCreationDate] ;
    }
    
    return ret;
}




+(NSArray*) arrayOfImageUrlStringsForUrlString:(NSString *)lastImageUrlString{
    //SLog(@"LastImageUrl:%@",lastImageUrlString);
	NSString * urlWithoutArg = [lastImageUrlString noArgsPartOfUrlString];
	NSString * lastImageNameWithoutExt =  [[urlWithoutArg lastPathComponent] stringByDeletingPathExtension];
	NSString * imageExtension = [urlWithoutArg pathExtension];
	
	NSMutableArray *tempArray= [NSMutableArray array];
	
	//Check if lastImageNameWithoutExt contains "_";
	NSRange range = [lastImageNameWithoutExt rangeOfString:@"_" options:NSBackwardsSearch];
	if (range.location == NSNotFound){
		//Add only 1 image in the array
		[tempArray addObject:lastImageUrlString];
	}
	else{
		NSString * imageNamePrefix = [lastImageNameWithoutExt substringToIndex:range.location+1];
		int numberImages = [[lastImageNameWithoutExt substringFromIndex:range.location+1] intValue];
		int i;
		
		for (i = 1; i <= numberImages; i++) {
			NSString *tempFileName = [NSString stringWithFormat:@"%@%d.%@",imageNamePrefix,i,imageExtension];
            NSRange range = [urlWithoutArg rangeOfString:@"/" options:NSBackwardsSearch];
            NSString * dir = @"";
            if (range.location != NSNotFound) dir = [urlWithoutArg substringToIndex:range.location];
            NSString * tempUrl = [NSString stringWithFormat:@"%@/%@",dir,tempFileName] ;

			[tempArray addObject:tempUrl];
			
		}
	}
	NSArray * ret = [NSArray  arrayWithArray:tempArray];
	return ret;
}



#pragma mark -
#pragma mark File management

+(NSString*)cacheFolderPath
{
	NSString *documentsFolderPath;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);//We now use the /Library/Caches directory pursuant to Apple's new specs http://developer.apple.com/icloud/documentation/data-storage
    documentsFolderPath = [paths objectAtIndex:0];	
    //iCloud
    
	return documentsFolderPath;
}


+ (void) storeFileWithUrlString:(NSString*)urlString withData:(NSData *) data{
	NSString *newFilePath = [urlString pathOfStorageForUrlString];
	NSString* dirPath=[self directoryUrlOfUrlString:newFilePath];
	if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
		//Directory does not exist, must be created
        NSError *error = nil;
		[[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error]; 
		
	}
	[[NSFileManager defaultManager] createFileAtPath:newFilePath contents:data attributes:nil];
	
}

+ (void) storeFileWithUrlString:(NSString*)urlString withFileAtPath:(NSString*)tempFilePath{
	NSString *newFilePath = [urlString pathOfStorageForUrlString];
	NSString* dirPath=[self directoryUrlOfUrlString:newFilePath];

    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
		//Directory does not exist, must be created
		[[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:NULL]; 
		
	}
	
	if (tempFilePath){
		NSError *error=nil;
		NSError *error2 =nil;
		NSDictionary * attDic = [[NSFileManager defaultManager]attributesOfItemAtPath:tempFilePath error:nil];
		if (([attDic fileSize]==0)&&([attDic fileType]==NSFileTypeRegular)){
			//If this is a file (not a directory) and the size is zero, delete it, 
			[[NSFileManager defaultManager]removeItemAtPath:tempFilePath error:nil];
            //NSLog(@"Deleted empty file");
		}
		else{
			//Move the file or directory
			[[NSFileManager defaultManager] removeItemAtPath:newFilePath error:&error2];//Remove existing file at filePath, if there is one
			//if (error2) SLog(@"Error:%@ when removing file at path:%@",[error2 localizedDescription],newFilePath);
			[[NSFileManager defaultManager] moveItemAtPath:tempFilePath toPath:newFilePath error:&error];
			//if (error) NSLog(@"Error:%@ with file at path:%@",error,tempFilePath);
            //else NSLog(@"moved from %@ to %@",tempFilePath,newFilePath);
            
        }

		

				 
		
	}
	
	
}

+ (void) clearTempDirectory{
	//The temp directory is located at the root level of the document directory, and called TempWa
	NSString * dirPath = [[NSBundle mainBundle] pathOfFileWithUrl:@"TempWa"];
	[[NSFileManager defaultManager]removeItemAtPath:dirPath error:NULL];

	
}

+ (void) deleteCorruptedResourceWithPath:(NSString*)path ForMainFileWithUrlString:(NSString*)urlString{
    [[NSFileManager defaultManager]removeItemAtPath:path error:NULL];
    
    //Update the metadata dic if needed
    NSString * plistUrl = [WAUtilities urlByChangingExtensionOfUrlString:urlString toSuffix:@"_metadata.plist"];
    NSString * plistPath = [[NSBundle mainBundle] pathOfFileWithUrl:plistUrl];
    if (plistPath){
        NSMutableDictionary * metaDic = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
        //SLog(@"Will set downloadcomplete");
        [metaDic removeObjectForKey:@"DownloadComplete"];
        [metaDic writeToFile:plistPath atomically:YES];
        
    }


    
    
    
    
}


#pragma mark -
#pragma mark Miscelaneous


+ (BOOL) isBigScreen {
	BOOL ret =  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
	return ret;
}

+ (BOOL) isScreenHigherThan500 {
	BOOL ret =  ([ [ UIScreen mainScreen ] bounds ].size.height>500);
	return ret;
}

+ (BOOL) featuresInApps{
    //Check if Newsstand is enabled; in this case, the app MUST feature In Apps
     if (NSClassFromString(@"NKLibrary")){
        //Check if newsstand is enabled in the app
        if ([NKLibrary sharedLibrary]){
            return YES;
        }
    
     }

    
    //If Newsstand is not enabled, check if we have an InApps field in Application_.xml
    NSString * appPrefs = [[NSBundle mainBundle] pathOfFileWithUrl:@"Application_.plist"];
    
	
	if (appPrefs) {
        NSString * inApps = [[NSDictionary dictionaryWithContentsOfFile:appPrefs]objectForKey:@"InApps"];
        if (inApps) return YES;
        
    }
    
    
    return NO;
}


+ (BOOL) isCheckUpdateNeededForUrlString:(NSString*)urlString{
	// NSLog(@"Checking update needed? for url:%@  isLocalUrl: %d",urlString, (int)[urlString isLocalUrl]);
	if ([urlString isLocalUrl]) {
		NSString * path = [[NSBundle mainBundle] pathOfFileWithUrl:urlString];
		if (!path) {
            //SLog(@"No local file found");
			return YES; //If there is no local file, an update is definitely needed!
		}
		
		else {
			NSString * mnString = [urlString valueOfParameterInUrlStringforKey:@"waupdate"];
			if (mnString){
				int mn = [mnString intValue];
				NSDate * fileModifDate = [self dateOfFileWithUrlString:urlString];
				NSDate * nextCheckDate = [fileModifDate dateByAddingTimeInterval:60*mn];//waupdate parameter is in minutes
				NSDate * nowDate = [NSDate date];
                //NSLog(@"path: %@ compare: nextCheckDate: %@  now: %@", path, nextCheckDate, nowDate);
				if (![path hasPrefix:[self cacheFolderPath]]){
                    //SLog(@"Document in app bunde, update needed");
					return YES; //The document is in the app bundle, we should check if an update is needed
				}
				else if ([nowDate compare:nextCheckDate]==NSOrderedAscending){
					return NO;
				}
				else{
                        //SLog(@"Time for next check, last check %@, now %@",fileModifDate,nowDate);
						return YES;
				}
			}
			else return NO;
		}
		
	}
	else {
		return NO;//No update needed for non local files
	}
	
	
	
	
}

+ (BOOL)isDownloadMissingResourcesNeededForUrlString :(NSString*)urlString{
    
    if (![urlString isLocalUrl]) {
        return NO;//No missing resources download needed for non local urls
    }
    else{
        NSString * scheme = [urlString schemePartOfUrlString];
        NSString * extension = [[urlString noArgsPartOfUrlString] pathExtension];
        
        if (scheme &&(![scheme isEqualToString:@"http"])){
            //If the scheme is not http , return no
            return NO;
        }
        else if ((![extension isEqualToString:@"sqlite"])&&(![extension isEqualToString:@"plist"])&&(![extension isEqualToString:@"pdf"])&&(![extension isEqualToString:@"atom"])&&(![extension isEqualToString:@"rss"])){
            //Only the files listed above have resources; otherwise, return NO
            return NO;
        }
        else {
            NSString * mainFilePath = [[NSBundle mainBundle] pathOfFileWithUrl:urlString];
            NSString * metadataPlistPath = [WAUtilities urlByChangingExtensionOfUrlString:mainFilePath toSuffix:@"_metadata.plist"];
            NSDictionary * metaDic = [NSDictionary dictionaryWithContentsOfFile:metadataPlistPath];
            if (![metaDic objectForKey:@"DownloadComplete"]) return YES;
            else return NO;
            
            
        }

    }



}

+ (NSString *) getCodeService{
 
    NSString * credentials = [[NSBundle mainBundle] pathOfFileWithUrl:@"Application_.plist"];
	NSString * codeService = nil;
    if (credentials) codeService = [[NSDictionary dictionaryWithContentsOfFile:credentials]objectForKey:@"CodeService"];
    return codeService;

    
    
}

+ (NSString *) getUserService{
    NSString * credentials = [[NSBundle mainBundle] pathOfFileWithUrl:@"Application_.plist"];
	NSString * userService = nil;
    if (credentials) userService = [[NSDictionary dictionaryWithContentsOfFile:credentials]objectForKey:@"UserService"];
    return userService;
   
    
}



#pragma mark -
#pragma mark Download URL generators and UUID

+ (NSString *)getUUID {
    NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceUUID"];
    if (string == nil) {
        CFUUIDRef   uuid;
        CFStringRef uuidStr;
        
        uuid = CFUUIDCreate(NULL);
        uuidStr = CFUUIDCreateString(NULL, uuid);
        
        string = [NSString stringWithFormat:@"%@", uuidStr];
        [[NSUserDefaults standardUserDefaults] setObject:string forKey:@"deviceUUID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        CFRelease(uuidStr);
        CFRelease(uuid);
    }
    
    return string;
}

+ (NSString *) completeDownloadUrlforUrlString:(NSString*)urlString{
    //Check if parameter waurl exists; in this case, use the speicified url, instead of the s3
	NSString * forcedUrl = [urlString valueOfParameterInUrlStringforKey:@"waurl"];
    if (forcedUrl){
        return forcedUrl;
    }
    else{
        NSString * appLongID = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleIdentifier"];
        NSArray *parts = [appLongID componentsSeparatedByString:@"."];
        NSString * appShortID = [parts objectAtIndex:[parts count]-1];
        NSString * clientShortID = [parts objectAtIndex:[parts count]-2];
        if ([clientShortID isEqualToString:@"widgetavenue"]) clientShortID = @"librelio";//this is for back compatibility reasons
        NSString * completeUrl = [NSString stringWithFormat:@"%@/%@/%@%@",kDownloadUrl, clientShortID,appShortID,[urlString noArgsPartOfUrlString]];
        return completeUrl;
    }
}

+ (NSString *) getAuthorizingUrlForUrlString:(NSString*)urlString{
    
    NSString* completeUrl = [WAUtilities completeCheckAppStoreUrlforUrlString:urlString];
    if (!completeUrl)
        completeUrl = [WAUtilities completeCheckPasswordUrlforUrlString:urlString];
    if (!completeUrl)
        completeUrl = [WAUtilities completeCheckUsernamePasswordUrlforUrlString:urlString];
    return completeUrl;
}

+ (NSString *) completeCheckAppStoreUrlforUrlString:(NSString*)urlString{
	//Retrieve receipt if it has been stored
    NSSet * relevantIDs = [urlString relevantSKProductIDsForUrlString];
    NSString * receipt = nil;
    NSString * userKey = nil;
    for(NSString * currentID in relevantIDs){
        NSString *tempKey = [NSString stringWithFormat:@"%@-receipt",currentID];
        NSString * tempReceipt = [[NSUserDefaults standardUserDefaults] objectForKey:tempKey];
        if (tempReceipt){
            receipt = tempReceipt;
            userKey = tempKey;
        }
    }
	if (!receipt) return nil;//If there is no receipt, no need to check app store => return nil
	
	//Retrieve shared secret
	NSString * sharedSecret = @"";
	NSString * credentials = [[NSBundle mainBundle] pathOfFileWithUrl:@"Application_.plist"];
	if (credentials) sharedSecret = [[NSDictionary dictionaryWithContentsOfFile:credentials]objectForKey:@"SharedSecret"];
	
	//Encode UrlString without args
	NSString * encodedUrl = [[urlString noArgsPartOfUrlString] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];

	
	NSString * retUrl = [NSString stringWithFormat:kCheckAppStoreUrl,receipt,sharedSecret,encodedUrl,userKey];
	//SLog(@"retAppSUrl=%@",retUrl);
	return retUrl;
	
}

+ (NSString *) completeCheckPasswordUrlforUrlString:(NSString*)urlString{
	//Get the subscription code
	NSString * password = [[NSUserDefaults standardUserDefaults] objectForKey:@"Subscription-code"];
	if (!password) return nil;//If there is no subscriber code, no need to check subscriber code => return nil

	
	//Get the service
    NSString * credentials = [[NSBundle mainBundle] pathOfFileWithUrl:@"Application_.plist"];
	NSString * codeService = @"";
    if (credentials) codeService = [[NSDictionary dictionaryWithContentsOfFile:credentials]objectForKey:@"UserService"];
    
	
	//Get the encoded URL
	NSString * encodedUrl = [[urlString noArgsPartOfUrlString] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];

	//Get the client and app names
	NSString * appLongID = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleIdentifier"];
	NSArray *parts = [appLongID componentsSeparatedByString:@"."];
	NSString * appShortID = [parts objectAtIndex:[parts count]-1];
	NSString * clientShortID = [parts objectAtIndex:[parts count]-2];
	if ([clientShortID isEqualToString:@"widgetavenue"]) clientShortID = @"librelio";//this is for back compatibility reasons
	
    NSString * deviceid = [self getUUID];
	NSString * retUrl = [NSString stringWithFormat:kCheckPasswordUrl,password,codeService,encodedUrl,clientShortID,appShortID,deviceid];
	//SLog(@"retpassUrl=%@",retUrl);
	return retUrl;
	
}

+ (NSString *) completeCheckUsernamePasswordUrlforUrlString:(NSString*)urlString{
	//Get the subscription code
	NSString * username = [[NSUserDefaults standardUserDefaults] objectForKey:@"Username"];
	if (!username) return nil;//If there is no password, no need to check username and password => return nil
    
	NSString * password = [[NSUserDefaults standardUserDefaults] objectForKey:@"Password"];
	
	//Get the encoded URL
	NSString * encodedUrl = [[urlString noArgsPartOfUrlString] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
	//Get the client and app names
	NSString * appLongID = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleIdentifier"];
	NSArray *parts = [appLongID componentsSeparatedByString:@"."];
	NSString * appShortID = [parts objectAtIndex:[parts count]-1];
	NSString * clientShortID = [parts objectAtIndex:[parts count]-2];
	if ([clientShortID isEqualToString:@"widgetavenue"]) clientShortID = @"librelio";//this is for back compatibility reasons
	
    NSString * deviceid = [self getUUID];
    NSString * credentials = [[NSBundle mainBundle] pathOfFileWithUrl:@"Application_.plist"];
	NSString * userService = @"";
    if (credentials) userService = [[NSDictionary dictionaryWithContentsOfFile:credentials]objectForKey:@"UserService"];

    
	NSString * retUrl = [NSString stringWithFormat:kCheckUsernamePasswordUrl,username,password,encodedUrl,clientShortID,appShortID,userService,deviceid];
	//SLog(@"retpassUrl=%@",retUrl);
	return retUrl;
	
}



#pragma mark -
#pragma mark Nib loading methods




+ (void) resizeNibView:(NSString*) nibName defaultNib:(NSString*) defaultNibName inView:(UIView*) containingView {
	CGSize newSize = [self sizeForResizedNibView:nibName defaultNib:defaultNibName inRect:containingView.frame];
	UIView * embeddedNibView = [[containingView subviews]objectAtIndex:0];//We assume that containingView only has one direct subview
	embeddedNibView.frame = CGRectMake((containingView.frame.size.width-newSize.width)/2, (containingView.frame.size.height-newSize.height)/2, newSize.width, newSize.height);
}

+ (CGSize) sizeForResizedNibView:(NSString*) nibName defaultNib:(NSString*) defaultNibName inRect:(CGRect)contaningRect{
	UIView * initialNibView = [UIView getNibView:nibName defaultNib:defaultNibName forOrientation:999];
	CGFloat initialAspectRatio = initialNibView.frame.size.width/initialNibView.frame.size.height;
	CGFloat containingAspectRatio = contaningRect.size.width/contaningRect.size.height;
	CGSize newSize = contaningRect.size;
	if (initialNibView.contentMode == UIViewContentModeScaleAspectFit){//This can be specified in the nib using the mode filed
		if (containingAspectRatio>initialAspectRatio){
			CGFloat newHeight = MIN(contaningRect.size.height,initialNibView.frame.size.height);//We do not want to increase the size of the nib
			newSize = CGSizeMake(newHeight*initialAspectRatio,newHeight);
		}
		else {
			CGFloat newWidth = MIN(contaningRect.size.width,initialNibView.frame.size.width);//We do not want to increase the size of the nib
			newSize = CGSizeMake(newWidth, newWidth/initialAspectRatio);
		}
	}
	return newSize;
	
}

+ (void)PDFDocument:(id)pdfDocument postNotificationForName:(NSString*)name object:(id)obj
{
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:@{
                                                                             @"pdfDocument": pdfDocument,
                                                                             @"object": obj
                                                                             }];
}



+ (CGRect)frameForSize:(CGSize)size withScreenSize:(CGSize)screenSize resizeMode:(ModuleResizeMode)resizeMode
{
    CGFloat w, h, vScale, hScale, scale;
    
    vScale = screenSize.height / size.height;
    hScale = screenSize.width / size.width;
    

    switch(resizeMode)
    {
        case ModuleResizeModeFill:
            scale = MAX(vScale, hScale);
            break;
        case ModuleResizeModeFit:
            scale = MIN(vScale, hScale);
            break;
        case ModuleResizeModeFillWidth:
            scale = hScale;
            break;
        case ModuleResizeModeFillHeight:
            scale = vScale;
            break;
    }
    
    w = size.width * scale;
    h = size.height * scale;
    
    return CGRectMake((screenSize.width - w) / 2.0, (screenSize.height - h) / 2.0, w, h);
}

@end
