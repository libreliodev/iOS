//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WAThumbnailsView.h"
#import "WAParserProtocol.h"
#import "WAModuleProtocol.h"

@class WAScreenView;

@interface WAPaginatedView : UIView <UIScrollViewDelegate,
													ThumbImageViewDelegate,
													WAModuleProtocol> 
{
	NSObject <WAParserProtocol> *pdfDocument;
	NSString *urlString;
	WAThumbnailsView * thumbnailsView;
	UIScrollView *scrollView;
	int numberOfScreens, currentScreen,currentPage;
	
	
	UIViewController* currentViewController;
	
	NSTimer * timer;
    
    int pagesPerScreenInPortrait,pagesPerScreenInLandscape,numberOfScreensCached;


}


@property (nonatomic, retain) NSObject <WAParserProtocol> *pdfDocument;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) WAThumbnailsView * thumbnailsView;



@property (nonatomic, retain) NSTimer * timer;

@property int pagesPerScreenInPortrait,pagesPerScreenInLandscape,numberOfScreensCached;


- (void) viewDidLoadSomeDelayAgo;

- (void) showScreen:(int)newScreen fromScreen:(int)oldScreen;
- (void)moveAndUpdateScreenView:(WAScreenView*)screenView toScreen:(int)screen;
- (WAScreenView*) screenViewForScreen:(int)screen;
- (WAScreenView*)firstAvailableScreenView; 

- (int) screenForPage:(int)page;
- (int) pageForScreen:(int)screen;

- (void) notifyVisiblePageViews;
- (void)jumpToPage:(int)page animated:(BOOL)animated;
- (void) toggleBottomBarDidAsk;
- (void) showBottomBarDidAsk;
- (void) removeBottomBarDidAsk;
- (void) turnPageRightDidAsk;
- (void) turnPageLeftDidAsk;






@end

