//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.

#import <UIKit/UIKit.h>
#import "WAPaymentTransactionObserver.h"	
#import "WAPListParser.h"
#import "EAAppSubDelegate.h"

#import "WASplashScreenViewController.h"


@interface WAAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
	UIWindow *window;
	UITabBarController *appTabBarController;
    WASplashScreenViewController * splashScreenViewController;
	WAPaymentTransactionObserver *observer;
    EAAppSubDelegate * apnsSubDelegate;
    NSMetadataQuery * metadataQuery;


}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UITabBarController *appTabBarController;
@property (nonatomic, retain) WASplashScreenViewController * splashScreenViewController;
@property (nonatomic, retain) EAAppSubDelegate * apnsSubDelegate;
@property (nonatomic, retain) NSMetadataQuery * metadataQuery;


/**
 * @brief: Builds or update the root view controller (tab view)
 **/
- (void) updateRootViewController;

/**
 * @brief: Adds a view controller to the tab views
 **/
- (void) addViewController:(UIViewController*)view toTabViews:(NSMutableArray *)tabviews withParser:(WAPListParser *)parser atRow:(int)row;

/**
 * @brief: Moves documents from the document directory to the cache directory according to Apple specs
 **/
- (void) moveDocumentsToCache;

/**
 * @brief: Restarts operations that may have been inteerrupted by a memory warning
 **/
- (void) restartOperations;

/**
 * @brief: launches Newsstand download after receiving a notification
 **/
- (void) launchNewstandDownloadFromNotification: (NSDictionary*) payload;

@end


