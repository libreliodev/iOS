//
//  GenericViewController.h
//  Librelio
//
//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WAModuleProtocol.h"
#import "WATransparentToolbar.h"
//#import "WATableViewController.h"
#import "WATableContainerView.h"
#import <MessageUI/MessageUI.h>

@interface WAModuleViewController : UIViewController  {
	UIViewController * initialViewController;
	UIView * containingView;
	UIView <WAModuleProtocol> * moduleView;
    UINavigationController * searchNavigationController;
	NSString *moduleUrlString;
	CGRect containingRect;
    UIInterfaceOrientation lastKnownOrientation;
    WATransparentToolbar * rightToolBar;
    
}
@property (nonatomic, retain)	NSString *moduleUrlString;

/**
 A navigation controller retained to keep track of last search actions
 **/
@property (nonatomic, retain)   UINavigationController * searchNavigationController;


@property (nonatomic, retain) UIView <WAModuleProtocol> * moduleView;
@property (nonatomic, assign) UIView * containingView;
@property (nonatomic, assign) UIViewController * initialViewController;

@property CGRect containingRect;

/**
 The last orientation the controller is aware of.
 **/
@property UIInterfaceOrientation lastKnownOrientation;

@property (nonatomic, retain) WATransparentToolbar* rightToolBar;


- (void)pushViewControllerIfNeededAndLoadModuleView;
- (void) initModuleView;
- (void)loadModuleViewAndCheckUpdate;
- (void)loadModuleView;
- (void)checkUpdate;
- (void) checkFullScreenAndPushViewControllerIfNeeded;
- (void) addButtonWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem orImageNamed:(NSString*)imageName orString:(NSString*)buttonString  andLink:(NSString*)linkString;
- (void) performButtonAction:(id)sender;


@end
