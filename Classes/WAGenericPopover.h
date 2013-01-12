//
//  WAGenericPopover.h
//  Librelio
//
//  Created by Volodymyr Obrizan on 19.02.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import <Foundation/Foundation.h>

////////////////////////////////////////////////////////////////////////////////

@class WAGenericPopover;

@protocol WAGenericPopoverDelegate

-(void)genericPopoverClose: (WAGenericPopover*)popover;

@end


////////////////////////////////////////////////////////////////////////////////


@interface WAGenericPopover : NSObject<UIGestureRecognizerDelegate>
{
@private
    UIViewController *_contentViewController;
}

@property (nonatomic, retain) UIViewController *contentViewController;
@property (nonatomic, readonly, getter=isPopoverVisible) BOOL popoverVisible;
@property (nonatomic, retain) IBOutlet UIView *popoverView;
@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, retain) UIView *topMostView;
@property (nonatomic, copy) NSArray *passthroughViews;
@property (nonatomic, assign) id <WAGenericPopoverDelegate> delegate;
@property (nonatomic, retain) UIView *view;

@property (nonatomic) CGRect keyboardRect;


// Initializing the Popover
- (id)initWithContentViewController:(UIViewController *)viewController;

// Configuring the Popover Attributes
- (void)setContentViewController:(UIViewController *)viewController animated:(BOOL)animated;

// Presenting and Dismissing the Popover
- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated;
- (void)dismissPopoverAnimated:(BOOL)animated;

// Actions
-(void)tapAction;

-(void)fitPopover;


@end


