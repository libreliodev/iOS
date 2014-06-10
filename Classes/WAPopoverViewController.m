//
//  WAPopoverViewController.m
//  Librelio
//
//  Created by Volodymyr Obrizan on 11.02.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import "WAPopoverViewController.h"

@implementation WAPopoverViewController

@synthesize scrollView          = _scrollView;
@synthesize imageView           = _imageView;
@synthesize activityIndicator   = _activityIndicator;


////////////////////////////////////////////////////////////////////////////////


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        connection = nil;
        data = nil;
    }
    return self;
}


////////////////////////////////////////////////////////////////////////////////


-(void)dealloc
{
    if (connection)
    {
        [connection cancel];
        connection = nil;
    }
    
    if (data)
    {
        [data release];
        data = nil;
    }
    
    [super dealloc];
}


////////////////////////////////////////////////////////////////////////////////


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


////////////////////////////////////////////////////////////////////////////////


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


////////////////////////////////////////////////////////////////////////////////


- (void)viewDidUnload
{
    self.imageView = nil;
    self.scrollView = nil;
    self.activityIndicator = nil;

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


////////////////////////////////////////////////////////////////////////////////


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


////////////////////////////////////////////////////////////////////////////////


#pragma mark - Image manipulation


-(NSString *)lowResImgFileName
{
    return nil;
}


////////////////////////////////////////////////////////////////////////////////


-(void)setLowResImgFileName:(NSString *)value
{
    if (value)
    {
		// Set image
        UIImage *image = [UIImage imageWithContentsOfFile:value];
        self.imageView.image = image;
		
		// 
        //CGFloat widthToHeightRatio = 1.0 * image.size.width / image.size.height;
        CGRect imageViewRect = self.imageView.bounds;
        //imageViewRect.size.width = imageViewRect.size.height * widthToHeightRatio;
		imageViewRect.size.width = 2 * image.size.width;
		imageViewRect.size.height = 2 * image.size.height;
        self.imageView.frame = imageViewRect;
        self.scrollView.contentSize = imageViewRect.size;
    }
}


////////////////////////////////////////////////////////////////////////////////


-(NSString *)highResImgURL
{
    return nil;
}


////////////////////////////////////////////////////////////////////////////////


-(void)setHighResImgURL:(NSString *)value
{
    if (value)
    {
        // Begin the image download
        NSURL *url = [NSURL URLWithString:value];
        NSURLRequest *request = [NSURLRequest requestWithURL:url
                                                 cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                             timeoutInterval:60.0];
        
        if (!connection)
        {
            connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [self.activityIndicator startAnimating];
        }
    }
}


////////////////////////////////////////////////////////////////////////////////


#pragma mark - NSUrlConnection delegate

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData 
{    
    if (data == nil)
        data = [[NSMutableData alloc] initWithCapacity:2048];                 
    
    [data appendData:incrementalData];
}


////////////////////////////////////////////////////////////////////////////////


- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
    [self.activityIndicator stopAnimating];
    UIImage *image = [UIImage imageWithData:data];
    self.imageView.image = image;

    // Set-up proper resolution of image view
//    CGFloat widthToHeightRatio = 1.0 * image.size.width / image.size.height;
//    CGRect imageViewRect = self.imageView.bounds;
//    imageViewRect.size.width = imageViewRect.size.height * widthToHeightRatio;
//    self.imageView.frame = imageViewRect;
//    self.scrollView.contentSize = imageViewRect.size;

    [data release];
    data = nil;
    [connection release];
    connection = nil;
}


////////////////////////////////////////////////////////////////////////////////


- (void)connection:(NSURLConnection *)curConnection didFailWithError:(NSError *)error
{
    [self.activityIndicator stopAnimating];
    
    if (data)
    {
        [data release];
        data = nil;
    }
    [connection release],
    connection = nil;
    //SLog(@"Connection error: %@", error);
}


////////////////////////////////////////////////////////////////////////////////


- (void)connection:(NSURLConnection *)_connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
	
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
	
    // receivedData is an instance variable declared elsewhere.
    [data setLength:0];
	
	// Check if we have errors on this stage
	if ([response respondsToSelector:@selector(statusCode)])
    {
        int statusCode = (int)[((NSHTTPURLResponse *)response)statusCode];
        
        if (statusCode >= 400)
        {
            // Some error occured during download
            [_connection cancel];
            
            NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:NSLocalizedString(@"Server returned status code %d",@""), statusCode] forKey:NSLocalizedDescriptionKey];
            NSError *statusError = [NSError errorWithDomain:@"NSHTTPPropertyStatusCodeKey" code:statusCode userInfo:errorInfo];
            
            [self connection:_connection didFailWithError:statusError];
        }
        
        // Checking content type. It must be an image
        NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
        NSString *contentType = [headers objectForKey:@"Content-Type"];
        NSRange range = [contentType rangeOfString:@"image" options:NSCaseInsensitiveSearch];
        
        if (range.location == NSNotFound)
        {
            // It is not an image
            [_connection cancel];
            
            NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:@"The server returned not an image" forKey:NSLocalizedDescriptionKey];
            NSError *statusError = [NSError errorWithDomain:@"NotAnImage" code:0 userInfo:errorInfo];
            
            [self connection:_connection didFailWithError:statusError];
        }
    }
}


////////////////////////////////////////////////////////////////////////////////

@end
