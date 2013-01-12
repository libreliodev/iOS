//
//  WAShare.h
//  Librelio
//
//  Copyright (c) 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>


#import "WAModuleProtocol.h"



@interface WAShareView : UIView <UIActionSheetDelegate,WAModuleProtocol,MFMailComposeViewControllerDelegate,UIAlertViewDelegate>{
    
    NSString *urlString;
    UIViewController* currentViewController;
    
}

-(void)prepareSharingForDestination:(NSString*)theDestination;
- (void) shareWithType: (NSString *)serviceType  withTitle:(NSString *)theTitle withLink:(NSString *)theLink withtText:(NSString*)theText withImage:(UIImage*)theImage;
-(void) shareMailWithTitle:(NSString *)theTitle withLink:(NSString *)theLink withtText:(NSString*)theText withImage:(UIImage*)theImage;
-(void)showIos6Message;



@end
