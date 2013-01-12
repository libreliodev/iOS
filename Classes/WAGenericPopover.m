//
//  WAGenericPopover.m
//  Librelio
//
//  Created by Volodymyr Obrizan on 19.02.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import "WAGenericPopover.h"

@implementation WAGenericPopover

@synthesize popoverVisible              = _popoverVisible;
@synthesize popoverView                 = _popoverView;
@synthesize tapGestureRecognizer        = _tapGestureRecognizer;
@synthesize topMostView                 = _topMostView;
@synthesize passthroughViews            = _passthroughViews;
@synthesize delegate					= _delegate;
@synthesize view						= _view;
@synthesize keyboardRect				= _keyboardRect;


////////////////////////////////////////////////////////////////////////////////


#pragma mark - Class lifecycle

- (id)initWithContentViewController:(UIViewController *)viewController
{
    self = super.init;
    if (self)
    {
        self.contentViewController = viewController;
        _popoverVisible = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tapAction) name:@"bodytouchstart" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWasShown:)
													 name:UIKeyboardDidShowNotification object:nil];
    }
    
    return self;
}


////////////////////////////////////////////////////////////////////////////////


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.contentViewController = nil;
    [super dealloc];
}


////////////////////////////////////////////////////////////////////////////////


- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGRect rect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	
	rect = [self.popoverView.superview convertRect:rect fromView:nil];
	
	self.keyboardRect = rect;
	[self fitPopover];
}


////////////////////////////////////////////////////////////////////////////////


#pragma mark - Properties

-(UIViewController *)contentViewController
{
    return _contentViewController;
}


////////////////////////////////////////////////////////////////////////////////


-(void)setContentViewController:(UIViewController *)value
{
    [self setContentViewController:value animated:NO];
}


////////////////////////////////////////////////////////////////////////////////


#pragma mark - Configuring the Popover Attributes

- (void)setContentViewController:(UIViewController *)value animated:(BOOL)animated
{
    if (_contentViewController)
    {
        [_contentViewController release];
        _contentViewController = nil;
    }
    
    if (value)
        _contentViewController = value.retain;
}


////////////////////////////////////////////////////////////////////////////////


#pragma mark - Presenting and Dismissing the Popover

- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated
{
    // arrowDirections are not respected at all at this time
    // The arrow will be always on top
	self.view = view;
    
    if (!self.contentViewController)
        return;
    
    [[NSBundle mainBundle] loadNibNamed:@"WAGenericPopover" owner:self options:nil];
    
    // Search for the top-most view
    self.topMostView = view;
    while (self.topMostView.superview)
        self.topMostView = self.topMostView.superview;
    
    UIView *childView = self.contentViewController.view;
    CGSize childViewSize = childView.bounds.size;
    
    // Detect a tap on the background to close the popover
    self.tapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)] autorelease];
    self.tapGestureRecognizer.numberOfTapsRequired = 1;
    self.tapGestureRecognizer.delegate = self;
    [self.topMostView addGestureRecognizer:self.tapGestureRecognizer];
    
    // Set-up frames
    CGRect popoverFrame = rect;
    popoverFrame = CGRectMake(0.0, popoverFrame.origin.y + popoverFrame.size.height - 15.0, childViewSize.width + 56.0, childViewSize.height + 72.0);
    self.popoverView.frame = popoverFrame;
    CGRect childFrame = CGRectMake(28.0, 34.0, childViewSize.width, childViewSize.height);
    childView.frame = childFrame;
    
    // Center the popover in relation to the object
    CGPoint popoverCenter = self.popoverView.center;
    popoverCenter.x = rect.origin.x + rect.size.width / 2.0;
    self.popoverView.center = popoverCenter;
	
    // Add the subviews in the proper hierarchy
    [self.popoverView addSubview:childView];

	// Check if the popover is bigger that the container
	if (self.popoverView.bounds.size.width > view.bounds.size.width)
	{
		CGRect rect = view.bounds;
		rect.origin.y = self.popoverView.frame.origin.y;
		rect.size.height = self.popoverView.bounds.size.height;
		self.popoverView.frame = rect;
	}
	
	[self fitPopover];

    [view addSubview:self.popoverView];

	// Show the popover with animation
    self.popoverView.alpha = 0.0;
    _popoverVisible = YES;
    [UIView animateWithDuration:(animated ? 0.2 : 0.0) animations:^{
        self.popoverView.alpha = 1.0;
    }];
}


////////////////////////////////////////////////////////////////////////////////


/* Change the popover frame so the on-screen keyboard doesn't cover it.
 */
-(void)fitPopover
{
	CGRect popoverWindowRect = self.popoverView.frame;
	
	// Increase the popover view to fit it with on-screen keyboard
	CGFloat len = self.keyboardRect.origin.y - popoverWindowRect.origin.y;
	CGRect rect = self.popoverView.frame;
	static const CGFloat SHADOW_INSET = 30.0;
	rect.size.height = len + SHADOW_INSET;
	
	[UIView animateWithDuration:0.25f animations:^{
		self.popoverView.frame = rect;
	}];
}


////////////////////////////////////////////////////////////////////////////////


-(void)tapAction
{
    [self dismissPopoverAnimated:YES];
}


////////////////////////////////////////////////////////////////////////////////


- (void)dismissPopoverAnimated:(BOOL)animated
{
    [self.topMostView removeGestureRecognizer:self.tapGestureRecognizer];
    
    [UIView animateWithDuration:(animated ? 0.2 : 0.0) animations:^{
        self.popoverView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (self.delegate)
			[self.delegate genericPopoverClose:self];
        [self.popoverView removeFromSuperview];
        _popoverVisible = NO;
		self.view = nil;
    }];
}


////////////////////////////////////////////////////////////////////////////////


#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // Source: http://stackoverflow.com/a/8198502/124115
    if ([touch.view isDescendantOfView:self.popoverView])
        // Ignore gesture recognizing for the popoverView
        // The events must be processed by the popover contents controller
        return NO;

    // Ignore gesture recognizing for pass-through views
    if (self.passthroughViews)
        for (UIView *v in self.passthroughViews)
            if ([touch.view isDescendantOfView:v])
                return NO;
    
    return YES;
}


////////////////////////////////////////////////////////////////////////////////


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // Allow to process gestures along with other recognizers
    return YES;
}


////////////////////////////////////////////////////////////////////////////////

@end
