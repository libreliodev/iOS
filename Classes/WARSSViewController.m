//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WARSSViewController.h"

#import "WARSSItemCell.h"
#import "WAUtilities.h"




#pragma mark -


@implementation WARSSViewController

@synthesize dataDic;
@synthesize imageDownloadsInProgress;
@synthesize headerView;
@synthesize headerLabel;
@synthesize headerImageView;
@synthesize navigController;


#pragma mark 

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
	
	
	//Prevent bouncing otherwise we also have horizontal bouncing for some reason
	self.tableView.bounces = NO;
	
	
	//Build the header View
	headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 110)];
	headerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
    headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
	headerLabel.text = [dataDic objectForKey:@"HeaderTitle"];
	headerLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
 	headerLabel.textAlignment =   NSTextAlignmentCenter;
	headerLabel.font = [UIFont boldSystemFontOfSize:20];//iPad
	if (![WAUtilities isBigScreen]) 	headerLabel.font = [UIFont boldSystemFontOfSize:14];//iPhone
    headerLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:headerLabel];
	
	headerImageView= [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-30, 40, 60, 60)];
	headerImageView.contentMode = UIViewContentModeScaleAspectFit;
	headerImageView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin);
	[self startIconDownloadAtURL:[dataDic objectForKey:@"HeaderIcon"] forIndexPath:nil];
    [headerView addSubview:headerImageView];
    self.tableView.tableHeaderView = headerView;
	
 	
	
	
	
	
	
}





- (void)dealloc
{
	[headerView release];
	[headerLabel release];
	[headerImageView release];
	[dataDic release];
	[imageDownloadsInProgress release];
	[navigController release];
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
}

#pragma mark -
#pragma mark Table view creation (UITableViewDataSource)

// customize the number of rows in the table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int count = (int)[[self.dataDic objectForKey:@"ItemsArray"] count];
	
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    WARSSItemCell *cell = (WARSSItemCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[WARSSItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.numberOfLines = 3;
    }
	if ([[dataDic objectForKey:@"ItemsArray"]  count]){
		// Set up the cell...
		NSDictionary * tempDic = [[dataDic objectForKey:@"ItemsArray"] objectAtIndex:indexPath.row];
        
		cell.textLabel.text = [tempDic objectForKey:@"ItemTextLabel"];
		
		//Get the date
		/**NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
		[formatter setDateStyle:NSDateFormatterMediumStyle];
		[formatter setTimeStyle:NSDateFormatterMediumStyle];
		NSString * tempText = [formatter stringFromDate:[tempDic objectForKey:@"Date"]];	
		cell.detailTextLabel.text = [NSString stringWithFormat:@"Posted: %@",tempText];
		[formatter release];**/
		cell.detailTextLabel.text = [tempDic objectForKey:@"ItemDetailTextLabel"];
		cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
		if (![tempDic objectForKey:@"Image"])
        {
 				if ([tempDic objectForKey:@"ImageURL"]) [self startIconDownloadAtURL:[tempDic objectForKey:@"ImageURL"] forIndexPath:indexPath];
        }
        else
        {
			cell.imageView.image = [tempDic objectForKey:@"Image"];
        }


	}
     
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat ret = (self.view.frame.size.height-headerView.frame.size.height)/5;//iPad
	if (![WAUtilities isBigScreen]) ret = 70.0;//iPhone
	return ret;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	//NSString * storyLink = [[[dataDic objectForKey:@"ItemsArray"] objectAtIndex: indexPath.row] objectForKey: @"ItemLink"];

	UIWebView *webViewController = [[UIWebView alloc] init];
	//webViewController.urlString = storyLink;
	//[self.navigController pushViewController:webViewController animated:YES];
	[webViewController release];
}

#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownloadAtURL:(NSString *)imageURL forIndexPath:(NSIndexPath *)indexPath
{
    WAIconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil) 
    {
        iconDownloader = [[WAIconDownloader alloc] init];
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
		iconDownloader.URLString = imageURL;
        if (indexPath) [imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
        [iconDownloader release];   
    }
}


#pragma mark -
#pragma mark ImageDownloader delegate methods
- (void)itemImageDidLoad:(UIImage *)img forIndex:(NSIndexPath *)indexPath;
{
	if (indexPath) {
		//This is an image for one of the entries
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        // Display the newly loaded image
		cell.imageView.contentMode =  UIViewContentModeScaleAspectFit;
        cell.imageView.image = img;
		[[[dataDic objectForKey:@"ItemsArray"] objectAtIndex:indexPath.row]setObject:img forKey:@"Image"];
	}
	else{
		//This is the header image
		headerImageView.image = img;
	}
}


#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

@end