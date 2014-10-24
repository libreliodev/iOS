//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.

#import "WADrawPageOperation.h"
#import <QuartzCore/QuartzCore.h>
#import "WAUtilities.h"
#import "WAOperationsManager.h"
#import "NSBundle+WAAdditions.h"
#import "NSString+WAURLString.h"
#import "UIImage+WAAdditions.h"



@implementation WADrawPageOperation

@synthesize pdfDocument,page,drawSize;


- (void)dealloc {
	[pdfDocument release];
    [super dealloc];
}

- (void)main
{
	
	//Check that the operation has not been cancelled, otherwise do nothing to save memory
	if (![[[WAOperationsManager sharedManager] defaultQueue] isSuspended]){
		
		//Get store URL
		NSString *fileName = [NSString stringWithFormat:@"page%isize%i.jpg",page,drawSize];
		NSString *cacheUrl = [pdfDocument.urlString urlOfCacheFileWithName:fileName]; ;

		//Double check that a cache image has not been created
		if (![[NSBundle mainBundle] pathOfFileWithUrl:cacheUrl]){
			
			//Get the image
			UIImage * img = [pdfDocument drawImageForPage:page atSize:drawSize];
			NSData * imgData = UIImageJPEGRepresentation(img,0.5);
			
			//Store it
			
			[WAUtilities storeFileWithUrlString:cacheUrl  withData:imgData];
			imgData = nil;
			
				
			//Send notification
			[self performSelectorOnMainThread:@selector(fireNotification:) withObject:cacheUrl waitUntilDone:YES];
            //SLog(@"fileName:%@" ,fileName);
            
            //If DrawSize is PDFPageViewSizeBig, resize it and store it directly
			if (drawSize == PDFPageViewSizeBig){
				NSString *fileNameSmall = [NSString stringWithFormat:@"page%isize%i.jpg",page,PDFPageViewSizeSmall];
                //SLog(@"fileNameSmall:%@" ,fileNameSmall);
				NSString *cacheUrlSmall = [pdfDocument.urlString urlOfCacheFileWithName:fileNameSmall];
				CGSize smallSize = CGSizeMake(img.size.width/8, img.size.height/8);
				UIImage * imgSmall = [img imageScaledToSize:smallSize];
				NSData * imgDataSmall = UIImageJPEGRepresentation(imgSmall,0.5);
				
				[WAUtilities storeFileWithUrlString:cacheUrlSmall  withData:imgDataSmall];
                [self performSelectorOnMainThread:@selector(fireNotification:) withObject:cacheUrlSmall waitUntilDone:YES];

				
			}

			
			
		}
		
		
	}
	
}

- (void)fireNotification:(NSString*)cacheUrl {
    //SLog(@"Will notify %@",cacheUrl);
    [WAUtilities PDFDocument:pdfDocument postNotificationForName:@"didEndDrawPageOperation" object:cacheUrl];
}



@end
