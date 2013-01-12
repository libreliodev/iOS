//
//  WAPageContainerController.h
//  Librelio
//
//  Created by Volodymyr Obrizan on 27.01.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import <UIKit/UIKit.h>


////////////////////////////////////////////////////////////////////////////////


@class WAPageContainerController;

@protocol PageContainerItem

@optional
@property (nonatomic, assign) WAPageContainerController *containerController;

@end


////////////////////////////////////////////////////////////////////////////////


@interface WAPageContainerController : UIViewController
{
@private
    UIViewController *_selectedViewController;
}

@property (nonatomic, retain) UIViewController<PageContainerItem> *selectedViewController;
@property (nonatomic, retain) NSMutableArray *viewControllersStack;

-(id)init;
-(void)renderSelectedViewController;
-(void)removeSelectedViewController;
-(void)showViewController:(UIViewController<PageContainerItem> *)vc;
-(void)pushViewController:(UIViewController<PageContainerItem> *)vc;
-(void)popViewController;

+(CGRect)rectForClass:(NSObject *)class;

@end


////////////////////////////////////////////////////////////////////////////////