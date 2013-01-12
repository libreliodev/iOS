//
//  WABuyViewController.h
//  Librelio
//
//  Created by Volodymyr Obrizan on 07.02.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WABuyViewController : UIViewController


@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIButton *button;

- (void) openModule:(NSString*)urlString inView:(UIView *)pageView inRect:(CGRect)rect;
-(void)redraw;
@end
