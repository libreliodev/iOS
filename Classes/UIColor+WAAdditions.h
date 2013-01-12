//
//  UIColor+Hex.h
//  Librelio
//
//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (WAAdditions)
+ (UIColor*)colorFromHex:(NSString *)hexString;
+ (UIColor*)colorFromString:(NSString *)string;


@end
