//
//  NSDate+WAAdditions.m
//  Librelio
//
//  Copyright (c) 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import "NSDate+WAAdditions.h"

@implementation NSDate (WAAdditions)


+ (NSDate*) dateWithHeaderString:(NSString *)headerString{
    NSDateFormatter *df = [[[NSDateFormatter alloc] init]autorelease];  
    df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";  
    df.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];         
    df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];  
    NSDate * ret = [df dateFromString:headerString]; 
    return ret;
    
}
- (NSString*) headerString{
    NSDateFormatter *df = [[[NSDateFormatter alloc] init]autorelease];  
    df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";  
    df.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];         
    df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];  
    NSString * ret = [df stringFromDate:self]; 
    return ret;
    
    
}

@end
