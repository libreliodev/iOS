//
//  WALexiqueController.m
//  Librelio
//
//  Created by svp on 02.02.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import "WALexiqueController.h"
#import "NSString+WAURLString.h"


@implementation WALexiqueController

@synthesize webView             = _webView;
// Datasource
@synthesize datasource          = _datasource;          


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


////////////////////////////////////////////////////////////////////////////////


#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableString *htmlText = [NSMutableString string];
    [htmlText appendFormat:@"<html><head><meta name=\"viewport\" content=\"initial-scale=1.0, user-scalable=no\" /><link href = \"%@\" rel=\"stylesheet\" type=\"text/css\"></head>", [NSString stringWithFormat:@"%@%@", @"style".device, @".css"]];
    [htmlText appendFormat:@"<body>"];
    for (NSDictionary *data in self.datasource)
    {    
        [htmlText appendFormat:@"<h1>%@</h1>", [data objectForKey:@"Gamme"]];
        [htmlText appendFormat:@"<p>%@</p>", [data objectForKey:@"Description"]];
    }
    [htmlText appendFormat:@"</body>"];
    [htmlText appendFormat:@"</html>"];
    
    NSString *pathCSS = [[NSBundle mainBundle]bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:pathCSS];
    
    [self.webView loadHTMLString:htmlText baseURL:baseURL];   
        
}


////////////////////////////////////////////////////////////////////////////////


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


////////////////////////////////////////////////////////////////////////////////


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

////////////////////////////////////////////////////////////////////////////////


#pragma mark UIWebViewDelegate 

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

////////////////////////////////////////////////////////////////////////////////

@end
