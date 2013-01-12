//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WALabelView.h"


@implementation WALabelView

@synthesize currentViewController;

#pragma mark -
#pragma mark Lifecycle

- (NSString *) urlString
{
    return urlString;
}

- (void)dealloc {
	[urlString release];
	
    [super dealloc];
}

- (void) setUrlString: (NSString *) theString
{
    urlString = [[NSString alloc]initWithString: theString];
	/*NSString * labelText = [urlString stringByReplacingOccurrencesOfString:@"label://" withString:@""];
	self.text = labelText;*/
}

- (void) layoutSubviews
{
	UIFont * newFont = [self.font fontWithSize:self.frame.size.height/1.5];
	self.font = newFont;
	[super layoutSubviews];
	
	
}

#pragma mark -
#pragma mark ModuleView protocol

- (void)moduleViewWillAppear:(BOOL)animated{
}

- (void) moduleViewDidAppear{
}


- (void) moduleViewWillDisappear:(BOOL)animated{
}



- (void) moduleWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
}

- (void) moduleWillAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
}

- (void) jumpToRow:(int)row{
    
}

@end
