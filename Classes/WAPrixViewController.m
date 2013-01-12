//
//  WAPrixViewController.m
//  Librelio
//
//  Created by svp on 24.01.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import "WAPrixViewController.h"
#import "WAPageContainerController.h"

@implementation WAPrixViewController

@synthesize minMaxValues        = _minMaxValues;
@synthesize containerController = _containerController;

@synthesize titleLabel      = _titleLabel;
@synthesize subscriptLabel  = _subscriptLabel;
@synthesize miniLabel       = _miniLabel;
@synthesize maxiLabel       = _maxiLabel;
@synthesize miniField       = _miniField;
@synthesize maxiField       = _maxiField;
@synthesize scrollView      = _scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    if (self.minMaxValues)
    {
        NSNumber *mini = [self.minMaxValues objectForKey:@"mini"];
        NSNumber *maxi = [self.minMaxValues objectForKey:@"maxi"];
        
        self.miniField.text = mini.stringValue;
        self.maxiField.text = maxi.stringValue;
    }
}


////////////////////////////////////////////////////////////////////////////////


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.scrollView = nil;
    self.titleLabel = nil;
    self.subscriptLabel = nil;
    self.miniLabel = nil;
    self.maxiLabel = nil;
    self.miniField = nil;
    self.maxiField = nil;
}


////////////////////////////////////////////////////////////////////////////////


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark - User actions

-(IBAction)backButtonClicked:(id)sender
{
    [self.maxiField resignFirstResponder];
    [self.miniField resignFirstResponder];
    
    if (self.containerController)
        [self.containerController removeSelectedViewController];
}


////////////////////////////////////////////////////////////////////////////////


-(IBAction)valueChange:(id)sender
{
    // Store values to user search preferences
    if (self.minMaxValues)
    {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *mini = [f numberFromString:self.miniField.text];
        NSNumber *maxi = [f numberFromString:self.maxiField.text];
        [f release];
        
        if (mini)
        {
            [self.minMaxValues setObject:mini forKey:@"mini"];
        }
        else
        {
            // Remove such object
            if ([self.minMaxValues objectForKey:@"mini"])
                [self.minMaxValues removeObjectForKey:@"mini"];
        }
        
        if (maxi)
            [self.minMaxValues setObject:maxi forKey:@"maxi"];        
        else
        {
            // Remove such object
            if ([self.minMaxValues objectForKey:@"maxi"])
                [self.minMaxValues removeObjectForKey:@"maxi"];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SearchPreferencesChanged" object:self];
    }    
}


////////////////////////////////////////////////////////////////////////////////


#pragma mark - Working with keyboard


- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}


////////////////////////////////////////////////////////////////////////////////


// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    self.scrollView.contentSize = self.scrollView.bounds.size;
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height - 49.0 /* TabBar height */, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}


////////////////////////////////////////////////////////////////////////////////


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}


////////////////////////////////////////////////////////////////////////////////


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	
	if ([textField isEqual:self.miniField])
	{
		[self.maxiField becomeFirstResponder];
		[self.scrollView scrollRectToVisible:self.maxiField.frame animated:YES];
	}
	
	return YES;
}


////////////////////////////////////////////////////////////////////////////////

@end
