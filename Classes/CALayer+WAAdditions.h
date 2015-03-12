//
//  CALayer(XibConfiguration).h
//  Librelio
//
//  Based on http://stackoverflow.com/questions/12301256/is-it-possible-to-set-uiview-border-properties-from-interface-builder
//  Copyright (c) 2015 WidgetAvenue - Librelio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface CALayer(WAAdditions)

// This assigns a CGColor to borderColor.
@property(nonatomic, assign) UIColor* borderUIColor;

@end
