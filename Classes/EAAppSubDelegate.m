/*
 Copyright (c) 2008 - 2010, Manifest Interactive, LLC. All rights
reserved.

This license is a legal agreement between you and Manifest Interactive,
LLC. for the use of Manifest Interactive Software (the "Software"). By
obtaining the Software you agree to comply with the terms and conditions
of this license.

PERMITTED USE You are permitted to use, copy, modify, and distribute the
Software and its documentation, with or without modification, for any
purpose, provided that the following conditions are met:

1. A copy of this license agreement must be included with the
distribution.

2. Redistributions of source code must retain the above copyright notice
in all source code files.

3. Redistributions in binary form must reproduce the above copyright
notice in the documentation and/or other materials provided with the
distribution.

4. Any files that have been modified must carry notices stating the
nature of the change and the names of those who changed them.

5. Products derived from the Software must include an acknowledgment
that they are derived from Manifest Interactive in their documentation
and/or other materials provided with the distribution.

6. Products derived from the Software may not be called "Manifest
Interactive", nor may "Manifest Interactive" appear in their name,
without prior written permission from Manifest Interactive, LLC.

INDEMNITY You agree to indemnify and hold harmless the authors of the
Software and any contributors for any direct, indirect, incidental, or
consequential third-party claims, actions or suits, as well as any
related expenses, liabilities, damages, settlements or fees arising from
your use or misuse of the Software, or a violation of any terms of this
license.

DISCLAIMER OF WARRANTY THE SOFTWARE IS PROVIDED "AS IS", WITHOUT
WARRANTY OF ANY KIND, EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED
TO, WARRANTIES OF QUALITY, PERFORMANCE, NON-INFRINGEMENT,
MERCHANTABILITY, OR FITNESS FOR A PARTICULAR PURPOSE.

LIMITATIONS OF LIABILITY YOU ASSUME ALL RISK ASSOCIATED WITH THE
INSTALLATION AND USE OF THE SOFTWARE. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS OF THE SOFTWARE BE LIABLE FOR CLAIMS, DAMAGES OR OTHER
LIABILITY ARISING FROM, OUT OF, OR IN CONNECTION WITH THE SOFTWARE.
LICENSE HOLDERS ARE SOLELY RESPONSIBLE FOR DETERMINING THE
APPROPRIATENESS OF USE AND ASSUME ALL RISKS ASSOCIATED WITH ITS USE,
INCLUDING BUT NOT LIMITED TO THE RISKS OF PROGRAM ERRORS, DAMAGE TO
EQUIPMENT, LOSS OF DATA OR SOFTWARE PROGRAMS, OR UNAVAILABILITY OR
INTERRUPTION OF OPERATIONS.





*/


#import "EAAppSubDelegate.h"

#import <AudioToolbox/AudioToolbox.h> //Added by Librelio


@implementation EAAppSubDelegate


/* 
 * --------------------------------------------------------------------------------------------------------------
 *  BEGIN APNS CODE 
 * --------------------------------------------------------------------------------------------------------------
 */

/**
 * Fetch and Format Device Token and Register Important Information to Remote Server
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
	
	
#if !TARGET_IPHONE_SIMULATOR
	
	// Get Bundle Info for Remote Registration (handy if you have more than one app)
	//NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];REMOVED BY LIBRELIO
	NSString *appName = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleIdentifier"];//ADDED BY LIBRELIO
	NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	
	// Check what Notifications the user has turned on.  We registered for all three, but they may have manually disabled some or all of them.
	NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];

	/*REMOVED BY LIBRELIO
	// Set the defaults to disabled unless we find otherwise...
	NSString *pushBadge = @"disabled";
	NSString *pushAlert = @"disabled";
	NSString *pushSound = @"disabled";
	
    // Check what Registered Types are turned on. This is a bit tricky since if two are enabled, and one is off, it will return a number 2... not telling you which
	// one is actually disabled. So we are literally checking to see if rnTypes matches what is turned on, instead of by number. The "tricky" part is that the 
	// single notification types will only match if they are the ONLY one enabled.  Likewise, when we are checking for a pair of notifications, it will only be 
	// true if those two notifications are on.  This is why the code is written this way ;)
	if(rntypes == UIRemoteNotificationTypeBadge){
		pushBadge = @"enabled";
	}
	else if(rntypes == UIRemoteNotificationTypeAlert){
		pushAlert = @"enabled";
	}
	else if(rntypes == UIRemoteNotificationTypeSound){
		pushSound = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert)){
		pushBadge = @"enabled";
		pushAlert = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)){
		pushBadge = @"enabled";
		pushSound = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)){
		pushAlert = @"enabled";
		pushSound = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)){
		pushBadge = @"enabled";
		pushAlert = @"enabled";
		pushSound = @"enabled";
	}
    END REMOVED*/
    //ADDED BY LIBRELIO
    
    //By default, enable notifications, otherwise we will not be able to send messages after the first launch
    NSString *pushBadge = @"enabled";
	NSString *pushAlert = @"enabled";
	NSString *pushSound = @"enabled";

	if(rntypes & UIRemoteNotificationTypeBadge) pushBadge = @"enabled";
    else pushBadge = @"disabled";
	if(rntypes & UIRemoteNotificationTypeAlert)pushAlert = @"enabled";
    else pushAlert = @"disabled";
	if(rntypes & UIRemoteNotificationTypeSound)pushSound = @"enabled";
    else pushSound = @"disabled";
    
     
    //END ADDED
	
	// Get the users Device Model, Display Name, Unique ID, Token & Version Number
	UIDevice *dev = [UIDevice currentDevice];
	NSString *deviceUuid = dev.uniqueIdentifier;
    NSString *deviceName = dev.name;
	NSString *deviceModel = dev.model;
	NSString *deviceSystemVersion = dev.systemVersion;
	
	// Prepare the Device Token for Registration (remove spaces and < >)
	NSString *deviceToken = [[[[devToken description] 
							   stringByReplacingOccurrencesOfString:@"<"withString:@""] 
							  stringByReplacingOccurrencesOfString:@">" withString:@""] 
							 stringByReplacingOccurrencesOfString: @" " withString: @""];
	
	// Build URL String for Registration
	// !!! CHANGE "www.mywebsite.com" TO YOUR WEBSITE. Leave out the http://
	// !!! SAMPLE: "secure.awesomeapp.com"
	NSString *host = @"apns.librelio.com";
	
	// !!! CHANGE "/apns.php?" TO THE PATH TO WHERE apns.php IS INSTALLED 
	// !!! ( MUST START WITH / AND END WITH ? ). 
	// !!! SAMPLE: "/path/to/apns.php?"
	NSString *urlString = [NSString stringWithFormat:@"/apns/apns.php?task=%@&appname=%@&appversion=%@&deviceuid=%@&devicetoken=%@&devicename=%@&devicemodel=%@&deviceversion=%@&pushbadge=%@&pushalert=%@&pushsound=%@", @"register", appName,appVersion, deviceUuid, deviceToken, deviceName, deviceModel, deviceSystemVersion, pushBadge, pushAlert, pushSound];
	
	// Register the Device Data
	// !!! CHANGE "http" TO "https" IF YOU ARE USING HTTPS PROTOCOL
	NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:host path:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [url release];
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
#endif
}

/**
 * Failed to Register for Remote Notifications
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	
#if !TARGET_IPHONE_SIMULATOR
	
	//SLog(@"Error in registration. Error: %@", error);
	
#endif
}

/**
 * Remote Notification Received while application was open.
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	
#if !TARGET_IPHONE_SIMULATOR
    
	//SLog(@"remote notification: %@",[userInfo description]);
	NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
	
	//NSString *alert = [apsInfo objectForKey:@"alert"];
	//SLog(@"Received Push Alert: %@", userInfo);
	
	//NSString *sound = [apsInfo objectForKey:@"sound"];
	//SLog(@"Received Push Sound: %@", sound);
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	
	//NSString *badge = [apsInfo objectForKey:@"badge"];
	//SLog(@"Received Push Badge: %@", badge);
	application.applicationIconBadgeNumber = [[apsInfo objectForKey:@"badge"] integerValue];
	
#endif
}

/* 
 * --------------------------------------------------------------------------------------------------------------
 *  END APNS CODE 
 * --------------------------------------------------------------------------------------------------------------
 */

@end
