//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.

#import <UIKit/UIKit.h>
#import "WAModuleViewController.h"
#import "WAModuleProtocol.h"
#import "WAParserProtocol.h"


@class WAGridCell;

@interface WAGridView : UITableView <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate,WAModuleProtocol,UIScrollViewDelegate>
{
	NSString *urlString;
	UIViewController* currentViewController;
	NSObject <WAParserProtocol> * parser;
    CGSize cellNibSize;
    CGSize headerNibSize;
    int rowInHeaderView;
    UIRefreshControl *refreshControl;
    UICollectionView * currentCollectionView;
	
}

@property (nonatomic,retain) NSObject <WAParserProtocol> * parser;
@property (nonatomic,retain) UIRefreshControl *refreshControl;
@property (nonatomic,retain) UICollectionView * currentCollectionView;




- (void) initParser;

- (void)buttonAction:(id)sender;
- (void) openModule:(NSString*)theUrlString inView:(UIView*)pageView inRect:(CGRect)rect;


- (void) didSucceedIssueDownloadWithNotification:(NSNotification *) notification;
- (void) didSucceedResourceDownloadWithNotification:(NSNotification *) notification;

- (void) openDetailView:(int)detailRow;
- (void) dismissDetailView;

- (void)loadImagesForOnscreenRows;


@end

