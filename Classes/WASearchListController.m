//
//  WASearchTableViewController.m
//  Librelio
//
//  Copyright (c) 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import "WASearchListController.h"
#import "WAModuleViewController.h"
#import "NSString+WAURLString.h"
#import "UIView+WAModuleView.h"
#import "UIColor+WAAdditions.h"
#import "NSBundle+WAAdditions.h"


@implementation WASearchListController

@synthesize  currentViewController,parser,presentingSearchView;


- (void)dealloc {
	[urlString release];
    [parser release];
    [currentQueryDic release];
    [super dealloc];
}

- (NSString *) urlString
{
    return urlString;
}

- (void) setUrlString: (NSString *) theString
{
    urlString = [[NSString alloc]initWithString: theString];
	
    NSString * className = [urlString classNameOfParserOfUrlString];
    Class theClass = NSClassFromString(className);
    parser =  (NSObject <WAParserProtocol> *)[[theClass alloc] init];
    parser.urlString = urlString;
    
    self.contentSizeForViewInPopover= CGSizeMake(320,480);

    

    
 	
}


- (NSDictionary *) currentQueryDic
{
    if (!currentQueryDic) self.currentQueryDic = [NSDictionary dictionaryWithObjectsAndKeys:@"Outline",@"From", nil];//Default value

    return currentQueryDic;
}

- (void) setCurrentQueryDic: (NSDictionary *) theDic
{
    if (theDic)  currentQueryDic = [[NSDictionary alloc]initWithDictionary: theDic];
	
    
	
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*- (void)viewDidLoad
{
    [super viewDidLoad];
    layoutDic = [[NSDictionary alloc] initWithDictionary:[parser getLayoutForQueryString:queryString forOrientation:999]];
   self.tableView.backgroundView = nil;//This allows the background color specified in the nib to be shown

    NSDictionary * footerLayoutDic = [layoutDic objectForKey:@"FooterView"];
    if (footerLayoutDic){
        UIView * hView = [[UIView alloc]initWithFrame:CGRectFromString([footerLayoutDic objectForKey:@"Bounds"])];
        hView.backgroundColor = [UIColor colorFromString:[footerLayoutDic objectForKey:@"BackgroundColor"]];
        self.tableView.tableFooterView = hView;
        [hView addSubViewsFromLayoutArray:[footerLayoutDic objectForKey:@"Subviews"]];
        [hView populateLayoutWithParser:parser withQueryString:queryString withButtonDelegate:self forRow:1];

  
    }
}*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //SLog(@"Count table:%i",[parser countSearchResultsForQueryDic:self.currentQueryDic ]);
    return [parser countSearchResultsForQueryDic:self.currentQueryDic ];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * identifier = [NSString stringWithFormat:@"CellSection%i",indexPath.section];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if(cell == nil) 
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];

        
        
	}
	
	cell.textLabel.text = [parser getDataAtRow:indexPath.row+1 forQueryDic:self.currentQueryDic forDataCol:DataColTitle];
    
    
    //[self  populateNibWithParser:parser  withButtonDelegate:self   forRow:row];
   /* [cell.contentView populateLayoutWithParser:parser withQueryString:queryString withButtonDelegate:self forRow:indexPath.row+1];
    
    
	*/
	
    return cell;
    
}




#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * detailLink =[parser getDataAtRow:indexPath.row+1 forQueryDic:self.currentQueryDic forDataCol:DataColDetailLink];
	NSURL * url = [NSURL URLWithString:detailLink];
	if ([url.scheme isEqualToString:@"goto"]){
		int newPage = [url.host intValue];
        [[(WAModuleViewController*)currentViewController moduleView]jumpToRow:newPage];	
    }
    else [self followDetailLink:detailLink];
    
    //iPhone Case
    [self dismissModalViewControllerAnimated:YES]; 
    
    //SLog(@"Will remove search list from superview");
    [self.presentingSearchView removeFromSuperview];

    
    
}


/**- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * detailLink =[parser getDataAtRow:indexPath.row+1 forQueryString:self.queryString forCol:@"DetailLink"];
    if (!detailLink) {
        //If no detail link was provided, display detail view
        detailLink = [queryString queryStringByReplacingClause:@"LIMIT" withValue:[NSString stringWithFormat:@"%i,1",indexPath.row]];
        detailLink = [detailLink queryStringByReplacingClause:@"FROM" withValue:@"Detail"];
    }
    
    WASearchListController * viewController = [[WASearchListController alloc]init];
    viewController.currentViewController = currentViewController;
    viewController.urlString = urlString;
    viewController.queryString = detailLink;
    viewController.title = [parser getDataAtRow:indexPath.row+1 forQueryString:self.queryString forCol:@"Title"];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
    SLog(@"Did push new table with query:%@",detailLink);


    

	WAModuleViewController * moduleViewController = [[WAModuleViewController alloc]init];
	
    NSString * currentRootModuleUrl = [(WAModuleViewController*)currentViewController moduleView].urlString;
    if ([currentRootModuleUrl isUrlStringOfSameFileAsUrlString:newUrl]){
        int row = [[newUrl valueOfParameterInUrlStringforKey:@"warow"]intValue];
        if (!row) row=1;
        [[(WAModuleViewController*)currentViewController moduleView]jumpToRow:row];
    }
    else{
        moduleViewController.moduleUrlString= newUrl ;
        moduleViewController.initialViewController= currentViewController;
        moduleViewController.containingView= self.view;
        moduleViewController.containingRect= self.view.frame;
        [moduleViewController pushViewControllerIfNeededAndLoadModuleView];
        [moduleViewController release];
        
    }
    [self dismissModalViewControllerAnimated:YES]; */


#pragma mark -
#pragma mark Btton actions
/**!
 This method is triggered by the "done" button
 */
- (void) performButtonAction:(id)sender{
    [self dismissModalViewControllerAnimated:YES];  
    
}

/**!
 This method is triggered by dynamically generated buttons
 */
- (void)buttonAction:(id)sender{
	//UIButton *button = (UIButton *)sender;
	//NSString * newUrlString = [button titleForState:UIControlStateApplication];
    //SLog(@"Will push from button new table with query:%@",newUrlString);

    WASearchListController * viewController = [[WASearchListController alloc]init];
    viewController.currentViewController = currentViewController;
    viewController.urlString = urlString;
    //viewController.queryString = newUrlString;
    //viewController.title = [parser getDataAtRow:indexPath.row+1 forQueryString:self.queryString forCol:@"Title"];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];

	//[self openModule:newUrlString inView:button.superview inRect:button.frame];
}


- (void) followDetailLink:(NSString *) detailLink{
    NSRange range = [detailLink rangeOfString:@"://"];
	if (range.location == NSNotFound){
        WASearchListController * viewController = [[WASearchListController alloc]init];
        viewController.currentViewController = currentViewController;
        viewController.urlString = urlString;
        //viewController.queryString = detailLink;
        //viewController.title = [parser getDataAtRow:indexPath.row+1 forQueryString:self.queryString forCol:@"Title"];
        [self.navigationController pushViewController:viewController animated:YES];
        [viewController release];
        //SLog(@"Did push new table with query:%@",detailLink);
        

        
    }
    else{
        WAModuleViewController * moduleViewController = [[WAModuleViewController alloc]init];
        
        moduleViewController.moduleUrlString= detailLink ;
        moduleViewController.initialViewController= currentViewController;
        moduleViewController.containingView= self.view;
        moduleViewController.containingRect= self.view.frame;
        [moduleViewController pushViewControllerIfNeededAndLoadModuleView];
        [moduleViewController release];
        [self dismissModalViewControllerAnimated:YES]; 

    }
    
    
    
}


@end
