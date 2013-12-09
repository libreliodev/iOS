//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.

#import <UIKit/UIKit.h>
#import "WAModuleViewController.h"
#import "WAModuleProtocol.h"
#import "WAParserProtocol.h"


@class WAGridCell;

@interface WAGridView : UITableView <UITableViewDelegate,UITableViewDataSource, UIGestureRecognizerDelegate,WAModuleProtocol>
{
	NSString *urlString;
	UIViewController* currentViewController;
	NSObject <WAParserProtocol> * parser;
    CGSize cellNibSize;
	
	
}

@property (nonatomic,retain) NSObject <WAParserProtocol> * parser;




- (void) initParser;

- (void)buttonAction:(id)sender;
- (void) openModule:(NSString*)theUrlString inView:(UIView*)pageView inRect:(CGRect)rect;


- (void) didSucceedResourceDownloadWithNotification:(NSNotification *) notification;

-(int)numberofColumns;

@end

