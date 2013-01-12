//
//  WAShare.m
//  Librelio
//
//  Copyright (c) 2011 WidgetAvenue - Librelio. All rights reserved.
//


#import "WAShareView.h"
#import "UIView+WAModuleView.h"
#import "WAModuleProtocol.h"
#import "WAModuleViewController.h"


#import "UIView+WAModuleView.h"
#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.h"

#import "WASharePopover.h"
#import "WAShareActionSheet.h"


@implementation WAShareView 

@synthesize currentViewController;






////////////////////////////////////////////////////////////////////////////////


- (void)dealloc {
    //SLog(@"ShareView will dealloc");
    [urlString release];
    [super dealloc];
}


////////////////////////////////////////////////////////////////////////////////


- (NSString *) urlString
{
    return urlString;
}


////////////////////////////////////////////////////////////////////////////////


- (void) setUrlString: (NSString *) theString
{
    self.autoresizesSubviews = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    //self.backgroundColor   = [UIColor yellowColor];//Just for testing

	urlString = [[NSString alloc]initWithString: theString];
	
    
    // Separate social networks by , sign
    
    NSString * waSitesString = [urlString valueOfParameterInUrlStringforKey:@"wasites"];
    waSitesString = [waSitesString stringByReplacingOccurrencesOfString:@"mail" withString:NSLocalizedString(@"Share by Mail",@"")];
    waSitesString = [waSitesString stringByReplacingOccurrencesOfString:@"twitter" withString:NSLocalizedString(@"Share on Twitter",@"")];
    waSitesString = [waSitesString stringByReplacingOccurrencesOfString:@"facebook" withString:NSLocalizedString(@"Share on Facebook",@"")];
    NSArray* wasitesArray = [waSitesString componentsSeparatedByString:@","];
    //SLog(@"Site array %@ for parameters %@ for url %@",wasitesArray,waSitesString,theString);
	
	// Return if there are no sites specified
	if (!wasitesArray.count)
		return;
    
    // If we have several social networks - create ActionSheet with selection
    if(wasitesArray.count > 1)
    {
        NSString * nibName = [urlString nameOfFileWithoutExtensionOfUrlString];
        //Check if we have a nib named either WASharePopover, or with the same name as the file opened
        WASharePopover * sharePopover = (WASharePopover *)[UIView  getNibView:nibName defaultNib:@"WASharePopover" forOrientation:999];    
        if (sharePopover){
            //We have a nib, let use it
            CGRect rect = CGRectMake(self.frame.origin.x-265,  self.frame.origin.y+32, 335.0, 216.0); 
            sharePopover.frame = rect;
            [self.superview addSubview:sharePopover];
            sharePopover.delegate = self;
            sharePopover.shareItems = wasitesArray;

        }
        else{
            //We don't have a nib, use a standard UIActionSheet
            WAShareActionSheet *shareActionSheet = [[WAShareActionSheet alloc] initWithTitle:@""
                                                                     delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil 
                                                            otherButtonTitles:nil]; 
            shareActionSheet.shareItems = wasitesArray;
            if ([WAUtilities isBigScreen]) [shareActionSheet showFromRect:self.frame inView:self.superview animated:YES];
            else [shareActionSheet showFromTabBar:self.currentViewController.tabBarController.tabBar];   

            

        }
    }
    else    
    {
        waSitesString = [urlString valueOfParameterInUrlStringforKey:@"wasites"];
        [self prepareSharingForDestination:waSitesString];
    
     }      
}

///////////////////////////////////////////////////////////////////////////////
-(void)prepareSharingForDestination:(NSString*)theDestination{
    NSString *walink =   [urlString valueOfParameterInUrlStringforKey:@"walink"];
    NSString *watitle = [urlString valueOfParameterInUrlStringforKey:@"watitle"];
    //SLog (@"waLink:%@___ watitle:%@___ for url:%@___",walink,watitle,urlString);
    NSString *watext = [urlString valueOfParameterInUrlStringforKey:@"watext"];
    NSString * imageUrlString = [urlString urlByChangingSchemeOfUrlStringToScheme:@"http"];
    UIImage* myImage;
    if (![imageUrlString isLocalUrl])
    {
        myImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrlString]]];
        if (!myImage) myImage = [UIImage imageNamed:@"Default.png"];
    }
    else{
        myImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathOfFileWithUrl:imageUrlString]];
        if (!myImage) myImage = [UIImage imageNamed:@"Default.png"];
        
    }
    if ([theDestination isEqualToString:@"mail"])
        // Share by mail
        [self shareMailWithTitle:watitle withLink:walink withtText:watext withImage:myImage];
    else if (NSClassFromString(@"SLComposeViewController")){
        if ([theDestination isEqualToString:@"twitter"])
            // Share via Twitter
            [self shareWithType:SLServiceTypeTwitter withTitle:watitle withLink:walink withtText:watext withImage:myImage];
        if ([theDestination isEqualToString:@"facebook"])
            // Share via Facebook
            [self shareWithType:SLServiceTypeFacebook  withTitle:watitle withLink:walink withtText:watext withImage:myImage];
        
    }
    else [self showIos6Message];
    
    
}
///////////////////////////////////////////////////////////////////////////////

- (void) shareWithType: (NSString *)serviceType  withTitle:(NSString *)theTitle withLink:(NSString *)theLink withtText:(NSString*)theText withImage:(UIImage*)theImage
{
    //Check that class exists, only iOS>=6
    if (NSClassFromString(@"SLComposeViewController")){
        
        SLComposeViewController * servicePostVC = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        [servicePostVC setInitialText:theText];//Default
        if (serviceType == SLServiceTypeTwitter)[servicePostVC setInitialText:theTitle];//Make it shorter for Twitter
        [servicePostVC addImage:theImage];
        [servicePostVC addURL:[NSURL URLWithString:theLink]];

        [self.currentViewController presentViewController:servicePostVC
                                    animated:YES
                                    completion:^(void){
                                        [self removeFromSuperview];
                                    }];

        
        

 
    }

    
    
}


////////////////////////////////////////////////////////////////////////////////


-(void) shareMailWithTitle:(NSString *)theTitle withLink:(NSString *)theLink withtText:(NSString*)theText withImage:(UIImage*)theImage ;
{
    
    MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
    [mailComposeViewController setSubject:theTitle];
    NSString * completeText = [NSString stringWithFormat:@"%@ %@",theText,theLink];
    [mailComposeViewController setMessageBody:completeText isHTML:YES];
    [mailComposeViewController addAttachmentData:UIImageJPEGRepresentation(theImage, 0.9) mimeType:@"image/jpeg" fileName:@"Image.jpg"];
    mailComposeViewController.mailComposeDelegate = self;
    [self.currentViewController presentModalViewController:mailComposeViewController animated:YES];
    //SLog(@"Mail Composer presented");
    [mailComposeViewController release];

}


////////////////////////////////////////////////////////////////////////////////


-(void)showIos6Message
{
    
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                       message:NSLocalizedString(@"iOS 6 required",@"")
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        
 
 }





////////////////////////////////////////////////////////////////////////////////


#pragma mark -
#pragma mark ModuleView protocol

- (void)moduleViewWillAppear:(BOOL)animated{
}

- (void) moduleViewDidAppear{
    
}


- (void) moduleViewWillDisappear:(BOOL)animated{
}


- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}
- (void) moduleWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

- (void) moduleWillAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
}

- (void) jumpToRow:(int)row{
    
}


#pragma mark -
#pragma mark UIActionSheet protocol

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex == actionSheet.numberOfButtons-1){
		//The cancel button was clicked
		[self removeFromSuperview];
	}
	else {
		
        NSString * waSitesString = [urlString valueOfParameterInUrlStringforKey:@"wasites"];
         NSArray* sitesArray = [waSitesString componentsSeparatedByString:@","];
        NSString * chosenSite = [sitesArray objectAtIndex:buttonIndex];
        [self prepareSharingForDestination:chosenSite];

	}
    
    
	
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate protocol

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self.currentViewController dismissModalViewControllerAnimated:YES];
    [self removeFromSuperview];

}


#pragma mark -
#pragma mark UIActionSheetDelegate methods



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self removeFromSuperview];

}






@end
