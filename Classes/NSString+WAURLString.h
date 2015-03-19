//
//  NSString+NSString_WAURLString.h
//  Librelio
//
//  Copyright (c) 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface NSString (WAURLString)

- (BOOL) isLocalUrl;
- (NSString *) noHashPartOfUrlString;
- (NSString *) noArgsPartOfUrlString;
- (NSString *) schemePartOfUrlString;
- (NSString *) rootDirectoryNameOfUrlString;
- (NSString *) nameOfFileWithoutExtensionOfUrlString;
- (NSString *) titleOfUrlString;
- (NSString *) pathOfStorageForUrlString;
- (NSString *) urlOfUnzippedFolder;
- (NSString*) urlOfCacheFileWithName:(NSString*)fileName;
- (NSString*) urlByChangingExtensionOfUrlStringToSuffix:(NSString*)newSuffix;
- (NSString*) urlByChangingSchemeOfUrlStringToScheme:(NSString*)newScheme;
- (NSString*) urlBySubstitutingHyphensWithResolutionForOrientation:(UIInterfaceOrientation)orientation;
- (NSString*) urlByRemovingFinalUnderscoreInUrlString;
- (NSString*) urlOfMainFileOfPackageWithUrlString;
- (BOOL) isUrlStringOfSameFileAsUrlString:(NSString*) otherUrlString;
- (NSString *) valueOfParameterInUrlStringforKey:(NSString*)key;
- (NSString *) urlByAddingParameterInUrlStringWithKey:(NSString*)key withValue:(NSString*)value;
- (LinkType) typeOfLinkOfUrlString;
- (NSString*) classNameOfModuleOfUrlString;
- (ParserType) typeOfParserOfUrlString;
- (NSString*) classNameOfParserOfUrlString;
- (BOOL) shouldUseNewsstandForUrlString;

- (NSString*) appStoreProductIDForLibrelioProductID;
- (NSSet*) relevantLibrelioProductIDsForUrlString;
- (NSString *) titleWithSubscriptionLengthForAppStoreProductId:(NSString*)theId;

/**
 Checks wether the product corresponding to urlString has already been purchased or if there is an active subscription; returns the corresponding receipt if yes
 */
- (NSString*) receiptForUrlString;


- (NSString*) completeAdUnitCodeForShortCode:(NSString*)shortAdUnitCode;



/**
 Deprecated
 @attention: Will work only if value is a single word
 @discussion: For example, if Test = @"SELECT * FROM TableA", [Test queryStringByReplacingClause:@"FROM" withValue:@"TableB"] returns @"SELECT * FROM TableB"
 */
- (NSString*) queryStringByReplacingClause:(NSString*)clause withValue:(NSString*)newValue;

/**
 Deprecated
 @attention: will work only if value is a single word
 */
- (NSString*) valueOfClause:(NSString*)clause;

- (NSString*) gaScreenForModuleWithName:(NSString*)moduleName withPage:(NSString*)pageName;


- (NSString *)stringFormattedRTF;
- (NSString*)stringWithRTFHeaderAndFooter;

@end
