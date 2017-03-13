//
//  WASharePopover.m
//  Librelio
//
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import "WASharePopover.h"
#import "NSBundle+WAAdditions.h"


@implementation WASharePopover

@synthesize delegate;

@synthesize topMostView = _topMostView;
@synthesize tapGestureRecognizer = _tapGestureRecognizer;




- (NSArray *) shareItems
{
    return shareItems;
}


////////////////////////////////////////////////////////////////////////////////


- (void) setShareItems: (NSArray *) theItems{
    
    shareItems = [[NSArray alloc]initWithArray:theItems];
    // Due to iOS interface guidelines, only iPhone has "Cancel" button on the action sheet
    NSString *cancelTitle = nil;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        cancelTitle = [[NSBundle mainBundle]stringForKey:@"Cancel"];
    
    
    
    // Search for the top-most view
    self.topMostView = self;
    while (self.topMostView.superview)
        self.topMostView = self.topMostView.superview;        
    
    // Detect a tap on the background to close the popover
    self.tapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeView)] autorelease];
    self.tapGestureRecognizer.numberOfTapsRequired = 1;
    self.tapGestureRecognizer.delegate = self;        
    [self.topMostView addGestureRecognizer:self.tapGestureRecognizer];        
    
    // Add all necessary buttons
    CGFloat currentOrigin= 39.0;
    int currentTag = 100;
    
    for (NSString *str in theItems)
    {
        CGRect buttonFrame = self.bounds; 
        buttonFrame.size.width = self.bounds.size.width -68;
        buttonFrame.size.height = 37.0;
        buttonFrame.origin.x = 34.0;
        buttonFrame.origin.y = currentOrigin;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"buttonbackground.png"] forState:UIControlStateNormal];
        [button setTitle:str forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"buttonbackground2.png"] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button setFrame:buttonFrame];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = currentTag;
        [self addSubview:button];
        currentOrigin = currentOrigin + 47.0;
        currentTag = currentTag+1;

    }

    
}

-(void)closeView
{
    [self.topMostView removeGestureRecognizer:self.tapGestureRecognizer];
	self.tapGestureRecognizer = nil;
    [self removeFromSuperview];
    
    //[self.delegate removeFromSuperview];//Do not remove the module from its superview here, but in the module itself
    
}


- (void)dealloc {
    
	[shareItems release];
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////


#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // Source: http://stackoverflow.com/a/8198502/124115
    if ([touch.view isDescendantOfView:self])
    {
        // Ignore gesture recognizing for the popoverView
        // The events must be processed by the popover contents controller
        return NO;
    }
    
    return YES;
}

////////////////////////////////////////////////////////////////////////////////


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


- (void)buttonAction:(id)sender{
    UIButton * button = (UIButton *) sender;
    //Fix: https://github.com/libreliodev/iOS/issues/180
    //Adding [UIActionSheet new] won't affect any existing functionality
    [self.delegate actionSheet:[UIActionSheet new] clickedButtonAtIndex:button.tag-100];
    [self closeView];
    
}


@end
