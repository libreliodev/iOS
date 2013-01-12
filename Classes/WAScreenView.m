//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WARSSBackViewController.h"
#import "WASlideShowView.h"
#import "WAModuleViewController.h"
#import "WAMapView.h"
#import "WATextView.h"
#import "WAButtonWithLink.h"
#import "WAUtilities.h"
#import "WAOperationsManager.h"
#import "UIView+WAModuleView.h"
#import "UIColor+WAAdditions.h"
#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.h"



#import "WAScreenView.h"
#import <QuartzCore/QuartzCore.h>

#define kMaxZoom  4
#define kMinZoom  1

/** @brief A view containing one or more pages, matching screen size
 *
 *	 
 **/
@implementation WAScreenView

@synthesize containingPdfView,pdfDocument,containerView;


- (id)initWithFrame:(CGRect)frame andParser:(NSObject <WAParserProtocol> *)pdfDoc;
{
    if ((self = [super initWithFrame:frame])) {
		pdfDocument = pdfDoc;
        
		//Create the container view (needed for zooming properly)
        containerView = [[UIView alloc]initWithFrame:frame];
        containerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
        [self addSubview:containerView];
		
		// Set up the UIScrollView
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
		[self setBackgroundColor:[UIColor blackColor]];
		self.maximumZoomScale = kMaxZoom;
		self.minimumZoomScale = kMinZoom;
		
        
        
		
		
		
		//Create tap recognizers and add them to the view.
		UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
		doubleTapGestureRecognizer.numberOfTapsRequired = 2;
		doubleTapGestureRecognizer.delegate = self;
		[self addGestureRecognizer:doubleTapGestureRecognizer];
		
		UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
		singleTapGestureRecognizer.numberOfTapsRequired = 1;
		[singleTapGestureRecognizer requireGestureRecognizerToFail: doubleTapGestureRecognizer];
		singleTapGestureRecognizer.delegate = self;
		[self addGestureRecognizer:singleTapGestureRecognizer];
		
		[doubleTapGestureRecognizer release];
		[singleTapGestureRecognizer release];
        
        
        
		
		
		
		
		
	}
	return self;
}


- (void) initPages:(int)numberOfPages{
    //Create and add the pageView subviews
    for (int i = 0;i<numberOfPages;i++) {
        WAPDFParserView * pageView = [[WAPDFParserView alloc]initWithFrame:self.frame];
        pageView.pdfDocument = pdfDocument;
        pageView.backgroundColor = [UIColor blackColor];
        pageView.tag= i+1;
        [containerView addSubview:pageView];
        [pageView release];
        
    }
    
    
}

- (void) setFirstPage:(int)page{
	firstPage = page;
	//Reset zoom: 
	[self setZoomScale:1.0 animated:NO];
    
	[self updatePages];
    
	
	
}

- (int) firstPage{
	return firstPage;
}


- (void) updatePages{
	//Right now, we only support a maximum of 2 pages, but we might support more in the future
	int visiblePages = (self.frame.size.width<self.frame.size.height)?self.containingPdfView.pagesPerScreenInPortrait:self.containingPdfView.pagesPerScreenInLandscape;
	if (visiblePages==0){
		[self layoutFullWidthPage];
	}
	else if (visiblePages==1){
		[self layoutSinglePage];
	}
	else {
		[self layoutDoublePage];
		
	}
    
}

- (void) layoutFullWidthPage{
	WAPDFParserView * pv1 = (WAPDFParserView *) [self viewWithTag:1];
	WAPDFParserView * pv2 = (WAPDFParserView *) [self viewWithTag:2];
	CGRect rect,fRect;
	CGFloat scale=1;
	//Update the page displayed by PageView
	pv1.page = firstPage;
	//Calculate the scale needed
	rect= CGRectFromString([pdfDocument getDataAtRow:firstPage forDataCol:DataColRect]);
    if (rect.size.width>0) scale = self.frame.size.width/rect.size.width;
	fRect = CGRectMake(0, 0, scale*rect.size.width, scale*rect.size.height);
	pv1.frame= fRect;
	self.contentSize = CGSizeMake(self.frame.size.width,scale*rect.size.height);
	containerView.frame = CGRectMake(0, 0, self.frame.size.width,scale*rect.size.height);//This is needed otherwise zoom does not work properly
	//[pv1 addTiledViewAtZoomScale:1];
	
	pv2.hidden = YES;
	
}


- (void) layoutSinglePage{
	containerView.frame = CGRectMake (0,0,self.frame.size.width,self.frame.size.height);//This is needed because full width page sets a different frame for containerView
	WAPDFParserView * pv1 = (WAPDFParserView *) [self viewWithTag:1];
	WAPDFParserView * pv2 = (WAPDFParserView *) [self viewWithTag:2];
	CGRect rect,fRect;
	CGFloat hScale,vScale;
	CGFloat scale =1;
	//Update the page displayed by PageView
	pv1.page = firstPage;
	//Calculate the scale needed
	rect= CGRectFromString([pdfDocument getDataAtRow:firstPage forDataCol:DataColRect]);;
	if ((rect.size.width>0)&&(rect.size.height>0)){
		hScale = self.frame.size.width/rect.size.width;
		vScale = self.frame.size.height/rect.size.height;
		scale = MIN(hScale, vScale);
        
	}
	fRect = CGRectMake(self.frame.size.width/2-scale*rect.size.width/2, self.frame.size.height/2-scale*rect.size.height/2, scale*rect.size.width, scale*rect.size.height);
	pv1.frame= fRect;
	pv2.hidden = YES;
}
- (void) layoutDoublePage{
	containerView.frame = CGRectMake (0,0,self.frame.size.width,self.frame.size.height);//This is needed because full width page sets a different frame for containerView
	WAPDFParserView * pv1 = (WAPDFParserView *) [self viewWithTag:1];
	WAPDFParserView * pv2 = (WAPDFParserView *) [self viewWithTag:2];
	CGRect rect,fRect;
	CGFloat hScale,vScale;
	CGFloat scale = 1;
	//Update the pages displayed by PageView
	pv1.page = firstPage;
	pv2.page = firstPage+1;
	//Calculate the scale needed for page 1
	rect= CGRectFromString([pdfDocument getDataAtRow:firstPage forDataCol:DataColRect]);;
	if ((rect.size.width>0)&&(rect.size.height>0)){
		hScale = self.frame.size.width*0.5f/rect.size.width;//The screen is divided by 2
		vScale = self.frame.size.height/rect.size.height;
		scale = MIN(hScale, vScale);
	}
	fRect = CGRectMake(self.frame.size.width/2-scale*rect.size.width, self.frame.size.height/2-scale*rect.size.height/2, scale*rect.size.width, scale*rect.size.height);
	pv1.frame= fRect;
	
	//Now for page 2
	pv2.hidden = NO;
	rect= CGRectFromString([pdfDocument getDataAtRow:firstPage+1 forDataCol:DataColRect]);;
	if ((rect.size.width>0)&&(rect.size.height>0)){
		hScale = self.frame.size.width*0.5f/rect.size.width;//The screen is divided by 2
		vScale = self.frame.size.height/rect.size.height;
		scale = MIN(hScale, vScale);
        
	}
	fRect = CGRectMake(self.frame.size.width/2, self.frame.size.height/2-scale*rect.size.height/2, scale*rect.size.width, scale*rect.size.height);
	pv2.backgroundColor = [UIColor blackColor];
	pv2.frame= fRect;
	
	
}






- (NSArray*)getVisiblePageViews{
	NSArray * ret;
	WAPDFParserView * pv1 = (WAPDFParserView *) [self viewWithTag:1];
	WAPDFParserView * pv2 = (WAPDFParserView *) [self viewWithTag:2];
	int visiblePages = (self.frame.size.width<self.frame.size.height)?self.containingPdfView.pagesPerScreenInPortrait:self.containingPdfView.pagesPerScreenInLandscape;
	if (visiblePages==1){
		ret = [NSArray arrayWithObjects:pv1,nil];
        //SLog(@"Visible array:%i",pv1.page);
	}
	else {
		ret = [NSArray arrayWithObjects:pv1,pv2,nil];
        //SLog(@"Visible array:%i %i",pv1.page,pv2.page);
	}
	return ret;
	
    
}



- (void)dealloc
{
	[containerView release];
    [super dealloc];
}



#pragma mark -
#pragma mark UIScrollView delegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    
	return containerView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    
	
	if (scale>1) {
		WAPDFParserView * pv1 = (WAPDFParserView *) [self viewWithTag:1];
		WAPDFParserView * pv2 = (WAPDFParserView *) [self viewWithTag:2];
		[pv1 addTiledView];
		[pv2 addTiledView];
	}
	//SLog(@"Self contentSize after:%f,%f",self.contentSize.width,self.contentSize.height);
	//SLog(@"Container View Size after:%f,%f",containerView.frame.size.width,containerView.frame.size.height);
	
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView 
{
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
	//SLog(@"Self contentSize:%f,%f",self.contentSize.width,self.contentSize.height);
	//SLog(@"Container View Size:%f,%f",containerView.frame.size.width,containerView.frame.size.height);
	[[[WAOperationsManager sharedManager] defaultQueue] setSuspended:YES];//Zooming is expensive for memory
	
    
}

#pragma mark -
#pragma mark GestureRecognizer delegate
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
	CGPoint point = [recognizer locationInView:self];
	//SLog(@"Point tapped: %f, %f", point.x, point.y);
	
    if (point.x < self.bounds.size.width/8 )[[self containingPdfView] turnPageLeftDidAsk];//Tapped at the left
	else if (point.x > self.bounds.size.width*7/8 )[[self containingPdfView] turnPageRightDidAsk];//Tapped at the right
	//else if (point.y > self.bounds.size.height*7/8 )[[self screenViewDelegate] showBottomBarDidAsk];//Tapped at the bottom
	//else if (point.y < self.bounds.size.height*1/8 )[[self screenViewDelegate] showBottomBarDidAsk];//Tapped at the top
	else [[self containingPdfView] toggleBottomBarDidAsk];
    
}




- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer {
	CGPoint point = [recognizer locationInView:self];
	CGPoint center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
	
	
	if (self.zoomScale !=1) [self setZoomScale:1 animated:YES];
	else{
		[self setZoomScale:1.999 animated:YES];//Avoid using x2 scale, as it will use x4 tiles
		CGFloat xOffset = MIN(MAX(0,2*point.x-center.x),2*center.x);//Center x axis on point tapped
		CGFloat yOffset = MIN(MAX(0,2*point.y-center.y),2*center.y);//Center y axis on point tapped
		[self setContentOffset:CGPointMake(xOffset, yOffset) animated:NO];
	}
	
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([[touch.view class] isSubclassOfClass:[UIButton class]]) return NO;//Disable gesture recognizer when button was clicked
    else if ([[touch.view class] conformsToProtocol:@protocol(WAModuleProtocol)]) return NO;//Disable gesture recognizer when module was clicked
    return YES;
}



#pragma mark -
#pragma mark Annotation actions
//TODO: finish refactoring with LoadingViewController

- (void) performLinkAction:(id)sender{
	WAButtonWithLink *button = (WAButtonWithLink *)sender;
	NSString * annotURLString =button.link;
	NSString * absoluteUrlString = [WAUtilities absoluteUrlOfRelativeUrl:annotURLString relativeToUrl:containingPdfView.urlString];
	NSURL * url = [NSURL URLWithString:annotURLString];
	CGRect rect = button.frame;
	if ([url.scheme isEqualToString:@"goto"]){
		int newPage = [url.host intValue];
		
		[self.containingPdfView jumpToPage:newPage animated:YES];
	}
	else {
		//NSString *filename2 = [[annotURLString noArgsPartOfUrlString] lastPathComponent];
		WAPDFParserView*pv = (WAPDFParserView*)button.superview;
		
		NSString * rectString = [annotURLString valueOfParameterInUrlStringforKey:@"warect"];
		BOOL playFullScreen = NO;//By default, elements are played in button rect except web links
		if ([rectString isEqualToString:@"full"]) playFullScreen=YES;
		
        
		
		
		NSString *filePath = [[NSBundle mainBundle] pathOfFileWithUrl:absoluteUrlString];
		//test the kind of file we need to open
		NSString * extension = [[annotURLString noArgsPartOfUrlString] pathExtension];
		
		//Some modules are still not integrated in the generic ModuleViewController
        if ([extension isEqualToString:@"mp3"]||[extension isEqualToString:@"mp3"]) [self openMusic:filePath inView:pv];
		else if ([extension isEqualToString:@"gif"]) [self openAnimation:absoluteUrlString inView:pv inRect:rect];
		else if ([extension isEqualToString:@"txt"]) [self openText:filePath inView:pv inRect:rect withOption:NO];
		else [self openModule:absoluteUrlString inView:pv inRect:rect]; 
		
	}
    
	
	
}

- (void) openModule:(NSString*)urlString inView:(WAPDFParserView*)pageView inRect:(CGRect)rect{
	WAModuleViewController * moduleViewController = [[WAModuleViewController alloc]init];
	moduleViewController.moduleUrlString= urlString;
	moduleViewController.initialViewController= containingPdfView.currentViewController;
	moduleViewController.containingView= pageView;
	moduleViewController.containingRect= rect;
	[moduleViewController pushViewControllerIfNeededAndLoadModuleView];
	[moduleViewController release];
	
    
    
    
}
- (void) openAnimation:(NSString*)urlString inView:(WAPDFParserView*)pageView inRect:(CGRect)rect {
	UIImageView * imView = [[UIImageView alloc]init];
	imView.frame = rect;
	imView.backgroundColor = [UIColor greenColor];
	[pageView addSubview:imView];
	imView.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin);
	imView.image = [UIImage imageNamed:@"white.gif"];
	imView.contentMode = UIViewContentModeScaleToFill;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:5];
	imView.frame = CGRectMake(rect.origin.x+rect.size.width, rect.origin.y, 0, rect.size.height);
	[UIView commitAnimations];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:3.0];
    CALayer *layer = self.layer;
    layer.transform = CATransform3DIdentity;
    [UIView commitAnimations];

    
	[imView release];
	
    
}

- (void) openRSS:(NSString*)urlString inView:(WAPDFParserView*)pageView inRect:(CGRect)rect withOption:(BOOL)playFullScreen{
	/*RSSBackViewController*Rss = [[RSSBackViewController alloc] init];
     Rss.URLString = urlString;
     [self.navigController pushViewController:Rss animated:YES];
     self.navigController.navigationBarHidden = NO;		
     [Rss release];*/
	
}

- (void) openText:(NSString*)urlString inView:(WAPDFParserView*)pageView inRect:(CGRect)rect withOption:(BOOL)playFullScreen{
	if (playFullScreen){
		/*MapViewController * mapViewController = [[MapViewController alloc]init];
         mapViewController.URLString = urlString;
         [self.navigController pushViewController:mapViewController animated:YES];
         [mapViewController release];*/
		
	}
	else {
		WATextView * textView = [[WATextView alloc]init];
		textView.frame = rect;
		[pageView addSubview:textView];
		textView.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin);
		textView.urlString = urlString;
		//textView.text = @"test";
		[textView release];
		
	}
	
}

- (void) openMap:(NSString*)urlString inView:(WAPDFParserView*)pageView inRect:(CGRect)rect withOption:(BOOL)playFullScreen{
	WAModuleViewController * loadingViewController = [[WAModuleViewController alloc]init];
	loadingViewController.moduleUrlString= urlString;
	loadingViewController.initialViewController= containingPdfView.currentViewController;
	loadingViewController.containingView= pageView;
	loadingViewController.containingRect= rect;
	[loadingViewController pushViewControllerIfNeededAndLoadModuleView];
	[loadingViewController release];
	
}

- (void) openMusic:(NSString*)urlString inView:(WAPDFParserView*)pageView {
	//If another music is playing on the page (which might be this one), do not interrupt or replace it
	if (!pageView.audioPlayer) {
		NSURL *url = [NSURL fileURLWithPath:urlString];
		
		NSError *error;
		pageView.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
		pageView.audioPlayer.numberOfLoops = 1;
		
		if (pageView.audioPlayer == nil){
			//SLog(@"%@",[error description]);
        }
		else
			[pageView.audioPlayer play];
		
		
	}
	
	
}

- (void) openPdf:(NSString*)urlString inView:(WAPDFParserView*)pageView inRect:(CGRect)rect withOption:(BOOL)playFullScreen{
	WAModuleViewController * loadingViewController = [[WAModuleViewController alloc]init];
	loadingViewController.moduleUrlString= urlString;
	loadingViewController.initialViewController= containingPdfView.currentViewController;
	loadingViewController.containingView= pageView;
	loadingViewController.containingRect= rect;
	[loadingViewController pushViewControllerIfNeededAndLoadModuleView];
	[loadingViewController release];
	
}


@end
