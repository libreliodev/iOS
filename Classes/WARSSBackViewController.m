//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WARSSBackViewController.h"
#import "WARSSParser.h"
#import "WAUtilities.h"


@implementation WARSSBackViewController

@synthesize rssTableViewController; 
@synthesize URLString;
@synthesize feedData;
@synthesize activityIndicator;

-(void) viewDidLoad{
	
	self.view.backgroundColor = [UIColor colorWithRed:0.168 green:0.168 blue:0.168 alpha:1.0];
	activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	
	[activityIndicator startAnimating];
	[self.view addSubview:activityIndicator];
	activityIndicator.center = self.view.center;
	activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin);
	
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
	[[NSURLConnection alloc] initWithRequest:urlRequest  delegate:self  startImmediately:YES];

}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void) viewWillAppear:(BOOL)animated{
	self.navigationController.navigationBarHidden = NO;	
	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;//Using this style prevents  AND seeting translucent property to NO the navigationBar from covering the upper part of the view.
	self.navigationController.navigationBar.translucent = NO;
	self.navigationController.navigationBar.tintColor = [UIColor blackColor];
	
}
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[rssTableViewController release];
	[URLString release];
	[activityIndicator release];
	[feedData release];
    [super dealloc];


}

#pragma mark -
#pragma mark NSURLConnection delegate methods


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.feedData = [NSMutableData data];    // start off with new data
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [feedData appendData:data];  // append incoming data
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[activityIndicator stopAnimating];
	[activityIndicator removeFromSuperview];
    
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
														message:errorMessage
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
    [alertView show];
    [alertView release];

    [connection release];   // release our connection
}



@end
