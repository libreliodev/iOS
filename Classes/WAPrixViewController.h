//
//  WAPrixViewController.h
//  Librelio
//
//  Created by svp on 24.01.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WAPageContainerController.h"


@interface WAPrixViewController : UIViewController<PageContainerItem, UITextFieldDelegate>

@property (nonatomic, retain) NSMutableDictionary *minMaxValues;

@property (nonatomic, assign) WAPageContainerController *containerController;

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *subscriptLabel;
@property (nonatomic, retain) IBOutlet UILabel *miniLabel;
@property (nonatomic, retain) IBOutlet UILabel *maxiLabel;
@property (nonatomic, retain) IBOutlet UITextField *miniField;
@property (nonatomic, retain) IBOutlet UITextField *maxiField;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

// User actions
-(IBAction)backButtonClicked:(id)sender;
-(IBAction)valueChange:(id)sender;

- (void)registerForKeyboardNotifications;

@end
