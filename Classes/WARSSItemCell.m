//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WARSSItemCell.h"
#import "WAUtilities.h"


@implementation WARSSItemCell



- (void) layoutSubviews
{
    [super layoutSubviews];
	self.imageView.contentMode = UIViewContentModeScaleAspectFit;
	CGRect rect = self.textLabel.frame;

	if ([WAUtilities isBigScreen]){
		//iPad Layout
		self.imageView.frame = CGRectMake(10, self.frame.size.height/10, 50, self.frame.size.height*8/10);
		
		CGFloat x = rect.origin.x;
		rect.origin.x = 80;
		rect.size.width = self.frame.size.width - (110);
		self.textLabel.frame= rect;
		self.textLabel.font = [UIFont systemFontOfSize:16];
		
		rect = self.detailTextLabel.frame;
		x = rect.origin.x;
		rect.origin.x = 80;
		rect.size.width = self.frame.size.width - (110);
		self.detailTextLabel.frame= rect;
	}
	else{
		//iPhone layout
		self.imageView.frame = CGRectMake(5, self.frame.size.height/20, 40, self.frame.size.height*18/20);//iPhone
		
		CGFloat x = rect.origin.x;
		rect.origin.x = 50;
		rect.size.width = self.frame.size.width - 80;
		self.textLabel.frame= rect;
		self.textLabel.font = [UIFont boldSystemFontOfSize:11];
		
		
		
		rect = self.detailTextLabel.frame;
		x = rect.origin.x;
		rect.origin.x = 50;
		rect.size.width = self.frame.size.width - 80;
		self.detailTextLabel.frame= rect;
		self.detailTextLabel.font = [UIFont boldSystemFontOfSize:10];
		
	}

	
	
}




@end
