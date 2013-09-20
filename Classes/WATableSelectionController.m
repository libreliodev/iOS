//
//  WATableSelectionController.m
//  Librelio
//
//  Created by Volodymyr Obrizan on 30.01.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import "WATableSelectionController.h"
#import "WAPageContainerController.h"

@implementation WATableSelectionController

// User interface
@synthesize titleLabel      = _titleLabel;
@synthesize subscriptLabel  = _subscriptLabel;
@synthesize tableView       = _tableView;
@synthesize tableViewCell   = _tableViewCell;
@synthesize helpButton		= _helpButton;

// Datasource
@synthesize datasource      = _datasource;
@synthesize indexSet        = _indexSet;
@synthesize helpButtonAction = _helpButtonAction;
@synthesize helpButtonTarget = _helpButtonTarget;

// The rest
@synthesize containerController = _containerController;


////////////////////////////////////////////////////////////////////////////////


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


////////////////////////////////////////////////////////////////////////////////


-(void)dealloc
{
    self.datasource = nil;
    self.indexSet = nil;
	self.helpButtonTarget = nil;
    
    [super dealloc];
}


////////////////////////////////////////////////////////////////////////////////


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Reduce section footer & header for iPad
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) 
	{
		self.tableView.backgroundView = nil;
		self.tableView.sectionHeaderHeight = -10.0;
		self.tableView.sectionFooterHeight = -10.0;
	}
	
	self.helpButton.hidden = !self.helpButtonEnabled;
}


////////////////////////////////////////////////////////////////////////////////


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.titleLabel = nil;
    self.subscriptLabel = nil;
    self.tableView = nil;
    self.tableViewCell = nil;
	self.helpButton = nil;
}


////////////////////////////////////////////////////////////////////////////////


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


////////////////////////////////////////////////////////////////////////////////


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self.tableView reloadData];
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark - UITableViewDatasource members


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}


////////////////////////////////////////////////////////////////////////////////


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Load custom cell from a nib file
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableSelectionCell"];
    if (cell == nil) 
    {
        [[NSBundle mainBundle] loadNibNamed:@"WATableSelectionCell" owner:self options:nil];
        cell = _tableViewCell;
        self.tableViewCell = nil;
    }
    
    // Set up text label
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    label.text = [self.datasource objectAtIndex:indexPath.row];
    
    // Set up checked/unchecked image
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:2];
    UIImage *checked = [UIImage imageNamed:@"table-checked.png"];
    UIImage *unchecked = [UIImage imageNamed:@"table-unchecked.png"];
    if ([self.indexSet containsIndex:indexPath.row]) 
        imageView.image = checked;
    else
        imageView.image = unchecked;
    
    return cell;    
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark - UITableViewDelegate members


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

    // Set up checked/unchecked image
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:2];
    UIImage *checked = [UIImage imageNamed:@"table-checked.png"];
    UIImage *unchecked = [UIImage imageNamed:@"table-unchecked.png"];

    // Togle the index in the collection
    if ([self.indexSet containsIndex:indexPath.row])
    {
        [self.indexSet removeIndex:indexPath.row];
        imageView.image = unchecked;
    }
    else
    {
        [self.indexSet addIndex:indexPath.row];
        imageView.image = checked;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SearchPreferencesChanged" object:self];
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark - Actions

-(IBAction)backButtonClicked:(id)sender
{
    if (self.containerController)
        [self.containerController removeSelectedViewController];
}



////////////////////////////////////////////////////////////////////////////////


-(IBAction)helpButtonClicked:(id)sender
{
	if (self.helpButtonAction && self.helpButtonTarget)
		[self.helpButtonTarget performSelector:self.helpButtonAction];
}


////////////////////////////////////////////////////////////////////////////////


-(BOOL)helpButtonEnabled
{
	return _helpButtonEnabled;
}


////////////////////////////////////////////////////////////////////////////////


-(void)setHelpButtonEnabled:(BOOL)value
{
	_helpButtonEnabled = value;
	
	self.helpButton.hidden = !_helpButtonEnabled;
}


////////////////////////////////////////////////////////////////////////////////

@end
