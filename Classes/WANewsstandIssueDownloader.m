//
//  WANewsstandIssueDownloader.m
//  Librelio
//
//  Copyright (c) 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import "WANewsstandIssueDownloader.h"
#import "NSString+WAURLString.h"
#import "WAFileDownloadsManager.h"
#import "NSBundle+WAAdditions.h"


@implementation WANewsstandIssueDownloader



#pragma mark -
#pragma mark NSURLConnectionDownloadDelegate methods

 - (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes{
     
     if (expectedTotalBytes==0) expectedTotalBytes = 50000000;//There is a bug when there is a redirect: the expectedTotalBytes appears as 0. In this case, it's better to assume that the file is going to be about 50 MB
     //SLog(@"Connection didWriteData for url %@",[connection.newsstandAssetDownload.userInfo objectForKey:@"completeUrl"]);
     currentProgress = 1.f*totalBytesWritten/expectedTotalBytes;
 
 }
 
 - (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL{
     
     //SLog(@"Did finish loading using newsstand %@",[destinationURL absoluteString]  );
     
     /*Store the downloaded asset in a temporary folder, compatible with earlier version*/
     NSString *tempUrlString = [NSString stringWithFormat:@"TempWa/%@", currentUrlString];
     //Create an empty file so that intermediate directories are created if needed
     [WAUtilities storeFileWithUrlString:tempUrlString withData:nil];
     NSString * newPath = [[NSBundle mainBundle]pathOfFileWithUrl:tempUrlString];
     NSString * oldPath = [destinationURL path];
     NSError *error =nil;
     [[NSFileManager defaultManager] removeItemAtPath:newPath error:&error];   
     [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:&error];   
     //SLog(@"Moved with error %@",error);
     
     if ([currentUrlString isEqual:urlString]) [self didDownloadMainFile];
     else [self downloadNextResource];

     
     
     
 
 }
 
 - (void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes{
     //SLog(@"Connection did resume %@",connection);
 
 }


#pragma mark -
#pragma mark Download cycle



#pragma mark -
#pragma mark Helper methods
- (void) launchConnectionWithUrlString:completeUrl{
    
    //Check if this is a protected file (ending with underscore)
    NSString * noUnderscoreCompleteUrl = [completeUrl urlByRemovingFinalUnderscoreInUrlString];
    if(![completeUrl isEqualToString:noUnderscoreCompleteUrl]){
        //The file is protected, we need to change the query so that background downloads can work
        completeUrl = [WAUtilities getCompleteUrlForUrlString:currentUrlString];
        //SLog(@"New complete Url: %@",completeUrl);
    }
    
	
     NSMutableURLRequest * urlRequest =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:completeUrl]];
    
    //Prevent download if local file is more recent than remote
    NSDate * last = [WAUtilities dateOfFileWithUrlString:[currentUrlString noArgsPartOfUrlString]];
    if (last){
        NSDateFormatter *df = [[NSDateFormatter alloc] init];  
        df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";  
        df.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];         
        df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];  
        NSString * since = [df stringFromDate:last]; 
        [df release];  
        
        //SLog(@"Since for URL:%@ %@",since,currentUrlString);
        [urlRequest setValue:since forHTTPHeaderField:@"If-Modified-Since"]; // conditonal load
        
    }
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    
    //Find the nkIssue based on UrlString, which must have been instantiated earlier
    NKIssue *nkIssue = [nkLib issueWithName:[urlString rootDirectoryNameOfUrlString]];
    //SLog(@"Found issue %@",nkIssue);
    
    //Check if there are already assetDownloads associated with nkIssue
    BOOL existsAssetDownload = NO;  
    NSArray * currentAssetDownloads = [nkIssue downloadingAssets];
    for ( NKAssetDownload *currentAssetDownload in currentAssetDownloads){
        if ([completeUrl isEqualToString:currentAssetDownload.URLRequest.URL.absoluteString]){
          //Set flag to YES
            existsAssetDownload = YES;
            
            //Relaunch download
            //SLog(@"Will REstart downloading asset %@",currentAssetDownload);
            [currentAssetDownload downloadWithDelegate:self];

            
        }
    }
    
    if (!existsAssetDownload){
        NKAssetDownload *assetDownload = [nkIssue addAssetWithRequest:urlRequest];
        [assetDownload setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:completeUrl,@"completeUrl",nil]];
        // let's start download
        //SLog(@"Will start downloading asset %@",assetDownload);
        [assetDownload downloadWithDelegate:self];
        
    }

    
    
    
    
	
    
}

- (void) notifyDownloadFinished{
    [super notifyDownloadFinished];
    
    //Update cover in Newsstand
    
    //Find the cover image
	NSString *noUnderscoreUrlString = [urlString urlByRemovingFinalUnderscoreInUrlString];//Remove the final underscore]
    NSString * imgUrl = [WAUtilities urlByChangingExtensionOfUrlString:noUnderscoreUrlString toSuffix:@".png"];//Change extension to png
    
    NSString * imgPath = [[NSBundle mainBundle]pathOfFileWithUrl:imgUrl];
    if (imgPath) {
        UIImage *img = [UIImage imageWithContentsOfFile:imgPath];
        if(img) {
            //SLog(@"Will set new newsstand image");
            [[UIApplication sharedApplication] setNewsstandIconImage:img];
            if ([[UIApplication sharedApplication] applicationState] ==UIApplicationStateBackground)
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
        }

    }
    

    
}




@end
