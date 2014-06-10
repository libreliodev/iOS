//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import "WAFileManager.h"
#import "WAModuleViewController.h"
#import "WAFileManagerCell.h"
#import "WALocalParser.h"

#import "UIView+WAModuleView.h"
#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.h"

#import "WAUtilities.h"

@implementation WAFileManager

@synthesize dataArray,currentViewController,parser;


#pragma mark -
#pragma mark View lifecycle

- (NSString *) urlString
{
    return urlString;
}

- (void) setUrlString: (NSString *) theString

{
	if (!urlString){
		urlString = [[NSString alloc]initWithString: theString];
		self.delegate = self;//UITableView delegate
		self.dataSource = self;//UITableViewDataSource delegate
		
		//Define rowHeight
		UIView * nibView = [UIView getNibView:[urlString nameOfFileWithoutExtensionOfUrlString] defaultNib:@"WAFileManagerCell" forOrientation:999];
		CGFloat tempRowHeight = nibView.frame.size.height;
		//Check if we need to adjust the hight, based on the contentMode of nibView
		CGRect tempRect = CGRectMake(0, 0, self.frame.size.width, tempRowHeight);
		CGSize newSize = [WAUtilities sizeForResizedNibView :[urlString nameOfFileWithoutExtensionOfUrlString] defaultNib:@"WAFileManagerCell" inRect:tempRect];
		self.rowHeight = newSize.height;
		
		parser = [[WALocalParser alloc]init];
		parser.urlString = urlString;
		
		
		
	}
	else {
		urlString = [[NSString alloc]initWithString: theString];
		
	}
	self.editing = YES;
	self.allowsSelectionDuringEditing = YES;
	
	
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [parser countData];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[WAFileManagerCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		UIView * nibView = [UIView getNibView:[urlString nameOfFileWithoutExtensionOfUrlString] defaultNib:@"WAFileManagerCell" forOrientation:999];
		[cell.contentView addSubview:nibView];
	}

	cell.textLabel.hidden = YES;//Hide the standard textLabel view, otherwise our custom subviews get hiddeen

	UIView * nibView = [[cell.contentView subviews]objectAtIndex:0];//Get  our Nib View
	
	[nibView populateNibWithParser:parser withButtonDelegate:self   forRow:(int)indexPath.row+1];
	
	
    return cell;
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		[parser deleteDataAtRow:(int)indexPath.row];
		//SLog(@"Deleted tata in parser, now %i lines",[parser countData]);
       [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}





#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = (int)indexPath.row+1;
	NSString * newUrlString = [parser getDataAtRow:row forDataCol:DataColDetailLink];
	
	WAModuleViewController * loadingViewController = [[WAModuleViewController alloc]init];
	loadingViewController.moduleUrlString= [WAUtilities absoluteUrlOfRelativeUrl:newUrlString relativeToUrl:urlString] ;
    //SLog(@"Should load %@",[WAUtilities absoluteUrlOfRelativeUrl:newUrlString relativeToUrl:urlString]);
	loadingViewController.initialViewController= self.currentViewController;
	loadingViewController.containingView= self;
	loadingViewController.containingRect= CGRectZero;
	[loadingViewController pushViewControllerIfNeededAndLoadModuleView];
	[loadingViewController release];
	
}

#pragma mark -
#pragma mark UITableView methods
- (void) reloadData{
    //SLog(@"Will reload data");
    [super reloadData];
    
    //Remove previously added modules
    NSArray * subViewsArray =[self subviews];
    for (UIView * subView in subViewsArray){
        if ([subView conformsToProtocol:@protocol(WAModuleProtocol)]) [subView removeFromSuperview];
    }
    if (![parser countData]){
        //If the is no data, display an html message
        
        //Conventionally, the message html file has the same name as the main file, with the html extension; find the corresponding url;
        NSString * htmlMessageUrl = [[urlString noArgsPartOfUrlString] urlByChangingSchemeOfUrlStringToScheme:@"http"];
        htmlMessageUrl = [WAUtilities urlByChangingExtensionOfUrlString:htmlMessageUrl toSuffix:@".html?warect=self"];
        //Check if html file exists locally
        if ([[NSBundle mainBundle] pathOfFileWithUrl:htmlMessageUrl]){
            WAModuleViewController * moduleViewController = [[WAModuleViewController alloc]init];
            
            //Load the html module
            moduleViewController.moduleUrlString= htmlMessageUrl ;
            moduleViewController.initialViewController= currentViewController;
            moduleViewController.containingView= self;
            moduleViewController.containingRect= self.frame;
            [moduleViewController pushViewControllerIfNeededAndLoadModuleView];
            [moduleViewController release];
 
        }
        
        
    }
}


#pragma mark -
#pragma mark ModuleView protocol

- (void)moduleViewWillAppear:(BOOL)animated{
}

- (void) moduleViewDidAppear{
	//Create a new parser, in case there have been updates
	[parser release];
	parser = [[WALocalParser alloc]init];
	parser.urlString = urlString;

	
	[self reloadData];//Repopulate table
}

- (void) moduleViewWillDisappear:(BOOL)animated{
}



- (void) moduleWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
}

- (void) moduleWillAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	[self reloadData];//Repopulate table

}
- (void) jumpToRow:(int)row{
    
}


#pragma mark -
#pragma mark Memory management


- (void)dealloc {
	[parser release];
	[urlString release];
	[dataArray release];
    [super dealloc];
}


@end

