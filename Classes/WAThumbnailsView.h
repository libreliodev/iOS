//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WAParserProtocol.h"


@protocol ThumbImageViewDelegate <NSObject>

- (void)thumbImageViewWasTappedAtPage:(int)pageTapped;

@end

/**
 *	@brief Manages the bottom slide in paginated module
 **/
@interface WAThumbnailsView : UITableView <UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource>
{
    id <ThumbImageViewDelegate> thumbImageViewDelegate;
	NSObject <WAParserProtocol> *pdfDocument;
}

@property (nonatomic, assign) NSObject <WAParserProtocol> * pdfDocument;
@property (nonatomic, assign) id <ThumbImageViewDelegate> thumbImageViewDelegate;

@end




