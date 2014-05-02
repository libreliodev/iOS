//
//  FixedViewController.h
//  CoreTest
//
//  Created by SkyTree on 11. 10. 19..
//  Copyright (c) 2011 Skytree Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FixedViewController, Book, Parallel;

/**
 FixedPageInfomation class contains information about a specific page of fixed layout epub.
*/
@interface FixedPageInformation :NSObject{
    /** the page index */
    NSInteger pageIndex;
    /** the number of pages for this book */
    NSInteger numberOfPages;
    /** pagePosition as double (0.0f is the start point and 1.0f is the end point of book) */
    double pagePosition;
    /** the cached file path for this page. */
    NSString *cachedImagePath;
}

@property NSInteger pageIndex;
@property NSInteger numberOfPages;
@property double pagePosition;
@property (nonatomic,retain) NSString* cachedImagePath;

@end

@protocol FixedViewControllerDataSource <NSObject>
@optional
@end


/** the FixedViewControllerDelegate object */
@protocol FixedViewControllerDelegate <NSObject>
@optional
/** called when single tap is detected @param position CGPoint object at tap position */
-(void)fixedViewController:(FixedViewController*)fvc didDetectTapAtPositionInView:(CGPoint)positionInView positionInPage:(CGPoint)positionInPage;
/** called when double tap is detected @param position CGPoint object at double tap position */
-(void)fixedViewController:(FixedViewController*)fvc didDetectDoubleTapAtPositionInView:(CGPoint)positionInView positionInPage:(CGPoint)positionInPage;
/** called when page is moved to or chapter is loaded at first time. @param pageInformation PageInformation object of current page. */
-(void)fixedViewController:(FixedViewController*)fvc pageMoved:(FixedPageInformation*)fixedPageInformation;
/** called when caching process for pages is started. @param index int the start index where caching process is started */
-(void)fixedViewController:(FixedViewController*)fvc cachingStarted:(int)index;
/** called when caching process for pages is finished @param index int the start index where caching process is finished **/
-(void)fixedViewController:(FixedViewController*)fvc cachingFinished:(int)index;
/** called when caching for one page is over. @param index the page index which is cached now. @param path the path of cached file. */
-(void)fixedViewController:(FixedViewController*)fvc cached:(int)index path:(NSString*)path;

/** called when playing one parallel started */
-(void)fixedViewController:(FixedViewController*)fvc parallelDidStart:(Parallel*)parallel;
/** called when playing one parallel finished */
-(void)fixedViewController:(FixedViewController*)fvc parallelDidEnd:(Parallel*)parallel;
/** called when playing all parallels finished */
-(void)parallesDidEnd:(FixedViewController*)fvc;
@end

/** the FixedViewController Object */
@interface FixedViewController : UIViewController {
    /** the page transition type. 0:none, 1:slide, 2:curl */
    int transitionType;
    /** the unique code for this book. */
    int bookCode;
    /** the Book object which contains information about epub. */
    Book* book;
    /** FixedViewControllerDelegate to handle events from FixedViewController. */
    id <FixedViewControllerDelegate>   delegate;
    /** FixedViewControllerDataSource to respond to the request from FixedViewController. */
    id <FixedViewControllerDataSource> dataSource;
    /** current engine version. */
    NSString* version;
    /** the base directory for custom content files of epub */
    NSString* baseDirectory;
    /** the class for custom reader for epub. */
    id contentProviderClass;
}

@property (nonatomic,retain) NSString *encryptKey; 
@property int transitionType;
@property int bookCode;
@property (nonatomic,retain) Book* book;
@property (nonatomic,retain) id <FixedViewControllerDelegate>      delegate;
@property (nonatomic,retain) id <FixedViewControllerDataSource>    dataSource;
@property (nonatomic,retain) NSString* version;
@property (nonatomic,retain) NSString* baseDirectory;

-(id)initWithStartPageIndex:(int)startPageIndex;
/** gets FixedPageInformation at the global position in book. @param pagePositionInBook is a double between 0 to 1 to indicate the position in entile book. */
-(FixedPageInformation*)getFixedPageInformationAtPagePosition:(double)pagePosition; 
/** gets FixedPageInformation at the given page index. @param pageIndex the page index */
-(FixedPageInformation*)getFixedPageInformationAtPageIndex:(int)pageIndex;
/** returns PageInformation at current page. */
-(FixedPageInformation*)getFixedPageInformation;
/**  goes to the page by the position(by pagePositionInChapter) in this book */
-(void)gotoPageByPagePosition:(double)pagePosition;
/**  goes to the page by page index */
-(void)gotoPageByPageIndex:(int)pageIndex;
-(void)changeBackgroundColor:(UIColor*)backgroundColor;
/**  goes to the page by NavPoint index */
-(void)gotoPageByNavMapIndex:(int)index;
/** delete all cached files in device */
-(void)clearCached;
/** set ContentProvider class */
-(void)setContentProviderClass:(Class)contentProvider;
/** tells device can be rotate or not while caching process is going on. */
-(BOOL)canRotate;


/** goto the page of pageIndex in this chapter */
-(void)gotoPage:(int)pageIndex;
/** goto the next page in this chapter */
-(void)gotoNextPage;
/** goto the prev page in this chapter */
-(void)gotoPrevPage;
/** get page count of this chapter */
-(int)pageCount;
/** get the current pageIndex in this chapter */
-(int)pageIndex;

/** change the color of element which has hash */
-(void)changeElementColor:(NSString*)colorString hash:(NSString*)hash pageIndex:(int)pageIndex;
/** restore the color of element lastly changed */
-(void)restoreElementColor;

/** returns MediaOverlay available */
-(BOOL)isMediaOverlayAvailable;
/** play the first Parallel in this page */
-(void)playFirstParallel;
/** pause playing parallel */
-(void)pausePlayingParallel;
/** stop playing parallel */
-(void)stopPlayingParallel;
/** play the parallel */
-(void)playParallel:(Parallel*)parallel;
/** play the parallel at parallelIndx */
-(void)playParallelByIndex:(int)parallelIndex;
/** get the parallel at parallelIndx */
-(Parallel*)getParallelByIndex:(int)parallelIndex;
/** get the count of parallels in this chapter */
-(int)parallelCount;
/** play the next parallel */
-(void)playNextParallel;
/** play the prev parallel */
-(void)playPrevParallel;
/** resume playing the paused parallel */
-(void)resumePlayingParallel;
/** tells whether playing is paused or not. */
-(BOOL)isPlayingPaused;
/** tells whether medaiOverlay started or not. */
-(BOOL)isPlayingStarted;

/** set license key */
-(void)setLicenseKey:(NSString *)licenseKey;

-(void)debug0;
-(void)debug1;
-(void)debug2;

@end
