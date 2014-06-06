//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import <UIKit/UIKit.h>
#import "WAModuleProtocol.h"
#import "StoreKit/StoreKit.h"



@interface WABuyView : UIView <UIActionSheetDelegate,UIAlertViewDelegate, WAModuleProtocol,SKProductsRequestDelegate> {
	NSString *urlString;
	UIViewController* currentViewController;
	NSArray *products;
	NSString *subscriberCodeTitle;
    NSString *usernamePasswordTitle;
	
}
@property (nonatomic, retain)	NSArray *products;

- (void) startDownloadOrCheckCredentials;
- (void) createPasswordAlert;
- (void) createNotAllowedAlert;
- (void) requestProducts;

@end
