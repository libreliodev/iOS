//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WAHTMLView.h"
#import "WAUtilities.h"
#import "WAModuleViewController.h"
#import "UIView+WAModuleView.m"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+WAAdditions.m"
#import "NSString+WAURLString.h"
#import "GAI.h"





@implementation WAHTMLView

@synthesize activityIndicator,splashView,currentViewController,backButton,previousPageTitle,currentPageTitle,forwardButton,parser;

- (id)init {
	if (self = [super init]) {
		self.scalesPageToFit = YES;
		self.dataDetectorTypes = UIDataDetectorTypeAll;
		self.delegate = self;
		activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
		if ([self respondsToSelector:@selector(setMediaPlaybackRequiresUserAction:)]) {
            self.mediaPlaybackRequiresUserAction = NO;//Allow autoplay;
        }

		
	}
	return self;
}


- (NSString *) urlString
{
    return urlString;
}

- (void) setUrlString: (NSString *) theString
{
    UIColor * bgColor = [UIColor whiteColor];//This is the default background
    NSString *bgColorString = [urlString valueOfParameterInUrlStringforKey:@"wabgcolor"];
    if (bgColorString) bgColor = [UIColor colorFromString:bgColorString];

    if (![self isRootModule]){
        //Prevent scrolling if module is not at the root level
       for (UIView* subview in self.subviews){
            if ([[subview class] isSubclassOfClass: [UIScrollView class]]){
                //SLog(@"Scrollview found");
                [(UIScrollView *)subview setScrollEnabled:NO];
            }
        }
        self.opaque = NO;//This prevents black borders being shown
        self.backgroundColor = bgColor;



    }
    
    
    urlString = [[NSString alloc]initWithString: theString];
	
    NSString * className = [urlString classNameOfParserOfUrlString];
    Class theClass = NSClassFromString(className);
    parser =  (NSObject <WAParserProtocol> *)[[theClass alloc] init];
    
    //Get the url for the root module
    NSString * rootModuleUrl = [self urlStringOfRootModule];
    //SLog(@"rootModuelUrl =%@ for url:%@",rootModuleUrl,urlString);
    
    parser.urlString = [urlString urlByAddingParameterInUrlStringWithKey:@"waroot" withValue:rootModuleUrl];
    
    //Check if parser returns an html string
    NSString * htmlString = [parser getDataAtRow:0 forDataCol:DataColHTML];
    NSString * urlToLoad = [parser getDataAtRow:0 forDataCol:DataColDetailLink];
    if (htmlString){
        NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathOfFileWithUrl:urlToLoad]];
        //SLog(@"Will load baseurl:%@ with html:%@",baseURL,htmlString);
        [self loadHTMLString:htmlString baseURL:baseURL];
        
    }

	
	else if ([urlToLoad hasPrefix:@"http"]||[urlToLoad hasPrefix:@"www"]){
		NSString * completeUrlString = ([urlToLoad hasPrefix:@"www"])?[NSString stringWithFormat:@"http://%@",urlToLoad]:urlToLoad;
        NSURL * url = [NSURL URLWithString:completeUrlString];
		NSURLRequest * request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
		[self loadRequest:request];
 		
	}
	else {
        if ([[NSBundle mainBundle] pathOfFileWithUrl:urlToLoad]){
            NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathOfFileWithUrl:urlToLoad]];
            NSString * waBase = [urlString valueOfParameterInUrlStringforKey:@"wabase"];
            if (waBase){
                NSData *htmldata = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathOfFileWithUrl:urlToLoad]];
                baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@",waBase]];
                //SLog(@"base:%@",[baseURL absoluteString]);
                [self loadData:htmldata MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:baseURL];

                
            }
            else{
                [self loadRequest:[NSURLRequest requestWithURL:baseURL]];
            }
        }
        
        //Tracking
        NSString * viewString = [urlString gaScreenForModuleWithName:@"Browser" withPage:nil];
        
        [[[GAI sharedInstance] defaultTracker]sendView:viewString];

	}
	
    
	splashView = [[UIImageView alloc]init];
    splashView.frame = CGRectMake (0,0,self.frame.size.width,self.frame.size.height);
    splashView.backgroundColor = bgColor;//This is the default
    [self addSubview:splashView];
    splashView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin);
    
    
    activityIndicator.center =  CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
	[activityIndicator startAnimating];
	[self addSubview:activityIndicator];
	activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin);
     
    self.previousPageTitle = [[NSString alloc]initWithString: @""];
    self.currentPageTitle = [[NSString alloc]initWithString: @""];

	
	
}


#pragma mark UIWebViewDelegate methods

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self stringByEvaluatingJavaScriptFromString:@"window.alert=null;"];//Prevent alerts from being shown
    [self stringByEvaluatingJavaScriptFromString:@"window.confirm=function(txt){return 1};"]; //Prevent confirms from being shown and returns default answer
    
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[splashView removeFromSuperview];
    [activityIndicator stopAnimating];
	[activityIndicator removeFromSuperview];
    

    if ([self isRootModule]){
        

        WAModuleViewController * vc = (WAModuleViewController * )[(UIView <WAModuleProtocol>*)self currentViewController];
        vc.navigationItem.title =[self stringByEvaluatingJavaScriptFromString:@"document.title"];
        
        //SLog(@"navTitle: %@, currentPage: %@",vc.navigationItem.title,self.currentPageTitle);
        if (![vc.navigationItem.title isEqualToString:self.currentPageTitle]){
            self.previousPageTitle= currentPageTitle;
            //SLog(@"Did set previous title to %@",self.previousPageTitle);
            
            self.currentPageTitle = vc.navigationItem.title;
        }

        
        //Reset toolbar
        [vc.rightToolBar setItems:nil];
        if ([self canGoBack]){
            NSMutableArray* buttons = [[NSMutableArray alloc] initWithArray:vc.rightToolBar.items];
            NSString * backString = [NSString stringWithFormat:@"< %@...",[self.previousPageTitle substringToIndex:5]];
            UIBarButtonItem * bi = [[WABarButtonItemWithLink alloc]initWithTitle:backString style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
            [buttons addObject:bi];
            [bi release];
            [vc.rightToolBar setItems:buttons animated:NO];
            [buttons release];
            vc.rightToolBar.frame = CGRectMake(vc.rightToolBar.frame.origin.x, vc.rightToolBar.frame.origin.y, 80, vc.navigationController.navigationBar.frame.size.height+0.01);
            

            
        }
 

        
        
    }

	
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSURL* tempUrl= [request URL];
    //SLog(@"shouldStartLoadWithRequest:%@",tempUrl);
	//If wabase has been specified, we open all links outside the host of wabase in Safari
	NSString * waBase = [urlString valueOfParameterInUrlStringforKey:@"wabase"];
	if (waBase){
		//We only filter clicked links
		if (navigationType==UIWebViewNavigationTypeLinkClicked) {
				NSString * waBaseHost = [[NSURL URLWithString:waBase] host];
			if ([tempUrl host] &&![[tempUrl host] isEqualToString:waBaseHost])
			{
				[[UIApplication sharedApplication] openURL:tempUrl];
				return NO;
			}
			
		}
	}
    
    //If html view is inside another module view, open all links in full screen view
    if (![self isRootModule]){
        if (navigationType==UIWebViewNavigationTypeLinkClicked) {
            WAModuleViewController * curModuleViewController = (WAModuleViewController *) [self traverseResponderChainForUIViewController];
            WAModuleViewController * moduleViewController = [[WAModuleViewController alloc]init];
            moduleViewController.moduleUrlString= [tempUrl absoluteString];
            moduleViewController.initialViewController= curModuleViewController;
            moduleViewController.containingView= curModuleViewController.containingView;
            moduleViewController.containingRect= curModuleViewController.containingRect;
            [moduleViewController pushViewControllerIfNeededAndLoadModuleView];
            [moduleViewController release];
            return NO;

        }
        
    }

   
	
	//If scheme is mailto or tel, open in appropriate app
	if ([tempUrl.scheme isEqualToString:@"mailto"]||[tempUrl.scheme isEqualToString:@"tel"]){
		[[UIApplication sharedApplication] openURL:tempUrl];
		return NO;
	
	}
	
    //If the link is for a module other than webview, open the module
    if ([[tempUrl absoluteString] typeOfLinkOfUrlString]!=LinkTypeHTML){
        if (navigationType==UIWebViewNavigationTypeLinkClicked) {
            WAModuleViewController * curModuleViewController = (WAModuleViewController *) [self currentViewController];
            WAModuleViewController * moduleViewController = [[WAModuleViewController alloc]init];
            moduleViewController.moduleUrlString= [tempUrl absoluteString];
            moduleViewController.initialViewController= curModuleViewController;
            moduleViewController.containingView= self.superview;
            moduleViewController.containingRect= CGRectMake(0,0,self.superview.frame.size.width,self.superview.frame.size.height/2);
            [moduleViewController pushViewControllerIfNeededAndLoadModuleView];
            [moduleViewController release];
            return NO;

        }
        
    }

	return YES;
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error {
}


- (void)dealloc {
	[activityIndicator release];
    [splashView release];
    [backButton release];
    [previousPageTitle release];
    [currentPageTitle release];
    [forwardButton release];
	[urlString release];
    [parser release];
    [super dealloc];
}



#pragma mark -
#pragma mark ModuleView protocol

- (void)moduleViewWillAppear:(BOOL)animated{
    if ([self isRootModule]){
        //The following code which would be recommended cannot be used because the delegate is not WAModuleViewControler but self
        /*WAModuleViewController *vc = (WAModuleViewController *)[self firstAvailableUIViewController];
        [vc addButtonWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace orImageNamed:@"back.png" orString:@"" andLink:[urlString urlByChangingSchemeOfUrlStringToScheme:@"search"]];*/
        
        //Add back button
        WAModuleViewController * vc = (WAModuleViewController * )[(UIView <WAModuleProtocol>*)self currentViewController];
        NSMutableArray* buttons = [[NSMutableArray alloc] initWithArray:vc.rightToolBar.items];
        UIImage* backImage = [UIImage imageNamed:@"back.png"];
        backButton = [[WABarButtonItemWithLink alloc]initWithImage:backImage style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
        backButton.enabled = NO;
            
        [buttons addObject:backButton];
        UIImage* forwardImage = [UIImage imageNamed:@"forward.png"];
        forwardButton = [[WABarButtonItemWithLink alloc]initWithImage:forwardImage style:UIBarButtonItemStyleBordered target:self action:@selector(goForward)];
        forwardButton.enabled = NO;
        
        [buttons addObject:forwardButton];

        
        // create a spacer
        UIBarButtonItem * bi = [[WABarButtonItemWithLink alloc]
              initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        [buttons addObject:bi];
        [bi release];
          [vc.rightToolBar setItems:buttons animated:NO];
        [buttons release];
 
        
        
    }

  
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
