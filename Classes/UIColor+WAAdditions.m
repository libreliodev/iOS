//
//  Librelio
//
//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import "UIColor+WAAdditions.h"

@implementation UIColor (WAAdditions)

+ (UIColor*)colorFromHex:(NSString *)hexString
{
    NSString *hexColor = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([hexColor length] < 6)
        return [UIColor blackColor];
    if ([hexColor hasPrefix:@"#"])
        hexColor = [hexColor substringFromIndex:1];
    if ([hexColor length] != 6 && [hexColor length] != 8)
        return [UIColor blackColor];
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    NSString *rString = [hexColor substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [hexColor substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [hexColor substringWithRange:range];
    
    range.location = 6;
    NSString *aString = @"FF";
    if ([hexColor length] == 8)
        aString = [hexColor substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b, a;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    [[NSScanner scannerWithString:aString] scanHexInt:&a];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:((float) a / 255.0f)];
}

/** @brief Returns a UIColor based on HexText or English name of color
 * Only a few color names are supported
 *	@param hex value or name of color
 *  @return UIColor
 **/
+ (UIColor*)colorFromString:(NSString *)string{
   if (!string) return [UIColor whiteColor];
    else if ([string isEqualToString:@"White"]) return [UIColor whiteColor];
    else if ([string isEqualToString:@"Black"]) return [UIColor blackColor];
    else if ([string isEqualToString:@"Clear"]) return [UIColor clearColor];
    else if ([string isEqualToString:@"Red"]) return [UIColor redColor];
    else if ([string isEqualToString:@"Blue"]) return [UIColor blueColor];
    else if ([string isEqualToString:@"Gray"]) return [UIColor grayColor];
    else if ([string isEqualToString:@"Green"]) return [UIColor greenColor];
    else if ([string isEqualToString:@"LightGray"]) return [UIColor lightGrayColor];
    else return [self colorFromHex:string];

    
}



@end
