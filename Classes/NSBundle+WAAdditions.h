//
//  NSFileManager+WAAdditions.h
//  Librelio
//
//  Copyright (c) 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSBundle (WAAdditions)

- (NSString *)stringForKey:(NSString *)key;
- (NSString *) pathOfFileWithUrl:(NSString*)relativeUrl ; //Returns the path of file if exists in Documents directory or Bundle directory, otherwise returns nil

- (NSString *) pathOfFileWithUrl:(NSString*)relativeUrl forOrientation:(UIInterfaceOrientation)orientation;
- (void) unzipFileWithUrlString:(NSString*) urlString;
- (int) countNumberOfReferencesForResourceWithUrlString:(NSString*) urlString;
@end
