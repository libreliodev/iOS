//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import <UIKit/UIKit.h>
#import "WAIconDownloader.h"

@interface WARSSViewController : UITableViewController <UIScrollViewDelegate, IconDownloaderDelegate>
{
	NSDictionary *dataDic;   // the main data model for our UITableView
    NSMutableDictionary *imageDownloadsInProgress;  // the set of IconDownloader objects for each entry
	UIView *headerView;
	UILabel *headerLabel;
	UIImageView *headerImageView;
	UINavigationController * navigController;


	
}

@property (nonatomic, retain) NSDictionary *dataDic;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) UILabel *headerLabel;
@property (nonatomic, retain) UIImageView *headerImageView;
@property (nonatomic, retain) UINavigationController * navigController;


- (void)startIconDownloadAtURL:(NSString *)imageURL forIndexPath:(NSIndexPath *)indexPath;


@end