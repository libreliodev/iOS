//
//  ReflowableViewController.h
//  Created by SkyTree on 11. 8. 29..
//  Copyright (c) 2011 Skytree Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

@class Highlight,ReflowableViewController,Book;
/**
 SearchResult class contains the information about the searched text.
 */
@interface SearchResult:NSObject {
    /** the text containing the searched key. */
    NSString *text;
    /** the name of html node that contains the searched key. */
    NSString *nodeName;
    /** the index of the element that contains the searched key. */
    int uniqueIndex;
    /** the start offset in the text which contains the searched key. */
    int startOffset;
    /** the end offset in the text which contains the searched key. */
    int endOffset;
    /** the index of chapter where the searched key is found in. */
    int chapterIndex;
    /** the title of chapter. */
    NSString *chapterTitle;
    /** the index of the page where the searched key is found in. */
    int pageIndex;
    /** the position from the start of chapter. */
    double pagePositionInChapter;
    /** the global position from the beginning of the book. */
    double pagePositionInBook;
    /** the accumulated number of the searched items. */
    int numberOfSearched;
    /** the accumulated number of the searched texts in this chapter. */
    int numberOfSearchedInChapter;
    /** the number of Pages in the chapter */
    int numberOfPagesInChapter;
    /** the number of Chapters in book */
    int numberOfChaptersInBook;
}

@property (nonatomic,retain) NSString *text;
@property (nonatomic,retain) NSString *nodeName;
@property (nonatomic,retain) NSString *chapterTitle;
@property int uniqueIndex,startOffset,endOffset,chapterIndex,pageIndex,numberOfSearched,numberOfSearchedInChapter,numberOfPagesInChapter,numberOfChaptersInBook;
@property double pagePositionInChapter,pagePositionInBook;

@end

/**
 PageInfomation class contains information about a specific page of epub.
 */
@interface PageInformation :NSObject{
    /** BookCode */
    NSInteger bookCode;
    /** Code */
    NSInteger code;
    /** the index of the chapter that this page belongs to */
    NSInteger chapterIndex;
    /** the number of chapter that epub has. */
    NSInteger numberOfChaptersInBook;
    /** the page index from the start of this chapter. */
    NSInteger pageIndex;
    /** the total page number of this chapter. */
    NSInteger numberOfPagesInChapter;
    /** the title of this chapter. */
    NSString* chapterTitle;
    /** all Highlights in this page. */
    NSMutableArray *highlightsInPage;
    /** the position from the start of this chapter. */
    double pagePositionInChapter;
    /** the global postion from the start of this book. */
    double pagePositionInBook;
    /** the description on this page. */
    NSString *pageDescription;
    bool isLoadedChapter;
    /** the index of the first element in this page. */
    NSInteger startIndex;
    /** the index of the end element in this page. */
    NSInteger endIndex;
    /** the page index from the start of book */
    NSInteger pageIndexInBook;
    /** the total number of pages in book */
    NSInteger numberOfPagesInBook;
}

@property NSInteger code,bookCode;
@property NSInteger chapterIndex;
@property NSInteger numberOfChaptersInBook;
@property NSInteger pageIndex;
@property NSInteger numberOfPagesInChapter;
@property (nonatomic,retain) NSString* chapterTitle;
@property (nonatomic,retain) NSMutableArray *highlightsInPage;
@property double pagePositionInChapter;
@property double pagePositionInBook;
@property (nonatomic,retain) NSString* pageDescription;
@property bool isLoadedChapter;
@property NSInteger startIndex,endIndex;
@property NSInteger pageIndexInBook,numberOfPagesInBook;
@end

/**
 PagingInformation class contains the information about paging for one chapter.
 */
@interface PagingInformation :NSObject {
    int code;
    /** the code of book which is loaded now */
    NSInteger bookCode;
    /** the index of chapter which is paginated now */
    NSInteger chapterIndex;
    /** the number of pages in this chapter */
    NSInteger numberOfPagesInChapter;
    /** the font name that is used for this paging. */
    NSString *fontName;
    /** the font size that is used for this paging. */
    NSInteger fontSize;
    /** the width of webView */
    int width;
    /** the height of webView */
    int hegith;
    /** the line space that is used for this paging. */
    NSInteger lineSpacing;
    /** the vertical gap ratio that is used for this paging. */
    double verticalGapRatio;
    /** the horizontal gap ratio that is used for this paging. */
    double horizontalGapRatio;
    /** denote the device was portrait or not */
    BOOL isPortrait;
    /** double paged in landscape mode */
    BOOL isDoublePagedForLandscape;
}

@property (nonatomic,retain) NSString *fontName;
@property NSInteger bookCode,chapterIndex,numberOfPagesInChapter,fontSize,lineSpacing;
@property double verticalGapRatio,horizontalGapRatio;
@property BOOL isPortrait,isDoublePagedForLandscape;
@property int code,width,height;

-(BOOL)isEqualTo:(PagingInformation*)pgi;
@end


/**
 ReflowableViewControllerDataSource is the protocol containing methods to be implemented to respond to the request from ReflowableViewController.
 */
@protocol ReflowableViewControllerDataSource <NSObject>
@optional
/** should return NSMutableArray holding highlight objects for the given chapter index. */
-(NSMutableArray*)reflowableViewController:(ReflowableViewController*)rvc highlightsForChapter:(NSInteger)chapterIndex;
/** called when new highlight object must be inserted. */
-(void)reflowableViewController:(ReflowableViewController*)rvc insertHighlight:(Highlight*)highlight;
/** called when certain highlight should be deleted in the case like merging highlights. */
-(void)reflowableViewController:(ReflowableViewController*)rvc deleteHighlight:(Highlight*)highlight;
/** should return the number of pages for specific PagingInformation in global pagination mode*/
-(NSInteger)reflowableViewController:(ReflowableViewController*)rvc numberOfPagesForPagingInformation:(PagingInformation*)pagingInformation;

// 3.5.5
/** called when certain highlight should be updated in the case like changing color */
-(void)reflowableViewController:(ReflowableViewController*)rvc updateHighlight:(Highlight*)highlight;
/** Javascript source for chapterIndex can be passed to the engine if you like to implement some custom behaviors.  */
-(NSString*)reflowableViewController:(ReflowableViewController*)rvc scriptForChapter:(NSInteger)chapterIndex;
/** should tell the engine whether a given pagePositionInBook value is bookmarked or not */
-(BOOL)reflowableViewController:(ReflowableViewController*)rvc isBookmarked:(PageInformation*)pageInformation;
/** should return the bookmarked image for rendering */
-(UIImage*)bookmarkImage:(ReflowableViewController*)rvc isBookmarked:(BOOL)isBookmarked;
/** should return the CGRect of the bookmarked image for rendering */
-(CGRect)bookmarkRect:(ReflowableViewController*)rvc isBookmarked:(BOOL)isBookmarked;
@end

@class Parallel;
/**
 ReflowableViewControllerDelegate is the protocol containing functions which should be implemented to handle the events from ReflowableViewController.
 */
@protocol ReflowableViewControllerDelegate <NSObject>
@optional
/** called when text selection is finished. @param highlight Highlight object @param startRect CGRect for  the first line range of selection area.  @param endRect CGRect for the last line range of selection area */
-(void)reflowableViewController:(ReflowableViewController*)rvc didSelectRange:(Highlight*)highlight startRect:(CGRect)startRect endRect:(CGRect)endRect;
/** called when single tap is detected @param position CGPoint object at tap position */
-(void)reflowableViewController:(ReflowableViewController*)rvc didDetectTapAtPosition:(CGPoint)position;
/** called when double tap is detected @param position CGPoint object at double tap position */
-(void)reflowableViewController:(ReflowableViewController*)rvc didDetectDoubleTapAtPosition:(CGPoint)position;
/** called when page is moved to or chapter is loaded at first time. @param pageInformation PageInformation object of current page. */
-(void)reflowableViewController:(ReflowableViewController*)rvc pageMoved:(PageInformation*)pageInformation;
/** called when the key is found. @param searchResult SearchResult object. */
-(void)reflowableViewController:(ReflowableViewController*)rvc didSearchKey:(SearchResult*)searchResult;
/** called when search process for one chapter is finished @param searchResult SearchResult object. */
-(void)reflowableViewController:(ReflowableViewController*)rvc didFinishSearchForChapter:(SearchResult*)searchResult;
/** called when all search process is finihsed @param searchResult SearchResult object. */
-(void)reflowableViewController:(ReflowableViewController*)rvc didFinishSearchAll:(SearchResult*)searchResult;
/** called when global pagination for all chapters is started */
-(void)reflowableViewController:(ReflowableViewController*)rvc didStartPaging:(int)bookCode;
/** called when paginating one chapter is over. */
-(void)reflowableViewController:(ReflowableViewController*)rvc didPaging:(PagingInformation*)pagingInformation;
/** called when global pagination for all chapters is finished */
-(void)reflowableViewController:(ReflowableViewController*)rvc didFinishPaging:(int)bookCode;

/** called when new chapter is loaded */
-(void)reflowableViewController:(ReflowableViewController*)rvc didChapterLoad:(int)chapterIndex;

/** called when playing one parallel started */
-(void)reflowableViewController:(ReflowableViewController*)rvc parallelDidStart:(Parallel*)parallel;
/** called when playing one parallel finished */
-(void)reflowableViewController:(ReflowableViewController*)rvc parallelDidEnd:(Parallel*)parallel;
/** called when playing all parallels finished */
-(void)parallesDidEnd:(ReflowableViewController*)rvc;

// 3.5.5
/** called when highlight is hit by tap gesture. @param highlight Highlight object hit by tap gesture. @param position CGPoint at tap position */
-(void)reflowableViewController:(ReflowableViewController*)rvc didHitHighlight:(Highlight*)highlight atPosition:(CGPoint)position startRect:(CGRect)startRect endRect:(CGRect)endRect;
// 3.6.2
//** called when link is hit by tap gesture. @param urlString the link address hit by tap */
-(void)reflowableViewController:(ReflowableViewController*)rvc didHitLink:(NSString*)urlString;
//** called when image is hit by tap gesture. @param urlString the image source hit by tap */
-(void)reflowableViewController:(ReflowableViewController*)rvc didHitImage:(NSString*)urlString;


-(void)pageTransitionStarted:(ReflowableViewController*)rvc;
-(void)pageTransitionEnded:(ReflowableViewController*)rvc;
/** called when text selection is cancelled */
-(void)reflowableViewController:(ReflowableViewController*)rvc didSelectionCanceled:(NSString*)lastSelectedText;
/** called when seletected text is changed */
-(void)reflowableViewController:(ReflowableViewController*)rvc didSelectionChanged:(NSString*)selectedText;
-(void)reflowableViewController:(ReflowableViewController*)rvc didHitBookmark:(PageInformation*)pageInformation isBookmarked:(BOOL)isBookmarked;

@end


/**
 the ReflowableViewController Object
 */
@interface ReflowableViewController : UIViewController {
    /** the page transition type. 0:none, 1:slide, 2:curl */
    int transitionType;
    /** the unique code for this book. */
    int bookCode;
    /** the Book object which contains information about epub. */
    Book* book;
    /** the UIView object for background under the text */
    UIView *backgroundView;
    /** ReflowableViewControllerDelegate to handle events from ReflowableViewController. */
    id <ReflowableViewControllerDelegate>   delegate;
    /** ReflowableViewControllerDataSource to respond to the request from ReflowableViewController. */
    id <ReflowableViewControllerDataSource> dataSource;
    /** to prevent rotation when rotationLocked is YES */
    BOOL rotationLocked;
    /** current engine version. */
    NSString *version;
    /** the base directory for custom content files of epub */
    NSString *baseDirectory;
    /** the class for custom reader for epub. */
    id contentProviderClass;
    /** the customView for user interface */
    UIView* customView;
    /** Search process is going on or not */
    BOOL isSearching;
}

@property (nonatomic,copy) NSString *encryptKey;
@property int transitionType;
@property int bookCode;
@property BOOL rotationLocked,isSearching;
@property (nonatomic,strong) UIView *backgroundView;
@property (nonatomic,strong) Book* book;
@property (nonatomic,weak) id <ReflowableViewControllerDelegate>      delegate;
@property (nonatomic,weak) id <ReflowableViewControllerDataSource>    dataSource;
@property (nonatomic,copy) NSString *version;
@property (nonatomic,copy) NSString *baseDirectory;
@property (nonatomic,strong) UIView* customView;

-(id)initWithStartPagePositionInBook:(double)pagePositionInBook;
/** gets PageInformation at the global position in book. @param pagePositionInBook is a double between 0 to 1 to indicate the position in entile book. */
-(PageInformation*)getPageInformationAtPagePositionInBook:(double)pagePositionInBook;
/** returns PageInformation at current page. */
-(PageInformation*)getPageInformation;
/**  goes to the page by global position in book. */
-(void)gotoPageByPagePositionInBook:(double)pagePositionInBook;
/**  goes to the page by global position in book with Animation effect - PageTransitionCurl mode only */
-(void)gotoPageByPagePositionInBook:(double)pagePositionInBook animated:(BOOL)animated;
/**  goes to the page by the position(by pagePositionInChapter) in the chapter(by chapterIndex) */
-(void)gotoPageByPagePosition:(double)pagePositionInChapter inChapter:(int)chapterIndex;
/**  goes to the page by the element index in the chapter by chapterIndex */
-(void)gotoPageByUniqueIndex:(int)index inChapter:(int)chapterIndex;
/**  goes to the page by NavPoint index */
-(void)gotoPageByNavMapIndex:(int)index;
/**  goes to the page by Highlight object, highlight must contain chapterIndex. */
-(void)gotoPageByHighlight:(Highlight*)highlight;
/**  goes to the page by SearchResult Object */
-(void)gotoPageBySearchResult:(SearchResult*)searchResult;
/**  changes font name and size of ReflowableViewController and reload the current chapter.*/
-(void)changeFontName:(NSString*)fontName fontSize:(NSInteger)fontSize;
/**  changes font name,size and lineSpacing of ReflowableViewController and reload the current chapter.*/
-(void)changeFontName:(NSString *)fontName fontSize:(NSInteger)fontSize lineSpacing:(NSInteger)lineSpacing;
/**  resets all font settings to default */
-(void)changeFontToDefault;
/**  changes the line spacing between lines and reload. lineSpacing is the value of px. */
-(void)changeLineSpacing:(NSInteger)lineSpacing;
/**  changes foreground and background color of ReflowableViewController and reload the current chapter. */
-(void)changeForegroundColor:(UIColor*)foregroundColor backgroundColor:(UIColor*)backgroundColor;
/** changes foreground color of ReflowableViewController and reload the current chapter. */
-(void)changeForegroundColor:(UIColor*)foregroundColor;
/** changes background color of ReflowableViewController and reload the current chapter. */
-(void)changeBackgroundColor:(UIColor *)backgroundColor;
/**  changes the background image For landscape with clientRect */
-(void)setBackgroundImageForLandscape:(UIImage*)backgroundImage contentRect:(CGRect)rect;
/**  changes the background image For Portrait with clientRect */
-(void)setBackgroundImageForPortrait:(UIImage*)backgroundImage contentRect:(CGRect)rect;
/**  set the marker image for highlight. */
-(void)setMarkerImage:(UIImage*)markerImage;
/**  set current Selection to Highlight; */
-(void)makeSelectionHighlight:(UIColor*)color;
/**  makes current Selection to Highlight its style note. */
-(void)makeSelectionNote:(UIColor*)color;
/**  clear current Highlight at mouse position; */
-(void)deleteHightlight:(Highlight*)highlight;
/**  reloads current chapter & highlights */
-(void)reloadData;
/**  erases all highlights and reload highlights from dataSource. */
-(void)reloadHighlights;
/**  reloads NCX file. */
-(void)reloadNCX;
/**  searches epub for the key. */
-(void)searchKey:(NSString*)key;
/**  searches the key more */
-(void)searchMore;
/**  pauses searching */
-(void)pauseSearch;
/**  stops searching */
-(void)stopSearch;
/**  unselects the text selection. */
-(void)unselect;
-(void)normalizeAll;
/**  executes javascript source. */
-(NSString*)executeScript:(NSString*)script;
/** set vertical gap */
-(void)setVerticalGapRatio:(double)ratio;
/** set horizontal gap */
-(void)setHorizontalGapRatio:(double)ratio;
/** set double page support for landscape view */
-(void)setDoublePagedForLandscape:(BOOL)isDoublePagedForLandscape;
/** set global pagination */
-(void)setGlobalPaging:(BOOL)isGlobalPaging;

/** show indicator while loading new chapter or not. */
-(void)showIndicatorWhileLoadingChapter:(BOOL)show;
/** show indicator while paginating whole chapters or not. */
-(void)showIndicatorWhilePaging:(BOOL)show;
/** show indicator while device is rotated or not */
-(void)showIndicatorWhileRotating:(BOOL)show;
/** allow fast page transition or not */
-(void)allowPageTransitionFast:(BOOL)isFast;

/** goto the page of pageIndex in this chapter */
-(void)gotoPageInChapter:(int)pageIndex;
/** goto the next page in this chapter */
-(void)gotoNextPageInChapter;
/** goto the prev page in this chapter */
-(void)gotoPrevPageInChapter;
/** get page count of this chapter */
-(int)pageCountInChapter;
/** get the current pageIndex in this chapter */
-(int)pageIndexInChapter;

/** returns MediaOverlay available */
-(BOOL)isMediaOverlayAvailable;
/** play the first Parallel in this page */
-(void)playFirstParallelInPage;
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
-(int)parallelCountInChapter;
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

/** change the color of element which has hash */
-(void)changeElementColor:(NSString*)colorString hash:(NSString*)hash;
/** restore the color of element lastly changed */
-(void)restoreElementColor;

-(void)debug0;
-(void)debug1;
-(void)debug2;
/** loads the chapter by index and go to the first page. */
-(void)gotoChapter:(int)chapterIndex;
/**  goes to the page by pageIndex in current chapter. */
-(void)gotoPage:(int)pageIndex;
/** set ContentProvider class */
-(void)setContentProviderClass:(Class)contentProvider;

/** use DOM structure for highlight text. */
-(void)useDOMHighlight:(BOOL)useDOM;

// 3.5.5
/** change the color of the highlight */
-(void)changeHighlight:(Highlight*)highlight color:(UIColor*)color;
/** change the text for note */
-(void)changeHighlight:(Highlight *)highlight note:(NSString *)note;
/** change the color and note of text. */
-(void)changeHighlight:(Highlight *)highlight color:(UIColor*)color note:(NSString *)note;
/** check where book is double paged or not. */
-(BOOL)isDoublePaged;
/** tells the engine to rebuild internal cache images for curl transition */
-(void)refresh;
/** tells the engine to repaint viewer */
-(void)repaint;
/** gets the start rectangle from a highlight */
-(CGRect)getStartRectFromHighlight:(Highlight*)highlight;
/** gets the end rectangle from  a highlight */
-(CGRect)getEndRectFromHighlight:(Highlight*)highlight;
/** return pagePositionInBook value for given page of current chapter */
-(double)getPagePositionInBook:(int)pageIndex;

/** backup current position */
-(void)backupPosition;
/** goto the position backuped */
-(void)restorePosition;

/** Hide the contents of book */
-(void)hidePages;
/** show the contents of book */
-(void)showPages;
/** tell the pages of viewer is shown or hidden */
-(BOOL)isPagesShown;

/** set license key */
-(void)setLicenseKey:(NSString *)licenseKey;
-(void)setMenuControllerEnabled:(BOOL)isEnabled;

/** convert screen coordination x to web coordination x */
-(int)toWebX:(int)vx;
/** convert web coordination x to screen coordination x */
-(int)toViewX:(int)wx;
/** convert screen coordination y to web coordination y */
-(int)toWebY:(int)vy;
/** convert web coordination y to screen coordination y */
-(int)toViewY:(int)wy;

// 3.7.1
/** ReflowablableView init with start chapter index and hashLocation. */
-(id)initWithStartChapterIndex:(int)ci hashLocation:(NSString*)hashLocation;
/** goto Page with start chapter index and hashLocation. */
-(void)gotoPageByChapterIndex:(int)ci hashLocation:(NSString*)hashLocation;
/** goto Page with NavPoint */
-(void)gotoPageByNavPoint:(NavPoint*)navPoint;

// 3.8.1
/** gets the number of chapters in book */
-(int)getNumberOfChaptersInBook;
/** gets the index of the current page in book - global pagination mode only */
-(int)getPageIndexInBook;
/** gets the total number of pages in book - global pagination mode only */
-(int)getNumberOfPagesInBook;

// 3.8.2
/** set the color of blank area */
-(void)setBlankColor:(UIColor*)blankColor;

// 3.9.0
/** returns whether current book is Right To Left reading or not */
-(BOOL)isRTL;

// 3.9.2
-(void)setDelayTimeForProcessContentInRecalc:(double)time;
-(void)setDelayTimeForProcessContentInRecalcPagesForRotation:(double)time;
-(void)setDelayTimeForShowWebViewInProcessContent:(double)time;
-(void)setDelayTimeForBringContentViewToFrontInShowWebView:(double)time;
-(void)setDelayTimeForMakeAndResetPageImagesInShowWebViewForPaing:(double)time;
-(void)setDelayTimeForSetPageReadyInShowWebView:(double)time;

@end
