//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WAPlainView.h"
#import "WAUtilities.h"

#import "NSString+WAURLString.h"
#import "UIView+WAModuleView.h"
#import "NSBundle+WAAdditions.h"
#import "UIColor+WAAdditions.h"
#import "WAModuleViewController.h"


@implementation WAPlainView

@synthesize currentViewController,dataArray,parser;

#pragma mark -
#pragma mark Lifecycle
- (void)dealloc {
	[urlString release];
	[dataArray release];
	[parser release];
    [super dealloc];
}

- (NSString *) urlString
{
    return urlString;
}

- (void) setUrlString: (NSString *) theString
{
    urlString = [[NSString alloc]initWithString: theString];
    //SLog(@"Starting setUrl");


		
    NSString * className = [urlString classNameOfParserOfUrlString];
    Class theClass = NSClassFromString(className);
    //SLog(@"Class Name:%@",className);
    parser =  (NSObject <WAParserProtocol> *)[[theClass alloc] init];
    parser.urlString = urlString;
	
    


	
	
}

- (void) refreshLayoutForOrientation:(UIInterfaceOrientation)orientation {
    for (UIView * subView in [self subviews]){
        [subView removeFromSuperview];
    }
    UIView * nibView = [UIView getNibView:[urlString nameOfFileWithoutExtensionOfUrlString] defaultNib:@"WAFileManagerCell" forOrientation:orientation];
    NSLog(@"NibView subviews:%i",[[nibView subviews]count]);
    nibView.frame = self.frame;
    [self addSubview:nibView];
    [nibView populateNibWithParser:parser withButtonDelegate:self   forRow:1];

    
    




}



#pragma mark -
#pragma mark ModuleView protocol

- (void)moduleViewWillAppear:(BOOL)animated{
    UIInterfaceOrientation orientation = [[self currentViewController] interfaceOrientation];
    
    [self refreshLayoutForOrientation:orientation];
    

}

- (void) moduleViewDidAppear{
}


- (void) moduleViewWillDisappear:(BOOL)animated{
 
}



- (void) moduleWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
}

- (void) moduleWillAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self refreshLayoutForOrientation:toInterfaceOrientation];
}

- (void) jumpToRow:(int)row{
    
}



#pragma mark -
#pragma mark Button Actions

- (void)buttonAction:(id)sender{
    
	UIButton *button = (UIButton *)sender;
	NSString * newUrlString = [button titleForState:UIControlStateApplication];
    //SLog(@"Button action received with Url:%@",newUrlString);
	WAModuleViewController * moduleViewController = [[WAModuleViewController alloc]init];
	moduleViewController.moduleUrlString= newUrlString;
	moduleViewController.initialViewController= self.currentViewController;
	moduleViewController.containingView= self;
	moduleViewController.containingRect= self.frame;
	[moduleViewController pushViewControllerIfNeededAndLoadModuleView];
	[moduleViewController release];
}


@end
