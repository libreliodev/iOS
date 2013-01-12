//
//  NSDate+WAAdditions.h
//  Librelio
//
//  Copyright (c) 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (WAAdditions)

+ (NSDate*) dateWithHeaderString:(NSString *)headerString;
- (NSString*) headerString;

@end
