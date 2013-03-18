//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.



/*
 * This class creates and manages "screens"(ScreenView class) and "pages"(PageView) class
 * A screen is a full screen view, which contains 1 or 2 or more pages (depending on orientation)
 * In order to avoid creating and destroying instances of ScreenView and PageView, which is not efficient,
 * all required instances are created at the beginning.
 * The number of required instances is:
 * number of ScreenView instances =  2xnumberOfScreensCached+1 
 */ 
 


#import "WAPaginatedView.h"
#import "WAUtilities.h"
#import "WAOperationsManager.h"
#import "WAScreenView.h"
#import "UIView+WAModuleView.h"
#import "WAModuleViewController.h"
#import "WABarButtonItemWithLink.h"
#import "NSString+WAURLString.h"



/** @brief A view containing WASreenViews
 * 
 * WAPaginatedView creates and manages "screens"(WAScreenView class) and "pages"(WAPaserViewProtocol)
 *
 **/
@implementation WAPaginatedView


@synthesize pdfDocument,thumbnailsView,scrollView,currentViewController,timer;

@synthesize pagesPerScreenInPortrait,pagesPerScreenInLandscape,numberOfScreensCached;



#pragma mark -
#pragma mark Lifecycle



- (NSString *) urlString
{
    return urlString;
}

- (void) setUrlString: (NSString *) theString
{
    if (urlString){
		//Do nothing
		
		
	}
	else {
		//Do once only
		urlString = [[NSString alloc]initWithString: theString];
        


		//Activity indicator
		UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		activityIndicator.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
		activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin);
		[activityIndicator startAnimating];
		[self addSubview:activityIndicator];
		[activityIndicator release];
		
		//Create pdfDocument instance
		pdfDocument = [[WAPDFParser alloc]init];
		pdfDocument.urlString = urlString;
		

		
        //Initial settings
        pagesPerScreenInPortrait = 1;
        
        //Check if a parameter was specified in the Url for pagesPerScreenInLandscape
        NSString * landscapePagesString = [urlString valueOfParameterInUrlStringforKey:@"wahpages"];
        if (landscapePagesString){
            pagesPerScreenInLandscape = [landscapePagesString intValue];
        }
        else{
            //Use defaults
            pagesPerScreenInLandscape = 2;//Default
            if ([pdfDocument countData] < 7) pagesPerScreenInLandscape = 1;//If there are less than 7 pages, it is better to center them
            //If the document is horizontal, pagesPerScreenInLandscape = 1
            CGRect rect = CGRectFromString([pdfDocument getDataAtRow:1 forDataCol:DataColRect]);
            if (rect.size.width>rect.size.height) pagesPerScreenInLandscape = 1;
            //if (![LibrelioUtilities isBigScreen]) pagesPerScreenInLandscape = 0;//On the iPhone, display full width

        }
        
        pdfDocument.intParam = pagesPerScreenInLandscape;//Needed in PDFParser to determine the size of big pages
        
        numberOfScreensCached = 2;

		self.backgroundColor = [UIColor whiteColor];
		
		
		// Create scrollview and add it to the view .
		scrollView = [[UIScrollView alloc] init];
		scrollView.frame = self.frame;
		scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
		[self addSubview:scrollView];
		
		//Initial settings
		currentScreen = 0;
		
		
		
		//Scroll view settings
		scrollView.bounces = YES;
		//self.backgroundColor = [UIColor blackColor];
		scrollView.backgroundColor = [UIColor clearColor];
		scrollView.pagingEnabled = YES;
		scrollView.showsHorizontalScrollIndicator = NO;
		scrollView.showsVerticalScrollIndicator = NO;
		scrollView.scrollsToTop = NO;
		scrollView.delegate = self;
		
		//Create thumbnails bar and add it to the view
		CGFloat tHeight = [UIScreen mainScreen].bounds.size.height*185/1024;
		thumbnailsView = [[WAThumbnailsView alloc]initWithFrame:self.frame style:UITableViewStylePlain];
		thumbnailsView.thumbImageViewDelegate = self;
		thumbnailsView.pdfDocument = pdfDocument;
		thumbnailsView.transform=CGAffineTransformMakeRotation(-M_PI/2);
		thumbnailsView.frame = CGRectMake(0,self.bounds.size.height-tHeight, self.bounds.size.width, tHeight);	
		thumbnailsView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin);
		thumbnailsView.hidden = YES;
		[self addSubview:thumbnailsView];
		
		//Show the bottom bar, and hide it after 5s
		[self showBottomBarDidAsk];
		timer = [[NSTimer scheduledTimerWithTimeInterval: 5 target:self selector:@selector(viewDidLoadSomeDelayAgo) userInfo:nil repeats:NO]retain];
		
		
		
		
		if (currentScreen == 0){
			//There is still no screen displayed, we need to display one with the appropriate settings
			//Create ScreenViews
			numberOfScreens = [self screenForPage:[pdfDocument countData]]+1;
			scrollView.contentSize = CGSizeMake(self.frame.size.width * numberOfScreens, self.frame.size.height);
			for (int i = 0;i<=2*numberOfScreensCached;i++) {
				WAScreenView * screenView = [[WAScreenView alloc]initWithFrame:self.frame andParser:pdfDocument];
				screenView.containingPdfView = self;
				screenView.frame= CGRectMake(self.frame.size.width * (numberOfScreens+numberOfScreensCached+1), 0,self.frame.size.width,self.frame.size.height);//Put the view outside so that they apprear to be available
				screenView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
				[scrollView addSubview:screenView];
                
                //Create PageViews 
                int maxViewsUsed = (int)MAX(pagesPerScreenInPortrait,pagesPerScreenInLandscape);
                [screenView initPages:maxViewsUsed];
                

				[screenView release];
			}
			//Go to screen
			//Check wether we had stored a page
			NSString *tempKey = [NSString stringWithFormat:@"%@-page",urlString];
			int newP = [[[NSUserDefaults standardUserDefaults] objectForKey:tempKey] intValue];
			if(!newP) newP=1;//This is the first time we open this doc
			//int newP=1;
			[self jumpToPage:newP animated:NO];
			
		}
		
		//Notify visible views
		[self notifyVisiblePageViews];
		
		
	}

	
	
}





- (void) viewDidLoadSomeDelayAgo {
	//Hide the bottom bar and navigation controller, unless bottom bar has been scrolled
	if (!self.thumbnailsView.contentOffset.y) [self removeBottomBarDidAsk];
}


- (void)willMoveToSuperview:(UIView *)newSuperview{
	if (!newSuperview){//In this case, the view is being removed from superview
		[timer invalidate];//This is important to avoid memory leaks
	}
	
}


- (void)dealloc {
    [pdfDocument cancelCacheOperations];
	[timer release];
	[pdfDocument release];
	[urlString release];
	[scrollView release];
	[thumbnailsView release];
    [super dealloc];
	
}





#pragma mark -
#pragma mark Page changing methods


- (void)jumpToPage:(int)page animated:(BOOL)animated {
	// update the scroll view to the appropriate page
	//Find the screen number corresponding to page
	int screen = [self screenForPage:page];
	CGPoint newOffset = CGPointMake(self.frame.size.width * screen, 0);
	[scrollView setContentOffset:newOffset animated:animated];
    int oldScreen =  currentScreen;
	currentScreen = screen;	
	[self showScreen:screen fromScreen:oldScreen];
}


- (void) showScreen:(int)newScreen fromScreen:(int)oldScreen {
    //SLog(@"Showing screen:%i from screen:%i",newScreen,oldScreen);
	//Store the current page number
	NSString *tempKey = [NSString stringWithFormat:@"%@-page",urlString];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[self pageForScreen:newScreen]] forKey:tempKey];
	//update the visible screen
	[[self  screenViewForScreen:oldScreen]setZoomScale:1.0];
	[[self  screenViewForScreen:oldScreen]setContentOffset:CGPointMake(0, 0)];
	 
	if ([self screenViewForScreen:newScreen]){
		//Do nothing
        
 	}
	else{
		//We need to find an unused screenView that we will resuse.
 		[self moveAndUpdateScreenView:[self firstAvailableScreenView ] toScreen:newScreen];
	}
	// update cached screens on either side of it (to avoid flashes when the user starts scrolling)
	for (int i = 1; i <=numberOfScreensCached; i++) 
	{
		if (![self screenViewForScreen:newScreen-i])[self moveAndUpdateScreenView:[self firstAvailableScreenView ] toScreen:newScreen-i];
		if (![self screenViewForScreen:newScreen+i])[self moveAndUpdateScreenView:[self firstAvailableScreenView ] toScreen:newScreen+i];
	}
    //Notify visible pages
	[self notifyVisiblePageViews];

}

- (void)moveAndUpdateScreenView:(WAScreenView*)screenView toScreen:(int)screen{
	screenView.firstPage = [self pageForScreen:screen];

	CGRect newFrame = CGRectMake(self.frame.size.width * screen, 0,self.frame.size.width,self.frame.size.height);
	screenView.frame = newFrame;
	
}







- (WAScreenView*) screenViewForScreen:(int)screen{
	NSArray * screenViewsArray = [scrollView subviews];
	for ( WAScreenView * screenView in screenViewsArray ){
		if (screenView.frame.origin.x == screen*self.frame.size.width) return screenView;
		
	}
	return nil;
	
}
- (WAScreenView*)firstAvailableScreenView{

	NSArray * screenViewsArray = [scrollView subviews];
    //SLog(@"ScreenViewsArray has %i subviews",[screenViewsArray count]);
	for ( WAScreenView * screenView in screenViewsArray ){
		//Check wether screenView is still usefull; it is not useful if it is more distant to currentScreen than cache requires
 		if (screenView.frame.origin.x > (currentScreen+numberOfScreensCached)*self.frame.size.width) return screenView;
		if (screenView.frame.origin.x < (currentScreen-numberOfScreensCached)*self.frame.size.width) return screenView;
		
			
	}
	return nil;
	
	
}



#pragma mark -
#pragma mark Former ScreenViewDelegate methods

- (void) notifyVisiblePageViews{
	//Check that curentViewController still exists; this might not be the case if deallocating is in progress
	if (currentViewController){
		//If this view controller is not the top in the navigation controller, send notification with empty array (meaning no visible page)
		if ((currentViewController.navigationController)&&!(currentViewController.navigationController.topViewController==currentViewController)){
			[[NSNotificationCenter defaultCenter] postNotificationName:@"didChangeVisiblePageViews" object:[NSArray array]]; 
		}
		//Otherwise, notify visible pages
		else{
            //SLog(@"Will get visibleScreenView %i",currentScreen);
			WAScreenView * visibleScreenView = [self screenViewForScreen:currentScreen];
			NSArray *pageViewsArray = [visibleScreenView getVisiblePageViews];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"didChangeVisiblePageViews" object:pageViewsArray]; 
		}
	}

	
}



- (void) turnPageRightDidAsk{
	/**[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:5.0];
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:scrollView cache:NO] ;**/

	if (currentScreen<numberOfScreens-1)[self jumpToPage:[self pageForScreen:currentScreen+1] animated:YES];
	
}

- (void) turnPageLeftDidAsk{
	if (currentScreen>0)[self jumpToPage:[self pageForScreen:currentScreen-1] animated:YES];
}

- (void) toggleBottomBarDidAsk{
	if (currentViewController.navigationController.navigationBarHidden) [self showBottomBarDidAsk];
	else [self removeBottomBarDidAsk];
		
}

- (void) showBottomBarDidAsk{
	//Show the navigation controller
	[currentViewController.navigationController setNavigationBarHidden:NO animated:YES];		
	//Show the thumbnails and update the selected page if there are at least 7 pages
	if ([pdfDocument countData]>6) {
		thumbnailsView.hidden = NO;
		[thumbnailsView deselectRowAtIndexPath:thumbnailsView.indexPathForSelectedRow animated:NO];
        
		NSIndexPath * ndxPath= [NSIndexPath indexPathForRow:[self pageForScreen:currentScreen]-1 inSection:0];
        if ((ndxPath.row>0)&&(ndxPath.row<[thumbnailsView numberOfRowsInSection:0]))
        {
            [thumbnailsView scrollToRowAtIndexPath:ndxPath atScrollPosition:UITableViewScrollPositionTop  animated:YES];

        }
	}
	//Restart the queue if it was stopped
	[[[WAOperationsManager sharedManager] defaultQueue]setSuspended:NO];

}

- (void) removeBottomBarDidAsk{
	BOOL userDidScroll = NO;//We need to detect if the user scrolled the thumbnailView after it has been displayed; in this case we do not hide it automatically
	
	if ((!userDidScroll)&&(currentViewController==currentViewController.navigationController.visibleViewController)){
		[currentViewController.navigationController setNavigationBarHidden:YES animated:YES];		
		thumbnailsView.hidden = YES;
		
	}

	
 	
}


- (void) resetFullScreenForPage:(int)page {
	[self showScreen:page fromScreen:currentScreen];
	
	
	
}
#pragma mark -
#pragma mark ScrollView delegate functions

- (void)scrollViewDidScroll:(UIScrollView *)sender {
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)sender {
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender {
	int screen = floor((scrollView.contentOffset.x - self.frame.size.width / 2) / self.frame.size.width) + 1;
    int oldScreen =  currentScreen;
	currentScreen = screen;	
	[self showScreen:screen fromScreen:oldScreen];

}


#pragma mark -
#pragma mark ThumbImageView delegate methods
- (void)thumbImageViewWasTappedAtPage:(int)pageTapped{
	currentViewController.navigationController.navigationBarHidden = YES;
	thumbnailsView.hidden=YES;	
	
	[self jumpToPage:pageTapped animated:YES];
	
}




	
#pragma mark -
#pragma mark Utility
- (int) screenForPage:(int)page{
	int pagesPerScreen;
	pagesPerScreen = (self.frame.size.width<self.frame.size.height)?pagesPerScreenInPortrait:pagesPerScreenInLandscape;
	if (pagesPerScreen ==0) pagesPerScreen=1;//Conventionally, pagesPerScreen = 0 for full width display
	int ret = (int) (page-1)/pagesPerScreen;//Screen numbers start at 0, pages start at 1
	if (pagesPerScreen==2) ret = (int) page/pagesPerScreen; //If there are 2 pages per screen we start at page 0;
	return ret;
	
}

	
- (int) pageForScreen:(int)screen{
	int pagesPerScreen;
	pagesPerScreen = (self.frame.size.width<self.frame.size.height)?pagesPerScreenInPortrait:pagesPerScreenInLandscape;
	if (pagesPerScreen ==0) pagesPerScreen=1;//Conventionally, pagesPerScreen = 0 for full width display
	int ret = (int) screen*pagesPerScreen+1;//Screen numbers start at 0, pages start at 1
	if (pagesPerScreen==2) ret = ret-1; //If there are 2 pages per screen we start at page 0;
	return ret;
	
}


#pragma mark -
#pragma mark ModuleView protocol

- (void)moduleViewWillAppear:(BOOL)animated{
    //Hide navbar if rootview
    if ([self isRootModule]){
        WAModuleViewController *vc = (WAModuleViewController *)[self firstAvailableUIViewController];
        vc.navigationController.navigationBar.barStyle = UIBarStyleBlack;//Using this style AND setting translucent property to YES prevents the navigationBar from "pushing" the view below, which is what we want here.
        vc.navigationController.navigationBar.translucent = YES;
        if (![timer isValid]){
            vc.navigationController.navigationBarHidden = YES;	
            thumbnailsView.hidden = YES;
        }
        
       //[vc addButtonWithBarButtonSystemItem:UIBarButtonSystemItemAdd andLink:[urlString urlByChangingSchemeOfUrlStringToScheme:@"share"]];
        
        //Check if the document has an outline; if yes, add the bar button
        if ([pdfDocument countSearchResultsForQueryDic:[NSDictionary dictionaryWithObjectsAndKeys:@"Outline",@"From", nil]]) 
            [vc addButtonWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks orImageNamed:@"" orString:@"" andLink:[urlString urlByChangingSchemeOfUrlStringToScheme:@"search"]];
       


    }

    
    
	//Notify visible pages
	[self notifyVisiblePageViews];
	
}
- (void) moduleViewDidAppear{
}


- (void) moduleViewWillDisappear:(BOOL)animated{
    //SLog(@"Module view will disappear");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"didChangeVisiblePageViews" object:[NSArray array]]; 	
}


	
- (void) moduleWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	//Reset the scale to 1
	[[self  screenViewForScreen:currentScreen]setZoomScale:1.0];
	//Update the currentPage
	currentPage = MAX(1,[self pageForScreen:currentScreen]);
	//SLog(@"Cur Page%i",currentPage);
	
}
- (void) moduleWillAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	//Update the number of screens (we don't need the same number of screens if we have 1 or 2 pages per screen
	numberOfScreens = [self screenForPage:[pdfDocument countData]]+1;
	//Update the scrollView contentSize
	scrollView.contentSize = CGSizeMake(self.frame.size.width * numberOfScreens, self.frame.size.height);
	//Move all views away in order to regenerate cache, except the view with the current page
	NSArray * screenViewsArray = [scrollView subviews];
	for ( WAScreenView * screenView in screenViewsArray ){
		//Check wether screenView's first page is equal to currentPage
		if (screenView.firstPage==currentPage) [self moveAndUpdateScreenView:screenView toScreen:[self screenForPage:currentPage]];//Move the view to its new location
		else screenView.frame = CGRectMake(self.frame.size.width * numberOfScreens+numberOfScreensCached+1, 0,self.frame.size.width,self.frame.size.height);//Move the view outside so that it is removed from cache
		
		
	}
	//SLog(@"Self:%f, Scroll:%f",self.frame.size.width,scrollView.frame.size.width);
	[self jumpToPage:currentPage animated:NO];
	
}


- (void) jumpToRow:(int)row{
    [self jumpToPage:row animated:YES];
}



@end
