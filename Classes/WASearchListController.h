//
//  WASearchTableViewController.h
//  Librelio
//
//  Copyright (c) 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WASearchListController : UITableViewController{
    NSString *urlString;
    UIViewController* currentViewController;
    NSObject <WAParserProtocol> *parser;
    NSDictionary * currentQueryDic;
    
}

@property (nonatomic, assign)  UIView *presentingSearchView;
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, assign) UIViewController* currentViewController;
@property (nonatomic, retain) NSObject <WAParserProtocol> *parser;
@property (nonatomic, retain)  NSDictionary * currentQueryDic;


-(void) performButtonAction:(id)sender;
- (void)buttonAction:(id)sender;

- (void) followDetailLink:(NSString *) detailLink;


@end
