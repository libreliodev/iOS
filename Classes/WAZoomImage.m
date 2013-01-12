//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WAZoomImage.h"
#import "WAUtilities.h"

#import "NSString+WAURLString.h"
#import "UIView+WAModuleView.h"
#import "NSBundle+WAAdditions.h"
#import "UIColor+WAAdditions.h"
#import "WAModuleViewController.h"

@implementation WAZoomImage

@synthesize imageScrollView;
@synthesize imageView;
@synthesize image;
@synthesize activity = _activity;

@synthesize currentViewController;

#pragma mark -
#pragma mark Lifecycle
- (void)dealloc {
    [data release];
    [connection release],
    [imageScrollView release];
    [imageView release];
    [image  release];
    
	[urlString release];
    [super dealloc];
}

- (NSString *) urlString
{
    return urlString;
}

- (void) setUrlString: (NSString *) theString
{
    // Prepare the backbround view
    self.backgroundColor = [UIColor blackColor];//Default
    NSString *bgColorString = [urlString valueOfParameterInUrlStringforKey:@"wabgcolor"];
    if (bgColorString) self.backgroundColor = [UIColor colorFromString:bgColorString];

    self.alpha = 1.0;
    self.hidden = NO;
    
    urlString = [[NSString alloc]initWithString: theString];
    
    NSString *stubImagePath = [urlString valueOfParameterInUrlStringforKey:@"walowres"];
    
    UIImage *lowResImage = [UIImage imageWithContentsOfFile:stubImagePath];
    
	// Prepare scrollview
    self.imageScrollView = [[[UIScrollView alloc] init] autorelease];
    self.imageScrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.imageScrollView.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin);
    [self addSubview:self.imageScrollView];
    self.imageScrollView.userInteractionEnabled = YES;
    self.imageScrollView.delegate = self;
    
    // Set up image view
    self.imageView = [[[UIImageView alloc] init] autorelease];
    self.imageView.frame = CGRectMake(0, 0, self.frame.size.width * 4, self.frame.size.height * 4);
    
    self.imageView.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin);
    [self.imageScrollView addSubview:self.imageView];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.userInteractionEnabled = YES;
    
    // Set up low-res image
    self.imageView.image = lowResImage;
    
    // Set up activity indicatory
    self.activity = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    self.activity.center = self.center;
    self.activity.hidesWhenStopped = YES;
    [self.activity startAnimating];
    
    [self addSubview:self.activity];
    
    // Set-up single tap recognizer
    UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)]autorelease];
    [self.imageView addGestureRecognizer:singleTap];
    
    // calculate minimum scale to perfectly fit image width, and begin at that scale
    float minimumScale = self.imageScrollView.frame.size.width  / self.imageView.frame.size.width;
    [self.imageScrollView setMinimumZoomScale:minimumScale];
    [self.imageScrollView setZoomScale:minimumScale];
    
    // Download hi-res image
    [self loadImageFromURLString:self.urlString];
}

////////////////////////////////////////////////////////////////////////////////


- (void)loadImageFromURLString:( NSString *)theUrlString
{
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:theUrlString]
                                             cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                         timeoutInterval:60.0];                          
    
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}


////////////////////////////////////////////////////////////////////////////////


- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData 
{    
    if (data == nil)
        data = [[NSMutableData alloc] initWithCapacity:2048];                 
    
    [data appendData:incrementalData];
}


////////////////////////////////////////////////////////////////////////////////


- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
    [self.activity stopAnimating];
    self.imageView.image = [UIImage imageWithData:data];
    
    [data release];
    data = nil;
    [connection release],
    connection = nil;
}


////////////////////////////////////////////////////////////////////////////////


- (void)connection:(NSURLConnection *)curConnection didFailWithError:(NSError *)error
{
    [data release];
    data = nil;
    [connection release],
    connection = nil;
    //SLog(@"Connection error: %@", error);
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"An internet connection is required for zooming"
                                                       delegate:self 
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}


////////////////////////////////////////////////////////////////////////////////


- (void)viewDidUnload {
	self.imageScrollView = nil;
	self.imageView = nil;
}


////////////////////////////////////////////////////////////////////////////////


#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}


////////////////////////////////////////////////////////////////////////////////


#pragma mark TapDetectingImageViewDelegate methods

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    [self.currentViewController dismissModalViewControllerAnimated:YES];
    //[self removeFromSuperview];
    
}


////////////////////////////////////////////////////////////////////////////////


#pragma mark Utility methods

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    zoomRect.size.height = self.imageScrollView.frame.size.height / scale;
    zoomRect.size.width  = self.imageScrollView.frame.size.width  / scale;
    
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}


////////////////////////////////////////////////////////////////////////////////


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


@end
