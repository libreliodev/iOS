//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.

#import <UIKit/UIKit.h>
#import "AQGridView.h"
#import "WAModuleViewController.h"
#import "WAModuleProtocol.h"
#import "WAParserProtocol.h"


@class WAGridCell;

@interface WAGridView : UIView <AQGridViewDataSource, AQGridViewDelegate, UIGestureRecognizerDelegate,WAModuleProtocol>
{
    AQGridView * _gridView;
    
    NSUInteger _emptyCellIndex;
    
    NSUInteger _dragOriginIndex;
    CGPoint _dragOriginCellOrigin;
    
    WAGridCell * _draggingCell;

	NSString *urlString;
	

	
	UIViewController* currentViewController;
	NSObject <WAParserProtocol> * parser;
	
	
}

@property (nonatomic,retain) NSObject <WAParserProtocol> * parser;



- (CGSize) getCellInnerSize;
- (CGSize) getCellOuterSize;
- (UIEdgeInsets) getHorizontalInsets;

- (void) initParser;

- (void)buttonAction:(id)sender;
- (void) openModule:(NSString*)theUrlString inView:(UIView*)pageView inRect:(CGRect)rect;


- (void) didSucceedResourceDownloadWithNotification:(NSNotification *) notification;



@end

