//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	LinkTypeSelf=0,
	LinkTypeRSS=1,
	LinkTypeVideo=2,
	LinkTypeSlideShow=3,
	LinkTypePaginated=4,
	LinkTypeMusic=5,
	LinkTypeMap=6,
	LinkTypeAnimation=7,
	LinkTypeGrid=8,
	LinkTypeText=9,
	LinkTypeBuy=10,
	LinkTypeRefresh=11,
	LinkTypeTable=13,
	LinkTypeDatabase=14,
	LinkTypeFileManager=15,
	LinkTypeExternal=16,
	LinkTypeHTML=17,
    LinkTypeChart=18,
    LinkTypeShare=19,
    LinkTypeSearch=20,
    LinkTypePlain=21,
    LinkTypeZoomImage=22,
    LinkTypeScan=23,
    LinkTypeOpenCVClient=24,
    LinkTypeAnalytics=25,
    LinkTypeAds=26,


    
} LinkType;







@protocol WAModuleProtocol <NSObject>

@optional

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@required

// Properties
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, assign) UIViewController* currentViewController;

- (void) moduleViewWillAppear:(BOOL)animated;
- (void) moduleViewDidAppear;
- (void) moduleViewWillDisappear:(BOOL)animated;
- (void) moduleWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void) moduleWillAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void) jumpToRow:(int)row;
@end
