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

- (void) populateNibWithParser:(NSObject <WAParserProtocol>*)parser withButtonDelegate:(NSObject*)delegate  forRow:(int)row;

+ (UIView *)getNibView:(NSString*) nibName defaultNib:(NSString*) defaultNibName forOrientation:(UIInterfaceOrientation)orientation;


@end
