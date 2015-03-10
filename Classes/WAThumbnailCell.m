//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WAThumbnailCell.h"


@implementation WAThumbnailCell

- (void) layoutSubviews
{
    CGFloat cellH = self.frame.size.height;
	//Remember that the table is rotated 
	[super layoutSubviews];
	CGFloat lowerImageMargin = cellH*15/100;
	CGFloat maxImageHeight = cellH*104/100;
	CGFloat maxImageWidth = cellH*98/100;
	self.imageView.frame = CGRectMake(lowerImageMargin, cellH*1/100, maxImageHeight, maxImageWidth);
	self.imageView.contentMode = UIViewContentModeScaleAspectFit;
	self.imageView.transform = CGAffineTransformMakeRotation(M_PI/2);
	self.imageView.backgroundColor = [UIColor clearColor];
	
	/*CGRect frame = self.textLabel.frame;
	frame.origin.x = 0;
	frame.size.width = self.frame.size.height;
	self.textLabel.frame= frame;*/
	self.textLabel.frame= CGRectMake(cellH*0/100,0, cellH*17/100, cellH);
	self.textLabel.font = [UIFont systemFontOfSize:12];
	self.textLabel.textAlignment = NSTextAlignmentCenter;
	self.textLabel.transform = CGAffineTransformMakeRotation(M_PI/2);
    //Depending on system version, we have a white or black nav bar
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        
        self.textLabel.textColor = [UIColor blackColor];
    }
    else{
        self.textLabel.textColor = [UIColor whiteColor];
        
    }


	self.textLabel.backgroundColor = [UIColor clearColor];
	
	
	self.detailTextLabel.hidden = YES;
	
	
}




@end
