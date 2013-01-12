//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WATextView.h"


@implementation WATextView

@synthesize currentViewController;


#pragma mark -
#pragma mark Lifecycle
- (void)dealloc {
	//SLog(@"Releasing textview");
	[urlString release];
	
    [super dealloc];
}

- (NSString *) urlString
{
    return urlString;
}

- (void) setUrlString: (NSString *) theString
{
    urlString = [[NSString alloc]initWithString: theString];
	//Set the text formatting
	self.editable = NO;
	self.textColor = [UIColor blackColor];
	self.font = [UIFont systemFontOfSize:10];
	
	//Set the content
	NSError *error = nil;
	NSString *desc = [NSString stringWithContentsOfFile:urlString encoding:NSUTF8StringEncoding error:&error];
	self.text = desc;
	
	
	
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
