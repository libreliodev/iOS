//
//  SplashScreenViewController.m
//  AdvertisingScreen
//
//  Created by admin on 09.12.11.
//  Copyright (c) 2011 Librelio. All rights reserved.
//

#import "WASplashScreenViewController.h"
#import "WASplashWebViewController.h"

#import "NSBundle+WAAdditions.h"
#import "NSString+WAURLString.h"

#import "WASplashFileDownloader.h"

#import "WAUtilities.h"

#import "GAI.h"


@implementation WASplashScreenViewController

@synthesize timer;
@synthesize imageView, rootViewController;
@synthesize resultData;
@synthesize adLinkUrlString;
@synthesize preferredLanguage;
@synthesize urlString;
@synthesize currentConnection;




////////////////////////////////////////////////////////////////////////////////


- (void)dealloc
{
    [imageView release];
    [currentConnection release];
    [timer release];
    [resultData release];
    [adLinkUrlString release];
    [preferredLanguage release];
    [urlString release];
    
    

    [super dealloc];
}


////////////////////////////////////////////////////////////////////////////////


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) requestAd{
    NSString * adLink;
    
    //Check if there are several languages in the app; in this case, load ad in preferred language
     NSDictionary * app_Dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathOfFileWithUrl:@"Application_.plist"]];
    NSString * language;
    if ([app_Dic objectForKey:@"Languages"]){
        NSString * preferredPlist = [[NSUserDefaults standardUserDefaults] objectForKey:@"PreferredLanguagePlist"];
        if (preferredPlist){
            //Find the language corresponding to the prefered plist; the language name is after the last "_"
            NSString * plistFileName = [preferredPlist nameOfFileWithoutExtensionOfUrlString];
            NSArray *parts = [plistFileName componentsSeparatedByString:@"_"];
            language = [parts objectAtIndex:[parts count]-1];
            
        }
        else  language = [[NSLocale preferredLanguages] objectAtIndex:0];//If language has not been chosen by user yet, choose the default language
        preferredLanguage = [[NSString alloc]initWithFormat:@"_%@",language];
        
    }
    else{
        preferredLanguage = @"";
    }
    
    
    
        
    // Check device
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            NSString * nameOfAd = [NSString stringWithFormat:@"%@%@%@",@"/AAD/Ad",preferredLanguage,@"~iphone.png"];
            if ([WAUtilities isScreenHigherThan500]) nameOfAd = [NSString stringWithFormat:@"%@%@%@",@"/AAD/Ad",preferredLanguage,@"~iphone5.png"];//iPhone 5
 			adLink = [WAUtilities completeDownloadUrlforUrlString:nameOfAd];
        }
        else
        {
            // iPad
            
            NSString * nameOfAd = [NSString stringWithFormat:@"/AAD/Ad%@-%@~ipad.png",preferredLanguage,[self currentOrientation]];
 			adLink = [WAUtilities completeDownloadUrlforUrlString:nameOfAd];
         }
    //SLog(@"AdLink:%@",adLink);

    // Load the ad screen asynchronously
    self.resultData = [NSMutableData dataWithCapacity:0];
     
    if (currentConnection){
        [currentConnection cancel];
        [currentConnection release];
    }
	
	// Create a request with a 10 seconds time-out
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:adLink] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    currentConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    urlString = [[NSString alloc]initWithString:adLink];
    


}

////////////////////////////////////////////////////////////////////////////////


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


////////////////////////////////////////////////////////////////////////////////

- (void) viewWillAppear:(BOOL)animated{
    //SLog(@"View will appear");
    if (! self.imageView.image){
        [self showDefault];
        [self requestAd];
        

    }
}

    

////////////////////////////////////////////////////////////////////////////////


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.imageView = nil;
    [timer invalidate];//This is important to avoid memory leaks
}


////////////////////////////////////////////////////////////////////////////////


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //SLog(@"Should rotate splash screen");

    return YES;
}

///////////////////////////////////////////////////////////////////////////////

- (void) didRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	//SLog(@"Did rotate splash screen");
    [self showDefault];
    [self requestAd];


}



////////////////////////////////////////////////////////////////////////////////

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
	//SLog(@"Point tapped: %f, %f", point.x, point.y);
	
    if (point.y < self.view.bounds.size.height*1/8 )//Tapped at the top
    {
        [timer invalidate];
        [self dismissAd];
    }
	else {
        WASplashWebViewController *webViewController;
        
        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            webViewController = [[[WASplashWebViewController alloc]initWithNibName:@"WASplashWebViewController_iPhone" bundle:nil]autorelease];
        }
        else
        {
            webViewController = [[[WASplashWebViewController alloc]initWithNibName:@"WASplashWebViewController_iPad" bundle:nil]autorelease];
        }
        
        if (adLinkUrlString)
        {
            //Invalidate timer
            [timer invalidate];
            
            
            // Show view controller with webview
            [webViewController loadView];
            [webViewController.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:adLinkUrlString]]];
            webViewController.parent = self;
            webViewController.rootViewController = rootViewController;
            webViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            
            [self presentModalViewController:webViewController animated:YES];
        }
        
    }
}



////////////////////////////////////////////////////////////////////////////////


- (void)dismissAd
{
    //SLog(@"Should dismiss now");
    [rootViewController dismissModalViewControllerAnimated:YES];
}


////////////////////////////////////////////////////////////////////////////////

- (void) showDefault{
    // Check device
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        if ([WAUtilities isScreenHigherThan500]){
            // iPhone5
            self.imageView.image = [UIImage imageNamed:@"Default-568h@2x.png"];
        }
        else{
            // iPhone
            self.imageView.image = [UIImage imageNamed:@"Default.png"];
            
        }
         
    }
    else
    {
        // iPad
        
        NSString *defaultPng = [NSString stringWithFormat:@"%@%@.png", @"Default-",[self currentOrientation]];
        //SLog(@"defaultPNG:%@",defaultPng);
        self.imageView.image = [UIImage imageNamed:defaultPng];
    }
    
    
}



- (NSString *)currentOrientation
{
    switch([self interfaceOrientation])
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            return @"Portrait";
        default:
            return @"Landscape";
    }
}




////////////////////////////////////////////////////////////////////////////////



#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.resultData setLength:0];
    
    if ([response respondsToSelector:@selector(statusCode)])
    {
        int statusCode = [((NSHTTPURLResponse *)response)statusCode];
        
        if (statusCode >= 400)
        {
            // Some error occured during download
            [connection cancel];
            
            NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:NSLocalizedString(@"Server returned status code %d",@""), statusCode] forKey:NSLocalizedDescriptionKey];
            NSError *statusError = [NSError errorWithDomain:@"NSHTTPPropertyStatusCodeKey" code:statusCode userInfo:errorInfo];
            
            [self connection:connection didFailWithError:statusError];
        }
        else{
            // Checking content type. It must be an image
            NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
            NSString *contentType = [headers objectForKey:@"Content-Type"];
            NSRange range = [contentType rangeOfString:@"image" options:NSCaseInsensitiveSearch];
            
            if (range.location == NSNotFound)
            {
                // It is not an image
                [connection cancel];
                
                NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:@"The server returned not an image for the splash screeen" forKey:NSLocalizedDescriptionKey];
                NSError *statusError = [NSError errorWithDomain:@"NotAnImage" code:0 userInfo:errorInfo];
                
                [self connection:connection didFailWithError:statusError];
            }

            
        }
        
     }
}


////////////////////////////////////////////////////////////////////////////////


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.resultData appendData:data];
}


////////////////////////////////////////////////////////////////////////////////

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // Download failed
    //SLog(@"Error: %@", [error localizedDescription]);
    
    // Dismiss the Default image
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissAd];
    
    // Release the resources
    self.resultData = nil;
}


////////////////////////////////////////////////////////////////////////////////


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Download succeeded
    // Display the ad
    //SLog(@"Did finish loading");
    self.imageView.image = [UIImage imageWithData:self.resultData];
    
    // Release the resources
    self.resultData = nil;
    
    if(![rootViewController.modalViewController isEqual:self]) [rootViewController presentModalViewController:self animated:YES];//This happens when the app did become active after being in the background
    
    //Tracking
    NSString * pageString = [urlString gaScreenForModuleWithName:@"Interstitial" withPage:nil];
    
    [[[GAI sharedInstance] defaultTracker]sendView:pageString];

    
    // Load plist file with a link to a web-page
    NSString * nameOfPlist = [NSString stringWithFormat:@"%@%@%@",@"/AAD/Ad",preferredLanguage,@".plist"];

    NSString *plistFileLink = [WAUtilities completeDownloadUrlforUrlString:nameOfPlist];
	
	// The WAFileDownloader object will be retained by its NSURLConnection and released upon completion
	[[[WASplashFileDownloader alloc]
	  initWithURL:[NSURL URLWithString:plistFileLink]
	  timeout:5.0
	  success:^(NSData *data)
	  {
		  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		  NSString *cachePath = [paths objectAtIndex:0];
		  BOOL isDir = NO;
		  NSError *error;
		  if (! [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir] && isDir == NO) {
			  [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:&error];
		  }
		  
		  cachePath = [cachePath stringByAppendingString:@"link.plist"];
		  
		  [data writeToFile:cachePath atomically:YES];
		  
		  NSDictionary *adLinkDic = [NSDictionary dictionaryWithContentsOfFile:cachePath];
		  
		  // Start timer
		  timer = [[NSTimer scheduledTimerWithTimeInterval: 5 target:self selector:@selector(dismissAd) userInfo:nil repeats:NO]retain];
		  
		  if ((!adLinkDic)||(![adLinkDic objectForKey:@"Link"]))
		  {
			  // Unable to download or parse plist file
			  //SLog(@"Can't load .plist file");
			  self.adLinkUrlString = nil;
		  }
		  else
		  {
			  self.adLinkUrlString = [NSString stringWithString:[adLinkDic objectForKey:@"Link"]];
		  }
	  }
	  failure:^(NSError *error)
	  {
		  self.adLinkUrlString = nil;
	  }] autorelease];
}


////////////////////////////////////////////////////////////////////////////////


@end
