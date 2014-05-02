//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.

#import <UIKit/UIKit.h>
#import "WAModuleViewController.h"
#import "WAModuleProtocol.h"
#import "WAParserProtocol.h"

#import "ReflowableViewController.h"



@interface WASkyView : UITableView <WAModuleProtocol,ReflowableViewControllerDataSource,ReflowableViewControllerDelegate,UIActionSheetDelegate>
{
	NSString *urlString;
	UIViewController* currentViewController;
    ReflowableViewController * rvc;
    UIActionSheet * as;
    
	
}


@property (nonatomic, retain)     ReflowableViewController * rvc;

@property (nonatomic, retain)     UIActionSheet * as;




@end

