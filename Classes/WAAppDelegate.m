//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WAAppDelegate.h"
#import "WAUtilities.h"

#import "WAModuleViewController.h"
#import "WAOperationsManager.h"
#import "NSBundle+WAAdditions.h"
#import "NSString+WAURLString.h"

#import <NewsstandKit/NewsstandKit.h>
#import "WADocumentDownloadsManager.h"
#import "WANewsstandIssueDownloader.h"



#import "GAI.h"
#import "APAppirater.h"

#import <QuartzCore/QuartzCore.h>



@implementation WAAppDelegate

@synthesize window = _window;
@synthesize appTabBarController = _appTabBarController;
@synthesize splashScreenViewController;
@synthesize apnsSubDelegate;
@synthesize metadataQuery;


////////////////////////////////////////////////////////////////////////////////


#pragma mark -
#pragma mark Lifecycle


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{   
    
     //SLog(@"Defaults %@",[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);//Just a test
    //This will be needed several times below
    NSDictionary * app_Dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathOfFileWithUrl:@"Application_.plist"]];

    
    //Create subdelegate for push notifications
    apnsSubDelegate = [[EAAppSubDelegate alloc]init];
    
    //Move documents from Documents directory to Library/Cache if not already done, per Apple's instruction
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"DocsMoved"])[self moveDocumentsToCache];       
    
    //Launch Google analytics
    NSString * googleCode = @"UA-1732003-23";//This is the default Librelio code
    if ([app_Dic objectForKey:@"GoogleAnalyticsCode"]) googleCode = [app_Dic objectForKey:@"GoogleAnalyticsCode"];
    [[GAI sharedInstance] trackerWithTrackingId:googleCode];
    [GAI sharedInstance].trackUncaughtExceptions = YES; // Enable exceptions tracking
    
    //Launch Appirater
    if ([app_Dic objectForKey:@"AppId"]) {
        //SLog(@"AppDic found");
        [Appirater setAppId:[app_Dic objectForKey:@"AppId"]];
        [Appirater setDaysUntilPrompt:0];
        [Appirater setUsesUntilPrompt:1];
        [Appirater setSignificantEventsUntilPrompt:-1];
        [Appirater setTimeBeforeReminding:1];

    }
    else{
        //SLog(@"AppDic not found");
        //Do nothing, not setting App id prevents Appirater from launching, which is fine in this case

    }
    //[Appirater setDebug:YES];
 
    
    
	
	//Add transaction observer for In App Purchases
    observer = [[WAPaymentTransactionObserver alloc] init];
	[[SKPaymentQueue defaultQueue] addTransactionObserver:observer];
    
 
	
	// Add registration for remote notifications
	[[UIApplication sharedApplication] 
	 registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound|UIRemoteNotificationTypeNewsstandContentAvailability)];
	
    
    //If the app was launched by a notification, launch corresponding download
    NSDictionary *payload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    [self launchNewstandDownloadFromNotification:payload];
    
    //Add window and RootViwController
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; //We are not using a Xib

    [self updateRootViewController];

    
    // Splash screen
    
    // Show the splash screen only if the key "Splash" is specified
    if ([app_Dic objectForKey:@"Splash"])
    {
        // Check device
        NSString * nibName = @"WASplashScreenViewController_iPad";//Default
        if (![WAUtilities isBigScreen]) nibName = @"WASplashScreenViewController_iPhone";
        splashScreenViewController = [[WASplashScreenViewController alloc]initWithNibName:nibName bundle:nil];
        
        /**Old code, may have caused problems with Apple's reviews
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            // iPhone
            splashScreenViewController = [[WASplashScreenViewController alloc]initWithNibName:@"WASplashScreenViewController_iPhone" bundle:nil];
            
        }
        else
        {
            // iPad
            
            splashScreenViewController = [[WASplashScreenViewController alloc]initWithNibName:@"WASplashScreenViewController_iPad" bundle:nil];
            
        }**/
        
        
        
        // Show the default splash screen
        splashScreenViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [appTabBarController presentModalViewController:splashScreenViewController animated:NO];
        //splashScreenViewController.view.hidden= YES;//Keep the view hidden until the image is received
        splashScreenViewController.rootViewController = appTabBarController;
        
    }

    //Notify appirater that launching is finished
    [Appirater appLaunched:YES];

	return YES;
    
}
////////////////////////////////////////////////////////////////////////////////

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Clear application badge 
	application.applicationIconBadgeNumber = 0;
    
    //Request ad if appropriate; this needs to be done here (and not in "didFinishLaunchingWithOptions") so that the ad is also displayed when the app awakes from background
    [splashScreenViewController requestAd];
    
    
    //Register event with GA
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"Application iOS" withAction:@"Became active" withLabel:@"App" withValue:[NSNumber numberWithInt:1]];


    
    
    //Newsstand
    
    //Relaunch interrupted downloads
    NSString* anyPdf = @"anything.pdf";//This is just to check wether Newsstand is available (not the case for example if iOS<5)
    if ([anyPdf shouldUseNewsstandForUrlString]){
        NKLibrary *nkLib = [NKLibrary sharedLibrary];
        //SLog(@"issues in library:%@",[nkLib issues]);
        //SLog(@"downloading assets:%@",[nkLib downloadingAssets]);
        
        
        for(NKAssetDownload *nkIssue in [nkLib downloadingAssets]) {
            NSDictionary * assetUserInfo = nkIssue.userInfo;
            NSString * urlString = [assetUserInfo objectForKey:@"completeUrl"];
            
            
            if (![[WADocumentDownloadsManager sharedManager]isAlreadyInQueueIssueWithUrlString:urlString]){
                WANewsstandIssueDownloader * issue = [[WANewsstandIssueDownloader alloc]init];
                issue.urlString = urlString;
                [[[WADocumentDownloadsManager sharedManager] issuesQueue]addObject:issue];
                [issue release];
            }
            
        }
        
    }
    
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

	NSString * urlString;
	
	if ([url isFileURL]){
        //SLog(@"Is File Url %@ with annotation %@",url,annotation);
		//url represents a  file
        
        //Define the urlString to open the module
        urlString = [NSString stringWithFormat:@"Inbox/%@",[[url absoluteString] lastPathComponent]];
        
        //Move document from document directory to cache
        [WAUtilities storeFileWithUrlString:urlString withFileAtPath:[url path]];
        
        //Delete inbox file
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentsFolderPath = [paths objectAtIndex:0];	
        NSString *inboxPath = [documentsFolderPath stringByAppendingPathComponent:@"Inbox"];
        [[NSFileManager defaultManager] removeItemAtPath:inboxPath error:nil];
        
		//Create and store metadata plist
		NSString * mainFilePath = [[NSBundle mainBundle] pathOfFileWithUrl:urlString];
        //SLog(@"urlString is %@ mainPath is %@",urlString,mainFilePath);
		NSString * plistPath = [WAUtilities urlByChangingExtensionOfUrlString:mainFilePath toSuffix:@"_metadata.plist"];
		NSMutableDictionary * metaDic = [NSMutableDictionary dictionary];
		[metaDic setObject:[NSDate date] forKey:@"DownloadDate"];
		[metaDic setObject:urlString forKey:@"FileUrl"];
		[metaDic writeToFile:plistPath atomically:YES];
		
		
		
	}
	else {
		//url starts with our custom scheme librelio://
        
        NSString * remoteUrl = [url absoluteString];
        remoteUrl = [remoteUrl urlByChangingSchemeOfUrlStringToScheme:@"http"];
        urlString = [[remoteUrl lastPathComponent] urlByAddingParameterInUrlStringWithKey:@"waurl" withValue:remoteUrl];
        
 		
	}
	//SLog(@"Will load url:%@",urlString);
	WAModuleViewController * moduleViewController = [[WAModuleViewController alloc]init];
	moduleViewController.moduleUrlString= urlString;
	UINavigationController * currentNavController = (UINavigationController *) appTabBarController.selectedViewController;
	if (currentNavController) {
		//SLog (@"NavControllerOK");
	}
	else {
		currentNavController = [appTabBarController.viewControllers objectAtIndex:0];//Keep this line, is useful when app is lauched via custom URL
	}
	UIViewController * currentViewController = currentNavController.topViewController;
	moduleViewController.initialViewController= currentViewController;
	moduleViewController.containingView= nil;
	moduleViewController.containingRect= CGRectZero;
	[moduleViewController pushViewControllerIfNeededAndLoadModuleView];
	[moduleViewController release];	
	
	return YES;
	
}

- (void)applicationWillTerminate:(UIApplication *)application {

	[[NSUserDefaults standardUserDefaults] synchronize];
	[WAUtilities clearTempDirectory];
	
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
	//SLog(@"Did enter background");
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void) applicationWillEnterForeground:(UIApplication *)application{
    [Appirater appEnteredForeground:YES];
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[[WAOperationsManager sharedManager] defaultQueue]setSuspended:YES];	//Suspend the queue for 5 seconds
    [self performSelector:@selector(restartOperations) withObject:nil afterDelay:5];
    
    //[self updateRootViewController];This was for testing
    
}

- (void)dealloc {
	[observer release];	
	[window release];
	[appTabBarController release];
    [splashScreenViewController release];
    [metadataQuery release];
    
   [apnsSubDelegate release];
    
	[super dealloc];
}





#pragma mark -
#pragma mark Helper methods

- (void) restartOperations{
    //SLog(@"Will restart ops");
    [[[WAOperationsManager sharedManager] defaultQueue]setSuspended:NO];
}


- (void) moveDocumentsToCache{
    //SLog(@"Will move documents");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsFolderPath = [paths objectAtIndex:0];	
	NSArray * dirArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsFolderPath error:NULL];
    for (NSString * fileName in dirArray){
        NSString *oldPath = [documentsFolderPath stringByAppendingPathComponent:fileName];
        NSString * newPath = [[WAUtilities cacheFolderPath]stringByAppendingPathComponent:fileName];
 		NSError *error=nil;
        [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:&error];
        
        if (error){
           //SLog(@"Error:%@ with file at path:%@ to path %@",[error localizedDescription],oldPath,newPath); 
        }
        //SLog(@"Moved %@",oldPath);
        
        
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@"Yes" forKey:@"DocsMoved"];
    
    
}

- (void) updateRootViewController {
    //Create the views
    WAPListParser * parser = [[WAPListParser alloc]init];
    parser.urlString = @"/Tabs.plist";
    //If user has selected admin mode in settings, use  Tabs_admin.plist
    if ([[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]objectForKey:@"admin_preference"]) parser.urlString = @"Tabs_admin.plist";
	//Create the tab ViewControllers
	NSMutableArray *tabviews	= [NSMutableArray array];
    
	
	for ( int j = 0; j < [parser countData]; j++ )
	{
        NSString *urlString = [parser getDataAtRow:j+1 forDataCol:DataColDetailLink];
        //SLog(@"dealing with %@",urlString);
		WAModuleViewController * moduleViewController = [[WAModuleViewController alloc]init];
		moduleViewController.moduleUrlString= urlString ;
        moduleViewController.title = [urlString titleOfUrlString];
        //Check if the view is a webview; in this case, we load it for speed reasons
        if ((j>0)&&([urlString typeOfParserOfUrlString]==ParserTypeHTML)&&(![urlString isLocalUrl])){
            //SLog(@"Will load view in background with Url %@",urlString);
            moduleViewController.view.tag = 111;			//Hack: force loadView if it is a webview with an external URL except for tab 1
            
        }
        [self addViewController:moduleViewController toTabViews:tabviews withParser:parser atRow:j+1];
        
		[moduleViewController release];
	}
	[parser release];
    if (appTabBarController){
        window.rootViewController = nil;
        [appTabBarController release];
    }
	appTabBarController = [[WARootViewController alloc]init];
	appTabBarController.moreNavigationController.navigationBar.barStyle = UIBarStyleBlack;
    appTabBarController.delegate = self;
	appTabBarController.viewControllers = 	tabviews;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) appTabBarController.tabBar.translucent = NO;
	
    window.rootViewController = appTabBarController;
	window.backgroundColor = [UIColor blackColor];
	[window addSubview:appTabBarController.view];
	[window makeKeyAndVisible];
 
    
}
- (void) addViewController:(UIViewController*)view toTabViews:(NSMutableArray *)tabviews withParser:(WAPListParser*)parser atRow:(int)row {
	//See if [tabInfo objectForKey:@"Icon"] contains a "."; if not, it means we want to use a system tabBarItem
	NSRange range = [[parser getDataAtRow:row forDataCol:DataColIcon] rangeOfString:@"."];
	if (range.location == NSNotFound){
		int uiTabBarSystemItemValue = [[parser getDataAtRow:row forDataCol:DataColIcon]intValue];
		view.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:uiTabBarSystemItemValue tag:3] autorelease];
		
	}
	else {
		view.tabBarItem.title = NSLocalizedString([parser getDataAtRow:row forDataCol:DataColTitle],@"");
		view.tabBarItem.image = [UIImage imageNamed:[parser getDataAtRow:row forDataCol:DataColIcon]];
        
	}
    
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:view];
	//If there is an image file called Tabs.png, use it instead of the title
    /*Deprecated
     NSString *imPath = [[NSBundle mainBundle] pathOfFileWithUrl:@"/Tabs.png" ];
     if (imPath){
     UIImage *image = [UIImage imageWithContentsOfFile:imPath];
     UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
     view.navigationItem.titleView = imageView;
     [imageView release];
     }
     */
    
    //Check if we have a PreferredLanguagePlist; in this case, if we are in the first tab ([tabviews count]==0), we need to push the view specified by PreferredLanguagePlist
    if (([tabviews count]==0) && [[NSUserDefaults standardUserDefaults] objectForKey:@"PreferredLanguagePlist"]){
		WAModuleViewController * moduleViewController = [[WAModuleViewController alloc]init];
        moduleViewController.moduleUrlString=  [[NSUserDefaults standardUserDefaults] objectForKey:@"PreferredLanguagePlist"];
        moduleViewController.title = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PreferredLanguagePlist"] titleOfUrlString];
        [navController pushViewController:moduleViewController animated:NO];
        [moduleViewController release];
        
        
    }

	
	//Add the navigation controller to the array to tabs
	[tabviews addObject:navController];
	[navController release];
	
}

- (void) launchNewstandDownloadFromNotification: (NSDictionary*) payload{
    //SLog(@"payload:%@",payload);
    
    if(payload) {
        //Add to issues if required
        NSString * urlString = [payload objectForKey:@"waurl"];//custom data to be sent with Newsstand notifications by our server
        
        //SLog(@"UrlString:%@",urlString);
        
        //Check if Newsstand should be used
        BOOL useNS = [urlString shouldUseNewsstandForUrlString];
        //SLog(@"Newsstand bool:%i",useNS);
        
        //Check if the user is an App Store subscriber for the app; if he is, method completeCheckAppStoreUrlforUrlString will return a string, otherwise null will be returned
        NSString * isAppSubscriber = [WAUtilities completeCheckAppStoreUrlforUrlString:urlString] ;
        //SLog(@"App Subscriber :%@",isAppSubscriber);
        
        
  
        //Check if the user is an Magazine subscriber with a subscriber code; if he is, method completeCheckPasswordUrlforUrlString will return a string, otherwise null will be returned
        NSString * isMagSubscriber = [WAUtilities completeCheckPasswordUrlforUrlString:urlString];
        // if no subscription code then test for username and password
        if (!isMagSubscriber) {
            isMagSubscriber = [WAUtilities completeCheckUsernamePasswordUrlforUrlString:urlString];
        }
        //SLog(@"Mag Subscriber :%@",isMagSubscriber);
        
        
        //Check if language is enabled; in this case, we will download only magazines in the right language
        BOOL correctLanguage = YES;
        NSDictionary * app_Dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathOfFileWithUrl:@"Application_.plist"]];
        if ([app_Dic objectForKey:@"Languages"]){
            NSString * preferredPlist = [[NSUserDefaults standardUserDefaults] objectForKey:@"PreferredLanguagePlist"];
            if (preferredPlist){
                NSString * plistFileName = [preferredPlist nameOfFileWithoutExtensionOfUrlString];
                //Check if the url of the file to download contains plistFileName
                NSRange range = [urlString rangeOfString:plistFileName];
                if (range.location == NSNotFound) correctLanguage = NO;

            }
            else correctLanguage = NO;
        }

    
        if (urlString && useNS &&correctLanguage && (isAppSubscriber||isMagSubscriber) )
        {
            //SLog(@"All conditions OK to start download");
            NKLibrary *nkLib = [NKLibrary sharedLibrary];
            NSDate * issueDate = [NSDate date];
            NSString * argDateString = [payload objectForKey:@"wadate"];
            if (argDateString){
                NSDateFormatter *df = [[[NSDateFormatter alloc] init]autorelease];  
                df.dateFormat = @"dd-MM-yyyy";  
                issueDate = [df dateFromString:argDateString]; 
                
            }
            
            NKIssue *nkIssue = [nkLib issueWithName:[urlString rootDirectoryNameOfUrlString]];
            if(!nkIssue) {
                nkIssue = [nkLib addIssueWithName:[urlString rootDirectoryNameOfUrlString] date:issueDate];
                
            }
            
            
            //Initiate download (if the file is not already downloaded or downloading
            if (![[NSBundle mainBundle] pathOfFileWithUrl:urlString]){
                if (![[WADocumentDownloadsManager sharedManager]isAlreadyInQueueIssueWithUrlString:urlString]){
                    WANewsstandIssueDownloader * issue = [[WANewsstandIssueDownloader alloc]init];
                    issue.urlString = urlString;
                    [[[WADocumentDownloadsManager sharedManager] issuesQueue]addObject:issue];
                    [issue release];
                    //SLog(@"Did start download in bg with nkIssue %@",nkIssue);
                }
                
            }
            
        }
    }

}



#pragma mark -
#pragma mark Notification methods


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    //Forward to EasyAPNS subdelegate
    [apnsSubDelegate application:application didRegisterForRemoteNotificationsWithDeviceToken:devToken];
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {

    //Forward to EasyAPNS subdelegate
    [apnsSubDelegate application:application didFailToRegisterForRemoteNotificationsWithError:error];

}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	
    //Forward to EasyAPNS subdelegate
    [apnsSubDelegate application:application didReceiveRemoteNotification:userInfo];
    
    //Trigger Newwstand download if necessary
    [self launchNewstandDownloadFromNotification:userInfo];
}

- (void)queryDidReceiveNotification:(NSNotification *)notification {
    /**SLog(@"Did receive iCloud notif");
    NSArray *results = [self.metadataQuery results];
    
    for(NSMetadataItem *item in results) {
        NSString *filename = [item valueForAttribute:NSMetadataItemDisplayNameKey];
        NSNumber *filesize = [item valueForAttribute:NSMetadataItemFSSizeKey];
        NSDate *updated = [item valueForAttribute:NSMetadataItemFSContentChangeDateKey];
        //SLog(@"%@ (%@ bytes, updated %@)", filename, filesize, updated);
    }**/
}


#pragma mark
#pragma mark UITabBarControllerDelegate methods

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    
    //SLog(@"tabbar changed:%@",viewController);
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    //Check if the bar button tapped is already the one displayed. 
    if([viewController isEqual:tabBarController.selectedViewController]){
        //In this case, pop to root viewcontroller; this is useful when the navigation upperbar is missing, which is sometimes the case
        UINavigationController * currentNavigationController = (UINavigationController *) viewController;
        [currentNavigationController popToRootViewControllerAnimated:YES];
        
    }
    return YES;
}


@end


