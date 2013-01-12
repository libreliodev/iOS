//
//  WAAdvancedSearchPopoverController.h
//  Librelio
//
//  Created by svp on 13.02.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WAPageContainerController.h"

@class WADetailsViewController;
@class WAGenericPopover;


@interface WAAdvancedSearchPopoverController : UIViewController <UITableViewDataSource, UITableViewDelegate,PageContainerItem>
{
    
}

// User interface
@property (nonatomic, assign) WAPageContainerController *containerController;
@property (nonatomic, assign) WAGenericPopover *genericPopover;


@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UITableViewCell *tableViewCell;

// Datasrouce
@property (nonatomic, retain) NSArray *datasource;
@property (nonatomic, retain) NSString *urlString;



@end
