//
//  WATableViewController.m
//  Librelio
//
//  Created by svp on 24.01.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import "WATableContainerView.h"
#import "WAPrixViewController.h"
#import "WAResultsViewController.h"
#import "WALexiqueController.h"
#import "WAModuleViewController.h"
#import "WAAdvancedSearchPopoverController.h"

#import "WADatabaseController.h"
#import "WAPageContainerController.h"
#import "WATableSelectionController.h"

#import "NSBundle+WAAdditions.h"
#import "NSString+WAURLString.m"

#import "WABuyViewController.h"

#import "WAGenericPopover.h"

#import "WAAppDelegate.h"

typedef enum {NEW_SEARCH, DISABLED_SEARCH, SEARCH} SearchState;

SearchState searchState = DISABLED_SEARCH;

@implementation WATableContainerView

@synthesize currentViewController;
@synthesize tableNavController;

@synthesize prixViewController          = _prixViewController;
@synthesize mainViewController          = _mainViewController;

@synthesize selectedIndex               = _selectedIndex;
@synthesize mainTable                   = _mainTable;
@synthesize leftTableData               = _leftTableData;
@synthesize buyViewController           = _buyViewController;
@synthesize genericPopover              = _genericPopover;
@synthesize searchPopover               = _searchPopover;

@synthesize pageContainerController     = _pageContainerController;
@synthesize databaseController          = _databaseController;
@synthesize searchTableCell             = _searchTableCell;
@synthesize searchPreferences           = _searchPreferences;
@synthesize previousSearchPreferences	= _previousSearchPreferences;
@synthesize searchKeyword               = _searchKeyword;
@synthesize rechercheButton             = _rechercheButton;
@synthesize favorisButton               = _favorisButton;
@synthesize lexiqueButton               = _lexiqueButton;
@synthesize aficherButton               = _aficherButton;
@synthesize marqueIndex                 = _marqueIndex;

@synthesize fullDatabase                = _fullDatabase;
@synthesize quickSearchResults          = _quickSearchResults;

@synthesize iphoneAfficherCell          = _iphoneAfficherCell;
@synthesize previousSearchCell			= _previousSearchCell;

// User interface collections
@synthesize searchKeywordCollection     = _searchKeywordCollection;
@synthesize rechercheButtonCollection   = _rechercheButtonCollection;
@synthesize favorisButtonCollection     = _favorisButtonCollection;
@synthesize lexiqueButtonCollection     = _lexiqueButtonCollection;

@synthesize keyboardRect				= _keyboardRect;

@synthesize splashScreenImage			= _splashScreenImage;


#pragma mark -
#pragma mark Lifecycle

////////////////////////////////////////////////////////////////////////////////


- (IBAction)rechercheButtonPressed:(id)sender
{
    // Change button states
    self.favorisButton.enabled = YES;
    [self.favorisButtonCollection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setEnabled: YES];
    }];
    
    self.rechercheButton.enabled = NO;
    [self.rechercheButtonCollection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setEnabled: NO];
    }];

    self.lexiqueButton.enabled = YES;
    [self.lexiqueButtonCollection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setEnabled: YES];
    }];
    
    // by default, the "Marque" TableSelection View should be displayed at the right of the screen, when rechercheButton is pressed. This is also true at startup (we do not wand the right part of the screen to be empty with an orange background). If a search criteria has been selected (with the disclosure indicator visible), then the corresponding table should be displayed on the right
	// in all apps/iPhone, the first screen should not be the "marques" selector, but the list of criteria
	if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone)
	{
		[self showTableSelectionController:self.marqueIndex];
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.marqueIndex inSection:0];
		[self updateIndex:indexPath];
	}
	else
		// Remove current view controller
		[self.pageContainerController removeSelectedViewController];
}


////////////////////////////////////////////////////////////////////////////////


- (IBAction)favorisButtonPressed:(id)sender
{
    // Change button states
    self.favorisButton.enabled = NO;
    [self.favorisButtonCollection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setEnabled: NO];
    }];
    
    self.rechercheButton.enabled = YES;
    [self.rechercheButtonCollection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setEnabled: YES];
    }];
    
    self.lexiqueButton.enabled = YES;
    [self.lexiqueButtonCollection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setEnabled: YES];
    }];
    
    NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults]; 
    WAResultsViewController *mesFavorisController = [[[WAResultsViewController alloc]initWithNibName:@"WAResultsView".device bundle:nil]autorelease];
	mesFavorisController.urlString = self.urlString;
    mesFavorisController.editable = YES;
    mesFavorisController.databaseController = self.databaseController;
    mesFavorisController.datasource = [self.databaseController favorisForCriterion:[userDefaults objectForKey:@"FavorisObjects"]];    
    [self.pageContainerController showViewController:mesFavorisController];
    
    // Set up text labels
    mesFavorisController.titleLabel.text = @"Mes Favoris";
}


////////////////////////////////////////////////////////////////////////////////


- (IBAction)lexiqueButtonPressed:(id)sender;
{
    // Change button states
    self.favorisButton.enabled = YES;
    [self.favorisButtonCollection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setEnabled: YES];
    }];

    self.rechercheButton.enabled = YES;
    [self.rechercheButtonCollection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setEnabled: YES];
    }];

    self.lexiqueButton.enabled = NO;
    [self.lexiqueButtonCollection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setEnabled: NO];
    }];

    WALexiqueController *lexiqueController = [[[WALexiqueController alloc]initWithNibName:@"WALexique".device bundle:nil]autorelease];
    lexiqueController.datasource = [self.databaseController lexique];    
    [self.pageContainerController showViewController:lexiqueController];
} 


////////////////////////////////////////////////////////////////////////////////


- (IBAction)aficherButtonPressed:(id)sender
{
    // Change button states
    self.favorisButton.enabled = YES;
    [self.favorisButtonCollection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setEnabled: YES];
    }];

    self.rechercheButton.enabled = NO;
    [self.rechercheButtonCollection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setEnabled: NO];
    }];
    
    self.lexiqueButton.enabled = YES;
    [self.lexiqueButtonCollection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setEnabled: YES];
    }];
	
	if (self.aficherButton.selected)
	{
		// Remember previous preferences
		self.previousSearchPreferences = [self.searchPreferences mutableCopy];
		
		// Clear the search preferences
		self.searchPreferences = [NSMutableDictionary dictionary];
		self.searchKeyword.text = @"";
		[self.searchKeywordCollection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[obj setText:@""];
		} ];
		
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SearchPreferencesChanged" object:self];
		
		// Update the search button
		self.aficherButton.selected = NO;
		self.aficherButton.enabled = NO;
		self.aficherButton.hidden = YES;
		
		searchState = DISABLED_SEARCH;
       
        // Remove indication from the selected cell
        NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];        
        [self updateIndex:ip];        
		
		// In all apps/iPhone, the first screen should not be the "marques" selector, but the list of criteria
		if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone)
			[self showMarqueTab];
		
		[self.mainTable reloadData];
	}
    else
	{
		// Pass user search preferences to the database search method
		NSArray *results = [self.databaseController searchWithPreferences:self.searchPreferences  andKeyword:self.searchKeyword.text];
		
		if (results.count)
		{
			// Show results
			WAResultsViewController *resultsCtrl = [[[WAResultsViewController alloc]initWithNibName:@"WAResultsView".device bundle:nil]autorelease];  
			resultsCtrl.urlString = self.urlString;
			resultsCtrl.datasource = results;
			[self.pageContainerController showViewController:resultsCtrl];
			resultsCtrl.editable = NO;
			
			// Set up text labels
			resultsCtrl.titleLabel.text = @"Votre recherche";
		}
		else
		{
			UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"No results" message:@"Désolé, aucun produit ne correspond à votre demande" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil] autorelease];
			[alertView show];
		}
		
		searchState = NEW_SEARCH;
		self.aficherButton.selected = YES;
		self.aficherButton.enabled = YES;
		self.aficherButton.hidden = NO;               
	}
}


////////////////////////////////////////////////////////////////////////////////


- (NSString *) urlString
{
    return urlString;    
}


////////////////////////////////////////////////////////////////////////////////


-(id)init
{
    self = super.init;
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(searchPreferencesChanged:) 
                                                     name:@"SearchPreferencesChanged"
                                                   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWasShown:)
													 name:UIKeyboardDidShowNotification object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillBeHidden:)
													 name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}


////////////////////////////////////////////////////////////////////////////////


-(void)searchPreferencesChanged:(NSNotification *)notification
{
	searchState = SEARCH;
    [self.mainTable reloadData];
	self.aficherButton.enabled = YES;
	self.aficherButton.selected = NO;
	self.aficherButton.hidden = NO;
}


////////////////////////////////////////////////////////////////////////////////


- (void) setUrlString: (NSString *) theString
{
    urlString = [[NSString alloc]initWithString: theString]; 
    //SLog(@"NewWAtableContainerViewInstantiated");
    
    // Initialize the database
    NSString *originalDBPath = [[NSBundle mainBundle] pathOfFileWithUrl:[urlString noArgsPartOfUrlString]];
    self.databaseController = [[[WADatabaseController alloc] initWithDatabase:originalDBPath] autorelease];
    
    // Get list of advanced criteria
    self.leftTableData = [self.databaseController advancedCriteria];      

    // Check if the specified database exists and contains data
    if(!self.leftTableData.count)
    {
        // Show Buy window
        self.buyViewController = [[[WABuyViewController alloc] initWithNibName:nil bundle:nil] autorelease];
        self.buyViewController.urlString = self.urlString;
        self.buyViewController.view.frame = self.bounds;
        [self addSubview:self.buyViewController.view];
        
        return;
    }
    
    // If the database exists and has data -- show the search window
    self.autoresizesSubviews = YES;

    self.pageContainerController = [[[WAPageContainerController alloc] init] autorelease];

    // Load left view (search and navigation)
    //SLog(@"Will load left view nib");
    [[NSBundle mainBundle]loadNibNamed:@"WALeftView".device owner:self options:nil];
    [self addSubview:self.mainViewController];
    //SLog(@" left view nib loaded");

    // Set up proper size for the main view with buttons and a table
    CGRect frame = self.mainViewController.frame;
    frame.size.height = self.bounds.size.height;
    self.mainViewController.frame = frame;
    
	// Prepare page container controller frame
	CGRect rect = [WAPageContainerController rectForClass:self.pageContainerController];

	// Show page container off-screen on iPhone
	if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
		rect.origin.x = rect.size.width;
    self.pageContainerController.view.frame = rect;

    // Draw view's container
    [self addSubview:self.pageContainerController.view];

    self.searchPreferences = [NSMutableDictionary dictionary];
}


////////////////////////////////////////////////////////////////////////////////


-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //Initialization code
    }
    return self;
}


////////////////////////////////////////////////////////////////////////////////


-(void)dealloc
{    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.splashScreenImage = nil;

    [urlString release];
    [tableNavController release];
    [_rechercheButton release];
    [_favorisButton release];
    [_lexiqueButton release];
    [_aficherButton release];
    [_searchKeyword release];
    [super dealloc];
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark ModuleView protocol

- (void)moduleViewWillAppear:(BOOL)animated
{    
    // Hide navigation bar
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        [self.currentViewController.navigationController setNavigationBarHidden:YES animated:NO];
        
        
    }
    //self.currentViewController.tabBarController.tabBar.hidden = YES;
    
    // by default, the "Marque" TableSelection View should be displayed at the right of the screen, when rechercheButton is pressed. This is also true at startup (we do not wand the right part of the screen to be empty with an orange background). If a search criteria has been selected (with the disclosure indicator visible), then the corresponding table should be displayed on the right
    //
    // Look up for 'Marque' tab and make it active
	// In all apps/iPhone, the first screen should not be the "marques" selectro, but the list of criteria
	// Do not show this tab, if there is an already some views on the navigation stack (if we restore from background)
	if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone &&
		!self.pageContainerController.viewControllersStack.count)
		[self showMarqueTab];
}


////////////////////////////////////////////////////////////////////////////////


- (void) moduleViewDidAppear
{
    [self.buyViewController viewDidAppear:NO];
	
	// Check, if the device in proper orientation
	// UIDevice.currentDevice.orientation improperly returns orientation
	// Source: http://stackoverflow.com/a/6680597/124115
	switch ([[UIApplication sharedApplication] statusBarOrientation])
    {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
            return;
        default:
		{
			if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
			{
				//SLog(@"Should show rotate image");
                // Show splash-screen with rotate sign, asking to rotate the device
				CGRect fullScreen = CGRectMake(0.0f, 0.0f, 480.0f, 320.0f);
				self.splashScreenImage = [[[UIImageView alloc] initWithFrame:fullScreen] autorelease];
				self.splashScreenImage.image = [UIImage imageNamed:@"rotate"];
				self.splashScreenImage.contentMode = UIViewContentModeScaleAspectFill;
				self.splashScreenImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

				[self.superview addSubview:self.splashScreenImage];
			}

            return;
		}
    }
}


////////////////////////////////////////////////////////////////////////////////


- (void) moduleViewWillDisappear:(BOOL)animated{
}


////////////////////////////////////////////////////////////////////////////////


- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.pageContainerController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.buyViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	
	// Remove splash-screen with rotate sign
	if (self.splashScreenImage)
	{
		[self.splashScreenImage removeFromSuperview];
		self.splashScreenImage = nil;
	}
}


////////////////////////////////////////////////////////////////////////////////


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	switch (UIDevice.currentDevice.userInterfaceIdiom)
	{
		case UIUserInterfaceIdiomPhone:
			// self.window is not nil if the view is visible
			// Source: http://stackoverflow.com/a/2777460/124115
			if (((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight)) && self.window)
				return NO;
			else
				return YES;
		default:
			return YES;
	}
}


////////////////////////////////////////////////////////////////////////////////


- (void) moduleWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.pageContainerController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}


////////////////////////////////////////////////////////////////////////////////


- (void) moduleWillAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
}

- (void) jumpToRow:(int)row{
    
}

#pragma mark -
#pragma mark UIPopoverControllerDelegate Protocol 

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [self removeFromSuperview];
}


////////////////////////////////////////////////////////////////////////////////


#pragma mark - Table View Delegate Methods


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	BOOL isIphone = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone;
	
	NSInteger pastSearchCellIndex = -1;
	if (isIphone)
		pastSearchCellIndex = self.previousSearchPreferences ? 0 : -1;
	else
		pastSearchCellIndex = self.previousSearchPreferences ? self.leftTableData.count : -1;
	
	NSInteger aficherCellIndex = self.previousSearchPreferences ? self.leftTableData.count + 1 : self.leftTableData.count;

    // Return the height of the bottom cell with 'Afficher' button
    if (indexPath.row == aficherCellIndex)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AfficherCell"];
        if (cell == nil) 
        {
            [[NSBundle mainBundle] loadNibNamed:@"WAAfficherCellIphone" owner:self options:nil];
            cell = _iphoneAfficherCell;
            self.iphoneAfficherCell = nil;
        }
        return cell.bounds.size.height;
    }
	
    // Return the height of the past search button
    if (indexPath.row == pastSearchCellIndex)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PastSearchCell"];
        if (cell == nil) 
        {
            [[NSBundle mainBundle] loadNibNamed:@"WAPreviousSearchCell".device owner:self options:nil];
            cell = _previousSearchCell;
            self.previousSearchCell = nil;
        }
		CGFloat height = cell.bounds.size.height;
        return height;
    }
	
	// In other case return the standard cell height
	return tableView.rowHeight;
}


////////////////////////////////////////////////////////////////////////////////


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	BOOL isIphone = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone;
	
	NSInteger pastSearchCellIndex = -1;
	if (isIphone)
		pastSearchCellIndex = self.previousSearchPreferences ? 0 : -1;
	else
		pastSearchCellIndex = self.previousSearchPreferences ? self.leftTableData.count : -1;
	
    // Return the height of the past search button
    if (indexPath.row == pastSearchCellIndex)
    {
		UITableViewCell *tempcell = [tableView dequeueReusableCellWithIdentifier:@"PastSearchCell"];
		if (tempcell == nil)
		{
			[[NSBundle mainBundle] loadNibNamed:@"WAPreviousSearchCell".device owner:self options:nil];
			tempcell = _previousSearchCell;
			self.previousSearchCell = nil;
		}
		// Update background color
		cell.backgroundColor = tempcell.backgroundColor;
    }
}


////////////////////////////////////////////////////////////////////////////////


#pragma mark -
#pragma mark Table View Data Source Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSUInteger spareRows = 0;
	
    // We show an additional cell with AFFICHER button in iPhone mode
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        spareRows++;
	
	// We show an addititonal cell for past search criteria
	if (self.previousSearchPreferences)
		spareRows++;
    //SLog(@"Will return %i numberOfRows",self.leftTableData.count + spareRows);
	
	return self.leftTableData.count + spareRows;
}


////////////////////////////////////////////////////////////////////////////////


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	BOOL isIphone = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone;
	
	NSInteger pastSearchCellIndex = -1;
	if (isIphone)
		pastSearchCellIndex = self.previousSearchPreferences ? 0 : -1;
	else
		pastSearchCellIndex = self.previousSearchPreferences ? self.leftTableData.count : -1;
	
	NSInteger aficherCellIndex = self.previousSearchPreferences ? self.leftTableData.count + 1 : self.leftTableData.count;
	
	// Show 'Previous search'
	if (indexPath.row == pastSearchCellIndex)
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PastSearchCell"];
		if (cell == nil)
		{
			[[NSBundle mainBundle] loadNibNamed:@"WAPreviousSearchCell".device owner:self options:nil];
			cell = _previousSearchCell;
			self.previousSearchCell = nil;
		}
		
		// Accumulate search preferenes details
		NSMutableArray *prefArray = [NSMutableArray array];
		for (NSDictionary *dic in self.databaseController.advancedCriteria)
		{
			NSString *tableColumn = [dic objectForKey:@"ColName"];
			NSString *str = [self.databaseController selectionDetailForCriterion:tableColumn preferences:self.previousSearchPreferences];
			
			if (str.length)
			{
				// Substitute "Oui" with the actual name
				if ([str isEqualToString:@"Oui"])
					str = [dic objectForKey:@"Title"];
			
				[prefArray addObject:str];
			}
		}
		
		// Form the string to show
		NSMutableString *searchPreferencesStr = [NSMutableString string];
		NSUInteger count = 0;
		for (NSString *str in prefArray) 
		{
			[searchPreferencesStr appendString:str];
			if (count + 1 != prefArray.count)
				[searchPreferencesStr appendString:@", "];
			count++;
		}
		
		UILabel *label = (UILabel *)[cell viewWithTag:2];
		label.text = searchPreferencesStr;
		
		// Update background color
		cell.contentView.backgroundColor = cell.backgroundColor;
		
		return cell;
	}
	
    // Show 'Afficher' button for iPhone
    if (indexPath.row == aficherCellIndex)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AfficherCell"];
        if (cell == nil) 
        {
            [[NSBundle mainBundle] loadNibNamed:@"WAAfficherCellIphone" owner:self options:nil];
            cell = _iphoneAfficherCell;
            self.iphoneAfficherCell = nil;
        }
		
		switch (searchState) {
			case NEW_SEARCH: 
				self.aficherButton.enabled = YES;
				self.aficherButton.selected = YES;
				self.aficherButton.hidden = NO;
				break;
			case DISABLED_SEARCH:
				self.aficherButton.hidden = YES;
				self.aficherButton.selected = NO;
				self.aficherButton.hidden = YES;
				break;
			case SEARCH:
			default:
				self.aficherButton.selected = NO;
				self.aficherButton.enabled = YES;
				self.aficherButton.hidden = NO;
				break;
		}

        return cell;
    }
	
	// Decrease the index by 1 if it is iPhone and we need to show the cell with past search criteria
	NSInteger index = self.previousSearchPreferences && isIphone ? indexPath.row - 1 : indexPath.row;
    
    // Load custom cell from a nib file
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchTableCell"];
    if (cell == nil) 
    {
        [[NSBundle mainBundle] loadNibNamed:@"WASearchTableCell".device owner:self options:nil];
        cell = _searchTableCell;
        self.searchTableCell = nil;
    }
    
    NSString *title = [[self.leftTableData objectAtIndex:index] objectForKey:@"Title"];
    
    UILabel *titleLabel =               (UILabel *) [cell viewWithTag:1];
    UILabel *highlightedTitleLabel =    (UILabel *) [cell viewWithTag:2];
    UILabel *selectionDetails =         (UILabel *) [cell viewWithTag:3];
    
    titleLabel.text = title;
    highlightedTitleLabel.text = title;
    [titleLabel sizeToFit];
    [highlightedTitleLabel sizeToFit];
    
    CGRect rect = CGRectMake(titleLabel.frame.origin.x + titleLabel.bounds.size.width + 5.0, 
                             selectionDetails.frame.origin.y,
                             selectionDetails.bounds.size.width, 
                             selectionDetails.bounds.size.height);
    
    selectionDetails.frame = rect;
    
    // Selection details
    NSString *tableColumn = [[self.leftTableData objectAtIndex:index] objectForKey:@"ColName"];
    NSMutableString *searchPreferencesStr = [NSMutableString stringWithString:[self.databaseController selectionDetailForCriterion:tableColumn preferences:self.searchPreferences]];

    // Cheat to align text top left
    // Source: http://stackoverflow.com/a/2663972
    [searchPreferencesStr appendString:@"\n\n\n\n"];
    selectionDetails.text = searchPreferencesStr;
    
    [self updateSelection:cell forIndexPath:indexPath];
    
    return cell;
}


////////////////////////////////////////////////////////////////////////////////


-(void)updateSelection:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    UILabel *titleLabel =               (UILabel *)     [cell viewWithTag:1];
    UILabel *highlightedTitleLabel =    (UILabel *)     [cell viewWithTag:2];
    UIImageView *disclosureIcon =       (UIImageView *) [cell viewWithTag:4];
    
    if ([indexPath compare:self.selectedIndex] == NSOrderedSame)
    {
        titleLabel.hidden = YES;
        highlightedTitleLabel.hidden = NO;
        disclosureIcon.hidden = NO;
    }
    else
    {
        titleLabel.hidden = NO;
        highlightedTitleLabel.hidden = YES;
        disclosureIcon.hidden = YES;
    }    
}


////////////////////////////////////////////////////////////////////////////////


#pragma mark -
#pragma mark Table Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	BOOL isIphone = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone;
    //SLog(@"Did select row");
	
	// Check if a user tapped the previous search results
	if (self.previousSearchPreferences)
	{
		if ((isIphone && indexPath.row == 0) || (indexPath.row == self.leftTableData.count && !isIphone))
		{
			// Show previous search results
			self.searchPreferences = self.previousSearchPreferences;
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SearchPreferencesChanged" object:self];
			
			// Pass user search preferences to the database search method
			NSArray *results = [self.databaseController searchWithPreferences:self.searchPreferences  andKeyword:self.searchKeyword.text];
			
			if (results.count)
			{
				// Show results
				WAResultsViewController *resultsCtrl = [[[WAResultsViewController alloc]initWithNibName:@"WAResultsView".device bundle:nil]autorelease];  
				resultsCtrl.urlString = self.urlString;
				resultsCtrl.datasource = results;
				[self.pageContainerController showViewController:resultsCtrl];
				resultsCtrl.editable = NO;
				
				// Set up text labels
				resultsCtrl.titleLabel.text = @"Votre recherche";
			}
			else
			{
				UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"No results" message:@"Désolé, aucun produit ne correspond à votre demande" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil] autorelease];
				[alertView show];
			}
			
			searchState = NEW_SEARCH;
			self.aficherButton.selected = YES;
			self.aficherButton.enabled = YES;
			self.aficherButton.hidden = NO;
		}
	}

	// Decrease the index by 1 if it is iPhone and we need to show the cell with past search criteria
	NSInteger index = self.previousSearchPreferences && isIphone ? indexPath.row - 1 : indexPath.row;

	// Clicked outside of the advanced criteria
	if (index >= self.leftTableData.count || index < 0)
	{
		return;
	}
	
    // Change button states
    self.favorisButton.enabled = YES;
    self.rechercheButton.enabled = NO;
    self.lexiqueButton.enabled = YES;

    [self updateIndex:indexPath];
    
    NSString *currentPageTitle = [[self.leftTableData objectAtIndex:index] objectForKey:@"Title"];
    NSString *currentPageDatabaseColumn = [[self.leftTableData objectAtIndex:index] objectForKey:@"ColName"];
    
    if ([currentPageTitle isEqualToString:@"Prix"] || [currentPageTitle isEqualToString:@"Taille"])
    {
        // Create the special controller for this selection
        WAPrixViewController *prixController = [[[WAPrixViewController alloc]initWithNibName:@"WAPrix".device bundle:nil]autorelease]; 
        
        // Set-up user preferences
        // For 'Prix' it is a dictionary with two keys: 'mini', 'maxi'
        NSMutableDictionary *dic = [self.searchPreferences objectForKey:currentPageDatabaseColumn];
        if (!dic)
        {
            // Create such key if not present
            dic = [NSMutableDictionary dictionary];
            [self.searchPreferences setObject:dic forKey:currentPageDatabaseColumn];
        }
        prixController.minMaxValues = dic;
        
        // Show its view
        [self.pageContainerController showViewController:prixController];
        
        // Set up text labels
        prixController.titleLabel.text = currentPageTitle;
        prixController.subscriptLabel.text = [[self.leftTableData objectAtIndex:index] objectForKey:@"HeaderText"];
        prixController.miniLabel.text = [NSString stringWithFormat:@"%@ %@", currentPageTitle, prixController.miniLabel.text];
        prixController.maxiLabel.text = [NSString stringWithFormat:@"%@ %@", currentPageTitle, prixController.maxiLabel.text];
        
    }
    else
    {
        [self showTableSelectionController:index];
    }
}


////////////////////////////////////////////////////////////////////////////////


-(void)updateIndex:(NSIndexPath *)indexPath
{
    if ([indexPath compare:self.selectedIndex] != NSOrderedSame)
    {
        // Update selection status
        // Keep oldSelectedRow for while we update the old selection
        NSIndexPath *oldSelectedRow = [self.selectedIndex retain];
        self.selectedIndex = indexPath;
        UITableViewCell *cell = [self.mainTable cellForRowAtIndexPath:indexPath];
        [self updateSelection:cell forIndexPath:indexPath];
        cell = [self.mainTable cellForRowAtIndexPath:oldSelectedRow];
        [self updateSelection:cell forIndexPath:oldSelectedRow];
        [oldSelectedRow release];
    }
}


////////////////////////////////////////////////////////////////////////////////


-(void)showTableSelectionController:(NSUInteger)index
{
    NSString *currentPageDatabaseColumn = [[self.leftTableData objectAtIndex:index] objectForKey:@"ColName"];
    
    NSArray *a = [self.databaseController valuesForCriterion:currentPageDatabaseColumn];
    
    WATableSelectionController *tableSelectionCtrl = [[[WATableSelectionController alloc] initWithNibName:@"WATableSelection".device bundle:nil] autorelease];
    tableSelectionCtrl.datasource = a;
    
    // Set-up user preferences
    // For tables with selection it is an index set
    NSMutableIndexSet *indexSet = [self.searchPreferences objectForKey:currentPageDatabaseColumn];
    if (!indexSet)
    {
		// Create such key if not present
		indexSet = [NSMutableIndexSet indexSet];
		[self.searchPreferences setObject:indexSet forKey:currentPageDatabaseColumn];
    }
    
    tableSelectionCtrl.indexSet = indexSet;
    [self.pageContainerController showViewController:tableSelectionCtrl];
    
    // Update text labels
	// NB: titleLabel will must be present in iPhone to make helpButton work
    tableSelectionCtrl.titleLabel.text = [[self.leftTableData objectAtIndex:index] objectForKey:@"Title"];
    tableSelectionCtrl.subscriptLabel.text = [[self.leftTableData objectAtIndex:index] objectForKey:@"HeaderText"];
	
	// Special case: show the question button in 'Gammes'
	if ([tableSelectionCtrl.titleLabel.text isEqualToString:@"Gamme"])
	{
		tableSelectionCtrl.helpButtonEnabled = YES;
		tableSelectionCtrl.helpButtonTarget = self;
		tableSelectionCtrl.helpButtonAction = @selector(lexiqueButtonPressed:);
	}
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark - UITextFieldDelegate


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    textField.text = nil;
    [textField resignFirstResponder];
	[self.searchKeywordCollection makeObjectsPerformSelector:@selector(resignFirstResponder)];
    return YES;
}


////////////////////////////////////////////////////////////////////////////////


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (!self.fullDatabase)
        self.fullDatabase = [self.databaseController fullDatabase];
}


////////////////////////////////////////////////////////////////////////////////


- (IBAction)textFieldChanged:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    
    if (textField.text.length)
    {
        // Show pop-over if not visible
        if (!self.genericPopover.popoverVisible) 
        {
            if (!self.searchPopover)
            {
                self.searchPopover = [[[WAAdvancedSearchPopoverController alloc] initWithNibName:@"WAAdvancedSearchPopover" bundle:nil] autorelease];
                if (!self.quickSearchResults)
                    self.quickSearchResults = [NSMutableArray array];
                self.searchPopover.datasource = self.quickSearchResults;
				self.searchPopover.urlString = self.urlString;
                self.searchPopover.containerController = self.pageContainerController;
            }
            if (!self.genericPopover)
            {
                self.genericPopover = [[[WAGenericPopover alloc] initWithContentViewController:self.searchPopover] autorelease];
                self.searchPopover.genericPopover = self.genericPopover;
                self.genericPopover.delegate = self;
            }
            NSArray *passThrough = [NSArray arrayWithObject:textField];
            self.genericPopover.passthroughViews = passThrough;
			self.genericPopover.keyboardRect = self.keyboardRect;
            [self.genericPopover presentPopoverFromRect:textField.frame inView:self permittedArrowDirections:0 animated:YES];
        }

        // Perform search in three fields: Marque, Modele, Gamme
        [self.quickSearchResults removeAllObjects];
        for (NSDictionary *dic in self.fullDatabase)
        {
            NSRange range = [[dic objectForKey:@"Marque"] rangeOfString:textField.text options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound)
            {
                [self.quickSearchResults addObject:dic];
                continue;
            }
            range = [[dic objectForKey:@"Modele"] rangeOfString:textField.text options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound)
            {
                [self.quickSearchResults addObject:dic];
                continue;
            }
            range = [[dic objectForKey:@"Gamme"] rangeOfString:textField.text options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound)
            {
                [self.quickSearchResults addObject:dic];
                continue;
            }
        }
        [self.searchPopover.tableView reloadData];
    }
}


////////////////////////////////////////////////////////////////////////////////


-(void)showMarqueTab
{
    NSUInteger counter = 0;
    BOOL found = NO;
    for (NSDictionary *dic in self.leftTableData)
    {
        NSString *currentPageTitle = [dic objectForKey:@"Title"];
        if ([currentPageTitle isEqualToString:@"Marque"])
        {
            self.marqueIndex = counter;
            found = YES;
            break;
        }
        counter++;
    }
    
    // Show the Marque tab only if the data has been loaded
    if (found)
    {
        [self showTableSelectionController:self.marqueIndex];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.marqueIndex inSection:0];
        [self updateIndex:indexPath];
    }	
}


////////////////////////////////////////////////////////////////////////////////


-(void)genericPopoverClose:(WAGenericPopover*)popover
{
    [self.searchKeyword resignFirstResponder];
	[self.searchKeywordCollection makeObjectsPerformSelector:@selector(resignFirstResponder)];
}


////////////////////////////////////////////////////////////////////////////////


#pragma mark - Keyboard notifications

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGRect rect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	
	self.keyboardRect = [self convertRect:rect fromView:nil];
}


////////////////////////////////////////////////////////////////////////////////


- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
	self.keyboardRect = CGRectZero;
}
	
	
////////////////////////////////////////////////////////////////////////////////

@end
