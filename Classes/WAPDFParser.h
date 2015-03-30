//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.

#import <Foundation/Foundation.h>
#import "WAParserProtocol.h"

typedef enum {
    Needed,
    Requested,
    Downloaded,
    NotNeeded
} ExtraInformationStatus;

@interface WAPDFParser : NSObject <WAParserProtocol,NSURLConnectionDelegate,NSURLConnectionDataDelegate>{
	int intParam,numberOfPages;
	NSString * urlString;
	CFURLRef pdfURL;//DO NOT USE CGPDFDocumentRef in an instance var, it produces crashes. Use CGPDFDocumentCreateWithURL every time you need it
    NSMutableArray * outlineArray;

    ExtraInformationStatus extraInfoStatus;
    NSFileHandle *currentConnFileHandle;
    NSString *currentConnPath;
}

@property (nonatomic, retain)  NSMutableArray * outlineArray;
@property (nonatomic, retain)   NSMutableString * currentString;


@property (nonatomic, retain) NSString * urlString;
@property int numberOfPages;

@property (nonatomic, retain) NSDictionary *linksUpdate;


- (NSArray*)getLinksOnPage:(int)page;
- (int) getPageNumber:(int)page;
- (void) generateCacheForAllPagesAtSize:(PDFPageViewSize)size;
- (NSString*) getImageUrlStringForPage:(int)page atSize:(PDFPageViewSize)size;
- (UIImage*) getImageForPage:(int)page atSize:(PDFPageViewSize)size;
- (void) addDrawPageOperationForPage :(int)page atSize:(PDFPageViewSize)size withPriority:(NSOperationQueuePriority)priority;
-(UIImage*) drawImageForPage:(int)page atSize:(PDFPageViewSize)size;
-(UIImage*) drawTileForPage:(int)page withTileRect:(CGRect)tileRect withImageRect:(CGRect)wholeRect;
- (CGRect) getRectAtPage:(int)page;

- (void) buildOutlineArray;
- (void) addOutlineChildrenFromDictionary:(CGPDFDictionaryRef)outlineDict atLevel:(int)level;

- (void) parseText;


-(void) deleteCorruptedFile;

- (void) cancelRelatedOperations;

@end

