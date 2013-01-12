//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.

#import <QuartzCore/QuartzCore.h>
#import "WAPDFParser.h"

@class WAPDFParser;//Required because PDFParser and PDFOperation both include each other

@interface WADrawPageOperation : NSOperation {
	WAPDFParser * pdfDocument;
	int page;
	int drawSize;
}
@property(nonatomic,retain) WAPDFParser * pdfDocument;
@property int page;
@property int drawSize;


- (void)fireNotification:(NSString*)cacheUrl;

@end