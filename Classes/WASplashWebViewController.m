//
//  WebViewBasedViewController.m
//  AdvertisingScreen
//
//  Created by playrhyba on 10.12.11.
//  Copyright (c) 2011 WodgetAvenue. All rights reserved.
//

#import "WASplashWebViewController.h"
#import "WASplashScreenViewController.h"
#import "WAAppDelegate.h"

@implementation WASplashWebViewController

@synthesize webView;
@synthesize toolbar;
@synthesize doneButton;
@synthesize safariButton;
@synthesize parent;
@synthesize rootViewController;

- (void)dealloc
{
    [webView release];
    [toolbar release];
    [doneButton release];
    [safariButton release];
    [parent release]; 
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Actions

- (IBAction)doneButtonClicked:(id)sender
{
    //dismiss the webview and the ad
    
    [self.parent dismissModalViewControllerAnimated:NO];
    [rootViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)safariButtonClicked:(id)sender
{
    //open open the link in Safari
    
    [[UIApplication sharedApplication] openURL:webView.request.URL];}

@end
