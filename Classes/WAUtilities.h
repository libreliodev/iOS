//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.

#import <Foundation/Foundation.h>
#import "WAParserProtocol.h"
#import "WAModuleProtocol.h"




/**
 This class contains utility methods, and should be imported in all other classes.
 We now prefer to use categories, so most utilty methods are now in categories.
 */
@interface WAUtilities : NSObject {

}

+ (NSString *)cacheFolderPath;
+ (NSString *) hashPartOfUrlString:(NSString*)urlString; //Returns the part after the # sign
+ (NSDate *) dateOfFileWithUrlString:(NSString*)name;
+ (NSString*)directoryUrlOfUrlString:(NSString*)urlString;//Returns the Url of the directory
+ (NSString*) absoluteUrlOfRelativeUrl:(NSString*)relativeUrl relativeToUrl:(NSString*)baseUrl;
+ (NSString*) urlByChangingExtensionOfUrlString:(NSString*)urlString toSuffix:(NSString*)newExtension;
+ (NSString*) urlByRemovingContainingFolderIfSameNameInUrlString:(NSString*)urlString ;//If the url is in the form http://site/document/document.ext, returns http://site/document.ext
+ (BOOL) isCheckUpdateNeededForUrlString:(NSString*)urlString;//Returns true if the server should be queried to check wether a file is up to date

+ (BOOL)isDownloadMissingResourcesNeededForUrlString :(NSString*)urlString;

/**
 Retrieves UUID, generates one if needed.
 See http://stackoverflow.com/questions/11930425/send-a-unique-identifier-from-ios-device-to-a-webservice?rq=1
 */
+ (NSString *)getUUID;
+ (NSString *) completeDownloadUrlforUrlString:(NSString*)urlString;
+ (NSString *) getAuthorizingUrlForUrlString:(NSString*)urlString;
+ (NSString *) completeCheckAppStoreUrlforUrlString:(NSString*)urlString;
+ (NSString *) completeCheckPasswordUrlforUrlString:(NSString*)urlString;
+ (NSString *) completeCheckUsernamePasswordUrlforUrlString:(NSString*)urlString;
+(NSArray*) arrayOfImageUrlStringsForUrlString:(NSString *)lastImageUrlString;
+ (void) storeFileWithUrlString:(NSString*)urlString withData:(NSData *) data;
+ (void) storeFileWithUrlString:(NSString*)urlString withFileAtPath:(NSString*)tempFilePath;
+ (void) clearTempDirectory;
+ (void) deleteCorruptedResourceWithPath:(NSString*)path ForMainFileWithUrlString:(NSString*)urlString;
+ (BOOL) isBigScreen;
+ (BOOL) isScreenHigherThan500;
+ (BOOL) featuresInApps;
+ (NSString *) getCodeService;
+ (NSString *) getUserService;

+ (void) resizeNibView:(NSString*) nibName defaultNib:(NSString*) defaultNibName inView:(UIView*) containingView;
+ (CGSize) sizeForResizedNibView:(NSString*) nibName defaultNib:(NSString*) defaultNibName inRect:(CGRect)contaningRect;

+ (void)PDFDocument:(id)pdfDocument postNotificationForName:(NSString*)name object:(id)obj;

+ (CGRect)frameForSize:(CGSize)size withScreenSize:(CGSize)screenSize resizeMode:(ModuleResizeMode)resizeMode;

@end
