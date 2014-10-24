//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "WAPDFParser.h"
#import "WAPDFParserView.h"
#import "WAPaginatedView.h"

@class PDFTiledView;


@interface WAScreenView : UIScrollView <UIScrollViewDelegate,UIGestureRecognizerDelegate> {
	WAPaginatedView * containingPdfView;
	int firstPage;
    CGRect screenRect;
	UIView * containerView;//Needed for zoom to work smoothly
    NSObject <WAParserProtocol> *pdfDocument;
}

@property (nonatomic, assign) WAPaginatedView * containingPdfView;
@property (nonatomic, assign) NSObject <WAParserProtocol> *pdfDocument;

@property (nonatomic, retain) UIView * containerView;

@property int firstPage;



- (id)initWithFrame:(CGRect)frame andParser:(NSObject <WAParserProtocol> *)pdfDoc;
- (void) initPages:(int)numberOfPages;
- (void) updatePages;
- (void) layoutFullWidthPage;
- (void) layoutSinglePage;
- (void) layoutDoublePage;
- (NSArray*)getVisiblePageViews;
- (void) performLinkAction:(id)sender;
- (void) openModule:(NSString*)urlString inView:(WAPDFParserView*)pageView inRect:(CGRect)rect;
- (void) openAnimation:(NSString*)urlString inView:(WAPDFParserView*)pageView inRect:(CGRect)rect;
- (void) openText:(NSString*)urlString inView:(WAPDFParserView*)pageView inRect:(CGRect)rect withOption:(BOOL)playFullScreen;
- (void) openMusic:(NSString*)urlString inView:(WAPDFParserView*)pageView;


@end
