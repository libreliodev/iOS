//
//  WASharePopover.h
//  Librelio
//
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WASharePopover : UIView <UIGestureRecognizerDelegate>{
    NSArray *shareItems;
}



@property (nonatomic,retain) NSArray *shareItems;
@property (nonatomic, assign) UIView <UIActionSheetDelegate> * delegate;

@property (nonatomic, retain) UIView *topMostView;
@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;


// It closes the SharePopover (remove from superview)
-(void)closeView;

- (void)buttonAction:(id)sender;



@end
