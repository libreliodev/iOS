
//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.
//

/*
 * This class performs 2 tasks:
 * - checks whether the view is in full screen; in the case, it pushes itself as the new controller
 * - creates a loadingView
 */

#import "WAModuleViewController.h"
#import "WAUtilities.h"
#import "WADownloadingView.h"
#import "WADocumentDownloadsManager.h"
#import "WAMissingResourcesDownloader.h"


#import "WABarButtonItemWithLink.h"

#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"

#import "SHKActivityIndicator.h"


@implementation WAModuleViewController


@synthesize moduleUrlString,containingView,moduleView,initialViewController,containingRect,rightToolBar;

@synthesize searchNavigationController;


@synthesize lastKnownOrientation;



- (void) pushViewControllerIfNeededAndLoadModuleView {
	[self checkFullScreenAndPushViewControllerIfNeeded];
	//Load the loadingview
	[self loadModuleViewAndCheckUpdate];

}

- (BOOL)checkFullScreen{
	NSString * rectString = [moduleUrlString valueOfParameterInUrlStringforKey:@"warect"];
	//Check whether play full screen is required
	BOOL playFullScreen;
	LinkType linkType = [moduleUrlString typeOfLinkOfUrlString];
	switch (linkType) {
		case LinkTypeGrid:
		case LinkTypePaginated:
        case LinkTypeTable:
        case LinkTypeDatabase:
        case LinkTypeZoomImage:
		case LinkTypeHTML:{
			playFullScreen=YES;//Unlike other modules, the above modules are FullScreen by default
			if ([rectString isEqualToString:@"self"]) playFullScreen=NO;
			break;
		}
		default:{
			playFullScreen=NO;//By default, elements are played in button rect except web links and a few others
			if ([rectString isEqualToString:@"full"]) playFullScreen=YES;
			break;
			
		}
	}
    //If containingRect is CGRectZero, we play full screen
    if (CGRectEqualToRect(containingRect,CGRectZero)) playFullScreen = YES;
    return playFullScreen  ;
    
}

- (void) checkFullScreenAndPushViewControllerIfNeeded{
    BOOL playFullScreen = [self checkFullScreen];
    //SLog(@"moduleurlstring%@",moduleUrlString);
	LinkType linkType = [moduleUrlString typeOfLinkOfUrlString];
    //SLog(@"linktype %u",linkType);
    
	//If play full screen is required, push view controller (self) EXCEPT for videos and Slideshows,Charts and ZoomImages
	if ((playFullScreen)&&(linkType!=LinkTypeVideo)){
        switch (linkType) {
            case LinkTypeChart:
            case LinkTypeZoomImage:
            case LinkTypeSlideShow:{
                self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [initialViewController.navigationController presentViewController:self animated:YES completion:nil];
                break;
            }

            default:{
                //Push view except if the initial module was a sample and the new one is the full version
                
                //Check if initial module is a sample
                NSString * initialModuleUrlString = [(WAModuleViewController*)initialViewController moduleUrlString];
                NSString * noArgsInitialModuleUrlString = [initialModuleUrlString noArgsPartOfUrlString];
                NSString * noUnderscoreModuleUrlString = [moduleUrlString urlByRemovingFinalUnderscoreInUrlString];
                NSString * noArgsNoUnderscoreModuleUrlString = [noUnderscoreModuleUrlString noArgsPartOfUrlString];
                if (![noArgsInitialModuleUrlString isEqualToString:noArgsNoUnderscoreModuleUrlString]){
                    //Push the new module view
                    //SLog(@"Will push %@ from %@",moduleUrlString,[(WAModuleViewController*)initialViewController moduleUrlString] );
                    
                    //Hide buttom bar by default, except if wabbar arg is set
                    NSString * shouldKeepBottomBar  = [moduleUrlString valueOfParameterInUrlStringforKey:@"wabbar"];
                    if (!shouldKeepBottomBar) self.hidesBottomBarWhenPushed = YES;
                    
                    self.title = [moduleUrlString titleOfUrlString];
 
                    [initialViewController.navigationController pushViewController:self animated:YES];
                }
                else{
                    //Initial module was a sample and the new one is the full version
                    //Replace the sample module view by the full version module view
                    
                    //Create a new view controllers array without the last view Controller
                    NSRange theRange;
                    theRange.location = 0;
                    theRange.length = [initialViewController.navigationController.viewControllers count]-1;

                    NSArray * viewControllersSubArray = [initialViewController.navigationController.viewControllers subarrayWithRange:theRange];
                    NSArray * newViewControllersArray = [viewControllersSubArray arrayByAddingObject:self];
                    if ([newViewControllersArray count]>1) self.hidesBottomBarWhenPushed = YES;//Do not display bottom bar only if there is more than one view controller
                    self.title = [moduleUrlString titleOfUrlString];//Set the title
                    self.tabBarItem.image = initialViewController.tabBarItem.image;//Set the tabbar image, otherwise it will appear empty

                    

                    
                     [initialViewController.navigationController setViewControllers:newViewControllersArray animated:YES];
                    
                }
            
                
                
 
                break;
            }
                 
                
        }
        containingView = self.view;
        containingRect = self.view.frame;
        initialViewController = self;
		
	}
	
}

- (void) initModuleView{
    NSString * className = [moduleUrlString classNameOfModuleOfUrlString];
    //SLog(@"Going to init %@ for %@",className,moduleUrlString);
    Class theClass = NSClassFromString(className);
    moduleView = (UIView <WAModuleProtocol> *)[[theClass alloc]init];

	
}

- (void)checkUpdateIfNeeded{

    if ([WAUtilities isCheckUpdateNeededForUrlString:moduleUrlString]||[WAUtilities isDownloadMissingResourcesNeededForUrlString:moduleUrlString]){
        //SLog(@"Update needed for url %@",moduleUrlString);
        [self checkUpdate:NO];

	}
	else {

		//SLog(@"No check update needed for %@",moduleUrlString);
	}

    
}

- (void)checkUpdate:(BOOL)force{
    WADownloadingView * loadingView = [[WADownloadingView alloc]init];
    loadingView.currentViewController = self;
    //loadingView.frame = containingRect;//this does not work well when there is a tabbar
    //SLog(@"Will add subview with height:%f to view with height:%f",containingRect.size.height,moduleView.frame.size.height);
    loadingView.frame = moduleView.frame;
    loadingView.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin);
    [moduleView addSubview:loadingView];
    
    
    //If there is already a downloaded resource available, no need to show the LoadingView, load in the background. Don't show if module is not full screen also.
    if ([[NSBundle mainBundle] pathOfFileWithUrl:moduleUrlString]||![self checkFullScreen])
        loadingView.hidden = YES;
    
    //Check wether we only need to download missing resources, or the whole stuff
    if ([WAUtilities isCheckUpdateNeededForUrlString:moduleUrlString]||force){
        loadingView.downloadOnlyMissingResources = NO;
        //SLog(@"downloadOnlyMissingResources = NO for %@",moduleUrlString);
        
    }
    else{
        //SLog(@"downloadOnlyMissingResources = YES for %@",moduleUrlString);
        
        loadingView.downloadOnlyMissingResources = YES;
        
    }
    
    loadingView.urlString = moduleUrlString;
     //SLog(@"count before releasing loading view with missing %hhd: %d",loadingView.downloadOnlyMissingResources, [loadingView retainCount]);

    [loadingView release];
     
    
}


- (void)loadModuleViewAndCheckUpdate{
	
	[self loadModuleView];
    //SLog(@"will check update for module %@",moduleUrlString);
    [self checkUpdateIfNeeded];

	

	
}



- (void)loadModuleView{
	[self initModuleView];
	LinkType linkType = [moduleUrlString typeOfLinkOfUrlString];
    //If the url contains wauserpref, save it to the corresponding user pref
    NSString* userPrefKey = [moduleUrlString valueOfParameterInUrlStringforKey:@"wauserpref"];
    //SLog(@"UserPrefKey:%@",userPrefKey);
    if (userPrefKey) [[NSUserDefaults standardUserDefaults] setObject:moduleUrlString forKey:userPrefKey];
	if (linkType == LinkTypeSelf){
		//SLog(@"We do nothing");
	}
	else {
		moduleView.frame = containingRect;
		moduleView.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin);
		[containingView addSubview:moduleView];
		moduleView.currentViewController = initialViewController;
		moduleView.urlString = moduleUrlString;	
        //SLog(@"moduleViewWillAppear %@",moduleView);
        [moduleView moduleViewWillAppear:NO];//This is not triggered automatically when the module loads because it is too late
        
        //Register event with Google Analytics
        NSString * action = @"Module opened by user";
        //Check if the module was opened automatically, or by the user
        NSString *hash = [WAUtilities hashPartOfUrlString:moduleUrlString];//the autoplay after the hash is deprecated (now we use waplay=auto), but we keep it here for back compatibility reasons
        if ([hash isEqualToString:@"autoplay"]||[[moduleUrlString valueOfParameterInUrlStringforKey:@"waplay"] isEqualToString:@"auto"]){
            action = @"Module opened automatically";
          }
        NSString * label = [NSString stringWithFormat:@"%@/%@",[[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleIdentifier"],[moduleUrlString stringByReplacingOccurrencesOfString:@"http://localhost/" withString:@""]];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Module" action:action label:label value:[NSNumber numberWithInt:1]] build]];

	}

	
}

-(void) addButtonWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem orImageNamed:(NSString*)imageName orString:(NSString*)buttonString  andLink:(NSString*)linkString;{
    // create the button
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithArray:rightToolBar.items];
    WABarButtonItemWithLink* bi = [[WABarButtonItemWithLink alloc]
                                   initWithBarButtonSystemItem:systemItem target:self action:@selector(performButtonAction:)];
    bi.style = UIBarButtonItemStyleBordered;
    if (systemItem == UIBarButtonSystemItemFixedSpace){
        //Conventionally, in this case, we take either an image and a string button
        if (![imageName isEqualToString:@""]){
            UIImage * btnImage = [UIImage imageNamed:imageName];
            bi = [[WABarButtonItemWithLink alloc]initWithImage:btnImage style:UIBarButtonItemStyleBordered target:self action:@selector(performButtonAction:)];
        }
        else{
            bi = [[WABarButtonItemWithLink alloc]initWithTitle:buttonString style:UIBarButtonItemStyleBordered target:self action:@selector(performButtonAction:)];
        }
        
    }
    bi.link = linkString;
    [buttons addObject:bi];
     [bi release];

    
    // create a spacer
    WABarButtonItemWithLink* bi2 = [[WABarButtonItemWithLink alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [buttons addObject:bi2];
     [bi2 release];
    
    [rightToolBar setItems:buttons animated:NO];
 
    //Calculate the width needed
    CGFloat widthNeeded = 4.0;
    for (WABarButtonItemWithLink* button in buttons){
        UIView *view = [button valueForKey:@"view"];
        CGFloat width = view? [view frame].size.width : (CGFloat)0.0;
        //SLog(@"Button  width:%f" , width);
        widthNeeded += width;
        
    }
    
    rightToolBar.frame = CGRectMake(rightToolBar.frame.origin.x, rightToolBar.frame.origin.y, widthNeeded, self.navigationController.navigationBar.frame.size.height+0.01);
  
    
 
    
   
    [buttons release];

    
}

- (void) viewWillAppear:(BOOL)animated{
    //Default navBar settings:
    self.navigationController.navigationBarHidden = NO;	
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;//Using this style   AND setting translucent property to NO prevents the navigationBar  from covering the upper part of the view.
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
   


    // create the right toolbar if does not exist
    if (!rightToolBar){
        rightToolBar = [[WATransparentToolbar alloc] initWithFrame:CGRectZero];
        rightToolBar.tintColor = [UIColor blackColor];
       self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightToolBar];
    }
    
    //Reset the toolbar
    [rightToolBar setItems:nil];

    
    //show upper bar by default, except if waubar arg is set
    NSString * shouldHideUpperBar  = [moduleUrlString valueOfParameterInUrlStringforKey:@"waubar"];
    if (shouldHideUpperBar) self.navigationController.navigationBarHidden = YES;


    //SLog(@"ModuleViewController will trigger moduleViewWillAppear");
	[moduleView moduleViewWillAppear:animated];


	
}




-(void) viewDidAppear:(BOOL)animated{
    UIInterfaceOrientation devOrientation = (UIInterfaceOrientation)[[UIDevice currentDevice]orientation];
    if (lastKnownOrientation != devOrientation){
        //Force orientation change methods
        //SLog(@"Force orientation change: lastknown:%i, dev:%i",lastKnownOrientation,devOrientation);
        [self willRotateToInterfaceOrientation:devOrientation duration:0];
        [self willAnimateRotationToInterfaceOrientation:devOrientation duration:0];

    }	
    [moduleView moduleViewDidAppear];

	
}

- (void) viewWillDisappear:(BOOL)animated{
    
    //Release existing toolbar module if any
    UIView * modView = [rightToolBar viewWithTag:999];
    if (modView) [modView removeFromSuperview];
    
    //Remove indicator if active
    [[SHKActivityIndicator currentIndicator] hide];

     [moduleView moduleViewWillDisappear:animated];
}

- (void)viewDidLoad {
    //self.trackedViewName = [[moduleUrlString classNameOfModuleOfUrlString]stringByReplacingCharactersInRange:NSMakeRange(0,2) withString:@""];
	
    self.view.backgroundColor = [UIColor blackColor];
	if (!containingView){//This happens when LoadingView controller is instantiated from LibrelioAppDelegate
		containingView = self.view;
		containingRect = self.view.frame;
		initialViewController = self;
		[self loadModuleViewAndCheckUpdate];

	}
    
    


}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Check, if a modlueview will manage orientation on its own
	// Currently, only the catalog view uses this (it supports only Portrait in iPhone)
	if ([moduleView respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)])
		return [moduleView shouldAutorotateToInterfaceOrientation:interfaceOrientation];
	return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	[moduleView moduleWillRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	[moduleView moduleWillAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    lastKnownOrientation = toInterfaceOrientation;

}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    // Propagate the event further
    if ([moduleView respondsToSelector:@selector(didRotateFromInterfaceOrientation:)])
        [moduleView didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    //In landscape mode on the iPhone, the navBar geometry should be updated
    rightToolBar.frame = CGRectMake (rightToolBar.frame.origin.x ,rightToolBar.frame.origin.y,rightToolBar.frame.size.width,self.navigationController.navigationBar.frame.size.height+0.01);
    
}



- (void)dealloc {
	[[NSNotificationCenter defaultCenter]removeObserver:self];
	[moduleUrlString release];
    [searchNavigationController release];
	[moduleView release];
    [rightToolBar release];
    [super dealloc];
}

#pragma mark -
#pragma mark Button methods
- (void) performButtonAction:(id)sender{
    WABarButtonItemWithLink * buttonItem = ( WABarButtonItemWithLink *) sender;
    //SLog(@"Performing action for button %@ with link: %@",buttonItem.title,buttonItem.link);

    
    WAModuleViewController * moduleViewController = [[WAModuleViewController alloc]init];
 	moduleViewController.moduleUrlString= buttonItem.link;

    //Release existing module if any
    UIView * modView = [self.navigationItem.rightBarButtonItem.customView viewWithTag:999];
    if (modView) [modView removeFromSuperview];
    
    if ([[buttonItem.link substringToIndex:7]isEqualToString:@"refresh"]) {
        [self checkUpdate:YES];
        
    }
    else{
        moduleViewController.initialViewController= self;
        //moduleViewController.containingView= buttonItem.customView;
        UIView * bView = [buttonItem valueForKey:@"view"]; //See http://stackoverflow.com/questions/5066847/get-the-width-of-a-uibarbuttonitem
        moduleViewController.containingView= self.navigationItem.rightBarButtonItem.customView;
        moduleViewController.containingRect= CGRectMake(bView.frame.origin.x,bView.frame.origin.y,bView.frame.size.width,1.0f);//Hack: we need to set height to 1.0 for popover to display correctly
        [moduleViewController pushViewControllerIfNeededAndLoadModuleView];
        moduleViewController.moduleView.tag = 999;
        [moduleViewController release];

        
    }
    
    
    
    
    
    
}
#pragma mark -

@end
