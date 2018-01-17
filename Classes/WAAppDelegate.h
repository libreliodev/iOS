//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.

#import <UIKit/UIKit.h>
#import "WAPaymentTransactionObserver.h"
#import "WAPListParser.h"
#import "WAAppSubDelegate.h"

@import GoogleMobileAds;




@interface WAAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate,GADInterstitialDelegate> {
    UIWindow *window;
    UIViewController *rootViewController;
    DFPInterstitial * startInterstitial;
    WAPaymentTransactionObserver *observer;
    WAAppSubDelegate * apnsSubDelegate;
    NSMetadataQuery * metadataQuery;
    
    
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UITabBarController *rootViewController;
@property (nonatomic, retain) DFPInterstitial * startInterstitial;
@property (nonatomic, retain) WAAppSubDelegate * apnsSubDelegate;
@property (nonatomic, retain) NSMetadataQuery * metadataQuery;



/**
 * @brief: Builds or update the root view controller (tab view)
 **/
- (void) createRootViewController;

/**
 * @brief: Adds a view controller to the tab views
 **/
- (void) addModuleToTabViews:(NSMutableArray *)tabviews withUrlLink:(NSString *)tabUrlString withTitle:(NSString*)tabTitle withIcon:(NSString*)iconName;


/**
 * @brief: Restarts operations that may have been inteerrupted by a memory warning
 **/
- (void) restartOperations;

/**
 * @brief: launches Newsstand download after receiving a notification
 **/
- (void) launchNewstandDownloadFromNotification: (NSDictionary*) payload;

@end


