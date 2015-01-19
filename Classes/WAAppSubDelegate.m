

#import "WAAppSubDelegate.h"

#import <AudioToolbox/AudioToolbox.h> 


@implementation WAAppSubDelegate


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
	
	NSString *appName = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleIdentifier"];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	
	NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];

    NSString *pushBadge = @"enabled";
	NSString *pushAlert = @"enabled";
	NSString *pushSound = @"enabled";

	if(rntypes & UIRemoteNotificationTypeBadge) pushBadge = @"enabled";
    else pushBadge = @"disabled";
	if(rntypes & UIRemoteNotificationTypeAlert)pushAlert = @"enabled";
    else pushAlert = @"disabled";
	if(rntypes & UIRemoteNotificationTypeSound)pushSound = @"enabled";
    else pushSound = @"disabled";
    
     
 	
	UIDevice *dev = [UIDevice currentDevice];
    
    // Prepare the Device Token for Registration (remove spaces and < >)
    NSString *deviceToken = [[[[devToken description]
                               stringByReplacingOccurrencesOfString:@"<"withString:@""]
                              stringByReplacingOccurrencesOfString:@">" withString:@""]
                             stringByReplacingOccurrencesOfString: @" " withString: @""];

	NSString *deviceUuid = @"unknown";
    if ([dev respondsToSelector:@selector(identifierForVendor)]) deviceUuid = [[dev identifierForVendor] UUIDString];
    NSString *deviceName = dev.name;
	
	NSString *host = @"apns.librelio.com";
	
	NSString *urlString = [NSString stringWithFormat:@"/apns/apns.php?task=%@&appname=%@&appversion=%@&deviceuid=%@&devicetoken=%@&devicename=%@", @"register", appName,appVersion, deviceUuid, deviceToken, deviceName];
    NSLog(@"urlstring: %@",urlString);
	
	NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:host path:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [url release];
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
}

/**
 * Failed to Register for Remote Notifications
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	
	
	//SLog(@"Error in registration. Error: %@", error);
	
}

/**
 * Remote Notification Received while application was open.
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
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
	
}


@end
