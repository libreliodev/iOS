//
//  Copyright (c) 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import "WASearchView.h"
#import "UIView+WAModuleView.h"
#import "WASearchListController.h"
#import "WAModuleViewController.h"
#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.h"

@implementation WASearchView

@synthesize currentViewController,popover;


#pragma mark -
#pragma mark Lifecycle
- (void)dealloc {
	[urlString release];
    [popover dismissPopoverAnimated:YES];
    popover.delegate = nil;//Useful in iOS4 because otherwise the popover seems to try to release its delegate
    [popover release];
	
    [super dealloc];
}

- (NSString *) urlString
{
    return urlString;
    
}

- (void) setUrlString: (NSString *) theString
{
    urlString = [[NSString alloc]initWithString: theString];
	
     
    UINavigationController* searchNavController = [(WAModuleViewController*)currentViewController searchNavigationController];
    if (!searchNavController){
        WASearchListController * viewController = [[WASearchListController alloc]init];
        //WASearchTableViewController * viewController = [[WASearchTableViewController alloc]init];
        viewController.currentViewController = currentViewController;
        viewController.urlString = [urlString urlByChangingSchemeOfUrlStringToScheme:@"http"];

        searchNavController= [[UINavigationController alloc] initWithRootViewController:viewController];
        [(WAModuleViewController*)currentViewController setSearchNavigationController:searchNavController];
        [viewController release];
        
    }
    WASearchListController * waSearchListController = (WASearchListController *)searchNavController.topViewController;
    waSearchListController.presentingSearchView = self;

    
    if ([WAUtilities isBigScreen]){
        popover = [[UIPopoverController alloc] initWithContentViewController:searchNavController];
        //popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
        popover.delegate = self;    
          [self showPopover:popover animated:YES];
  
    }
    else {
        UIBarButtonItem * cancelB = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:waSearchListController action:@selector(performButtonAction:)];
        
        waSearchListController.navigationItem.rightBarButtonItem = cancelB;
        [currentViewController presentModalViewController:searchNavController animated:YES];
    }


	
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

#pragma mark -
#pragma mark UIPopoverControllerDelegate Protocol 

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [self removeFromSuperview];
}


@end


