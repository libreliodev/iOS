//
//  WASearch.h
//  Librelio
//
//  Copyright (c) 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WAModuleProtocol.h"

@interface WASearchView : UIView <WAModuleProtocol,UIPopoverControllerDelegate>{
    
    NSString *urlString;
    UIViewController* currentViewController;
    UIPopoverController *popover;
    
}

@property (nonatomic, retain)  UIPopoverController *popover;


@end
