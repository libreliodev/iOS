//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.

#import "WASkyView.h"
#import "WAUtilities.h"
#import "WAModuleViewController.h"
#import "UIView+WAModuleView.m"
#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#import "FileProvider.h"



@implementation WASkyView

@synthesize currentViewController,rvc,as;


- (NSString *) urlString
{
    return urlString;
}

- (void) setUrlString: (NSString *) theString
{
    if (!urlString){
        NSLog(@"Starting epub");
		urlString = [[NSString alloc]initWithString: theString];
		//Initial setup is needed

        // Create ReflowableViewController and set the start position at 0.0f.
        rvc = [[ReflowableViewController alloc]initWithStartPagePositionInBook:0.0f];
        NSLog(@"rvc started");
        // set that this view is for Reflowable Layout not Fixed Layout.
        rvc.book.isFixedLayout = NO;
        // set the default font name and size.
        rvc.book.fontName = @"TimesRoman";
        rvc.book.fontSize = 15;
        // set the name of epub file.
        //rvc.book.fileName = [[urlString  noArgsPartOfUrlString] lastPathComponent];
        rvc.book.fileName = @"Alice.epub";
        // set the base directory.
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *baseDirectory = [NSString stringWithFormat:@"%@/%@",documentsDirectory,@"books"];
        rvc.baseDirectory = baseDirectory;
        // set the page transition type.
        // PageTransitionNone  0
        // PageTransitionSlide 1
        // PageTransitionCurl  2
        rvc.transitionType = 2;
        // set ContentProvider class to deliver contents to engine.
        [rvc setContentProviderClass:[FileProvider self]];
        // set the dataSource for ReflowableViewController
        rvc.dataSource = self;
        // set the delegate for ReflowableViewController
        rvc.delegate =self;
        // insert ReflowableViewController into BookViewController.
        rvc.view.frame = self.bounds;
        rvc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:rvc.view];
        self.autoresizesSubviews = YES;
        // Create ActionSheet to show up when text is selected by customer.
        // this can be replaced customized user interface.
        as = [[UIActionSheet alloc] initWithTitle:@"Select Action"
                                         delegate:self
                                cancelButtonTitle:@"Cancel"
                           destructiveButtonTitle:nil
                                otherButtonTitles:@"Highlight", @"Note",nil];

 		
		
        //Tracking
        NSString * viewString = [urlString gaScreenForModuleWithName:@"Epub" withPage:nil];
        // May return nil if a tracker has not already been initialized with a
        // property ID.
        id tracker = [[GAI sharedInstance] defaultTracker];
        
        // This screen name value will remain set on the tracker and sent with
        // hits until it is set to a new value or to nil.
        [tracker set:kGAIScreenName
               value:viewString];
        
        [tracker send:[[GAIDictionaryBuilder createAppView] build]];
        
		
		
		
	}
	else {
		urlString = [[NSString alloc]initWithString: theString];

	}

	
	
}

- (void) dealloc
{
	[urlString release];
    [rvc release];
    [as release];
    [super dealloc];
}


#pragma mark -
#pragma mark ModuleView protocol

- (void)moduleViewWillAppear:(BOOL)animated{
    

    
    

}

- (void) moduleViewDidAppear{
    //SLog(@"grid moduleview did appear, should check update");
    //Check wether an update of the source data is needed 
    WAModuleViewController * moduleViewController = (WAModuleViewController *) [self traverseResponderChainForUIViewController];
    [moduleViewController checkUpdateIfNeeded];
    
    
 

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
