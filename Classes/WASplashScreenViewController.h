//
//  SplashScreenViewController.h
//  AdvertisingScreen
//
//  Created by admin on 09.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WASplashScreenViewController : UIViewController <NSURLConnectionDelegate>
{
    NSTimer * timer;
    NSString * preferredLanguage;
    NSString * urlString;
    NSURLConnection *currentConnection;



}

@property (nonatomic, retain) NSTimer * timer;
@property (nonatomic, retain) NSString * preferredLanguage;
@property (nonatomic, retain) NSString * urlString;
@property (nonatomic, retain) NSURLConnection *currentConnection;


@property (nonatomic, retain) NSMutableData *resultData;
@property (nonatomic, retain) NSString *adLinkUrlString;


@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, assign) UIViewController *rootViewController;

- (void)dismissAd;
- (void) requestAd;
- (void) showDefault;
- (NSString *)currentOrientation;

@end
