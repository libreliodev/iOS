#import "WAAdView.h"
#import "UIColor+WAAdditions.h"
#import "UIView+WAModuleView.h"
#import "WAModuleViewController.h"
#import "WAUtilities.h"
#import "WAOperationsManager.h"

#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.h"

//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


@implementation WAAdView

@synthesize currentViewController;



- (NSString *) urlString
{
    return urlString;
}

- (void) setUrlString: (NSString *) theString
{
    if (urlString){
		//Do nothing
		
		
	}
	else {
		//Do once only
		urlString = [[NSString alloc]initWithString: theString];
        self.rootViewController = currentViewController;
        
        NSDictionary * app_Dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathOfFileWithUrl:@"Application_.plist"]];
        NSString * DfpPrefix = [app_Dic objectForKey:@"DfpPrefix"];
        if (DfpPrefix){
            NSString * shortUnitId = [[urlString noArgsPartOfUrlString] lastPathComponent];
            self.adUnitID = [DfpPrefix completeAdUnitCodeForShortCode:shortUnitId];
            [self loadRequest:[GADRequest request]];
            
            
       }

 
    }
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

- (void) jumpToRow:(int)row{
    
}

@end
