

#import "WATableView.h"
#import "WAModuleViewController.h"
#import "NSString+WAURLString.h"
#import "UIView+WAModuleView.h"
#import "UIColor+WAAdditions.h"
#import "NSBundle+WAAdditions.h"
#import "WAUtilities.h"


@implementation WATableView


@synthesize currentViewController,parser;

#pragma mark -
#pragma mark Lifecycle

- (id)init {
	if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSucceedResourceDownloadWithNotification:) name:@"didSucceedResourceDownload" object:nil];
        
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter]removeObserver:self];
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
    //SLog(@"WAtableview OK with Url:%@",theString);
    urlString = [[NSString alloc]initWithString: theString];
	self.delegate = self;//UITableView delegate
	self.dataSource = self;//UITableViewDataSource delegate
    
    //NSString * queryStringInUrl = [urlString valueOfParameterInUrlStringforKey:@"waquery"];
    //if (queryStringInUrl) self.currentQueryDic = queryStringInUrl;
    
    [self initParser];

}

- (NSDictionary *) currentQueryDic
{
    return currentQueryDic;
}

- (void) setCurrentQueryDic: (NSDictionary *) theDic
{
    currentQueryDic = [[NSDictionary alloc]initWithDictionary: theDic];
	
    
	
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //SLog(@"Number of sections: %i",[[layoutDic objectForKey:@"SectionViews" ]count]);
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [parser countSearchResultsForQueryDic:self.currentQueryDic];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * identifier = [NSString stringWithFormat:@"CellSection%i",indexPath.section];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if(cell == nil) 
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
	}
	cell.textLabel.text = [parser getDataAtRow:indexPath.row+1 forDataCol:DataColTitle];
    cell.detailTextLabel.text = [parser getDataAtRow:indexPath.row+1 forDataCol:DataColSubTitle];

    NSString * imageUrlString = [parser getDataAtRow:indexPath.row+1 forDataCol:DataColImage];
    //SLog(@"Should show image %@",imageUrlString);
    cell.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathOfFileWithUrl:imageUrlString]];
    //cell.imageView.image = [UIImage imageNamed:@"Default.png"];
	
	
    return cell;
    
}



/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * detailLink =[parser getDataAtRow:indexPath.row+1 forDataCol:DataColDetailLink];
   /* if (!detailLink) {
        //If no detail link was provided, display detail view
        detailLink = [queryString queryStringByReplacingClause:@"LIMIT" withValue:[NSString stringWithFormat:@"%i,1",indexPath.row]];
        detailLink = [detailLink queryStringByReplacingClause:@"FROM" withValue:@"Detail"];
    }*/
    [self followDetailLink:detailLink];
     
    
    
}




#pragma mark -
#pragma mark ModuleView protocol

- (void)moduleViewWillAppear:(BOOL)animated{
    //WAModuleViewController *vc = (WAModuleViewController *)[self firstAvailableUIViewController];
    
    //NSString * searchLink = [parser getHeaderForDataCol:@"SearchLink"];
    //NSString * searchLink = @"search://localhost/testskis2012/Guide_.sqlite";
    //SLog(@"SearchLink:%@",searchLink);
    /*if (searchLink) {
        [vc addButtonWithBarButtonSystemItem:UIBarButtonSystemItemSearch andLink:searchLink];
    }*/
    /*NSString * shareLink = [parser getHeaderForDataCol:@"ShareLink"];
    if (shareLink) {
        [vc addButtonWithBarButtonSystemItem:UIBarButtonSystemItemAdd andLink:shareLink];
    }*/

}

- (void) moduleViewDidAppear{
    //SLog(@"grid moduleview did appear");
    //Check wether an update of the source data is needed 
    WAModuleViewController * moduleViewController = (WAModuleViewController *) [self traverseResponderChainForUIViewController];
    [moduleViewController checkUpdate];
    
    //Update the table
    [self initParser];
    [self reloadData];
    
}


- (void) moduleViewWillDisappear:(BOOL)animated{
}



- (void) moduleWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
}

- (void) moduleWillAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
}

- (void) jumpToRow:(int)row{
    
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


#pragma mark -
#pragma mark Helper methods

- (void) initParser{
    NSString * className = [urlString classNameOfParserOfUrlString];
    Class theClass = NSClassFromString(className);
    parser =  (NSObject <WAParserProtocol> *)[[theClass alloc] init];
    parser.urlString = urlString;
    
}


- (void) followDetailLink:(NSString *) detailLink{
    NSRange range = [detailLink rangeOfString:@"://"];
	if (range.location == NSNotFound){
        //Transform detailLink into a URL
        detailLink = [urlString urlByAddingParameterInUrlStringWithKey:@"waquery" withValue:detailLink];
        
    }
	WAModuleViewController * moduleViewController = [[WAModuleViewController alloc]init];
    
    moduleViewController.moduleUrlString= detailLink ;
    moduleViewController.initialViewController= currentViewController;
    moduleViewController.containingView= self;
    moduleViewController.containingRect= self.frame;
    [moduleViewController pushViewControllerIfNeededAndLoadModuleView];
    [moduleViewController release];
    
    
 
}

- (void) didSucceedResourceDownloadWithNotification:(NSNotification *) notification{
    
    //SLog(@"didSucceedResourceDownload");
    NSString *notificatedUrl = notification.object;
    if ([[notificatedUrl noArgsPartOfUrlString]isEqualToString:[urlString noArgsPartOfUrlString]])     [self reloadData];
    
}




@end


