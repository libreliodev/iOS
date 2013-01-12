#import "Font.h"

// Simple fonts
/*#import "Type1Font.h"
#import "TrueTypeFont.h"
#import "MMType1Font.h"
#import "Type3Font.h"

// Composite fonts
#import "Type0Font.h"
#import "CIDType2Font.h"
#import "CIDType0Font.h"*/


#pragma mark 

@implementation Font

@synthesize toUnicode,fontEncoding;

#pragma mark - Initialization

/* Factory method returns a Font object given a PDF font dictionary */
+ (Font *)fontWithDictionary:(CGPDFDictionaryRef)dictionary
{
	const char *type = nil;
	CGPDFDictionaryGetName(dictionary, "Type", &type);
	if (!type || strcmp(type, "Font") != 0) return nil;
	/*const char *subtype = nil;
	CGPDFDictionaryGetName(dictionary, "Subtype", &subtype);
    //SLog(@"FontSubtype:%s",subtype);
	const char *baseFont = nil;
	CGPDFDictionaryGetName(dictionary, "BaseFont", &baseFont);
    //SLog(@"BaseFont:%s",baseFont);
    CGPDFStreamRef value;
    if(CGPDFDictionaryGetStream(dictionary, "ToUnicode", &value))
    {
        //SLog(@"To Unicode found");
        
    }*/
    


	/*if (strcmp(subtype, "Type0") == 0)
	{
		return [[[Type0Font	alloc] initWithFontDictionary:dictionary] autorelease];
	}
	else if (strcmp(subtype, "Type1") == 0)
	{
		return [[[Type1Font alloc] initWithFontDictionary:dictionary] autorelease];
	}
	else if (strcmp(subtype, "MMType1") == 0)
	{
		return [[[MMType1Font alloc] initWithFontDictionary:dictionary] autorelease];
	}
	else if (strcmp(subtype, "Type3") == 0)
	{
		return [[[Type3Font alloc] initWithFontDictionary:dictionary] autorelease];
	}
	else if (strcmp(subtype, "TrueType") == 0)
	{
		return [[[TrueTypeFont alloc] initWithFontDictionary:dictionary] autorelease];
	}
	else if (strcmp(subtype, "CIDFontType0") == 0)
	{
		return [[[CIDType0Font alloc] initWithFontDictionary:dictionary] autorelease];
	}
	else if (strcmp(subtype, "CIDFontType2") == 0)
	{
		return [[[CIDType2Font alloc] initWithFontDictionary:dictionary] autorelease];
	}
	return nil;*/
    return [[[Font alloc] initWithFontDictionary:dictionary] autorelease]; 
}

/* Initialize with font dictionary */
- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict
{
    if ((self = [super init]))
	{
		// Populate the glyph widths store
		//[self setWidthsWithFontDictionary:dict];
		
		// Initialize the font descriptor
		//[self setFontDescriptorWithFontDictionary:dict];
		
		// Parse ToUnicode map
		[self setToUnicodeWithFontDictionary:dict];
        
        //Set Encoding
		[self setEncodingWithFontDictionary:dict];
		
		// NOTE: Any furhter initialization is performed by the appropriate subclass
	}
	return self;
}

#pragma mark Font Resources

/* Import font descriptor */
- (void)setFontDescriptorWithFontDictionary:(CGPDFDictionaryRef)dict
{
/*	CGPDFDictionaryRef descriptor;
	if (!CGPDFDictionaryGetDictionary(dict, "FontDescriptor", &descriptor)) return;
	FontDescriptor *desc = [[FontDescriptor alloc] initWithPDFDictionary:descriptor];
	self.fontDescriptor = desc;
	[desc release];*/
}

/* Populate the widths array given font dictionary */
- (void)setWidthsWithFontDictionary:(CGPDFDictionaryRef)dict
{
	// Custom implementation in subclasses
}

/* Parse the ToUnicode map */
- (void)setToUnicodeWithFontDictionary:(CGPDFDictionaryRef)dict
{
    CGPDFStreamRef stream;
	if (!CGPDFDictionaryGetStream(dict, "ToUnicode", &stream)) return;
	CMap *map = [[CMap alloc] initWithPDFStream:stream];
	self.toUnicode = map;
	[map release];
}

/* Set the encoding*/
- (void) setEncodingWithFontDictionary:(CGPDFDictionaryRef)dict{
	const char *encoding = nil;
	CGPDFDictionaryGetName(dict, "Encoding", &encoding);
    CGPDFDictionaryRef encodingDic;
    if(CGPDFDictionaryGetDictionary(dict, "Encoding", &encodingDic)){
        CGPDFDictionaryGetName(encodingDic, "BaseEncoding", &encoding);
        CGPDFArrayRef differencesArray;
        if (CGPDFDictionaryGetArray(encodingDic, "Differences", &differencesArray)){
            //SLog(@"%zu differences found",CGPDFArrayGetCount(differencesArray));
        }
        
    }
    
    self.fontEncoding = NSISOLatin1StringEncoding;//Defaut; there may be other cases to consider
    if (encoding){
        if (strcmp(encoding, "MacRomanEncoding") == 0) self.fontEncoding = NSMacOSRomanStringEncoding;
        else if (strcmp(encoding, "WinAnsiEncoding") == 0)self.fontEncoding = NSWindowsCP1252StringEncoding;
        
    }
    
}

#pragma mark Font Property Accessors

/* Subclasses will override this method with their own implementation */
- (NSString *)stringWithPDFString:(CGPDFStringRef)pdfString
{
   
    // Copy PDFString to NSString
   // NSString *string = (NSString *) CGPDFStringCopyTextString(pdfString);
	//return [string autorelease];
	if (self.toUnicode)
	{
		// Use ToUnicode map
		NSMutableString *unicodeString = [NSMutableString string];
        NSString * str =[NSString stringWithCString:(char *)CGPDFStringGetBytePtr(pdfString) encoding:NSISOLatin1StringEncoding];

        
		// Translate to Unicode
		for (int i = 0; i < [str length]; i++)
		{
            unichar cid = [str characterAtIndex:i];
		 	[unicodeString appendFormat:@"%C", [self.toUnicode characterWithCID:cid]];
		}
		
		return unicodeString;
	}
    NSString * data =[NSString stringWithCString:(char *)CGPDFStringGetBytePtr(pdfString) encoding:self.fontEncoding];
    return data;
}

/* Description is the class name of the object */
- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@>", [self.class description]];
}

/* Unicode character with CID */
- (NSString *)stringWithCharacters:(const char *)characters
{
	return 0;
}


#pragma mark Memory Management

- (void)dealloc
{
	[toUnicode release];
	[super dealloc];
}

@end
