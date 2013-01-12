//
//  WADetailsViewController.m
//  Librelio
//
//  Created by svp on 07.02.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import "WADetailsViewController.h"
#import "WAPageContainerController.h"
#import "WAShareView.h"
#import "WAPopoverViewController.h"
#import "WAModuleViewController.h"
#import "NSBundle+WAAdditions.h"
#import "NSString+WAURLString.h"


@implementation WADetailsViewController

@synthesize containerController = _containerController;
@synthesize segmentedControl    = _segmentedControl;
@synthesize webView             = _webView;
@synthesize shareButton         = _shareButton;
@synthesize shareView           = _shareView;
@synthesize favorisButton       = _favorisButton;
@synthesize datasource          = _datasource;
@synthesize currentIndex        = _currentIndex;
@synthesize popoverViewController   = _popoverViewController;
@synthesize showSharePopover    = _showSharePopover;
@synthesize urlString			= _urlString;
@synthesize topLogo				= _topLogo;
@synthesize pageTitle			= _pageTitle;
@synthesize contents            = _contents;


////////////////////////////////////////////////////////////////////////////////

#pragma mark - Instance lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Custom initialization
        self.popoverViewController = [[[WAPopoverViewController alloc] initWithNibName:@"WAPopoverView" bundle:nil] autorelease];
    }
    return self;
}


////////////////////////////////////////////////////////////////////////////////


-(void)dealloc
{
    self.popoverViewController = nil;
	self.datasource = nil;
	self.urlString = nil;
	self.contents = nil;
           
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self reloadData];
	
	// The logo is visible in portrait orientation only
	switch ([[UIApplication sharedApplication] statusBarOrientation]) 
	{
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
			self.topLogo.hidden = NO;
			self.pageTitle.hidden = YES;
			break;
		default:
			self.topLogo.hidden = YES;
			self.pageTitle.hidden = NO;
			break;
	}
}


////////////////////////////////////////////////////////////////////////////////


-(void)reloadData
{
	// Get current datasource
    NSDictionary *currentDatasource = [self.datasource objectAtIndex:self.currentIndex];
	
	// Load the HTML template
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"details".device ofType:@"html"];
    NSString *htmlText = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];    
    
	NSString *contentsPath = [[NSBundle mainBundle] pathForResource:@"contents" ofType:@"plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:contentsPath];
	NSArray *contents = [dic objectForKey:@"root"];
	NSString *valueTag = @"%value%";

    for(NSDictionary *data in contents)
    {
		// If there is no field titled 'Column' just skip
		NSString *column = [data objectForKey:@"Column"];
		if (!column)
			continue;

		// If there is no tag, then reuse the %Column% as the tag
		NSString *tag = [data objectForKey:@"Tag"];
		if (!tag)
			tag = [NSString stringWithFormat:@"%%%@%%", column];
		
		// If template is not present, put here default template
		NSString *template = [data objectForKey:@"Template"];
		if (!template)
			template = valueTag;
		
		// Get column value
		NSString *value = [currentDatasource objectForKey:column];
		
        // Special case to get absolute path for a low-res image
        if ([column isEqualToString:@"imgLR"])
        {
            // Image processing
            NSString *relativePathToLowResImage = [currentDatasource objectForKey:column];
            NSString *pathToLowResImage = [WAUtilities absoluteUrlOfRelativeUrl:relativePathToLowResImage relativeToUrl:self.urlString];
            pathToLowResImage = [[NSBundle mainBundle] pathOfFileWithUrl:pathToLowResImage];
            if (pathToLowResImage)
                value = pathToLowResImage;
        }
		
		// Check if the value is actually present
		if (value && [value isKindOfClass:NSString.class] && value.length)
			template = [template stringByReplacingOccurrencesOfString:valueTag withString:value];
		else
			// Remove the template if the value is not present
			template = @"";

		// Substitue template with the associated tag
        htmlText = [htmlText stringByReplacingOccurrencesOfString:tag withString:template];
    }
         
    // Load the processed HTML file
    NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
    [self.webView loadHTMLString:htmlText baseURL:bundleURL];
    
    // Change Favorites button states
    NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];      
    if(![[userDefaults objectForKey:@"FavorisObjects"] containsObject:[currentDatasource objectForKey:@"id_modele"]])
        self.favorisButton.selected = NO; 
    else
        self.favorisButton.selected = YES;         
}


////////////////////////////////////////////////////////////////////////////////


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.segmentedControl = nil;
    self.webView = nil;
    self.shareButton = nil;
    self.favorisButton = nil;
    self.shareView  = nil;
}


////////////////////////////////////////////////////////////////////////////////


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}


////////////////////////////////////////////////////////////////////////////////


- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	// The logo is visible in portrait orientation only
	switch (toInterfaceOrientation) 
	{
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
			self.topLogo.hidden = NO;
			self.pageTitle.hidden = YES;
			break;
		default:
			self.topLogo.hidden = YES;
			self.pageTitle.hidden = NO;
			break;
	}
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark - User actions


-(IBAction)backButtonClicked:(id)sender
{
    if (self.containerController)
        [self.containerController popViewController];      
}


////////////////////////////////////////////////////////////////////////////////


-(IBAction)didSelectSegment:(id)sender
{
    NSInteger index = self.segmentedControl.selectedSegmentIndex;
    switch (index) 
    {
        case 0:
            self.currentIndex = self.currentIndex == 0 ? self.datasource.count - 1 : self.currentIndex - 1;
            break;
        case 1:
            self.currentIndex = self.currentIndex == self.datasource.count - 1 ? 0 : self.currentIndex + 1;
        default:
            break;
    }
    [self reloadData];
}


////////////////////////////////////////////////////////////////////////////////


-(IBAction)favorisButtonClicked:(id)sender
{
    NSDictionary *currentDatasource = [self.datasource objectAtIndex:self.currentIndex];
    NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];    
    
    if([userDefaults objectForKey:@"FavorisObjects"])
    {
        NSMutableArray *favorisObjects = [NSMutableArray arrayWithArray:[userDefaults objectForKey:@"FavorisObjects"]];
        
        if (![favorisObjects containsObject:[currentDatasource objectForKey:@"id_modele"]])
        {            
            [favorisObjects addObject: [currentDatasource objectForKey:@"id_modele"]]; 
            [userDefaults setObject:favorisObjects forKey:@"FavorisObjects"];
            // Change button state
            self.favorisButton.selected = YES;
            return;
        }
    }
    else
    {
        NSMutableArray *favorisObjects = [NSMutableArray array];
        [favorisObjects addObject:[currentDatasource objectForKey:@"id_modele"]];
        [userDefaults setObject:favorisObjects forKey:@"FavorisObjects"];
        // Change button state
        self.favorisButton.selected = YES;
        return;
    }

    //Check state of the favorisButton
    if (self.favorisButton.selected)
    {
        NSMutableArray *favorisObjects = [NSMutableArray arrayWithArray:[userDefaults objectForKey:@"FavorisObjects"]];
        [favorisObjects removeObject:[currentDatasource objectForKey:@"id_modele"]];
        [userDefaults setObject:favorisObjects forKey:@"FavorisObjects"];
        // Change button state
        self.favorisButton.selected = NO;
    }
    
    //SLog(@"Favoris: %@",[userDefaults objectForKey:@"FavorisObjects"]);    
}


////////////////////////////////////////////////////////////////////////////////


-(IBAction)partagerButtonClicked:(id)sender
{
	NSString *url = [[self.datasource objectAtIndex:self.currentIndex] objectForKey:@"Lien_Partage"];  
	//CGRect rect = CGRectMake(self.shareButton.frame.origin.x-265,  self.shareButton.frame.origin.y+32, 335.0, 216.0); 
    CGRect rect = self.shareButton.frame; 
    [self openModule:url inView:self.view inRect:rect];
}


//////////////////////////////////////////////////////////////////////////////// 


- (void) openModule:(NSString*)urlString inView:(UIView *)pageView inRect:(CGRect)rect
{
    WAModuleViewController *moduleViewController = [[WAModuleViewController alloc] init];
    moduleViewController.moduleUrlString = urlString;
    moduleViewController.initialViewController = self;
    moduleViewController.containingView = pageView;
    moduleViewController.containingRect = rect;
    //self.shareView = moduleViewController.moduleView;
    [moduleViewController pushViewControllerIfNeededAndLoadModuleView];
    [moduleViewController release];
}


////////////////////////////////////////////////////////////////////////////////


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self reloadData];
}


////////////////////////////////////////////////////////////////////////////////


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    if ([url.scheme isEqualToString:@"zoom"]) 
    {
        // For touchstart and touchmove events we have two parameters: x,top
        // x - position of finger
        // top - top coordinate of the image (to calculate proper position of the popover view)
        NSArray *params = [url.query componentsSeparatedByString:@","];
        
        CGFloat x		= 0.0;
		CGFloat y		= 0.0;
        CGFloat top		= 0.0;
		CGFloat height	= 0.0;
		CGFloat right	= 0.0;
		CGFloat width	= 0.0;
        
        if (params && params.count > 1)
        {
            x		= [[params objectAtIndex:0] floatValue];
			y		= [[params objectAtIndex:1] floatValue];
            top		= [[params objectAtIndex:2] floatValue];
			height	= [[params objectAtIndex:3] floatValue];
			right	= [[params objectAtIndex:4] floatValue];
			width	= [[params objectAtIndex:5] floatValue];
			
			// Normalize coordinages
			x = x - right;
			if (x < 0)
				x = 0;
			if (x > width)
				x = width;
			
			y = y - top;
			if (y < 0)
				y = 0;
			if (y > height)
				y = height;
        }
        
        // UIWebView.scrollView is available only in iOS 5.0
        UIScrollView *scrollView = nil;
        if ([self.webView respondsToSelector:@selector(scrollView)])
            scrollView = webView.scrollView;
        else
            scrollView = [webView.subviews objectAtIndex:0];
        
        if ([url.host isEqualToString:@"touchstart"])
        {
            // Disable scrolling because we don't want to scroll while viewing zoomed picture
            scrollView.scrollEnabled = NO;
            
            // Find out touch location and image position and height
            [self showPopoverAtLocation:(top + height) animated:YES];
            [self scrollPopoverTo:CGPointMake (x / width, y / height)];
        }
        if ([url.host isEqualToString:@"touchmove"])
        {
            // Just scroll the image to the proper location under finger
            [self scrollPopoverTo:CGPointMake (x / width, y / height)];
        }
        if ([url.host isEqualToString:@"touchend"])
        {
            // Hide the popover
            scrollView.scrollEnabled = YES;
            [self hidePopoverAnimated:YES];
        }
        
        return NO;
    }
    return YES;
}


////////////////////////////////////////////////////////////////////////////////


#pragma mark - Popover control

-(void)showPopoverAtLocation:(CGFloat)top animated:(BOOL)animated
{
    CGRect rect = self.popoverViewController.view.bounds;
    rect.size.width = self.webView.bounds.size.width;
    rect.origin.x = 0;
    UIScrollView *scrollView = nil;
    
    // UIWebView.scrollView is available in iOS 5.0 only
    if ([self.webView respondsToSelector:@selector(scrollView)])
        scrollView = self.webView.scrollView;
    else
        scrollView = [self.webView.subviews objectAtIndex:0];
    rect.origin.y = top - scrollView.contentOffset.y;
    
    self.popoverViewController.view.frame = rect;
    self.popoverViewController.view.alpha = 0.0;
    
    NSDictionary *currentDatasource = [self.datasource objectAtIndex:self.currentIndex];
    
    NSString *relativePathToLowResImage = [currentDatasource objectForKey:@"imgLR"];
    NSString *pathToLowResImage = [WAUtilities absoluteUrlOfRelativeUrl:relativePathToLowResImage relativeToUrl:self.urlString];
    pathToLowResImage = [[NSBundle mainBundle] pathOfFileWithUrl:pathToLowResImage];
    self.popoverViewController.lowResImgFileName = pathToLowResImage;
    self.popoverViewController.highResImgURL = [currentDatasource objectForKey:@"imgHR"];
    
    [self.webView addSubview:self.popoverViewController.view];
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        self.popoverViewController.view.alpha = 1.0;
    }];
}


////////////////////////////////////////////////////////////////////////////////


-(void)hidePopoverAnimated:(BOOL)animated
{
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        self.popoverViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.popoverViewController.view removeFromSuperview];
    }];
}


////////////////////////////////////////////////////////////////////////////////


-(void)scrollPopoverTo:(CGPoint)location
{
    CGRect rect = self.popoverViewController.imageView.bounds;
	
    rect.origin.x = rect.size.width * location.x - self.popoverViewController.scrollView.bounds.size.width / 2.0;
    rect.size.width = self.popoverViewController.scrollView.bounds.size.width;
	rect.origin.y = rect.size.height * location.y - self.popoverViewController.scrollView.bounds.size.height / 2.0;
	rect.size.height = self.popoverViewController.scrollView.bounds.size.height;
	
    [self.popoverViewController.scrollView scrollRectToVisible:rect animated:NO];
}


////////////////////////////////////////////////////////////////////////////////

@end
