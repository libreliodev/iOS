//
//  UIView+FindUIViewController.h
//  Librelio
//
//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (WAModuleView)
- (UIViewController *) firstAvailableUIViewController;
- (id) traverseResponderChainForUIViewController;
- (BOOL) isRootModule;
- (NSString*) urlStringOfRootModule;
- (void) showActionSheet:(UIActionSheet*)actionSheet animated:(BOOL)animated;
- (void) showPopover:(UIPopoverController*)popover animated:(BOOL)animated;

- (void) populateNibWithParser:(NSObject <WAParserProtocol>*)parser withButtonDelegate:(NSObject*)delegate withController:(UIViewController*)controller  forRow:(int)row;

+ (NSString *)getNibName:(NSString*) nibName defaultNib:(NSString*) defaultNibName forOrientation:(UIInterfaceOrientation)orientation;
+ (UIView *)getNibView:(NSString*) nibName defaultNib:(NSString*) defaultNibName forOrientation:(UIInterfaceOrientation)orientation;


@end
