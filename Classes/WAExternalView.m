//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WAExternalView.h"
#import "WAUtilities.h"
#import "WAModuleViewController.h"
#import "NSBundle+WAAdditions.h"




@implementation WAExternalView

@synthesize currentViewController;

- (NSString *) urlString
{
    return urlString;
}

- (void) setUrlString: (NSString *) theString
{
	
	urlString = [[NSString alloc]initWithString: theString];

	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Do you really want to quit this app?",@"" ) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",@"" ) otherButtonTitles:nil] autorelease];
    // optional - add more buttons:
    [alert addButtonWithTitle:NSLocalizedString(@"Yes",@"" )];
    [alert show];
	
	
	
	


	

}




- (void)dealloc {
	[urlString release];
    [super dealloc];
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

#pragma mark -
#pragma mark UIAlertView protocol

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
		{
			[self removeFromSuperview];
			break;
		}
		case 1:
		{
			NSURL * newUrl = [NSURL URLWithString:urlString];
			[[UIApplication sharedApplication] openURL:newUrl];
			[self removeFromSuperview];

			break;
		}

		default:
		{
			//
		}
	}
}

- (void) jumpToRow:(int)row{
    
}



@end

