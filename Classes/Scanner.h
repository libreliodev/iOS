#import <Foundation/Foundation.h>
//#import "StringDetector.h"
#import "FontCollection.h"
#import "RenderingState.h"
//#import "Selection.h"

@interface Scanner : NSObject {
	CGPDFOperatorTableRef operatorTable;
	//StringDetector *stringDetector;
	FontCollection *fontCollection;
	RenderingStateStack *renderingStateStack;
	//Selection *currentSelection;
	NSMutableString **rawTextContent;
    NSMutableString * currentString;

}


/* Start scanning (synchronous) */

- (void)scanPage:(CGPDFPageRef)page;

@property (nonatomic, retain) RenderingStateStack *renderingStateStack;
@property (nonatomic, retain) FontCollection *fontCollection;
//@property (nonatomic, retain) StringDetector *stringDetector;
@property (nonatomic, assign) NSMutableString **rawTextContent;
@property (nonatomic, retain) NSMutableString * currentString;
@end
