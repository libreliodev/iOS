//
//  WADetailsViewController.h
//  Librelio
//
//  Created by svp on 07.02.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WAPageContainerController.h"

@class WAShareView;
@class WAPopoverViewController;

@interface WADetailsViewController : UIViewController<PageContainerItem, UIWebViewDelegate>

@property (nonatomic, assign) WAPageContainerController *containerController;
@property (nonatomic, retain) WAShareView  *shareView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIButton *favorisButton;
@property (nonatomic, retain) IBOutlet UIButton *shareButton;
@property (nonatomic, retain) IBOutlet UIImageView *topLogo;
@property (nonatomic, retain) IBOutlet UILabel *pageTitle;

// Child view controllers
@property (nonatomic, retain) WAPopoverViewController *popoverViewController;

// User actions
-(IBAction)backButtonClicked:(id)sender;
-(IBAction)didSelectSegment:(id)sender;
-(IBAction)favorisButtonClicked:(id)sender;
-(IBAction)partagerButtonClicked:(id)sender;

// Datasrouce
@property (nonatomic, copy) NSArray *datasource;
@property (nonatomic) NSUInteger currentIndex;
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, retain) NSArray *contents;

// Internal
-(void)reloadData;

// Popover control
-(void)showPopoverAtLocation:(CGFloat)top animated:(BOOL)animated;
-(void)hidePopoverAnimated:(BOOL)animated;
-(void)scrollPopoverTo:(CGPoint)location;

- (void) openModule:(NSString*)urlString inView:(UIView *)pageView inRect:(CGRect)rect;
@property(nonatomic) BOOL showSharePopover; 

@end
