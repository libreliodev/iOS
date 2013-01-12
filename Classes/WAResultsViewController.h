//
//  WAResultsViewController.h
//  Librelio
//
//  Created by svp on 31.01.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WAPageContainerController.h"

@class WADetailsViewController;
@class WADatabaseController;

@interface WAResultsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, PageContainerItem>
{
    BOOL ascendingSearch;
    BOOL _editable;
}

// User interface
@property (nonatomic, assign) WAPageContainerController *containerController;
@property (nonatomic, retain) WADatabaseController *databaseController;

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UITableViewCell *tableViewCell;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *modifierButton;
@property (retain, nonatomic) IBOutlet UIButton *marqueButton;
@property (retain, nonatomic) IBOutlet UIButton *gammeButton;
@property (retain, nonatomic) IBOutlet UIButton *prixButton;
@property (nonatomic, retain) IBOutlet UIButton *backButton;
@property (nonatomic) BOOL editable;

// Datasrouce
@property (nonatomic, retain) NSArray *datasource;
@property (nonatomic, retain) NSString *urlString;

// User actions
-(IBAction)backButtonClicked:(id)sender;
- (IBAction)marqueButtonClicked:(id)sender;
- (IBAction)gammeButtonClicked:(id)sender;
- (IBAction)prixButtonClicked:(id)sender;
-(IBAction)modifierButtonClicked:(id)sender;

// Supporting methods
-(NSString *)removeOrderIndicator:(NSString *)title;
-(NSString *)setOrderIndicator:(NSString *)title ascending:(BOOL)ascending;

@end
