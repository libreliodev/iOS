//
//  CALayer(XibConfiguration).m
//  Librelio
//
//  Copyright (c) 2015 WidgetAvenue - Librelio. All rights reserved.
//

#import "CALayer+WAAdditions.h"

@implementation CALayer(WAAdditions)

-(void)setBorderUIColor:(UIColor*)color
{
    self.borderColor = color.CGColor;
}

-(UIColor*)borderUIColor
{
    return [UIColor colorWithCGColor:self.borderColor];
}

@end
