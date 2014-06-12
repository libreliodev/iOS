//
//  WABuyViewController.m
//  Librelio
//
//  Created by Volodymyr Obrizan on 07.02.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import "WABuyViewController.h"

#import "WAModuleViewController.h"
#import "NSString+WAURLString.h"
#import "UIView+WAModuleView.h"
#import "NSBundle+WAAdditions.h"



@implementation WABuyViewController

@synthesize urlString       = _urlString;
@synthesize button          = _button;
@synthesize imageView       = _imageView;


////////////////////////////////////////////////////////////////////////////////


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


////////////////////////////////////////////////////////////////////////////////


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


////////////////////////////////////////////////////////////////////////////////


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
    
    // Create background image
    self.imageView = [[[UIImageView alloc] init] autorelease];
    self.imageView.autoresizesSubviews = YES;
    self.imageView.clipsToBounds = YES;
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.imageView];

    // Create buy button
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    // Here we substitute "search:" with "buy:" schema
    NSString *buttonTitle = [self.urlString urlByChangingSchemeOfUrlStringToScheme:@"buy"];
    [self.button setTitle:buttonTitle forState:UIControlStateApplication];
    [self.button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.button];
    
    [self redraw];
}


////////////////////////////////////////////////////////////////////////////////


-(void)redraw
{
    // Load background image
    NSString *backgroundImageFileName = [NSString stringWithFormat:@"%@%@.png", @"fond_1_telecharger_".device,NSString.orientation];
    UIImage *backgroundImage = [UIImage imageNamed:backgroundImageFileName];
    self.imageView.image = backgroundImage;
    self.imageView.frame = self.view.bounds;
    
    // Load image for button
    NSString *buttonImagePath = [NSString stringWithFormat:@"%@%@.png", @"bouton_1_telecharger_".device,NSString.orientation];
    UIImage *buttonImage = [UIImage imageNamed:buttonImagePath];
    
    NSString *buyBittonPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@%@",@"WABuyBotton".device,NSString.orientation] ofType:@"plist"];
    NSDictionary *dic = [[NSDictionary dictionaryWithContentsOfFile:buyBittonPath]objectForKey:@"root"]; 
    CGRect rect = CGRectMake([[dic objectForKey:@"x"] floatValue],
                             [[dic objectForKey:@"y"] floatValue],
                             [[dic objectForKey:@"width"] floatValue],
                             [[dic objectForKey:@"height"] floatValue]); 
    self.button.frame = rect;
    [self.button setImage:buttonImage forState:UIControlStateNormal]; 
}


////////////////////////////////////////////////////////////////////////////////


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self redraw];
}


////////////////////////////////////////////////////////////////////////////////


-(void)viewDidAppear:(BOOL)animated
{
    [self redraw];
}


////////////////////////////////////////////////////////////////////////////////


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


////////////////////////////////////////////////////////////////////////////////


- (void) openModule:(NSString*)urlString inView:(UIView *)pageView inRect:(CGRect)rect
{
    //Add the final underscore
    NSString *newUrlString = [urlString stringByReplacingOccurrencesOfString:@".sqlite" withString:@"_.sqlite"];
    
    
    //Remove the " (sample)" part in the title
    NSString * encodedSampleString = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)NSLocalizedString(@" (Sample)",@""), NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8 );
    newUrlString = [newUrlString stringByReplacingOccurrencesOfString:encodedSampleString withString:@""];
    
     
	WAModuleViewController *moduleViewController = [[WAModuleViewController alloc] init];
	moduleViewController.moduleUrlString = newUrlString;
    
    //Find the current WAModuleViewController; self.view does not conform to the WAModuleProtocol, but its superview does
   WAModuleViewController * curModuleViewController = (WAModuleViewController * )[(UIView <WAModuleProtocol>*)self.view.superview currentViewController];
    //WAModuleViewController * curModuleViewController = (WAModuleViewController * )[self.view.superview.superview.superview firstAvailableUIViewController];
    

	moduleViewController.initialViewController = curModuleViewController;
	moduleViewController.containingView = pageView;
	moduleViewController.containingRect = rect;
	[moduleViewController pushViewControllerIfNeededAndLoadModuleView];
	[moduleViewController release];
}


////////////////////////////////////////////////////////////////////////////////


-(void)buttonAction:(id)sender
{
    // Code suggested by Librelio
    UIButton *button = (UIButton *)sender;
    NSString *newUrlString = [button titleForState:UIControlStateApplication];
    [self openModule:newUrlString inView:button.superview inRect:button.frame];
}


////////////////////////////////////////////////////////////////////////////////

@end
