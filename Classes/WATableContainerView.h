//
//  WATableViewController.h
//  Librelio
//
//  Created by svp on 24.01.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "WAModuleProtocol.h"
#import "WAGenericPopover.h"


@class WAPrixViewController;
@class WAPageContainerController;
@class WAResultsViewController;
@class WALexiqueController;
@class WADatabaseController;
@class WAAdvancedSearchPopoverController;
@class WABuyViewController;
@class WAGenericPopover;

@interface WATableContainerView : UIView <WAModuleProtocol, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, WAGenericPopoverDelegate>{
    NSString *urlString;
    UIViewController* currentViewController;
    UINavigationController *tableNavController;

    UIView *mainViewController;
     
    WAPrixViewController *prixViewController;
}

/**
 The UINavigationController attached to the view, with a WATableViewController at the root level
 */
@property (nonatomic, retain) UINavigationController *tableNavController;
@property (nonatomic, retain) WAPageContainerController *pageContainerController;
@property (nonatomic, retain) WADatabaseController *databaseController;
@property (nonatomic, retain) WABuyViewController *buyViewController;
@property (nonatomic, retain) WAGenericPopover *genericPopover;
@property (nonatomic, retain) WAAdvancedSearchPopoverController *searchPopover;

@property (nonatomic, retain) IBOutlet UIView *mainViewController;
@property (nonatomic, retain) WAPrixViewController *prixViewController;

@property (nonatomic, retain) NSIndexPath *selectedIndex;
@property (nonatomic, retain) IBOutlet UITableView *mainTable;
@property (nonatomic, retain) IBOutlet UITableViewCell *searchTableCell;

@property (nonatomic, retain) NSArray *leftTableData;
@property (nonatomic, retain) NSArray *fullDatabase;
@property (nonatomic, retain) NSMutableArray *quickSearchResults;

@property (nonatomic, retain) NSMutableDictionary *searchPreferences;
@property (nonatomic, retain) NSMutableDictionary *previousSearchPreferences;

// User interface
@property (retain, nonatomic) IBOutlet UITextField *searchKeyword;
@property (retain, nonatomic) IBOutlet UIButton *rechercheButton;
@property (retain, nonatomic) IBOutlet UIButton *favorisButton;
@property (retain, nonatomic) IBOutlet UIButton *lexiqueButton;
@property (retain, nonatomic) IBOutlet UIButton *aficherButton;

@property (retain, nonatomic) IBOutlet UITableViewCell *iphoneAfficherCell;
@property (retain, nonatomic) IBOutlet UITableViewCell *previousSearchCell;

@property (nonatomic, retain) UIImageView *splashScreenImage;

// User interface collections
@property (nonatomic, retain) IBOutletCollection(UITextField) NSArray *searchKeywordCollection;
@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray *rechercheButtonCollection;
@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray *favorisButtonCollection;
@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray *lexiqueButtonCollection;

@property (nonatomic) CGRect keyboardRect;


@property (nonatomic) NSUInteger marqueIndex;

// User interactions
- (IBAction)favorisButtonPressed:(id)sender;
- (IBAction)rechercheButtonPressed:(id)sender;
- (IBAction)lexiqueButtonPressed:(id)sender;
- (IBAction)aficherButtonPressed:(id)sender;
- (IBAction)textFieldChanged:(id)sender;

-(void)updateSelection:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath;
-(void)showTableSelectionController:(NSUInteger)index;
-(void)updateIndex:(NSIndexPath *)indexPath;

-(void)showMarqueTab;

@end
