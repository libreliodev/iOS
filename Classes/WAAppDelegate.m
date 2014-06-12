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
#import "GAIDictionaryBuilder.h"
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
    
    
    //Launch Google analytics
    NSString * googleCode = @"UA-1732003-23";//This is the default Librelio code
    if ([app_Dic objectForKey:@"GoogleAnalyticsCode"]) googleCode = [app_Dic objectForKey:@"GoogleAnalyticsCode"];
    [[GAI sharedInstance] trackerWithTrackingId:googleCode];
    [GAI sharedInstance].trackUncaughtExceptions = YES; // Enable exceptions tracking
    
    //Launch Appirater
    if ([app_Dic objectForKey:@"AppId"]) {
        [Appirater setAppId:[app_Dic objectForKey:@"AppId"]];
        [Appirater setDaysUntilPrompt:0];
        [Appirater setUsesUntilPrompt:1];
        [Appirater setSignificantEventsUntilPrompt:-1];
        [Appirater setTimeBeforeReminding:1];

    }
    else{
        //Do nothing, not setting App id prevents Appirater from launching, which is fine in this case

    }
    //[Appirater setDebug:YES];
 
    //SLog(@"Will add Transaction Observer");
    
	
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
    
    //SLog(@"Will updateRootViewController");
    [self updateRootViewController];
    //SLog(@"Did updateRootViewController");

    
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
    //SLog(@"Will launch appirater");

    //Notify appirater that launching is finished
    [Appirater appLaunched:YES];

	return YES;
    
}
////////////////////////////////////////////////////////////////////////////////

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //SLog(@"Application did become active");
    // Clear application badge
	application.applicationIconBadgeNumber = 0;
    //Check if publisherCode1 changed; if yes, we need to update the tabs
    NSString * old = [[NSUserDefaults standardUserDefaults]objectForKey:@"OldPublisherCode1"];
    old = old?old:@"waempty";
    NSString * new = [[NSUserDefaults standardUserDefaults]objectForKey:@"PublisherCode1"];
    new = new?new:@"waempty";
    //SLog(@"old:%@,new:%@",old,new);
    if (![old isEqual:new]){
        [[NSUserDefaults standardUserDefaults]setObject:new forKey:@"OldPublisherCode1"];
        //SLog(@"will updateRootViewCOntroller");
        [self updateRootViewController];
    }
    else{
        //Request ad if appropriate; this needs to be done here (and not in "didFinishLaunchingWithOptions") so that the ad is also displayed when the app awakes from background
        
        [splashScreenViewController requestAd];
    }


    
    
    //Register event with GA
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Application iOS" action:@"Became active" label:@"App" value:[NSNumber numberWithInt:1]] build]];
     


    
    
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
        
        //Add waupdate=0 so that the document is updated every time it is opened
        urlString = [urlString urlByAddingParameterInUrlStringWithKey:@"waupdate" withValue:@"0"];//This permits cached file to be refreshed everytime the main document is changed

        
 		
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



- (void) updateRootViewController {
    //Create the views
    WAPListParser * parser = [[WAPListParser alloc]init];
    parser.urlString = @"/Tabs.plist";
 
	NSMutableArray *tabviews	= [NSMutableArray array];
    
    //If user has specified PublisherCode1, add corresponding tab
    //SLog(@"PublisherCode1: %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"PublisherCode1"]);
    NSString * publisherCode1 = [[NSUserDefaults standardUserDefaults]objectForKey:@"PublisherCode1"];
    if(publisherCode1.length>0){
        //Capitalize first letter
        NSString *firstCapChar = [[publisherCode1 substringToIndex:1] capitalizedString];
        NSString *cappedString = [publisherCode1 stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:firstCapChar];

        NSString * tabUrlString = [NSString stringWithFormat:@"/%@/Magazines.plist?waupdate=30&watitle=%@",publisherCode1,cappedString];
        [self addModuleToTabViews:tabviews withUrlLink:tabUrlString withTitle:cappedString withIcon:@"download.png"];
        
    }

	
	for ( int j = 0; j < [parser countData]; j++ )
	{
         [self addModuleToTabViews:tabviews withUrlLink:[parser getDataAtRow:j+1 forDataCol:DataColDetailLink] withTitle:[parser getDataAtRow:j+1 forDataCol:DataColTitle] withIcon:[parser getDataAtRow:j+1 forDataCol:DataColIcon]];
        
	}
    //SLog(@"Will release parser");
	[parser release];
    if (appTabBarController){
        window.rootViewController = nil;
        [appTabBarController release];
    }
    //SLog(@"Will init WARootViewController");

	appTabBarController = [[WARootViewController alloc]init];
	appTabBarController.moreNavigationController.navigationBar.barStyle = UIBarStyleBlack;
    appTabBarController.delegate = self;
	appTabBarController.viewControllers = 	tabviews;
    //SLog(@"Will test iOS7");
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) appTabBarController.tabBar.translucent = NO;
	
    window.rootViewController = appTabBarController;
	window.backgroundColor = [UIColor blackColor];
    //SLog(@"Will add subview");
	[window addSubview:appTabBarController.view];
    //SLog(@"Did add subview");
	[window makeKeyAndVisible];
    //SLog(@"Did updateRootViewController");
 
    
}
- (void) addModuleToTabViews:(NSMutableArray *)tabviews withUrlLink:(NSString *)tabUrlString withTitle:(NSString*)tabTitle withIcon:(NSString*)iconName {
    WAModuleViewController * moduleViewController = [[WAModuleViewController alloc]init];
    moduleViewController.moduleUrlString= tabUrlString ;
    moduleViewController.title = [tabUrlString titleOfUrlString];
    //Check if the view is a webview; in this case, we load it for speed reasons
    if ((tabviews.count>0)&&([tabUrlString typeOfParserOfUrlString]==ParserTypeHTML)&&(![tabUrlString isLocalUrl])){
     //SLog(@"Will load view in background with Url %@",urlString);
     moduleViewController.view.tag = 111;			//Hack: force loadView if it is a webview with an external URL except for tab 1
     
     }

    
	//See if iconName contains a "."; if not, it means we want to use a system tabBarItem
	NSRange range = [iconName rangeOfString:@"."];
	if (range.location == NSNotFound){
		int uiTabBarSystemItemValue = [iconName intValue];
		moduleViewController.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:uiTabBarSystemItemValue tag:3] autorelease];
		
	}
	else {
		moduleViewController.tabBarItem.title = [[NSBundle mainBundle]stringForKey:tabTitle];
		moduleViewController.tabBarItem.image = [UIImage imageNamed:iconName];
        
	}
    
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:moduleViewController];
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
    [moduleViewController release];

	
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
            NSString *noUnderscoreUrlString = [urlString urlByRemovingFinalUnderscoreInUrlString];//Remove the final underscore];
            NSString * fileName = [noUnderscoreUrlString nameOfFileWithoutExtensionOfUrlString];

            NKIssue *nkIssue = [nkLib issueWithName:fileName];
            if(!nkIssue) {
                nkIssue = [nkLib addIssueWithName:fileName date:issueDate];
                
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


