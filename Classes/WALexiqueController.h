//
//  WALexiqueController.h
//  Librelio
//
//  Created by svp on 02.02.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WAPageContainerController.h"



@interface WALexiqueController : UIViewController <UIWebViewDelegate, PageContainerItem>
{
    
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
// Datasrouce
@property (nonatomic, retain) NSArray *datasource;


@end
