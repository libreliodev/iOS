//
//  WAResultsViewController.m
//  Librelio
//
//  Created by svp on 31.01.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import "WAResultsViewController.h"
#import "WAPageContainerController.h"
#import "WADetailsViewController.h"
#import "WADatabaseController.h"
#import "NSBundle+WAAdditions.h"
#import "NSString+WAURLString.h"

@implementation WAResultsViewController

// Constants (used as tags in UITableViewCell)

// Labels
const NSUInteger	TAG_TITLE		= 1;
const NSUInteger	TAG_MODELE		= 2;
const NSUInteger	TAG_GAMME		= 3;
const NSUInteger	TAG_BUDGET		= 4;

// Badges in rangne [TAG_BADGE_MIN, TAG_BADGE_MAX]
const NSUInteger	TAG_BADGE_MIN	= 10;
const NSUInteger	TAG_BADGE_MAX	= 13;

// Previews images
const NSUInteger	TAG_IMAGE		= 20;
const NSUInteger	TAG_IMAGE_90DEG = 21;


// User interface
@synthesize tableViewCell       = _tableViewCell;
@synthesize containerController = _containerController;
@synthesize databaseController  = _databaseController;
@synthesize tableView           = _tableView;
@synthesize titleLabel          = _titleLabel;
@synthesize modifierButton      = _modifierButton;
@synthesize marqueButton        = _marqueButton;
@synthesize gammeButton         = _gammeButton;
@synthesize prixButton          = _prixButton;
@synthesize backButton          = _backButton;

// Datasource
@synthesize datasource          = _datasource;
@synthesize urlString			= _urlString;


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
	self.backButton.hidden = NO;
    
    [super viewDidLoad];
}


////////////////////////////////////////////////////////////////////////////////


- (void)viewDidUnload
{
    [self setModifierButton:nil];
    [self setMarqueButton:nil];
    [self setGammeButton:nil];
    [self setPrixButton:nil];
    [self setTableView:nil];
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
    [[NSBundle mainBundle] loadNibNamed:@"WAResultsViewCell".device owner:self options:nil];
	UITableViewCell* cell = _tableViewCell;
	self.tableViewCell = nil;
	return cell.bounds.size.height;    
}


////////////////////////////////////////////////////////////////////////////////


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Cell elements
    UILabel *title			= nil;
    UILabel *modele			= nil;
    UILabel *gamme			= nil;
    UILabel *budget			= nil;
	
    NSMutableArray *badges = [NSMutableArray array];
	
    UIImageView *image		= nil;
    UIImageView *image90deg	= nil;

    // Load custom cell from a nib file
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MesFavorisCell"];
    if (cell == nil) 
    {
        [[NSBundle mainBundle] loadNibNamed:@"WAResultsViewCell".device owner:self options:nil];
        cell = _tableViewCell;
        self.tableViewCell = nil;
    }
    
    title	= (UILabel *) [cell viewWithTag:TAG_TITLE];
    modele	= (UILabel *) [cell viewWithTag:TAG_MODELE];
    gamme	= (UILabel *) [cell viewWithTag:TAG_GAMME];
    budget	= (UILabel *) [cell viewWithTag:TAG_BUDGET];
	
	for (NSUInteger i = TAG_BADGE_MIN; i <= TAG_BADGE_MAX; i++)
	{
		UIImageView *imgView = (UIImageView *) [cell viewWithTag:i];
		if (imgView)
		{
			imgView.image = nil;
			[badges addObject:imgView];
		}
	}
	
	image		= (UIImageView *) [cell viewWithTag:TAG_IMAGE];
	image90deg	= (UIImageView *) [cell viewWithTag:TAG_IMAGE_90DEG];
    
    NSDictionary *contentsItem = [self.datasource objectAtIndex:indexPath.row];      
    NSString *relativePathToLowResImage = [contentsItem objectForKey:@"imgLR"];
    NSString *pathToLowResImage = [WAUtilities absoluteUrlOfRelativeUrl:relativePathToLowResImage relativeToUrl:self.urlString];

    UIImage *img = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathOfFileWithUrl:pathToLowResImage]];
	
	if (image)
	{
		// Blur the image (as it is scaled from much bigger picture)
		// Source: http://stackoverflow.com/a/7775470/124115
		CGSize newSize = image.bounds.size;
		CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
		CGImageRef imageRef = img.CGImage;
		
		UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		// Set the quality level to use when rescaling
		CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
		CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
		
		CGContextConcatCTM(context, flipVertical);  
		// Draw into the context; this scales the image
		CGContextDrawImage(context, newRect, imageRef);
		
		// Get the resized image from the context and a UIImage
		CGImageRef newImageRef = CGBitmapContextCreateImage(context);
		UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
		
		CGImageRelease(newImageRef);
		UIGraphicsEndImageContext();
		
		image.image = newImage;
	}
	
	if (image90deg)
	{
		image90deg.image = img;
		
		// 4.71238898 is 90 degrees in radians
		image90deg.transform = CGAffineTransformMakeRotation(4.71238898);
	}
	
    title.text	= [[contentsItem objectForKey:@"Marque"] uppercaseString];
    modele.text	=  [contentsItem objectForKey:@"Modele"];
    gamme.text	=  [contentsItem objectForKey:@"Gamme"];
    budget.text =  [contentsItem objectForKey:@"Prix_String"];
	
	// Prepare a list with badges
    NSString *contentsPath = [[NSBundle mainBundle] pathForResource:@"contents" ofType:@"plist"];
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile: contentsPath];
	NSArray *badgesArray = [dic objectForKey:@"badges"];
    
	// Go through all badges and put to the cell if a badge is present
	NSUInteger i = 0;
	for (NSString *badgeName in badgesArray) 
	{
		NSString *imageName = [contentsItem objectForKey:badgeName];
		if (imageName && imageName.length)
		{
			UIImage *img = [UIImage imageNamed:imageName];
			if (img)
			{
				[[badges objectAtIndex:i] setImage:img];
				i++;
				if (i == ((TAG_BADGE_MAX - TAG_BADGE_MIN) + 1) || i == badges.count)
					break;
			}
		}
	}
    
    return cell;    
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark - UITableViewDelegate members


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WADetailsViewController *detailsViewController = [[[WADetailsViewController alloc] initWithNibName:@"WADetails".device bundle:nil]autorelease];
    
    // Pass the whole results set because Details View has 'previous', 'next' selectors
	detailsViewController.urlString = self.urlString;
    detailsViewController.datasource = self.datasource;
    detailsViewController.currentIndex = indexPath.row;
    [self.containerController pushViewController:detailsViewController];
}


////////////////////////////////////////////////////////////////////////////////


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    { 
        NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];    
        NSDictionary *contentsItem = [self.datasource objectAtIndex:indexPath.row]; 
        
        NSMutableArray *favorisObjects = [NSMutableArray arrayWithArray:[userDefaults objectForKey:@"FavorisObjects"]];
        [favorisObjects removeObject:[contentsItem objectForKey:@"id_modele"]];
        [userDefaults setObject:favorisObjects forKey:@"FavorisObjects"];
        self.datasource = [self.databaseController favorisForCriterion:[userDefaults objectForKey:@"FavorisObjects"]];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];     
    }   
}


////////////////////////////////////////////////////////////////////////////////


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editable)
        return UITableViewCellEditingStyleDelete;
    else
        return UITableViewCellEditingStyleNone;
}

////////////////////////////////////////////////////////////////////////////////


#pragma mark - User actions


-(IBAction)backButtonClicked:(id)sender
{
	self.tableView.dataSource = nil;
	
    if (self.containerController)
		[self.containerController removeSelectedViewController];
}


////////////////////////////////////////////////////////////////////////////////


- (IBAction)marqueButtonClicked:(id)sender 
{
    ascendingSearch = !ascendingSearch;
    
    self.marqueButton.selected = YES;
    [self.marqueButton setTitle:[self setOrderIndicator:self.marqueButton.titleLabel.text ascending:ascendingSearch] forState:UIControlStateSelected];
    self.gammeButton.selected = NO;
    self.prixButton.selected = NO;
    
    // Sort the results
    // Source: http://stackoverflow.com/a/805589
    NSArray *sortedArray;
    sortedArray = [self.datasource sortedArrayUsingComparator:^(id a, id b) {
        NSString *first = [(NSDictionary *)a objectForKey:@"Marque"];
        NSString *second = [(NSDictionary *)b objectForKey:@"Marque"];
        if (ascendingSearch)
            return [first compare:second];
        else
            return [second compare:first];
    }];
    
    self.datasource = sortedArray;
    [self.tableView reloadData];
}


////////////////////////////////////////////////////////////////////////////////


- (IBAction)gammeButtonClicked:(id)sender 
{
    ascendingSearch = !ascendingSearch;
    
    self.marqueButton.selected = NO;
    self.gammeButton.selected = YES;
    [self.gammeButton setTitle:[self setOrderIndicator:self.gammeButton.titleLabel.text ascending:ascendingSearch] forState:UIControlStateSelected];
    self.prixButton.selected = NO;
    
    // Sort the results
    // Source: http://stackoverflow.com/a/805589
    NSArray *sortedArray;
    sortedArray = [self.datasource sortedArrayUsingComparator:^(id a, id b) {
        NSString *first = [(NSDictionary *)a objectForKey:@"Gamme"];
        NSString *second = [(NSDictionary *)b objectForKey:@"Gamme"];
        if (ascendingSearch)
            return [first compare:second];
        else
            return [second compare:first];
    }];
    
    self.datasource = sortedArray;
    [self.tableView reloadData];
}


////////////////////////////////////////////////////////////////////////////////


- (IBAction)prixButtonClicked:(id)sender 
{
    ascendingSearch = !ascendingSearch;
    
    self.marqueButton.selected = NO;
    self.gammeButton.selected = NO;
    self.prixButton.selected = YES;
    [self.prixButton setTitle:[self setOrderIndicator:self.prixButton.titleLabel.text ascending:ascendingSearch] forState:UIControlStateSelected];
    
    // Sort the results
    // Source: http://stackoverflow.com/a/805589
    NSArray *sortedArray;
    sortedArray = [self.datasource sortedArrayUsingComparator:^(id a, id b) {
        NSNumber *first = [NSNumber numberWithFloat:[[(NSDictionary *)a objectForKey:@"Prix_de_reference"] floatValue]];
        NSNumber *second = [NSNumber numberWithFloat:[[(NSDictionary *)b objectForKey:@"Prix_de_reference"] floatValue]];
        if (ascendingSearch)
            return [first compare:second];
        else
            return [second compare:first];
    }];
    
    self.datasource = sortedArray;
    [self.tableView reloadData];
}


////////////////////////////////////////////////////////////////////////////////


-(IBAction)modifierButtonClicked:(id)sender
{
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}


////////////////////////////////////////////////////////////////////////////////


-(BOOL)editable
{
    return _editable;
}


////////////////////////////////////////////////////////////////////////////////


-(void)setEditable:(BOOL)editable
{
    _editable = editable;
    self.modifierButton.hidden = !editable;
    self.tableView.editing = editable;
}


////////////////////////////////////////////////////////////////////////////////


# pragma mark - Supporting mehtods

-(NSString *)removeOrderIndicator:(NSString *)title
{
    return [[title componentsSeparatedByString:@" "] objectAtIndex:0];
}


////////////////////////////////////////////////////////////////////////////////


-(NSString *)setOrderIndicator:(NSString *)title ascending:(BOOL)ascending
{
    return [NSString stringWithFormat:@"%@ %@", [self removeOrderIndicator:title], (ascending ? @"▲" : @"▼")];
}


////////////////////////////////////////////////////////////////////////////////


- (void)dealloc 
{
    [_modifierButton release];
    [_marqueButton release];
    [_gammeButton release];
    [_prixButton release];
    [_tableView release];
	
	self.datasource = nil;
	self.urlString = nil;
	self.databaseController = nil;
	
    [super dealloc];
}


////////////////////////////////////////////////////////////////////////////////

@end