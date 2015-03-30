//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WABuyView.h"
#import "WAUtilities.h"
#import "WAModuleViewController.h"
#import "NSBundle+WAAdditions.h"
#import "NSString+WAURLString.h"
#import "UIView+WAModuleView.m"
#import "WADocumentDownloadsManager.h"



#import "SHKActivityIndicator.h"
#import <QuartzCore/QuartzCore.h>



@implementation WABuyView

@synthesize currentViewController,products;


- (NSString *) urlString
{
    return urlString;
}

- (void) setUrlString: (NSString *) theString
{
	//Receive notification when transaction status changed
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transactionStatusDidChangeWithNotification:) name:@"transactionStatusDidChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreCompletedTransactionsFinishedWithNotification:) name:@"restoreCompletedTransactionsFinished" object:nil];
    
    
    //Receive notifications when logging in
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailIssueDownloadWithNotification:) name:@"didFailIssueDownload" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSucceedIssueDownloadWithNotification:) name:@"didSucceedIssueDownload" object:nil];


	
	urlString = [[NSString alloc]initWithString: theString];


    NSString * receipt = [urlString receiptForUrlString];
    
    NSString * login = [urlString valueOfParameterInUrlStringforKey:@"walogin"];

	
    if (receipt){
		//We have a receipt, proceed to download
		[self startDownloadOrCheckCredentials];
	}
	else if ([WAUtilities featuresInApps]&&!login) {
        //The app has in app purchases, fetch list of relevant products (single or subscriptions)
        [self requestProducts];

    }
    else if ([WAUtilities getCodeService]){
        [self createPasswordAlert];
    }
    else if ([WAUtilities getUserService]){
        [self createUsernamePasswordAlert];
    }
    else{
        [self createNotAllowedAlert];
    }


	

}




- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [[SHKActivityIndicator currentIndicator] hide];
    
	[products release];
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

# pragma mark -
# pragma mark SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
     
    [[SHKActivityIndicator currentIndicator] hide];

    NSString * credentials = [[NSBundle mainBundle] pathOfFileWithUrl:@"Application_.plist"];
    
    
    //If waproductid was specified, do not display action sheet
    NSString * productId = [urlString valueOfParameterInUrlStringforKey:@"waproductid"];
    if (productId){
        for (SKProduct *product in response.products) {
            //SLog(@"found %@, looking for %@",[product productIdentifier],productId);
            if ([[productId appStoreProductIDForLibrelioProductID]isEqualToString:[product productIdentifier]]){
                //SLog(@"will try to buy %@",product);
                [self orderProduct:product];
            }
            
     
        }

    }
    else{
        //Otherwise, reate actionSheet
        NSString * theTitle = [[NSBundle mainBundle]stringForKey:@"What do you want to buy?"];
        NSString * customTitle = [[NSDictionary dictionaryWithContentsOfFile:credentials]objectForKey:@"TextForBuyTitle"];
        if (customTitle) theTitle = [[NSBundle mainBundle]stringForKey:customTitle];
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:theTitle
                                                                 delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
        
        
        //Parse response
        products = [[NSArray alloc] initWithArray: response.products];
        for (SKProduct *product in products) {
            //SLog(@"Product received:%@",product);
            
            //Format the price
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setLocale:product.priceLocale];
            NSString *formattedString = [numberFormatter stringFromNumber:product.price];
            [numberFormatter release];
            
            //Append duration to description if needed
            NSString * completeTitle = [product.localizedTitle titleWithSubscriptionLengthForAppStoreProductId:product.productIdentifier] ;
            
            [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@: %@",completeTitle, formattedString]];
            
            
            ;
        }
        //Add a Restore my purchases button
        NSString * locTitle0 = [[NSBundle mainBundle]stringForKey:@"Restore my purchases"];//This is the default title
        [actionSheet addButtonWithTitle:locTitle0];
        
        //Add a Code Enter button in case we have a CodeService key in Application_.plist
        NSString * codeService = nil ;
        if (credentials) codeService = [[NSDictionary dictionaryWithContentsOfFile:credentials]objectForKey:@"CodeService"];
        if (codeService) {
            //SLog(@"Code Hash:%@",codeHash);
            subscriberCodeTitle = [[NSBundle mainBundle]stringForKey:@"I have a subscriber code"];
            [actionSheet addButtonWithTitle:subscriberCodeTitle];
            //    actionSheet.cancelButtonIndex = destructiveIndex;//was buggy
            
            
        }
        NSString * userService = nil ;
        if (credentials) userService = [[NSDictionary dictionaryWithContentsOfFile:credentials]objectForKey:@"UserService"];
        if (userService) {
            usernamePasswordTitle = [[NSBundle mainBundle]stringForKey:@"I have a username and password"];
            [actionSheet addButtonWithTitle:usernamePasswordTitle];
            //    actionSheet.cancelButtonIndex = destructiveIndex;//was buggy
            
            
        }
        
        //Add the cancel button. It will not be displayed on the iPad.
        NSInteger destructiveIndex = [actionSheet addButtonWithTitle:[[NSBundle mainBundle]stringForKey:@"Cancel"]];
        actionSheet.destructiveButtonIndex = destructiveIndex;
        actionSheet.cancelButtonIndex = destructiveIndex;
        
        
        
        
        /*for (NSString * invalidS in response.invalidProductIdentifiers){
         //SLog(@"invalidS:%@",invalidS);
         }*/
        //[actionSheet showInView:self.superview];
        if (self.superview)//The superview may have been released if a refresh download has taken place
        {
            if ([WAUtilities isBigScreen]){
                //SLog(@"will show from rect with width %f and x %f and y %f",self.frame.size.width,self.frame.origin.x, self.frame.origin.y);
                [actionSheet showFromRect:self.frame inView:self.superview animated:YES];
                
            }
            else [actionSheet showFromTabBar:self.currentViewController.tabBarController.tabBar];
            
            
        }	
        [actionSheet release];
        
    }
    
	
 
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
	
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
												   message:[[NSBundle mainBundle]stringForKey:@"Please check your connection"]
												  delegate:nil 
										 cancelButtonTitle:@"OK"
										 otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	[self removeFromSuperview];

	
}


#pragma mark -
#pragma mark UIActionSheet protocol

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	if (buttonIndex == actionSheet.numberOfButtons-1){
		//The cancel button was clicked
		[self removeFromSuperview];
	} else if (buttonIndex==[products count]) {
		//The restore purchases button was clicked
        [[SHKActivityIndicator currentIndicator] displayActivity:[[NSBundle mainBundle]stringForKey:@"Connecting..."]];
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    } else if ([buttonTitle isEqualToString:subscriberCodeTitle]) {
            //The enter code button was clicked
            [self createPasswordAlert];
    } else if ([buttonTitle isEqualToString:usernamePasswordTitle]) {
            //The enter username and password button was clicked
            [self createUsernamePasswordAlert];
    } else {
        [self orderProduct:[products objectAtIndex:buttonIndex]];
		
	}

				
	
}

#pragma mark -
#pragma mark UIAlertView protocol

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex == 0) {
		//Cancel button was clicked
		[self removeFromSuperview];
	}
    
    if (alertView.tag == 1 && buttonIndex == 1) {
		//OK button was clicked in password only alert
            UITextField *psField  = [alertView textFieldAtIndex:0];
            [[NSUserDefaults standardUserDefaults] setObject:[psField text] forKey:@"Subscription-code"];

 		[self startDownloadOrCheckCredentials];
	}
    if (alertView.tag == 2 && buttonIndex == 1) {
		//OK button was clicked in username + password alart
            UITextField *usernameField = [alertView textFieldAtIndex:0];
            UITextField *passwordField = [alertView textFieldAtIndex:1];
            [[NSUserDefaults standardUserDefaults] setObject:[usernameField text] forKey:@"Username"];
            [[NSUserDefaults standardUserDefaults] setObject:[passwordField text] forKey:@"Password"];
 
		[self startDownloadOrCheckCredentials];
	}
	
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    UITextField *usernameField = [alertView textFieldAtIndex:0];
    if ([usernameField.text length] == 0)
    {
        return NO;//Username should not be empty
    }
    if (alertView.tag == 2) {
        UITextField *passwordField = [alertView textFieldAtIndex:1];
        if ([passwordField.text length] == 0)
        {
            return NO;//Password should not be empty
        }

    }
    return YES;
}


#pragma mark -
#pragma mark Notifications
- (void) transactionStatusDidChangeWithNotification:(NSNotification *) notification
{
	//Check whether the transaction is for a product requested here or a subscription
	NSSet * acceptableLibrelioIDs = [urlString relevantLibrelioProductIDsForUrlString];
    NSMutableSet * acceptableAppStoreIDs = [NSMutableSet set];
    for (NSString * curentID in acceptableLibrelioIDs){
        NSString * appStoreID =  [curentID appStoreProductIDForLibrelioProductID];
        [acceptableAppStoreIDs addObject:appStoreID];
    }

	
	SKPaymentTransaction *transaction = notification.object;
	NSString * productId = transaction.payment.productIdentifier;
	
	
	if ([acceptableAppStoreIDs containsObject:productId]){
		switch (transaction.transactionState)
		{
			case SKPaymentTransactionStateRestored:{
                //Do nothing, wait for restoreCompletedTransactionsFinished notification
                break;
            }
			case SKPaymentTransactionStatePurchased:{
				[self startDownloadOrCheckCredentials];
				break;
			}
			case SKPaymentTransactionStateFailed:{
					if (transaction.error.code != SKErrorPaymentCancelled){
					//Inform user if he did not cancel the order himself
					UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
																   message:[[NSBundle mainBundle]stringForKey:@"The order failed"]
																  delegate:nil 
														 cancelButtonTitle:@"OK"
														 otherButtonTitles:nil];
					[alert show];
					[alert release];
				}
						
				[self removeFromSuperview];
				break;
			}
			default:
				break;
		}
		
	}
		
		
	
	
	
	
	
}


- (void) restoreCompletedTransactionsFinishedWithNotification:(NSNotification *) notification{
	//SLog(@"restore Transaction finished with notification %@",notification);
    

    
    NSString * receipt = [urlString receiptForUrlString];
	
    if (receipt){
        //SLog(@"Receipt found: %@",receipt);
		//We have a receipt, proceed to download
		[self startDownloadOrCheckCredentials];
	}
	else {
          [self removeFromSuperview];
 		
	}
 
}

- (void) didFailIssueDownloadWithNotification:(NSNotification *) notification{
    NSDictionary *notificatedDic = notification.object;
    //Check if notificatin is for wanodownload, otherwise don't do anything
    NSString *notificatedUrl = [notificatedDic objectForKey:@"urlString"];
    //SLog(@"Notification received by didFailIssueDownloadWithNotification %@, %@",notification,notificatedUrl);
   if ([notificatedUrl isEqualToString:@"buy://localhost/wanodownload.pdf"]){
        [[SHKActivityIndicator currentIndicator] hide];
        
        NSString * httpStatus = [notificatedDic objectForKey:@"httpStatus"];
        NSString * theMessage = [[NSBundle mainBundle]stringForKey:@"Please check your connection"];
        if ([httpStatus isEqualToString:@"401"]) theMessage = [[NSBundle mainBundle]stringForKey:@"Invalid Code"];
        if ([httpStatus isEqualToString:@"461"]) theMessage = [[NSBundle mainBundle]stringForKey:@"Invalid Username Or Password"];
        if ([httpStatus isEqualToString:@"462"]) [self didSucceedIssueDownloadWithNotification:notification];//No error to display, it's normal that "wanodownload" is not allowed
       else if ([httpStatus isEqualToString:@"999"]) [self didSucceedIssueDownloadWithNotification:notification];//No error to display, 999 error code is returned by AWS when trying to download non existing file
        else if ([httpStatus isEqualToString:@"463"]) [self didSucceedIssueDownloadWithNotification:notification];//Should not happen
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                           message:theMessage
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
            [alert show];
            [alert release];
            
        }
        
    }
}

- (void) didSucceedIssueDownloadWithNotification:(NSNotification *) notification{
    [[SHKActivityIndicator currentIndicator] hide];
    NSDictionary *notificatedDic = notification.object;
    NSString *notificatedUrl = [notificatedDic objectForKey:@"urlString"];
    
    if ([notificatedUrl isEqualToString:@"buy://localhost/wanodownload.pdf"]){
        [[SHKActivityIndicator currentIndicator] hide];
    }
    //Refresh dispaly so that Subscribe button is no longer shown
    WAModuleViewController * moduleViewController = (WAModuleViewController *) [self traverseResponderChainForUIViewController];
    [moduleViewController viewWillAppear:YES];

    
}



#pragma mark -
#pragma mark Helper methods

- (void) startDownloadOrCheckCredentials{
    //SLog(@"Will start download");
    if ([[urlString nameOfFileWithoutExtensionOfUrlString]isEqualToString:@"wanodownload"]){
        //There is nothing to download, we just need to check credentials are OK. We use WADocumentDownloader class because it has all needed geatures and will report status with notications.
        if (![[WADocumentDownloadsManager sharedManager]isAlreadyInQueueIssueWithUrlString:urlString]){
                WADocumentDownloader * issue = [[WADocumentDownloader alloc]init];
                [[[WADocumentDownloadsManager sharedManager] issuesQueue]addObject:issue];
                issue.urlString = urlString;
                [issue release];
        }
        //Add SHKActivityIndicator
        [[SHKActivityIndicator currentIndicator] displayActivity:[[NSBundle mainBundle]stringForKey:@"Connecting..."]];

    }
    else{
        NSString * newUrlString = [urlString stringByReplacingOccurrencesOfString:@"buy://localhost" withString:@""];
        WAModuleViewController * loadingViewController = [[WAModuleViewController alloc]init];
        loadingViewController.moduleUrlString= newUrlString;
        loadingViewController.initialViewController= self.currentViewController;
        loadingViewController.containingView= self.superview;
        loadingViewController.containingRect= CGRectZero;
        [loadingViewController pushViewControllerIfNeededAndLoadModuleView];
        [loadingViewController release];
        [self removeFromSuperview];

    }
	
	
}

- (void) createPasswordAlert{
	
    
        UIAlertView *passwordAlert = [[UIAlertView alloc] initWithTitle:[[NSBundle mainBundle]stringForKey:@"Code"] message:[[NSBundle mainBundle]stringForKey:@"Please enter your code"] delegate:self cancelButtonTitle:[[NSBundle mainBundle]stringForKey:@"Cancel"] otherButtonTitles:[[NSBundle mainBundle]stringForKey:@"OK"] , nil, nil];
        
        passwordAlert.alertViewStyle =  UIAlertViewStylePlainTextInput;
        UITextField *passwordField = [passwordAlert textFieldAtIndex:0];
        [passwordField becomeFirstResponder];
        passwordAlert.tag = 1;
        [passwordAlert show];
        [passwordAlert release];
        


 	

	
}

- (void) createUsernamePasswordAlert{
    //SLog(@"Will create alrt ppp");
    
        UIAlertView *passwordAlert = [[UIAlertView alloc] initWithTitle:[[NSBundle mainBundle]stringForKey:@"Login"] message:@"" delegate:self cancelButtonTitle:[[NSBundle mainBundle]stringForKey:@"Cancel"] otherButtonTitles:[[NSBundle mainBundle]stringForKey:@"OK"], nil];
        
        passwordAlert.alertViewStyle =  UIAlertViewStyleLoginAndPasswordInput;
        UITextField *usernameField = [passwordAlert textFieldAtIndex:0];
        [usernameField setPlaceholder:[[NSBundle mainBundle]stringForKey:@"Username"]];
        [usernameField becomeFirstResponder];
        
        UITextField *passwordField = [passwordAlert textFieldAtIndex:1];
        [passwordField setPlaceholder:[[NSBundle mainBundle]stringForKey:@"Password"]];
        [passwordField setSecureTextEntry:YES];
        
        
        passwordAlert.tag = 2;
        [passwordAlert show];
        [passwordAlert release];
        
        
      
    
	
	
}

- (void) createNotAllowedAlert{
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:[[NSBundle mainBundle]stringForKey:@"Error"] message:[[NSBundle mainBundle]stringForKey:@"You are not allowed to download this publication"] delegate:self cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
    
    errorAlert.tag = 3;
    [errorAlert show];
    [errorAlert release];
}







- (void) requestProducts{
    //Add SHKActivityIndicator
    [[SHKActivityIndicator currentIndicator] displayActivity:[[NSBundle mainBundle]stringForKey:@"Connecting..."]];
    
    //Get the Librelio ID of the product. Our convention is that it is always the name of the file without extension
    NSString * shortID = [[urlString urlByRemovingFinalUnderscoreInUrlString] nameOfFileWithoutExtensionOfUrlString];
    //SLog(@"ShortID:%@, theString:%@",shortID,theString);
    
    //get product data
    NSString * itemID = [shortID appStoreProductIDForLibrelioProductID];
    //SLog(@"ItemID:%@",itemID);
    SKProductsRequest *request;
    //Add all subscriptions, only if we have a secret key
    NSString * credentials = [[NSBundle mainBundle] pathOfFileWithUrl:@"Application_.plist"];
    NSString * sharedSecret = [NSString string];
    if (credentials) sharedSecret = [[NSDictionary dictionaryWithContentsOfFile:credentials]objectForKey:@"SharedSecret"];
    if (sharedSecret){
        NSMutableSet * productIdentifiers = [NSMutableSet set];
        NSSet * relevantIDs = [urlString relevantLibrelioProductIDsForUrlString];
        //SLog(@"Relevant ids:%@",relevantIDs);
        for (NSString * curentID in relevantIDs){
            NSString * tempID =  [curentID appStoreProductIDForLibrelioProductID];
            [productIdentifiers addObject:tempID];
        }
        //Request the data
        request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    }
    else {
        request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObjects:
                                                                         itemID,
                                                                         nil]];
        
    }
    request.delegate = self;
    [request start];
    
    
    
}

- (void) orderProduct:(SKProduct*)product{
     //NSString * itemID = product.productIdentifier;
    //SKPayment *payment = [SKPayment paymentWithProductIdentifier:itemID];
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    // Add storeObserver in LibrelioAppDelegate
    [[SKPaymentQueue defaultQueue] addPayment:payment];

    
    
}


@end

