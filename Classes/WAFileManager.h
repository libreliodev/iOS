//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WAParserProtocol.h"
#import "WAModuleProtocol.h"


@interface WAFileManager : UITableView <WAModuleProtocol,UITableViewDelegate,UITableViewDataSource> {

	NSString *urlString;
	UIViewController* currentViewController;
	NSObject <WAParserProtocol> * parser;
	
	
	
}

@property (nonatomic,retain) NSObject <WAParserProtocol> * parser;
@property (nonatomic, retain)  NSMutableArray *dataArray; 


@end
