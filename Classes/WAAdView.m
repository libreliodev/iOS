#import "WAAdView.h"
#import "UIColor+WAAdditions.h"
#import "UIView+WAModuleView.h"
#import "WAModuleViewController.h"
#import "WAUtilities.h"
#import "WAOperationsManager.h"

#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.h"



//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


@implementation WAAdView

@synthesize currentViewController;


- (id)init
{
    if ((self = [super initWithAdSize:kGADAdSizeBanner])) {
    }
    return self;
}


- (NSString *) urlString
{
    return urlString;
}

- (void) setUrlString: (NSString *) theString
{
    if (urlString){
		//Do nothing
		
		
	}
	else {
        urlString = [[NSString alloc]initWithString: theString];
        self.rootViewController = currentViewController;
        
        NSDictionary * app_Dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathOfFileWithUrl:@"Application_.plist"]];
        NSString * DfpPrefix = [app_Dic objectForKey:@"DfpPrefix"];
        if (DfpPrefix){
            NSString * shortUnitId = [[urlString noArgsPartOfUrlString] lastPathComponent];
            //SLog (@"url: %@, short:%@",urlString,shortUnitId);
            self.adUnitID = [DfpPrefix completeAdUnitCodeForShortCode:shortUnitId];
            self.delegate = self;
            //SLog(@"self.adUnitID %@",self.adUnitID);
            GADRequest *request = [GADRequest request];
            //request.testDevices = @[ GAD_SIMULATOR_ID ];
            [self loadRequest:request];
            
            
       }

 
    }
}










- (void)dealloc {

	[urlString release];
    [super dealloc];
}

#pragma mark -
#pragma mark ModuleView protocol

- (void)moduleViewWillAppear:(BOOL)animated{
	
	
}
- (void) moduleViewDidAppear{
}


- (void) moduleViewWillDisappear:(BOOL)animated{
}



- (void) moduleWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
}
- (void) moduleWillAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{

	
}

- (void) jumpToRow:(int)row{
    
}


#pragma mark -
#pragma mark GADBannerViewDelegate

/// Called when an ad request loaded an ad.
- (void)adViewDidReceiveAd:(DFPBannerView *)adView {
    //SLog(@"adViewDidReceiveAd");
}

/// Called when an ad request failed.
- (void)adView:(DFPBannerView *)adView didFailToReceiveAdWithError:(GADRequestError *)error {
    //SLog(@"adViewDidFailToReceiveAdWithError: %@", [error localizedDescription]);
}

/// Called just before presenting the user a full screen view, such as
/// a browser, in response to clicking on an ad.
- (void)adViewWillPresentScreen:(DFPBannerView *)adView {
    //SLog(@"adViewWillPresentScreen");
}

/// Called just before dismissing a full screen view.
- (void)adViewWillDismissScreen:(DFPBannerView *)adView {
    //SLog(@"adViewWillDismissScreen");
}

/// Called just after dismissing a full screen view.
- (void)adViewDidDismissScreen:(DFPBannerView *)adView {
    //SLog(@"adViewDidDismissScreen");
}

/// Called just before the application will background or terminate
/// because the user clicked on an ad that will launch another
/// application (such as the App Store).
- (void)adViewWillLeaveApplication:(DFPBannerView *)adView {
    //SLog(@"adViewWillLeaveApplication");
}

@end
