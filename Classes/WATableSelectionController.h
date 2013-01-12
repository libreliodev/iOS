//
//  WATableSelectionController.h
//  Librelio
//
//  Created by Volodymyr Obrizan on 30.01.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WAPageContainerController.h"

@interface WATableSelectionController : UIViewController<UITableViewDataSource, UITableViewDelegate, PageContainerItem>
{
@private
	BOOL _helpButtonEnabled;
    
}

// User interface
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *subscriptLabel;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UITableViewCell *tableViewCell;
@property (nonatomic, retain) IBOutlet UIButton *helpButton;

// Datasrouce
@property (nonatomic, retain) NSArray *datasource;
@property (nonatomic, retain) NSMutableIndexSet *indexSet;
@property (nonatomic) BOOL helpButtonEnabled;
@property (nonatomic, assign) id helpButtonTarget;
@property (nonatomic) SEL helpButtonAction;

@property (nonatomic, assign) WAPageContainerController *containerController;

-(IBAction)backButtonClicked:(id)sender;
-(IBAction)helpButtonClicked:(id)sender;

@end
