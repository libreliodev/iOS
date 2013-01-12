//
//  WATableViewController.h
//  Librelio
//
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "WAModuleProtocol.h"

@interface WAAnalyticsView : UITableView <WAModuleProtocol,UITableViewDelegate,UITableViewDataSource>{
    NSString *urlString;
    UIViewController* currentViewController;
 	NSObject <WAParserProtocol> * parser;
    
}

@property (nonatomic,retain) NSObject <WAParserProtocol> * parser;


@end
