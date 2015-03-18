//
//  NSFileManager+WAAdditions.m
//  Librelio
//
//  Copyright (c) 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import "NSBundle+WAAdditions.h"
#import "NSString+WAURLString.h"
#import "WAUtilities.h"
#import <NewsstandKit/NewsstandKit.h>
#import "SSZipArchive.h"


@implementation NSBundle (WAAdditions)


- (NSString *) stringForKey:(NSString *)key{
    //Check if we have a customized translation
    NSString * customizedTranslation = [self localizedStringForKey:key value:key table:@"Application"];
    //SLog(@"customized: %@",customizedTranslation);
    if (![customizedTranslation isEqualToString:key]){
        return customizedTranslation;
    }
    else{
        return [self localizedStringForKey:key value:key table:nil];
    }
    
    
}

- (NSString *) pathOfFileWithUrl:(NSString*)relativeUrl{
	return [self pathOfFileWithUrl:relativeUrl forOrientation:999];
}



/**
 * This method is similar to pathOfFileWithUrl, but adds the orientation arg
 * @return: The real path of the file if found, or nil 
 
*/
- (NSString *) pathOfFileWithUrl:(NSString*)relativeUrl forOrientation:(UIInterfaceOrientation)orientation {
    //SLog(@"Finding path for Url:%@",relativeUrl);
    NSString * filePath = [relativeUrl pathOfStorageForUrlString];
	
	//Build name with device  suffix
	NSString *deviceName = [WAUtilities isBigScreen] ? @"ipad" : @"iphone";
	NSString * extension = [filePath pathExtension];	
	NSString *suffix = [NSString stringWithFormat:@"~%@.%@",deviceName,extension];
	NSString *filePathWithDeviceSuffix = [filePath urlByChangingExtensionOfUrlStringToSuffix:suffix];
    
    //Build names with orientation (and device) suffixes
    NSString * filePathWithOrientationSuffix;
    NSString * filePathWithOrientationAndDeviceSuffix;
    //SLog(@"orientation %i",(int)orientation);
    
     if ((int)orientation!=999)//999 code conventionally means we do not care about orientation
     {
        NSString * orientationString=@"";
        switch (orientation) {
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown:
            case UIInterfaceOrientationUnknown:{
                orientationString = @"Portrait";
                break;
            }
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:{
                orientationString = @"Landscape";
                break;
            }
        }
         //SLog(@"File path:%@ orientation:%@ ext:%@",filePath, orientationString,extension);
        filePathWithOrientationSuffix = [filePath urlByChangingExtensionOfUrlStringToSuffix:[NSString stringWithFormat:@"-%@.%@",orientationString,extension]];
        filePathWithOrientationAndDeviceSuffix = [filePath urlByChangingExtensionOfUrlStringToSuffix:[NSString stringWithFormat:@"-%@~%@.%@",orientationString,deviceName,extension]];
         //SLog(@"filePathWithOrientationAndDeviceSuffix:%@",filePathWithOrientationAndDeviceSuffix);
    }
    
    
	
	//First, check the Cache directory
    if ((int)orientation!=999)//999 code conventionally means we do not care about orientation
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePathWithOrientationAndDeviceSuffix]) //MP no need to create further stuff if found here
        {
            return filePathWithOrientationAndDeviceSuffix;
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePathWithOrientationSuffix]) //MP no need to create further stuff if found here
        {
            return filePathWithOrientationSuffix;
        }
    }
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePathWithDeviceSuffix]) //MP no need to create further stuff if found here
	{
		return filePathWithDeviceSuffix;
	}
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])  //MP no need to create further stuff if found here
	{
		return filePath;
	}
	
	//Now, check the ROOT LEVEL in the bundle directory
    if ((int)orientation!=999)//999 code conventionally means we do not care about orientation
    {
        NSString *filePathWithOrientationAndDeviceInBundle = [[[NSBundle mainBundle]bundlePath] stringByAppendingPathComponent:[filePathWithOrientationAndDeviceSuffix lastPathComponent]];
        //SLog(@"filePathWithOrientationAndDeviceInBundle %@",filePathWithOrientationAndDeviceInBundle);
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePathWithOrientationAndDeviceInBundle]) 	{
            //SLog(@"Should return device + or");
            return filePathWithOrientationAndDeviceInBundle;
        }
        NSString *filePathWithOrientationInBundle = [[[NSBundle mainBundle]bundlePath] stringByAppendingPathComponent:[filePathWithOrientationSuffix lastPathComponent]]; 
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePathWithOrientationInBundle]) 	{
            return filePathWithOrientationInBundle;
        }
    }
	NSString *filePathWithDeviceInBundle = [[[NSBundle mainBundle]bundlePath] stringByAppendingPathComponent:[filePathWithDeviceSuffix lastPathComponent]]; 
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePathWithDeviceInBundle]) 	{
		return filePathWithDeviceInBundle;
	}
	NSString *filePathInBundle = [[[NSBundle mainBundle]bundlePath] stringByAppendingPathComponent:[filePath lastPathComponent]]; 
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePathInBundle]){
		return filePathInBundle;
	}
    
    
    //Hack: when a Newsstand issue has not been completely downloaded, the cover png is not found, so the library screen does not display it; the following code is intended to solve this issue
    NSString *noArgsUrl = [relativeUrl noArgsPartOfUrlString] ;
    NSString * dirPath = [WAUtilities cacheFolderPath];
    NSString *filePathOutsideNewsstand = [dirPath stringByAppendingPathComponent:noArgsUrl];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePathOutsideNewsstand]){
		return filePathOutsideNewsstand;
	}
    

	
    //By default, return  nil
    //SLog(@"Did not find path of file with URL: %@",relativeUrl);

	return nil;
}

- (void) unzipFileWithUrlString:(NSString*) urlString{
    NSString * unzippedFolderUrlString = [urlString urlOfUnzippedFolder];
    //Check if the file at UrlString is already a plist
    NSDictionary * testDic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathOfFileWithUrl:urlString]];
    if ([testDic objectForKey:@"UnzippedFolder"]){
        //File is already a plist, no need to uncompress
    }
    else{
        //Decompress the file
        NSString *zipPath = [[NSBundle mainBundle] pathOfFileWithUrl:urlString];
        NSString *destinationPath = [unzippedFolderUrlString pathOfStorageForUrlString];
        //SLog(@"zip:%@, unzip:%@",zipPath,destinationPath);
        [SSZipArchive unzipFileAtPath:zipPath toDestination:destinationPath];
        
        //Replace it with a dictionary
         NSString * plistPath = [[NSBundle mainBundle] pathOfFileWithUrl:urlString];
         NSMutableDictionary * testDic = [NSMutableDictionary dictionary];
         [testDic  setObject:unzippedFolderUrlString forKey:@"UnzippedFolder"];
         [testDic writeToFile:plistPath atomically:YES];
        
        
    }
    

    
}

- (NSString *) getLibrelioAppId{
    NSDictionary * app_Dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathOfFileWithUrl:@"Application_.plist"]];
    NSString * appShortId = [app_Dic objectForKey:@"LibrelioAppId"];
    if(!appShortId){
        NSString * appLongId = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleIdentifier"];
        NSArray *parts = [appLongId componentsSeparatedByString:@"."];
        appShortId = [parts objectAtIndex:[parts count]-1];
    }
    
    return appShortId;
    
}

- (NSString *) getLibrelioClientId{
    NSDictionary * app_Dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathOfFileWithUrl:@"Application_.plist"]];
    NSString * clientShortId = [app_Dic objectForKey:@"LibrelioClientId"];
    if(!clientShortId){
        NSString * appLongId = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleIdentifier"];
        NSArray *parts = [appLongId componentsSeparatedByString:@"."];
        clientShortId = [parts objectAtIndex:[parts count]-2];
        if ([clientShortId isEqualToString:@"widgetavenue"]) clientShortId = @"librelio";//this is for back compatibility reasons
        
        
    }
    
    return clientShortId;
    
}


- (int) countNumberOfReferencesForResourceWithUrlString:(NSString*) urlString {
    
    //TODO
    
    return 1;//Temporary
}




@end
