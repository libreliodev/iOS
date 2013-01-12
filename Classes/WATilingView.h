//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import <UIKit/UIKit.h>
#import "WAPDFParser.h"


@interface WATilingView : UIView {
	WAPDFParser * pdfDocument;
    BOOL      annotates;
	int page;
}
@property (assign) BOOL annotates;
@property int page;
@property (nonatomic, assign) WAPDFParser * pdfDocument;


@end
