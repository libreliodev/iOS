//
//  WAPageContainerController.m
//  Librelio
//
//  Created by Volodymyr Obrizan on 27.01.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import "WAPageContainerController.h"

#import "WADetailsViewController.h"

#import "WAUtilities.h"
#import "NSString+WAURLString.m"

@implementation WAPageContainerController

@synthesize viewControllersStack    = _viewControllersStack;

////////////////////////////////////////////////////////////////////////////////


-(id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.viewControllersStack  = [NSMutableArray array];
        
    }
    return self;
}


////////////////////////////////////////////////////////////////////////////////


-(void)dealloc
{
    self.viewControllersStack = nil;
    [super dealloc];
}


////////////////////////////////////////////////////////////////////////////////


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


////////////////////////////////////////////////////////////////////////////////


#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    self.view = [[[UIView alloc] init] autorelease];
    self.view.backgroundColor = UIColor.clearColor;
    self.view.clipsToBounds = NO;
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask =  UIViewAutoresizingFlexibleWidth 
                                | UIViewAutoresizingFlexibleHeight
                                | UIViewAutoresizingFlexibleRightMargin
                                | UIViewAutoresizingFlexibleBottomMargin;
    self.view.userInteractionEnabled = YES;
}


////////////////////////////////////////////////////////////////////////////////


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.viewControllersStack  = [NSMutableArray array];
}


////////////////////////////////////////////////////////////////////////////////


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.viewControllersStack = nil;
    self.selectedViewController = nil;
}


////////////////////////////////////////////////////////////////////////////////


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES; //(interfaceOrientation == UIInterfaceOrientationPortrait);
}


////////////////////////////////////////////////////////////////////////////////


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.selectedViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}


////////////////////////////////////////////////////////////////////////////////


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGRect rect = [WAPageContainerController rectForClass:self.selectedViewController];
    
    // Keep it off-screen if there is no selected controller
    if (!self.selectedViewController)
        rect.origin.x = rect.origin.x + rect.size.width;
    
    [UIView animateWithDuration:0.1 animations:
     ^{
         self.view.frame = rect;
     }];
    
    [self.selectedViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark - Properties accessors


-(UIViewController *)selectedViewController
{
    return _selectedViewController;
}


////////////////////////////////////////////////////////////////////////////////


-(void)setSelectedViewController:(UIViewController *)value
{
    if (_selectedViewController)
    {
        [_selectedViewController release];
        _selectedViewController = nil;
    }
    if (value)
    {
        _selectedViewController = [value retain];
        
        // Put reference to myself
        if ([_selectedViewController respondsToSelector:@selector(setContainerController:)])
            self.selectedViewController.containerController = self;
        
        [self renderSelectedViewController];
    }
}


////////////////////////////////////////////////////////////////////////////////


# pragma mark - Managing views

-(void)renderSelectedViewController
{
    CGRect rect = [WAPageContainerController rectForClass:self.selectedViewController];
    self.view.frame = rect;
        
    // Add selected subview
    self.selectedViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.selectedViewController.view];
}


////////////////////////////////////////////////////////////////////////////////


-(void)removeSelectedViewController
{
	CGRect newRect = CGRectMake(self.view.bounds.size.width, self.view.frame.origin.y, self.view.bounds.size.width, self.view.bounds.size.width);
	self.view.frame = newRect;
	[self.selectedViewController.view removeFromSuperview];
	self.selectedViewController = nil;
}


////////////////////////////////////////////////////////////////////////////////


-(void)showViewController:(UIViewController<PageContainerItem> *)vc
{
    if (self.selectedViewController)
        [self.selectedViewController.view removeFromSuperview];
    
    // Remove all already presented views
    if (self.viewControllersStack)
        for (UIViewController *_tempvc in self.viewControllersStack)
            [_tempvc.view removeFromSuperview];

    // Remove the old navigation stack and create a new one
    self.viewControllersStack = [NSMutableArray array];
    self.selectedViewController = vc;
}


////////////////////////////////////////////////////////////////////////////////


-(void)pushViewController:(UIViewController<PageContainerItem> *)vc
{
    if (self.selectedViewController)
        [self.viewControllersStack addObject:self.selectedViewController];
    self.selectedViewController = vc;
}


////////////////////////////////////////////////////////////////////////////////


-(void)popViewController
{
    [self removeSelectedViewController];
    self.selectedViewController = self.viewControllersStack.lastObject;
    [self.viewControllersStack removeLastObject];
}


////////////////////////////////////////////////////////////////////////////////


+(CGRect)rectForClass:(NSObject *)object
{
    // lauout.plist specifies layouts for different classes for different interface 
    // idioms and different orientations
    
    NSString *layoutPlist = [[NSBundle mainBundle] pathForResource:@"layout" ofType:@"plist"];
    NSDictionary *layoutDic = [NSDictionary dictionaryWithContentsOfFile:layoutPlist];
    
    // Look up for special cases. If not present, look up for the "Default" layout
    NSDictionary *classDic = [layoutDic objectForKey:NSStringFromClass(object.class)];
    if (!classDic)
        classDic = [layoutDic objectForKey:@"Default"];
    //SLog(@"classDic %@",classDic);
    
    NSString * device = @"Iphone";
    if ([WAUtilities isBigScreen]) device = @"Ipad";
    else if ([WAUtilities isScreenHigherThan500]) device = @"Iphone5";
   
    
    NSDictionary *deviceDic = [classDic objectForKey:device];
    
    //SLog(@"deviceDic for device %@: %@",device,deviceDic);

    
    NSDictionary *orientationDic = [deviceDic objectForKey:NSString.orientation];
    
    
    CGFloat x       = [[orientationDic objectForKey:@"x"] floatValue];
    CGFloat y       = [[orientationDic objectForKey:@"y"] floatValue];
    CGFloat width   = [[orientationDic objectForKey:@"width"] floatValue];
    CGFloat height  = [[orientationDic objectForKey:@"height"] floatValue];
    
    return CGRectMake(x, y, width, height);
}


////////////////////////////////////////////////////////////////////////////////

@end
