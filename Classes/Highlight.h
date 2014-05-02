//
//  Highlight.h
//  eBook
//
//  Created by 하늘나무 on 10. 10. 25..
//  Copyright 2010 Techdigm Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Highlight Object */
@interface Highlight : NSObject {
	/** the unique code for highlight */
    int code;
    /** the book code that this highlight belongs to */
	int bookCode;
    /** the chapter index that this highlight belongs to */
	int chapterIndex;
    /** the highlight position in the chapter */
	float pagePercent;
	/** the start element index that this highlight covers */
    int startIndex;
	/** the start offset in start element index that this highlight covers */
    int startOffset;
	/** the end element index that this highlight covers */
    int endIndex;
	/** the end offset in the end element index that this highlight covers */
    int endOffset;
	/** highlight cololr */
    unsigned int highlightColor;
	/** whether this highlight is note or not */
    BOOL isNote;
    /** the text that this highlight covers */
	NSString *text;
    /** contains the text usr input */
	NSString *note;
    /** the background color for highlight */
	unsigned int backgroundColor;
	/** the y coodination of the highlight start point*/
    int top;
    /** the x coodination of the highlight start point. */
    int left;
    /** the page index where this highlight belongs to */
    int pageIndex;
    /** the String for Created Date Time */
    NSString* datetime;
    /** tells this highlight is used for search only - don't use the property */
    BOOL forSearch;
}

-(void)print;
-(BOOL)isEqual:(Highlight*)highlight;

@property (retain,nonatomic) NSString* note,*text,*datetime;
@property int code,bookCode,chapterIndex,startIndex,startOffset,endIndex,endOffset,top,left,pageIndex;
@property unsigned int highlightColor,backgroundColor;
@property float pagePercent;
@property BOOL isNote,forSearch;

@end
