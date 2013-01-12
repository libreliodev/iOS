//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WAFileManagerCell.h"
#import "WAUtilities.h"


@implementation WAFileManagerCell



- (void) layoutSubviews 
{
	[WAUtilities resizeNibView:@"WAFileManagerCell" defaultNib:nil inView:self.contentView];//Resize the nib
    [super layoutSubviews];
	
	
}




@end
