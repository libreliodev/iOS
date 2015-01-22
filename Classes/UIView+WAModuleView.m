//
//  UIView+FindUIViewController.m
//  Librelio
//
//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import "UIView+WAModuleView.h"
#import "WAModuleViewController.h"
#import "WAModuleProtocol.h"
#import "WABarButtonItemWithLink.h"
#import "NSBundle+WAAdditions.h"
#import "UIColor+WAAdditions.h"
#import "NSString+WAURLString.h"

#import <QuartzCore/QuartzCore.h>


@implementation UIView (WAModuleView)
- (UIViewController *) firstAvailableUIViewController {
    // convenience function for casting and to "mask" the recursive function
    return (UIViewController *)[self traverseResponderChainForUIViewController];
}


- (id) traverseResponderChainForUIViewController {
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [nextResponder traverseResponderChainForUIViewController];
    } else {
        return nil;
    }
}

/** @brief Checks wether module view is at the root level, or is embeded in another module view
 **/
- (BOOL) isRootModule {
    WAModuleViewController * curModuleViewController = (WAModuleViewController *) [self traverseResponderChainForUIViewController];
    UIView  * moduleView = curModuleViewController.moduleView;
    if ([moduleView isEqual:self]) return true;
    else return false;
}


/** @brief Returns url of root module
 **/
- (NSString*) urlStringOfRootModule {
    //SLog(@"Will return urlStringOfRootModule");
    WAModuleViewController * curModuleViewController = (WAModuleViewController *) [self traverseResponderChainForUIViewController];
    UIView <WAModuleProtocol>*  rootModuleView = curModuleViewController.moduleView;
    return (rootModuleView.urlString);
    

}

/** @brief Presents an action sheet from a the current view only if posible
 **/
- (void) showActionSheet:(UIActionSheet*)actionSheet animated:(BOOL)animated{
    //SLog(@"View height:%f",self.frame.size.height);
   if (self.frame.size.height>1.0f){
       [actionSheet showFromRect:self.frame inView:self.superview animated:YES];
   } 
   else {
       //If the height  of the view is 1.0, we assume that it is the contentView of a BarButton
       WAModuleViewController * curModuleViewController = (WAModuleViewController * )[(UIView <WAModuleProtocol>*)self currentViewController];
        [actionSheet showInView:curModuleViewController.moduleView]; 
   }
}


- (void) showPopover:(UIPopoverController*)popover animated:(BOOL)animated{
    WAModuleViewController * curModuleViewController = (WAModuleViewController * )[(UIView <WAModuleProtocol>*)self currentViewController];
    if (self.frame.size.height>1.0f){
         [popover  presentPopoverFromRect:self.frame inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } 
    else {
        //If the height  of the view is 1.0, we assume that it is the contentView of a BarButton; let's try to find it 
        UIToolbar * toolBar = curModuleViewController.rightToolBar;

        for (WABarButtonItemWithLink * currentBarButton in toolBar.items){
             if ([currentBarButton.link isEqualToString:[(UIView <WAModuleProtocol>*)self urlString]]){
                 //SLog(@"Button item found, will present popover");
                 [popover presentPopoverFromBarButtonItem:currentBarButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }
        }
    }
            


}

#pragma mark -
#pragma mark Nib and Layout management methods

- (void) populateNibWithParser:(NSObject <WAParserProtocol>*)parser withButtonDelegate:(NSObject*)delegate withController:(UIViewController*)controller forRow:(int)row{
   	for (UIView * subView in self.subviews){
        //SLog(@"Found subview with tag %i.",subView.tag);
		if (subView.tag>=0){
			NSString * tempString;
            if (row==0) tempString=[parser getHeaderForDataCol:(int)subView.tag];//This is conventional
            else tempString=[parser getDataAtRow:row forDataCol:(int)subView.tag];

            //SLog(@"Found tempString:%@",tempString);
            //[parser getDataAtRow:row forQueryString:queryString forDataCol:subView.tag];Deprecated
			if (!tempString){
				subView.hidden = YES;
			}
			else {
                subView.hidden = NO;
				if ([subView isKindOfClass:[UIImageView class]]){
					UIImageView * imView = (UIImageView*) subView; 
					UIImage * img = [UIImage imageWithContentsOfFile:tempString];
                    if (img){
                        imView.image = img;
                        //Add shadow
                        imView.layer.shadowRadius = 10.0;
                        imView.layer.shadowOpacity = 0.4;
                        imView.layer.shadowOffset = CGSizeMake( 20.0, 10.0 );
                        
                    }
                    else{
                        //Delete corrupted file
                        [WAUtilities deleteCorruptedResourceWithPath:tempString ForMainFileWithUrlString:parser.urlString];
                        subView.hidden = YES;

                        
                    }
                    
                    
					
				}
				else if  ([subView isKindOfClass:[UILabel class]]){
					UILabel * lbView = (UILabel *) subView;
					lbView.text = tempString;
                    
				}
				else if  ([subView isKindOfClass:[UIWebView class]]){
					UIWebView * wView = (UIWebView *) subView;
                    
					NSString * templatePath =[[NSBundle mainBundle] pathOfFileWithUrl:parser.urlString];
					NSURL *baseURL = [NSURL fileURLWithPath:templatePath];
					[wView loadHTMLString:tempString baseURL:baseURL];
				}
				else if  ([subView isKindOfClass:[UIButton class]]){
					UIButton * buyButton = (UIButton*) subView; 
					buyButton.backgroundColor = [buyButton titleShadowColorForState:UIControlStateNormal];//Conventionally, we use the shadow color to describe the background color
					NSArray * parts = [tempString componentsSeparatedByString:@";"];
					[buyButton setTitle:[parts objectAtIndex:0] forState:UIControlStateNormal];
					[buyButton setTitle:[parts objectAtIndex:1] forState:UIControlStateApplication];//Store the link here
					[buyButton addTarget:delegate action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
					
					
				}
                else if ([subView conformsToProtocol:@protocol(WAModuleProtocol)]){
                    NSLog(@"Conforms");
                    UIView <WAModuleProtocol>* moduleView = (UIView <WAModuleProtocol>*)subView;
                    moduleView.currentViewController = controller;
                    moduleView.urlString = tempString;
				
				
                }
			}
			
			
		}
	}
}

+ (NSString *)getNibName:(NSString*) nibName defaultNib:(NSString*) defaultNibName forOrientation:(UIInterfaceOrientation)orientation{
    //SLog(@"Getting nib %@ with default %@",nibName, defaultNibName);
    //Check if nibName.xib exists, otherwise use defaultNibName;
    NSString * nibUrlString = [nibName stringByAppendingString:@".nib"];//see http://stackoverflow.com/questions/923706/checking-if-a-nib-or-xib-file-exists for explanation of using "nib" extension instead of "xib"
    NSString * nibPath = [[NSBundle mainBundle]pathOfFileWithUrl:nibUrlString forOrientation:orientation];
    //SLog(@"nibPath: %@",nibPath);
    if(nibPath) nibName = [nibPath nameOfFileWithoutExtensionOfUrlString];
    else {
        nibPath = [[NSBundle mainBundle]pathOfFileWithUrl:[defaultNibName stringByAppendingString:@".nib"] forOrientation:orientation];
        if (nibPath) {
            nibName = defaultNibName;
            
        }
        else{
            return nil;
        }
    }
    NSLog (@"will return nibName:%@",nibName);
    return nibName;

}


+ (UIView *)getNibView:(NSString*) nibName defaultNib:(NSString*) defaultNibName forOrientation:(UIInterfaceOrientation)orientation{
    NSString * chosenNibName = [self getNibName:nibName defaultNib:defaultNibName forOrientation:orientation];
    if (!chosenNibName) return nil;

	NSArray*    topLevelObjs = nil;
    NSLog(@"chosenNibName:%@",chosenNibName);
	topLevelObjs=	[[NSBundle mainBundle] loadNibNamed:chosenNibName owner:nil options:nil];
	
	UIView * nibView = [topLevelObjs lastObject];
    
	return nibView;
}




@end
