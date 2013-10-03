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

@synthesize activityIndicator,splashView,currentViewController,backButton,previousPageTitle,currentPageTitle,forwardButton;

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
    //Prevent scrolling if module is not at the root level
    if (![self isRootModule]){
        for (UIView* subview in self.subviews)
            if ([[subview class] isSubclassOfClass: [UIScrollView class]]){
                //SLog(@"Scrollview found");
                [(UIScrollView *)subview setScrollEnabled:NO]; 
                
                /*CGPoint newOffset = CGPointMake(-50, 0);
                [(UIScrollView *)subview setContentOffset:newOffset animated:NO];*/

                //subview.backgroundColor = [UIColor whiteColor];
                //[(UIScrollView *)subview setAlwaysBounceHorizontal:NO];//This does not work
                
                /**for (UIView* subSubview in subview.subviews){
                    //SLog(@"subsubview found");
                    subSubview.layer.borderWidth = 0.0f;//Remove undesirable black border
                    subSubview.backgroundColor = [UIColor whiteColor];//Remove undesirable black border
                    
                    
                }**/

                
        }

    }
    
    
    urlString = [[NSString alloc]initWithString: theString];
	

	NSString * extension = [[urlString noArgsPartOfUrlString] pathExtension];
	
	
	if ([extension isEqualToString:@"tab"]){
		[self loadTabFile];
		
	}
	
	else if ([urlString hasPrefix:@"http"]||[urlString hasPrefix:@"www"]){
		NSString * completeUrlString = ([urlString hasPrefix:@"www"])?[NSString stringWithFormat:@"http://%@",urlString]:urlString;
        NSURL * url = [NSURL URLWithString:completeUrlString];
		NSURLRequest * request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
		[self loadRequest:request];
 		
	}
	else {
        if ([[NSBundle mainBundle] pathOfFileWithUrl:urlString]){
            NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathOfFileWithUrl:urlString]];
            NSString * waBase = [urlString valueOfParameterInUrlStringforKey:@"wabase"];
            if (waBase){
                NSData *htmldata = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathOfFileWithUrl:urlString]];
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
    splashView.backgroundColor = [UIColor blackColor];//This is the default
    NSString *bgColorString = [urlString valueOfParameterInUrlStringforKey:@"wabgcolor"];
    if (bgColorString) splashView.backgroundColor = [UIColor colorFromString:bgColorString];
    [self addSubview:splashView];
    splashView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin);
    
    
    activityIndicator.center =  CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
	[activityIndicator startAnimating];
	[self addSubview:activityIndicator];
	activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin);
    
    /**
    //UIToolbar *toolbar = [[UIToolbar alloc] init];
    UIView * toolbar = [[UIView alloc]init];
    toolbar.backgroundColor = [UIColor yellowColor];
    toolbar.frame = CGRectMake(0, self.frame.size.height-144, self.frame.size.width, self.frame.size.height);
    //NSMutableArray *items = [[NSMutableArray alloc] init];
    //[items addObject:[[[UIBarButtonItem alloc] initWith....] autorelease]];
    //[toolbar setItems:items animated:NO];
    //[items release];
    [self addSubview:toolbar];
    [toolbar release];
     **/
    
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
        
        NSLog(@"navTitle: %@, currentPage: %@",vc.navigationItem.title,self.currentPageTitle);
        if (![vc.navigationItem.title isEqualToString:self.currentPageTitle]){
            self.previousPageTitle= currentPageTitle;
            NSLog(@"Did set previous title to %@",self.previousPageTitle);
            
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
	//If wabase has been specified, we open all links outside the host of wabaseline in Safari
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
    [super dealloc];
}

- (void) loadTabFile{
	//Get the template html
	NSString * templatePath =[[NSBundle mainBundle] pathOfFileWithUrl:@"HTMLTemplate.html"];
	NSString * templateString = [NSString stringWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:nil];//Tab files are to be  with Windows default encoding
	NSURL *baseURL = [NSURL fileURLWithPath:templatePath];
	//SLog(@"Template:%@",templateString);
	
	//Get the data html
	NSString * filePath = [[NSBundle mainBundle] pathOfFileWithUrl:urlString];
	NSString * fileString = [NSString stringWithContentsOfFile:filePath encoding:NSWindowsCP1252StringEncoding error:nil];
	NSArray * lineArray = [fileString componentsSeparatedByString:@"\n"];
	int index = [[urlString valueOfParameterInUrlStringforKey:@"waline"]intValue];
	NSArray * colArray = [[lineArray objectAtIndex:index]componentsSeparatedByString:@"\t"] ; 
	NSArray * titleArray = [[lineArray objectAtIndex:0]componentsSeparatedByString:@"\t"];
	NSMutableString *dataHtmlString = [NSMutableString stringWithString: @""];
	for (int i = 0; i <[colArray count]; i++) {
		[dataHtmlString appendFormat:@"<div class=\"%@\" title=\"%@\">%@</div>",[titleArray objectAtIndex:i],[colArray objectAtIndex:i],[colArray objectAtIndex:i]];
	}
 
	
	//Get the CSS
	NSString * cssPath = [[NSBundle mainBundle] pathOfFileWithUrl:[WAUtilities urlByChangingExtensionOfUrlString:urlString toSuffix:@".css"]];
	NSString *cssString = @"";
	if (cssPath) cssString=[NSString stringWithContentsOfFile:cssPath encoding:NSUTF8StringEncoding error:nil];
	
	//Build the html string
	NSString * htmlString = [NSString stringWithFormat:templateString,cssString,dataHtmlString]; 
	[self loadHTMLString:htmlString baseURL:baseURL];
	
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
