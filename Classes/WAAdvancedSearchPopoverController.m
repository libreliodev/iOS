//
//  WAAdvancedSearchPopoverController.m
//  Librelio
//
//  Created by svp on 13.02.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import "WAAdvancedSearchPopoverController.h"
#import "WADetailsViewController.h"
#import "NSString+WAURLString.h"
#import "WAGenericPopover.h"

@implementation WAAdvancedSearchPopoverController

// User interface
@synthesize containerController = _containerController;
@synthesize tableView           = _tableView;
@synthesize tableViewCell       = _tableViewCell;

// Datasource
@synthesize datasource          = _datasource;
@synthesize urlString			= _urlString;

@synthesize genericPopover      = _genericPopover;


////////////////////////////////////////////////////////////////////////////////


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)dealloc
{
	self.datasource = nil;
	self.urlString = nil;
	
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
    
}


////////////////////////////////////////////////////////////////////////////////


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


////////////////////////////////////////////////////////////////////////////////


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

////////////////////////////////////////////////////////////////////////////////



#pragma mark - UITableViewDatasource members

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.datasource count];
}


////////////////////////////////////////////////////////////////////////////////


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSBundle mainBundle] loadNibNamed:@"WAAdvancedSearchPopoverCell".device owner:self options:nil];
    UITableViewCell* cell = _tableViewCell;
    self.tableViewCell = nil;
    return cell.bounds.size.height;    
}

////////////////////////////////////////////////////////////////////////////////


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Load custom cell from a nib file
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WAAdvancedSearchPopoverCell"];
    if (cell == nil) 
    {
        [[NSBundle mainBundle] loadNibNamed:@"WAAdvancedSearchPopoverCell".device owner:self options:nil];
        cell = _tableViewCell;
        self.tableViewCell = nil;
    }
    // Configure the cell...
    UILabel* titleLabel;
    UILabel* descriptionModele;
    UILabel* descriptionGamme;
    UILabel* descriptionBudget;       
    
    titleLabel = (UILabel *) [cell viewWithTag:1];
    descriptionModele = (UILabel *)[cell viewWithTag:2];
    descriptionGamme = (UILabel *)[cell viewWithTag:3];
    descriptionBudget = (UILabel *)[cell viewWithTag:4];
    
    
    NSDictionary *contentsItem = [self.datasource objectAtIndex:indexPath.row];      
    
    titleLabel.text = [[contentsItem objectForKey:@"Marque"] uppercaseString];
    descriptionModele.text = [contentsItem objectForKey:@"Modele"];
    descriptionGamme.text = [contentsItem objectForKey:@"Gamme"];
    
    NSString *price = [contentsItem objectForKey:@"Prix_String"];
    descriptionBudget.text = price;
    
    return cell;    
}


////////////////////////////////////////////////////////////////////////////////


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WADetailsViewController *detailsViewController = [[[WADetailsViewController alloc] initWithNibName:@"WADetails".device bundle:nil]autorelease];    
    detailsViewController.datasource = self.datasource;
	detailsViewController.urlString = self.urlString;
    detailsViewController.currentIndex = indexPath.row;  
    [self.containerController pushViewController:detailsViewController];
    [self.genericPopover dismissPopoverAnimated:YES];
}


////////////////////////////////////////////////////////////////////////////////



@end
