//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WABuyView.h"
#import "WAUtilities.h"
#import "WAModuleViewController.h"
#import "NSBundle+WAAdditions.h"
#import "NSString+WAURLString.h"
#import "UIView+WAModuleView.m"


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

	
	urlString = [[NSString alloc]initWithString: theString];

	//Add SHKActivityIndicator

    [[SHKActivityIndicator currentIndicator] displayActivity:NSLocalizedString(@"Connecting...",@"")];

    NSString * receipt = [urlString receiptForUrlString];
	
    if (receipt){
		//We have a receipt, proceed to download
		[self startDownload];
	}
	else {
        //Get the ID of the product. Our convention is that it is always the name of the file without extension 
        NSString * shortID = [[urlString urlByRemovingFinalUnderscoreInUrlString] nameOfFileWithoutExtensionOfUrlString];
        //SLog(@"ShortID:%@, theString:%@",shortID,theString);

        //get product data
        NSString * itemID = [NSString stringWithFormat:@"%@.%@",[[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleIdentifier"],shortID];
        //SLog(@"ItemID:%@",itemID);
        SKProductsRequest *request;
        //Add all subscriptions, only if we have a secret key
        NSString * credentials = [[NSBundle mainBundle] pathOfFileWithUrl:@"Application_.plist"];
        NSString * sharedSecret = [NSString string];
        if (credentials) sharedSecret = [[NSDictionary dictionaryWithContentsOfFile:credentials]objectForKey:@"SharedSecret"];
        if (sharedSecret){
            NSMutableSet * productIdentifiers = [NSMutableSet set];
            NSSet * relevantIDs = [urlString relevantSKProductIDsForUrlString];
            //SLog(@"Relevant ids:%@",relevantIDs);
            for (NSString * curentID in relevantIDs){
                NSString * tempID = [NSString stringWithFormat:@"%@.%@",[[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleIdentifier"],curentID];
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
    
	//Create actionSheet
    NSString * theTitle = NSLocalizedString(@"What do you want to buy?",@"" );
    NSString * customTitle = [[NSDictionary dictionaryWithContentsOfFile:credentials]objectForKey:@"TextForBuyTitle"];
     if (customTitle) theTitle = NSLocalizedString(customTitle,@"" );
    
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
        NSString * completeTitle = [product.localizedTitle titleWithSubscriptionLengthForId:product.productIdentifier] ;
        
		[actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@: %@",completeTitle, formattedString]];
		
		
		;
	}
	//Add a Restore my purchases button
	 NSString * locTitle0 = NSLocalizedString(@"Restore my purchases",@"" );//This is the default title
    [actionSheet addButtonWithTitle:locTitle0];
	
	//Add a Code Enter button in case we have a CodeService key in Application_.plist
	NSString * codeService = nil ;
	if (credentials) codeService = [[NSDictionary dictionaryWithContentsOfFile:credentials]objectForKey:@"CodeService"];
	if (codeService) {
        //SLog(@"Code Hash:%@",codeHash);
        subscriberCodeTitle = NSLocalizedString(@"I have a subscriber code",@"" );//This is the default title
        NSString * TextForSubscribers = [[NSDictionary dictionaryWithContentsOfFile:credentials]objectForKey:@"TextForSubscribers"];
        if (TextForSubscribers) subscriberCodeTitle = NSLocalizedString(TextForSubscribers,@"" );
        
		[actionSheet addButtonWithTitle:subscriberCodeTitle];
        //    actionSheet.cancelButtonIndex = destructiveIndex;//was buggy


	}
    NSString * userService = nil ;
    if (credentials) userService = [[NSDictionary dictionaryWithContentsOfFile:credentials]objectForKey:@"UserService"];
    if (userService) {
        usernamePasswordTitle = NSLocalizedString(@"I have a username and password",@"" );//This is the default title
        NSString * TextForSubscribers = [[NSDictionary dictionaryWithContentsOfFile:credentials]objectForKey:@"TextForSubscribers"];
        if (TextForSubscribers) usernamePasswordTitle = NSLocalizedString(TextForSubscribers,@"" );
        
		[actionSheet addButtonWithTitle:usernamePasswordTitle];
        //    actionSheet.cancelButtonIndex = destructiveIndex;//was buggy
        
        
	}
	
	//Add the cancel button. It will not be displayed on the iPad.
	NSInteger destructiveIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel",@"" )];
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

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
	
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
												   message:NSLocalizedString(@"Please check your connection",@"")
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
        [[SHKActivityIndicator currentIndicator] displayActivity:NSLocalizedString(@"Connecting...",@"")];
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    } else if ([buttonTitle isEqualToString:subscriberCodeTitle]) {
            //The enter code button was clicked
            [self createPasswordAlert];
    } else if ([buttonTitle isEqualToString:usernamePasswordTitle]) {
            //The enter username and password button was clicked
            [self createUsernamePasswordAlert];
    } else {
		SKProduct  * product = [products objectAtIndex:buttonIndex];
		//NSString * itemID = product.productIdentifier;
		//SKPayment *payment = [SKPayment paymentWithProductIdentifier:itemID];
        SKPayment * payment = [SKPayment paymentWithProduct:product];
		// Add storeObserver in LibrelioAppDelegate
		[[SKPaymentQueue defaultQueue] addPayment:payment];	
		
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
		//OK button was clicked
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5) {
            UITextField *psField  = [alertView textFieldAtIndex:0];
            [[NSUserDefaults standardUserDefaults] setObject:[psField text] forKey:@"Subscription-code"];

        }
        else{
            UITextField *psField = (UITextField *)[alertView viewWithTag:111];
            [[NSUserDefaults standardUserDefaults] setObject:[psField text] forKey:@"Subscription-code"];
            
        }
		[self startDownload];
	}
    if (alertView.tag == 2 && buttonIndex == 1) {
		//OK button was clicked
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5) {
            UITextField *usernameField = [alertView textFieldAtIndex:0];
            UITextField *passwordField = [alertView textFieldAtIndex:1];
            [[NSUserDefaults standardUserDefaults] setObject:[usernameField text] forKey:@"Username"];
            [[NSUserDefaults standardUserDefaults] setObject:[passwordField text] forKey:@"Password"];
           
        }
        else{
            UITextField *usernameField = (UITextField *)[alertView viewWithTag:111];
            UITextField *passwordField = (UITextField *)[alertView viewWithTag:222];
            [[NSUserDefaults standardUserDefaults] setObject:[usernameField text] forKey:@"Username"];
            [[NSUserDefaults standardUserDefaults] setObject:[passwordField text] forKey:@"Password"];
            
        }

		[self startDownload];
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
	NSSet * acceptableIDs = [urlString relevantSKProductIDsForUrlString];
	
	SKPaymentTransaction *transaction = notification.object;
	NSString * productId = transaction.payment.productIdentifier;
	NSArray *parts = [productId componentsSeparatedByString:@"."];
	NSString *shortID2 = [parts objectAtIndex:[parts count]-1];
	
	
	if ([acceptableIDs containsObject:shortID2]){
		switch (transaction.transactionState)
		{
			case SKPaymentTransactionStateRestored:{
                //Do nothing, wait for restoreCompletedTransactionsFinished notification
                break;
            }
			case SKPaymentTransactionStatePurchased:{
				[self startDownload];
				break;
			}
			case SKPaymentTransactionStateFailed:{
					if (transaction.error.code != SKErrorPaymentCancelled){
					//Inform user if he did not cancel the order himself
					UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
																   message:NSLocalizedString(@"The order failed",@"")
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
		[self startDownload];
	}
	else {
          [self removeFromSuperview];
 		
	}
 
}
#pragma mark -
#pragma mark Helper methods

- (void) startDownload{
    if ([[urlString nameOfFileWithoutExtensionOfUrlString]isEqualToString:@"wanodownload"]){
        //Refresh dispaly so that Subscribe button is no longer shown
        WAModuleViewController * moduleViewController = (WAModuleViewController *) [self traverseResponderChainForUIViewController];
        [moduleViewController viewWillAppear:YES];

        
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
    }
	[self removeFromSuperview];
	
	
}

- (void) createPasswordAlert{
	
    
    //Depending on system version, we have UIAlertViewStyleSecureTextInput or not
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5) {
        UIAlertView *passwordAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Code",@"" ) message:NSLocalizedString(@"Please enter your code",@"" ) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
        
        passwordAlert.alertViewStyle =  UIAlertViewStylePlainTextInput;
        UITextField *passwordField = [passwordAlert textFieldAtIndex:0];
        [passwordField becomeFirstResponder];
        passwordAlert.tag = 1;
        [passwordAlert show];
        [passwordAlert release];
        

    }
    else{
        //This will soon be deprecated
        UIAlertView *passwordAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Code",@"" ) message:@"\n\n\n" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
        UILabel *passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,40,260,25)];
        passwordLabel.font = [UIFont systemFontOfSize:16];
        passwordLabel.textColor = [UIColor whiteColor];
        passwordLabel.backgroundColor = [UIColor clearColor];
        passwordLabel.shadowColor = [UIColor blackColor];
        passwordLabel.shadowOffset = CGSizeMake(0,-1);
        passwordLabel.textAlignment = UITextAlignmentCenter;
        passwordLabel.text = NSLocalizedString(@"Please enter your code",@"" );
        [passwordAlert addSubview:passwordLabel];
        [passwordLabel release];
        
        
        UITextField *passwordField = [[UITextField alloc] initWithFrame:CGRectMake(16,78,252,30)];
        passwordField.secureTextEntry = YES;
        passwordField.borderStyle = UITextBorderStyleRoundedRect;
        passwordField.keyboardAppearance = UIKeyboardAppearanceAlert;
        //passwordField.delegate = self;
        [passwordField becomeFirstResponder];
        [passwordAlert addSubview:passwordField];
        passwordField.tag = 111;
        [passwordField release];
        
        passwordAlert.tag = 1;
        [passwordAlert show];
        [passwordAlert release];
        

    }

 	

	
}

- (void) createUsernamePasswordAlert{
    
    
    //Depending on system version, we have UIAlertViewStyleSecureTextInput or not
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5) {
        UIAlertView *passwordAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login",@"" ) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
        
        passwordAlert.alertViewStyle =  UIAlertViewStyleLoginAndPasswordInput;
        UITextField *usernameField = [passwordAlert textFieldAtIndex:0];
        [usernameField setPlaceholder:NSLocalizedString(@"Username",@"" )];
        [usernameField becomeFirstResponder];
        
        UITextField *passwordField = [passwordAlert textFieldAtIndex:1];
        [passwordField setPlaceholder:NSLocalizedString(@"Password",@"" )];
        [passwordField setSecureTextEntry:YES];
        
        
        passwordAlert.tag = 2;
        [passwordAlert show];
        [passwordAlert release];
        
        
    }
    else{
        //This will soon be deprecated
        UIAlertView *passwordAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login",@"" ) message:@"\n\n\n" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
        
        UITextField *usernameField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 50.0, 260.0, 25.0)];
        [usernameField setBackgroundColor:[UIColor whiteColor]];
        [usernameField setPlaceholder:NSLocalizedString(@"Username",@"" )];
        usernameField.borderStyle = UITextBorderStyleRoundedRect;
        usernameField.keyboardAppearance = UIKeyboardAppearanceAlert;
        usernameField.tag = 111;
        [passwordAlert addSubview:usernameField];
        
        UITextField *passwordField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 85.0, 260.0, 25.0)];
        [passwordField setBackgroundColor:[UIColor whiteColor]];
        [passwordField setPlaceholder:NSLocalizedString(@"Password",@"" )];
        [passwordField setSecureTextEntry:YES];
        passwordField.borderStyle = UITextBorderStyleRoundedRect;
        passwordField.keyboardAppearance = UIKeyboardAppearanceAlert;
        passwordField.tag = 222;
        [passwordAlert addSubview:passwordField];
        
        passwordAlert.tag = 2;
        [passwordAlert show];
        [passwordAlert release];
        
        [usernameField becomeFirstResponder];
        
        
    }
    
    
	
	
}



@end

