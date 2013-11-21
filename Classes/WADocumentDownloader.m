//
//  WAIssueDownloader.m
//  Librelio
//
//  Copyright (c) 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import "WADocumentDownloader.h"
#import "WAUtilities.h"
#import "WAModuleViewController.h"
#import "WAFileDownloadsManager.h"
#import "WADocumentDownloadsManager.h"
#import "WAPDFParser.h"
#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.h"
#import "NSDate+WAAdditions.h"

@implementation WADocumentDownloader 

@synthesize parser,currentUrlString,receivedData,handle,filesize,nnewResourcesArray,mutableResourcesArray,oldResourcesArray, currentMessage,currentProgress;


- (NSString *) urlString
{
    return urlString;
    
 
}

- (void) setUrlString: (NSString *) theString
{
	
	urlString = [[NSString alloc]initWithString: theString];
    
    
    
    //SLog(@"WADocumentDownloader (or subclass launched for Url:%@",theString);

    [self downloadMainFile];
    
    //Add observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndDrawPageOperationWithNotification:) name:@"didEndDrawPageOperation" object:nil];
    

    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [parser cancelCacheOperations];
    
    [parser release];
	[currentUrlString release];
	[filesize release];
	[urlString release];
	[receivedData release];
	[handle release];
	[nnewResourcesArray release];
	[mutableResourcesArray release];
	[oldResourcesArray release];
    [currentMessage release];
    [super dealloc];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    //SLog(@"Connection started, received %i headers with dic: %@",[[response allHeaderFields]count],[[response allHeaderFields]description]);
	[receivedData setLength:0];
    filesize = [[NSNumber numberWithLong: [response expectedContentLength] ] retain];
    
    //Hack for version 4.3 in PdfBrowser
    if (![response respondsToSelector:@selector(statusCode)]) return;
    
    //SLog(@"Did respond to selector");
    
    //Trigger error if one of the following statusCodes is returned
    if (([response statusCode]==304)||([response statusCode]==401)||([response statusCode]==402)||([response statusCode]==403)||([response statusCode]==461)||([response statusCode]==462)||([response statusCode]==463)){
        //SLog(@"Connection error %i",[response statusCode]);
        NSDictionary * userDic = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%i",[response statusCode]] forKey:@"SSErrorHTTPStatusCodeKey"];
		NSError * error = [NSError errorWithDomain:@"Librelio" code:2 userInfo:userDic];

        
        [self connection:connection didFailWithError:error];
    }

	
	
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[receivedData appendData:data];
	
    NSNumber* curLength = [NSNumber numberWithLong:[receivedData length] ];
    currentProgress = ([curLength floatValue]+[handle offsetInFile]) / [filesize floatValue] ;
    //SLog(@"Downloaded %f ",progress);
	//progressView.progress = progress;
	if( receivedData.length > 1000000 && handle!=nil )
	{
		[handle writeData:self.receivedData];
		[receivedData setLength:0];
        
	}
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    //SLog(@"Download error for connection %@:%@",connection,error);
    NSDictionary * userInfo = error.userInfo;
    NSString * httpStatus = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"SSErrorHTTPStatusCodeKey"]];
    //SLog(@"Status %@",httpStatus);
	//If a 304 status code is received, trigger didReceiveNotModifiedHeaderForConnection
	if ([httpStatus isEqualToString:@"304"]){
        [self didReceiveNotModifiedHeaderForConnection:connection];
        return;
    }
    
	//If a 403 status code is received, trigger didReceiveAuthenticationChallenge
	//if ([response statusCode]==403) [self didReceiveAuthenticationChallenge:nil forConnection:connection];
    if ([httpStatus isEqualToString:@"403"]){
        [self connection:connection didReceiveAuthenticationChallenge:nil];
        return;
    }
	
	//If a status code 402 is returned, it comes from appstoreV2.php, and means that the credentails were not fine
	if ([httpStatus isEqualToString:@"402"]){
		[connection cancel];
		//Remove the json certificate from the standard user defaults, since it is not or no longer valid
		NSString * connUrl = [WAUtilities completeCheckAppStoreUrlforUrlString:currentUrlString];
		NSString * userKey = [connUrl valueOfParameterInUrlStringforKey:@"userkey"];
		//SLog(@"UserKey:%@",userKey);
		if (userKey) [[NSUserDefaults standardUserDefaults] removeObjectForKey:userKey];		
		
	}
    
	//If a status code 401 is returned, it comes from pswd.php, and means that the credentials were not fine
	if ([httpStatus isEqualToString:@"401"]){
		[connection cancel];
		//Remove the subscription code from the standard user defaults, since they are no longer valid
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Subscription-code"];
    }

    //If a status code 461 is returned, it comes from subscribers.php, and means that the credentials were not fine
	if ([httpStatus isEqualToString:@"461"]){
		[connection cancel];
		//Remove the username and password from the standard user defaults, since they are no longer valid
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Username"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Password"];
    }
    
    //Temporary: If a status code 462 is returned, wipe credentials so that issue can be bought
	if ([httpStatus isEqualToString:@"462"]){
		[connection cancel];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Subscription-code"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Username"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Password"];
    }
    
     
     [[[WAFileDownloadsManager sharedManager] downloadQueue] removeObjectIdenticalTo:connection];
     if ([currentUrlString isEqual:urlString]){
     //We were downloading the main resource, we need to stop everything and display an error
     
         
         NSDictionary * notificationDic = [NSDictionary dictionaryWithObjectsAndKeys:urlString, @"urlString",httpStatus,@"httpStatus", nil];
     [[NSNotificationCenter defaultCenter] postNotificationName:@"didFailIssueDownload" object:notificationDic];
     [[[WADocumentDownloadsManager sharedManager] issuesQueue] removeObjectIdenticalTo:self];//This will release this instance if not owned by a download view
     
     
     }
     else {
     //Delete the content of the file so that we do not keep a corrupted file
     //[handle truncateFileAtOffset:0];
     //We were downloading a resource, let's be tolerant and move to the next one
     [self downloadNextResource];
     }
     
     
     

     
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	//SLog(@"Did finish loading %@",connection);
    [handle writeData:self.receivedData];
	
    
    
	
	//Remove from queue
	//[[[DownloadManager sharedManager] issuesQueue] removeObjectIdenticalTo:connection];
    
	//Continue with other downloads
	if ([currentUrlString isEqual:urlString]) [self didDownloadMainFile];
	else [self downloadNextResource];
	
}







- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    [[[WAFileDownloadsManager sharedManager] downloadQueue] removeObjectIdenticalTo:connection];
	[connection cancel];
	
	//Launch the new connection
	NSString*completeUrl = [WAUtilities getCompleteUrlForUrlString:currentUrlString];
	if (completeUrl){
        //SLog(@"Will launch complete url: %@",completeUrl);
		//Try to get file after approval by Apple or Password check
		[self launchConnectionWithUrlString:completeUrl];
		//Initialize handle and receivedData
		[handle release];
		NSString *tempUrlString = [NSString stringWithFormat:@"TempWa/%@", currentUrlString];
		[WAUtilities storeFileWithUrlString:tempUrlString withData:nil];
		NSString * path = [[NSBundle mainBundle] pathOfFileWithUrl:tempUrlString];
		handle = [[NSFileHandle fileHandleForWritingAtPath:path] retain];
		receivedData = [[NSMutableData alloc]init];
	}
	else {
		//Generate the error
        NSDictionary * userDic = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Invalid Code",@"") forKey:NSLocalizedDescriptionKey];
		NSError * error = [NSError errorWithDomain:@"Librelio" code:2 userInfo:userDic];
		[self connection:connection didFailWithError:error];
		
	}

    
	
}




#pragma mark -
#pragma mark Resources handling



- (void)didReceiveNotModifiedHeaderForConnection:(NSURLConnection *)connection {
    //SLog(@"Not modified");
    [[[WAFileDownloadsManager sharedManager] downloadQueue] removeObjectIdenticalTo:connection];
	if ([currentUrlString isEqual:urlString]){
		//We were downloading the main resource, no need to go further
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didSucceedIssueDownload" object:urlString];
        
        //Update modification date of local file; this will avoid unnecessary queries to distant server until expiration of cache
        NSString* path = [[NSBundle mainBundle] pathOfFileWithUrl:[urlString noArgsPartOfUrlString]];
         NSDictionary * dateAttDic = [NSDictionary dictionaryWithObject:[NSDate date] forKey:NSFileModificationDate];
         NSError *error = nil;
         [[NSFileManager defaultManager] setAttributes:dateAttDic ofItemAtPath:path error:&error];

        
        
        [[[WADocumentDownloadsManager sharedManager] issuesQueue] removeObjectIdenticalTo:self];//This will release this instance if not owned by a download view
        
        
	}
	else {
		//Delete the content of the file so that we do not keep a corrupted file
		//[handle truncateFileAtOffset:0];
		//We were downloading a resource, let's be tolerant and move to the next one
		//[self downloadNextResource];NOT NEEDED,connexiondidfinishloading will be called,  produces bug
	}
    
}


- (void) downloadMainFile{
	//Launch the connection
	currentUrlString = [[NSString alloc]initWithString: urlString];
	NSString*completeUrl = [WAUtilities completeDownloadUrlforUrlString:urlString];
    //SLog(@"Complete Url: %@ for url:%@",completeUrl,urlString);
    
    //Put message
    currentMessage = [[NSString alloc]initWithString: NSLocalizedString(@"Download in progress",@"")];
	
	
	//Initialize handle and receivedData
	NSString *tempUrlString = [NSString stringWithFormat:@"TempWa/%@",currentUrlString];
	[WAUtilities storeFileWithUrlString:tempUrlString withData:nil];
	NSString * path = [[NSBundle mainBundle] pathOfFileWithUrl:tempUrlString];
    //SLog(@"pathOfFileWithUrl:%@",path);
	handle = [[NSFileHandle fileHandleForWritingAtPath:path] retain];
	receivedData = [[NSMutableData alloc]init];

	[self launchConnectionWithUrlString:completeUrl];
	
}
- (void) didDownloadMainFile{
	NSString *tempUrlString = [NSString stringWithFormat:@"TempWa/%@", currentUrlString];
    
    //Init parser
    NSString * className = [tempUrlString classNameOfParserOfUrlString];
    Class theClass = NSClassFromString(className);
    parser =  (NSObject <WAParserProtocol> *)[[theClass alloc] init];
    parser.urlString = tempUrlString;
    
    //SLog(@"parser count data:%i for Url:%@",[parser countData],tempUrlString);
    if (!([parser countData]>0)){
        //SLog(@"File corrupted: %@",tempUrlString);
        //The file is corrupted, let us notify an error
        NSDictionary * notificationDic = [NSDictionary dictionaryWithObjectsAndKeys:urlString, @"urlString",@"999",@"httpStatus", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didFailIssueDownload" object:notificationDic];
        [[[WADocumentDownloadsManager sharedManager] issuesQueue] removeObjectIdenticalTo:self];//This will release this instance if not owned by a download view
        return;
        
    }
    
    //Start chaching while we are downloading resources
    [parser startCacheOperations];
    
    //Get relative resources urls from parser
    NSArray * resourcesArray = [parser getRessources];
    

    
    //Add the absolute Url to tempArray
    NSString * forcedUrl = [urlString valueOfParameterInUrlStringforKey:@"waurl"];
    //SLog(@"Forced Url:%@",forcedUrl);
    NSMutableArray *tempArray= [NSMutableArray array];
    for (NSString * relativeResourceUrl in resourcesArray){
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
        
        
        
        if (![tempArray containsObject:absUrl]) [tempArray addObject:absUrl];
        
    }


    
	nnewResourcesArray = [[NSArray alloc]initWithArray:tempArray];
    //SLog(@"nnewResourcesArray:%@",nnewResourcesArray);
	if (nnewResourcesArray&&[parser shouldCompleteDownloadResources]){
		mutableResourcesArray = [[NSMutableArray alloc ]initWithArray: nnewResourcesArray];
        //SLog(@"MutableRessources:%@",nnewResourcesArray);
		[self downloadNextResource];//Start looping in newResourcesArray
	}
	else {
        //SLog(@"Launch didDownloadAllResources from didDownloadMainFile");
        currentUrlString = nil;//This is important because there is a test in didEndDrawPageOperationWithNotification
         [[[WADocumentDownloadsManager sharedManager] issuesQueue] removeObjectIdenticalTo:self];//Remove self from issuesQueue now, because WAMissingResourecesDwnloader may need to add itself again immediately after
		[self didDownloadAllResources];//No resources to download now
	}
    
	
}
- (void) downloadNextResource{
    //SLog(@"NSMutable:%@",mutableResourcesArray);
	if ([mutableResourcesArray count]){
		NSString * nextUrlString = [mutableResourcesArray lastObject];
		
		//Open new handle
		[handle release];
		NSString *tempUrlString = [NSString stringWithFormat:@"TempWa/%@", nextUrlString];
		//Create empty file
		[WAUtilities storeFileWithUrlString:tempUrlString withData:nil];
		NSString * path = [[NSBundle mainBundle] pathOfFileWithUrl:tempUrlString];
        //SLog(@"handle path:%@",path);
		handle = [[NSFileHandle fileHandleForWritingAtPath:path] retain];
		
		
		[currentUrlString release];
		currentUrlString = [[NSString alloc]initWithString: nextUrlString];

        NSString*completeUrl = [WAUtilities completeDownloadUrlforUrlString:nextUrlString];
        //SLog(@"complete asset Url: %@",completeUrl);
		[self launchConnectionWithUrlString:completeUrl];

        
		[mutableResourcesArray removeLastObject];
        
		int total = [nnewResourcesArray count]+1;
		int done = [nnewResourcesArray count]+1-[mutableResourcesArray count];
        [currentMessage release];
		currentMessage = [[NSString alloc]initWithFormat:@"%@ (%i/%i)", NSLocalizedString(@"Download in progress",@""),done,total];
		
        
	}
	else {
        currentUrlString = nil;//This is important because there is a test in didEndDrawPageOperationWithNotification

        //SLog(@"Launch didDownloadAllResources from downloadAllResources");
		[self didDownloadAllResources];
	}
    
}
- (void) didDownloadAllResources{	
    
    //Check if some extra caching operations are required
    currentProgress = [parser cacheProgress];
    //SLog(@"Current progress in did: %f", currentProgress);
    if (currentProgress<0.99){
        //We still need to wait for cache operations
        currentMessage = [[NSString alloc]initWithString: NSLocalizedString(@"Caching operation in progress",@"")];
        
     }
    else{
        
        //SLog(@"Did really download all resources");

        [[NSNotificationCenter defaultCenter] removeObserver:self];

         //Store all temp files: main file, cache, and resources
        NSString * dirPath = [WAUtilities cacheFolderPath];
        NSLog(@"Will move main %@ to %@",[NSString stringWithFormat:@"%@/TempWa/%@",dirPath,[urlString noArgsPartOfUrlString]], urlString);
        [WAUtilities storeFileWithUrlString:urlString withFileAtPath:[NSString stringWithFormat:@"%@/TempWa/%@",dirPath,[urlString noArgsPartOfUrlString]]];//Move the main file
        
        //Store generated cache files
        NSString * cacheDirUrlString = [urlString urlOfCacheFileWithName:@""];
        cacheDirUrlString = [cacheDirUrlString substringToIndex:[cacheDirUrlString length]-1];//Remove final "/"
        [[NSFileManager defaultManager]removeItemAtPath:[[NSBundle mainBundle] pathOfFileWithUrl:cacheDirUrlString] error:nil];//Delete existing cache dir
        NSString * tempCacheDirUrlString = [[NSString stringWithFormat:@"TempWa/%@", urlString] urlOfCacheFileWithName:@""];
        //SLog(@"Will move cache %@ to %@",[NSString stringWithFormat:@"%@/%@",dirPath,tempCacheDirUrlString], tempCacheDirUrlString);
        [WAUtilities storeFileWithUrlString:cacheDirUrlString withFileAtPath:[NSString stringWithFormat:@"%@/%@",dirPath,tempCacheDirUrlString]];//Move the cache dir
        
        //Loop through resources
        for (NSString * loopedUrlString in nnewResourcesArray){
            loopedUrlString = [loopedUrlString noArgsPartOfUrlString];//Remove the args
            NSString *tempUrlString = [NSString stringWithFormat:@"%@/TempWa/%@", dirPath,loopedUrlString];
            NSLog(@"Will move %@ to %@",tempUrlString, loopedUrlString);
            [WAUtilities storeFileWithUrlString:loopedUrlString withFileAtPath:tempUrlString];
        }
        
        //Store plist with metadata and list of resources for this download
        NSString * mainFilePath = [[NSBundle mainBundle] pathOfFileWithUrl:urlString];
        NSString * plistPath = [WAUtilities urlByChangingExtensionOfUrlString:mainFilePath toSuffix:@"_metadata.plist"];
        NSMutableDictionary * metaDic = [NSMutableDictionary dictionary];
        if (nnewResourcesArray) [metaDic setObject:nnewResourcesArray forKey:@"Resources"];
        [metaDic setObject:[NSDate date] forKey:@"DownloadDate"];
        [metaDic setObject:urlString forKey:@"FileUrl"];
        
        [metaDic writeToFile:plistPath atomically:YES];
        //SLog(@"metadic written:%@",metaDic);
        
        
         
        //Delete sample file,metadata plist and cache if the downloaded file was a paid one
        NSString *noUnderscoreUrlString = [urlString urlByRemovingFinalUnderscoreInUrlString];//Remove the final underscore]
        NSString * noUnderscoreUrlPath = [[NSBundle mainBundle] pathOfFileWithUrl:noUnderscoreUrlString];//Check the path of the file without underscore
        if (noUnderscoreUrlPath&&(![mainFilePath isEqualToString:noUnderscoreUrlPath])){
            [[NSFileManager defaultManager]removeItemAtPath:noUnderscoreUrlPath error:NULL];//delete the no underscore file if it exists, and is not the same as the just downloaded file
            NSString * noUnderscorePlistPath = [WAUtilities urlByChangingExtensionOfUrlString:noUnderscoreUrlPath toSuffix:@"_metadata.plist"];
            [[NSFileManager defaultManager]removeItemAtPath:noUnderscorePlistPath error:NULL];//delete the metadata plist
            //Delete cache
            NSString * cacheUrlString = [noUnderscoreUrlString urlOfCacheFileWithName:@""];
            cacheUrlString = [cacheUrlString substringToIndex:[cacheUrlString length]-1];//Remove final "/"
            NSString * cachePath = [[NSBundle mainBundle] pathOfFileWithUrl:cacheUrlString];
            [[NSFileManager defaultManager]removeItemAtPath:cachePath error:NULL];

            
           
        }
        
        
        
                
        [self notifyDownloadFinished];
        //SLog(@"Objet identical index:%i",[[[WAIssuesManager sharedManager] issuesQueue] indexOfObjectIdenticalTo:self]);
        [[[WADocumentDownloadsManager sharedManager] issuesQueue] removeObjectIdenticalTo:self];//This will release this instance if not owned by a download view

        
        
    }

	
	
 	
}

- (void) notifyDownloadFinished{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSucceedIssueDownload" object:urlString];
    
}


- (void) didEndDrawPageOperationWithNotification:(NSNotification *) notification{
    if ([currentUrlString isEqual:urlString]){
        //We are still downloading the main file, the notification came from another file => Do nothing
        
    }
    if (currentUrlString){
        //We are still downloading resources => Do nothing
    }
    else{
        //Trigger didDownloadAllResources again
        [self didDownloadAllResources];
    }

}



#pragma mark -
#pragma mark Files handling






- (void) deleteUnusedOldResources{
	//TODO: complete
}
#pragma mark -
#pragma mark Helper methods
- (void) launchConnectionWithUrlString:completeUrl{
    
    NSMutableURLRequest * urlRequest =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:completeUrl]];
    
    //Prevent download if local file is more recent than remote (except if 
    
   NSDate * last = [WAUtilities dateOfFileWithUrlString:[currentUrlString noArgsPartOfUrlString]];
    //NSDate * last = nil;

    if (last){
        //SLog(@"Will set If-Modified-Since to %@",[last headerString]);
        [urlRequest setValue:[last headerString] forHTTPHeaderField:@"If-Modified-Since"]; // conditonal load

    }

     

    
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:urlRequest  delegate:self];
    //SLog(@"will launch connection for %@ with connexion %@",completeUrl,conn);
    
	//Add connection to download queue
	[[[WAFileDownloadsManager sharedManager] downloadQueue] addObject:conn];
	[conn release];
	
    
}

- (AuthenticationType) getAuthenticationType{
	//Temporary function, will be more sophisticated in the future
	NSString*authType = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"AuthType"];
	if ([authType isEqualToString:@"Password"]) return AuthenticationTypePassword;
	else return AuthenticationTypeAppStore;
}




@end
