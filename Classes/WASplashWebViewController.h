//
//  WebViewBasedViewController.h
//  AdvertisingScreen
//
//  Created by playrhyba on 10.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WASplashScreenViewController;

@interface WASplashWebViewController : UIViewController
{
    
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *safariButton;

@property (nonatomic, retain) WASplashScreenViewController *parent;
@property (nonatomic, retain) UIViewController *rootViewController;

- (IBAction)doneButtonClicked:(id)sender;
- (IBAction)safariButtonClicked:(id)sender;



@end
