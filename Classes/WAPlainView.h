//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import <UIKit/UIKit.h>
#import "WAModuleProtocol.h"
#import "WAParserProtocol.h"


@interface WAPlainView : UIView <WAModuleProtocol> {
	NSString *urlString;
	UIViewController* currentViewController;
	NSObject <WAParserProtocol> * parser;
	NSArray * dataArray;
	
	
}

@property (nonatomic, retain)  NSArray * dataArray;
@property (nonatomic, retain)  NSObject <WAParserProtocol> * parser;


//- (void) buildDataArray;

- (void) refreshLayoutForOrientation:(UIInterfaceOrientation)orientation ;

- (void)buttonAction:(id)sender;

@end
