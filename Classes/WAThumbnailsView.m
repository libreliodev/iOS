//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WAThumbnailsView.h"
#import "WAThumbnailCell.h"
#import "WAUtilities.h"

#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.h"


@implementation WAThumbnailsView
@synthesize thumbImageViewDelegate,pdfDocument;




#pragma mark -
#pragma mark View lifecycle

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style;
{
	if ((self = [super initWithFrame:frame style:style])) {
		self.delegate = self;//UITableView delegate
		self.dataSource = self;//UITableViewDataSource delegate
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndDrawPageOperationWithNotification:) name:@"didEndDrawPageOperation" object:nil];
		self.rowHeight =  [UIScreen mainScreen].bounds.size.height*0.8*185/1024;
		self.separatorStyle = UITableViewCellSeparatorStyleNone;
		self.scrollIndicatorInsets=UIEdgeInsetsMake(0.0,0.0,0.0,[UIScreen mainScreen].bounds.size.height*185/1024-8);
		self.backgroundColor = [[UIColor darkGrayColor]colorWithAlphaComponent:0.7f];
		
	}
	return self;
}




#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    int numberOfPages = [pdfDocument countData];
    return numberOfPages;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    WAThumbnailCell *cell = (WAThumbnailCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[WAThumbnailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
	/**Code for books with pagination starting at page 3
	 if (indexPath.row==0) cell.textLabel.text = @"";
	else if (indexPath.row==1) cell.textLabel.text = @"";
	else cell.textLabel.text = [NSString stringWithFormat:@"%i",indexPath.row-1];**/
	 
	//Code for books with pagination starting at 1
	cell.textLabel.text = [NSString stringWithFormat:@"%i",indexPath.row+1];
	
	//else cell.textLabel.text = [NSString stringWithFormat:@"%i",[pdfDocument getPageNumber: indexPath.row-1]];
    NSString * imgUrlString = [pdfDocument getDataAtRow:indexPath.row+1 forDataCol:DataColImage];
    if (imgUrlString) {
        UIImage * img = [UIImage imageWithContentsOfFile:imgUrlString];            
		cell.imageView.image = img;
	}	
	else {
		UIImage * img = [UIImage imageNamed:@"Loader.png"];
		cell.imageView.image = img;
		/**Kept for future reference, if we want to animate the loader
		UIImage * img2 = [UIImage imageNamed:@"Loader2.png"];
		cell.imageView.animationImages = [NSArray arrayWithObjects:img,img2,nil];
		[cell.imageView startAnimating];**/

	}

	

    
    return cell;
}




#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.thumbImageViewDelegate thumbImageViewWasTappedAtPage:indexPath.row+1];

}


#pragma mark -
#pragma mark Memory management




- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}


#pragma mark -
#pragma mark Notifications
- (void) didEndDrawPageOperationWithNotification:(NSNotification *) notification
{
	NSString *returnedCacheUrl = notification.object;
	
	NSRange pageRange = [returnedCacheUrl rangeOfString:@"page"];
	NSRange sizeRange = [returnedCacheUrl rangeOfString:@"size"];
	NSRange pageNumberRange = NSMakeRange(pageRange.location+4, sizeRange.location-(pageRange.location+4));
	int returnedPage = [[returnedCacheUrl substringWithRange:pageNumberRange]intValue];
	NSRange sizeNumberRange = NSMakeRange(sizeRange.location+4,[returnedCacheUrl length]-(sizeRange.location+4));
	int drawSize = [[returnedCacheUrl substringWithRange:sizeNumberRange]intValue];

	NSString * returnedPdfUrl = [[WAUtilities directoryUrlOfUrlString:returnedCacheUrl]stringByReplacingOccurrencesOfString:@"_cache" withString:@".pdf"] ;
    NSString * neededPdfUrl = [pdfDocument.urlString noArgsPartOfUrlString];
    neededPdfUrl = [WAUtilities absoluteUrlOfRelativeUrl:neededPdfUrl relativeToUrl:@""];

	//Check if the returned CacheUrl corresponds to the current pdf document
	if ([returnedPdfUrl isEqualToString:neededPdfUrl]){
		NSIndexPath*indexPath = [NSIndexPath indexPathForRow:returnedPage-1 inSection:0];
		UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
		if ((cell)&&(drawSize==PDFPageViewSizeSmall)){
			UIImage * img = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathOfFileWithUrl:returnedCacheUrl]];
			cell.imageView.image = img;
			
		}
		
	}
	

	
}




@end

            
