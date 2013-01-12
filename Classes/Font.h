/*
 *	Implements generic behavior of a font.
 *
 *	Most likely used exclusively for subclassing, for Type 0, Type 1 etc.
 *
 *	Ideally, the subclasses are hidden from the user, who interacts with them through this facade class.
 *	
 */
#import <Foundation/Foundation.h>
//#import "FontDescriptor.h"
#import "CMap.h"

@interface Font : NSObject {
	CMap *toUnicode;
    NSStringEncoding fontEncoding;
}

/* Factory method returns a Font object given a PDF font dictionary */
+ (Font *)fontWithDictionary:(CGPDFDictionaryRef)dictionary;

/* Initialize with a font dictionary */
- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict;

/* Populate the widths array given font dictionary */
- (void)setWidthsWithFontDictionary:(CGPDFDictionaryRef)dict;

/* Construct a font descriptor given font dictionary */
- (void)setFontDescriptorWithFontDictionary:(CGPDFDictionaryRef)dict;

/* Given a PDF string, returns a Unicode string */
- (NSString *)stringWithPDFString:(CGPDFStringRef)pdfString;


/* Import a ToUnicode CMap from a font dictionary */
- (void)setToUnicodeWithFontDictionary:(CGPDFDictionaryRef)dict;

- (void) setEncodingWithFontDictionary:(CGPDFDictionaryRef)dict;

/* Unicode character with CID */
- (NSString *)stringWithCharacters:(const char *)characters;

@property (nonatomic, retain) CMap *toUnicode;
@property (nonatomic, assign) NSStringEncoding fontEncoding;

@end
