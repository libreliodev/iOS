//
//  WAMissingResourcesDownloader.m
//  Librelio
//
//  Copyright (c) 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import "WAMissingResourcesDownloader.h"
#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.h"
#import "WADocumentDownloadsManager.h"

@implementation WAMissingResourcesDownloader


- (void) setUrlString: (NSString *) theString
{
    NSLog(@"WAMissingResourcesDownloader launched for Url:%@",theString);
	
	urlString = [[NSString alloc]initWithString: theString];
     [self didDownloadMainFile];    //No need to download main file

}




- (void) didDownloadMainFile{
    
    //Init parser
    NSString * className = [urlString classNameOfParserOfUrlString];
    Class theClass = NSClassFromString(className);
    parser =  (NSObject <WAParserProtocol> *)[[theClass alloc] init];
    parser.urlString = urlString;

     
    NSArray * imagesArray = [parser getRessources];
    
    NSLog(@"Images Array:%@",imagesArray);
    //Add the absolute Url to tempArray
    NSString * forcedUrl = [urlString valueOfParameterInUrlStringforKey:@"waurl"];
    //SLog(@"Forced Url:%@",forcedUrl);
    NSMutableArray *tempArray= [NSMutableArray array];
    for (NSString * relativeResourceUrl in imagesArray){
        NSString *absUrl ;
        
        if (forcedUrl){
            if ([relativeResourceUrl valueOfParameterInUrlStringforKey:@"waurl"]){
                //If the waurl argument is already included in the resources url, no need to change it
                absUrl = [WAUtilities absoluteUrlOfRelativeUrl:relativeResourceUrl relativeToUrl:urlString];
            }
            else{
                //Remove the leading localhost in noArgsUrl 
                if ([relativeResourceUrl hasPrefix:@"http://localhost/"]) relativeResourceUrl = [relativeResourceUrl substringFromIndex:17];
                //Get the remote absolute url
                NSString * remoteAbsUrl = [WAUtilities absoluteUrlOfRelativeUrl:relativeResourceUrl relativeToUrl:forcedUrl];
                //Get the destination (local) absolute url
                absUrl = [WAUtilities absoluteUrlOfRelativeUrl:relativeResourceUrl relativeToUrl:urlString];
                absUrl = [absUrl urlByAddingParameterInUrlStringWithKey:@"waurl" withValue:remoteAbsUrl];
                
                
            }

        }
        else{
            absUrl = [WAUtilities absoluteUrlOfRelativeUrl:relativeResourceUrl relativeToUrl:urlString];
        }
        
        
        //Add it to the download queue
        if (![tempArray containsObject:absUrl]) [tempArray addObject:absUrl];
        
    }
    
    
    
	nnewResourcesArray = [[NSArray alloc]initWithArray:tempArray];
	if ([nnewResourcesArray count]){
		mutableResourcesArray = [[NSMutableArray alloc ]initWithArray: nnewResourcesArray];
        NSLog(@"Missing resources:%@",nnewResourcesArray);
        
        receivedData = [[NSMutableData alloc]init];

    
		[self downloadNextResource];//Start looping in newResourcesArray
	}
	else {
        //Update the metadata plist to reflect the fact that download is complete
        NSString * mainFilePath = [[NSBundle mainBundle] pathOfFileWithUrl:urlString];
        NSString * plistPath = [WAUtilities urlByChangingExtensionOfUrlString:mainFilePath toSuffix:@"_metadata.plist"];
        NSMutableDictionary * metaDic = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
        //SLog(@"Will set downloadcomplete");
        [metaDic setObject:@"YES" forKey:@"DownloadComplete"];
        [metaDic writeToFile:plistPath atomically:YES];
        //SLog(@"sharedManager before remove in else:%@",[[WADocumentDownloadsManager sharedManager]issuesQueue]);

        [[[WADocumentDownloadsManager sharedManager] issuesQueue] removeObjectIdenticalTo:self];//This will release this instance if not owned by a download view
        //SLog(@"sharedManager after remove in else:%@,%@",[WADocumentDownloadsManager sharedManager],[[WADocumentDownloadsManager sharedManager]issuesQueue]);

	}
    
	
}

- (void) didDownloadAllResources{	
	//SLog(@"Did download all resources in waMissing .. %@",nnewResourcesArray);
    
    
    
    //Update metadata plist
    NSString * mainFilePath = [[NSBundle mainBundle] pathOfFileWithUrl:urlString];
    NSString * plistPath = [WAUtilities urlByChangingExtensionOfUrlString:mainFilePath toSuffix:@"_metadata.plist"];
    
     if (nnewResourcesArray){
         NSMutableDictionary * metaDic = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
         NSArray * concatArray = [nnewResourcesArray arrayByAddingObjectsFromArray:[metaDic objectForKey:@"Resources"]];
         [metaDic setObject:concatArray forKey:@"Resources"];
         
         [metaDic writeToFile:plistPath atomically:YES];
         
        
    }
    
 
    
    //SLog(@"sharedManager before remove:%@",[[WADocumentDownloadsManager sharedManager]issuesQueue]);

    
    [[[WADocumentDownloadsManager sharedManager] issuesQueue] removeObjectIdenticalTo:self];//This will release this instance if not owned by a download view
        
    //SLog(@"sharedManager after remove:%@",[[WADocumentDownloadsManager sharedManager]issuesQueue]);
    
        
    
	
	
 	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{

    [handle writeData:self.receivedData];
    
    //Move the file from TempWA directory to relevant place
    NSString * dirPath = [WAUtilities cacheFolderPath];
    NSString *tempUrlString = [NSString stringWithFormat:@"%@/TempWa/%@", dirPath,[currentUrlString noArgsPartOfUrlString]];
    //SLog(@"Will move %@ to %@",tempUrlString, currentUrlString);
    [WAUtilities storeFileWithUrlString:currentUrlString withFileAtPath:tempUrlString];

    
       
    //SLog(@"Will send didSucceedResourceDownload notification for connection %@",connection); 
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSucceedResourceDownload" object:urlString];

	
    
	//Continue with other downloads
	if ([currentUrlString isEqual:urlString]) [self didDownloadMainFile];
	else [self downloadNextResource];
	
}




@end
