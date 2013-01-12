//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


@class AppRecord;
@class WAZoomViewController;

@protocol IconDownloaderDelegate 

- (void)itemImageDidLoad:(UIImage *)img forIndex:(NSIndexPath *)indexPath;

@end

@interface WAIconDownloader : NSObject
{
     NSIndexPath *indexPathInTableView;
	NSString * URLString;
    id <IconDownloaderDelegate> delegate;
    
	UIImage *appIcon;
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
}

@property (nonatomic, retain) 	NSString * URLString;
@property (nonatomic, retain) UIImage *appIcon;
@property (nonatomic, retain) NSIndexPath *indexPathInTableView;
@property (nonatomic, assign) id <IconDownloaderDelegate> delegate;

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;

- (void)startDownload;
- (void)cancelDownload;

@end

