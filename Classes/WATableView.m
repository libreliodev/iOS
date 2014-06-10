

#import "WATableView.h"
#import "WAModuleViewController.h"
#import "NSString+WAURLString.h"
#import "UIView+WAModuleView.h"
#import "UIColor+WAAdditions.h"
#import "UIImage+WAAdditions.h"
#import "NSBundle+WAAdditions.h"
#import "WAUtilities.h"


@implementation WATableView


@synthesize currentViewController,parser,refreshControl;

#pragma mark -
#pragma mark Lifecycle

- (id)init {
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moduleViewDidAppear) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishDownloadWithNotification:) name:@"didSucceedResourceDownload" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishDownloadWithNotification:) name:@"didFailIssueDownload" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishDownloadWithNotification:) name:@"didSuccedIssueDownload" object:nil];
        
        
        
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter]removeObserver:self];
	[urlString release];
    [parser release];
    [currentQueryDic release];
    [refreshControl release];
	
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
    self.rowHeight = 120;    //NSString * queryStringInUrl = [urlString valueOfParameterInUrlStringforKey:@"waquery"];
    //if (queryStringInUrl) self.currentQueryDic = queryStringInUrl;
    
    [self initParser];
    
    //Refresh
    //Add refresh view if waupdate parameter was present
    NSString * mnString = [urlString valueOfParameterInUrlStringforKey:@"waupdate"];
    if (mnString){
        
        refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.backgroundColor = [UIColor whiteColor];
        [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:refreshControl];
    }
    

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
    NSString * identifier = [NSString stringWithFormat:@"CellSection%li",(long)indexPath.section];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if(cell == nil) 
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
	}
	cell.textLabel.text = [parser getDataAtRow:(int)indexPath.row+1 forDataCol:DataColTitle];
    cell.textLabel.textColor = [UIColor colorWithRed:0.0627  green:0.4863 blue:0.9647 alpha:1];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",[parser getDataAtRow:(int)indexPath.row+1 forDataCol:DataColDate],[parser getDataAtRow:(int)indexPath.row+1 forDataCol:DataColSubTitle]];
    cell.detailTextLabel.numberOfLines = 3;


    NSString * imageUrlString = [parser getDataAtRow:(int)indexPath.row+1 forDataCol:DataColImage];
    //SLog(@"Should show image %@",imageUrlString);
    cell.imageView.image = [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathOfFileWithUrl:imageUrlString]]squareImageWithSize:CGSizeMake(100,100)] ;
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
    NSString * detailLink =[parser getDataAtRow:(int)indexPath.row+1 forDataCol:DataColDetailLink];
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
}

- (void) moduleViewDidAppear{
    //SLog(@"grid moduleview did appear");
    //Check wether an update of the source data is needed 
    WAModuleViewController * moduleViewController = (WAModuleViewController *) [self traverseResponderChainForUIViewController];
    [moduleViewController checkUpdateIfNeeded];
    
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

- (void) didFinishDownloadWithNotification:(NSNotification *) notification{
    
    NSString *notificatedUrl = notification.object;
    //SLog(@"notification.object:%@",notification.object);
    if ([notificatedUrl respondsToSelector:@selector(noArgsPartOfUrlString)]){
        if ([[notificatedUrl noArgsPartOfUrlString]isEqualToString:[urlString noArgsPartOfUrlString]])     [self reloadData];
    }
    
    [refreshControl endRefreshing];
    
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    WAModuleViewController *vc = (WAModuleViewController *)[self firstAvailableUIViewController];
    [vc checkUpdate:YES];
}


@end


