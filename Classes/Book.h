//
//  Book.h
//  eBook
//
//  Created by 허지웅 on 10. 5. 11..
//  Copyright 2010 Techdigm Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject
{
	NSString *href;
	NSString *identifier;
	NSString *mediaType;
    NSString *mediaOverlayIdentifier;
    BOOL hasMediaOverlay;
}

@property (nonatomic,retain) NSString *href;
@property (nonatomic,retain) NSString *identifier;
@property (nonatomic,retain) NSString *mediaType;
@property (nonatomic,retain) NSString *mediaOverlayIdentifier;
@property BOOL hasMediaOverlay;

@end

@interface ItemRef : NSObject
{
	NSString *idref;
	NSString *linear;
	NSString *fullPath;
    NSString *href;
    NSString *mediaOverlayPath;
    BOOL hasMediaOverlay;
}

@property (nonatomic,retain) NSString *idref;
@property (nonatomic,retain) NSString *linear;
@property (nonatomic,retain) NSString *fullPath;
@property (nonatomic,retain) NSString *href;
@property (nonatomic,retain) NSString *mediaOverlayPath;
@property BOOL hasMediaOverlay;
@end


@interface Reference : NSObject
{
	NSString *href;
	NSString *type;
	NSString *title;	
}

@property (nonatomic,retain) NSString *href;
@property (nonatomic,retain) NSString *type;
@property (nonatomic,retain) NSString *title;

@end

/**
 NavPoint class holds information about navPoint entry in NavMap included in ncx file of epub.
*/
@interface NavPoint : NSObject
{
	/** chapterIndex */
    int chapterIndex;
    /** hash */
    NSString *hashLocation;
    /** identifer */
    NSString *identifier;
	/** play order */
    int playOrder;
	/** description */
    NSString *text;
	/** the relative path of content file */
    NSString *content;
	NSString *originalContent;
	/** the depth of indentation */
    int depth;
}

@property (nonatomic,retain) NSString *identifier,*text,*content,*originalContent,*hashLocation; //버그픽스
@property int chapterIndex,playOrder,depth; // 버그픽스

@end


@interface PlatformOption :NSObject {
    NSString *name;
    NSString *value;    
}
@property (nonatomic,retain) NSString *name,*value;
@end

@interface Platform :NSObject {
    NSString *name;
    NSMutableArray *platformOptions;   
}
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSMutableArray *platformOptions;

@end

@interface DisplayOptions : NSObject {
    NSMutableArray *platforms;
}
@property (nonatomic,retain) NSMutableArray *platforms;
@end

@interface MediaOverlayObject : NSObject {
    Byte kind;
}
@property Byte kind;

@end


@interface Sequence :MediaOverlayObject {
    NSMutableArray *mos;
    NSString *identifier;
    NSString *textReference;
    NSString *type;
}
@property (nonatomic,retain) NSMutableArray *mos;
@property (nonatomic,retain) NSString* identifier;
@property (nonatomic,retain) NSString* textReference;
@property (nonatomic,retain) NSString* type;
-(void)print;
-(NSMutableArray*)getParallelsByPageIndex:(int)pageIndex;
-(NSMutableArray*)getParallels;
@end

@interface Audio :MediaOverlayObject {
    NSString *identifier;
    NSString *source;
    NSString *clipBegin;
    NSString *clipEnd;
    NSTimeInterval intervalBegin;
    NSTimeInterval intervalEnd;
    NSString *fullPath;
}
@property (nonatomic,retain) NSString* identifier;
@property (nonatomic,retain) NSString* source;
@property (nonatomic,retain) NSString* fullPath;
@property (nonatomic,retain) NSString* clipBegin;
@property (nonatomic,retain) NSString* clipEnd;
@property NSTimeInterval intervalBegin;
@property NSTimeInterval intervalEnd;
-(void)calc;
-(void)print;
@end


@interface Text :MediaOverlayObject {
    NSString *identifier;
    NSString *source;
}
@property (nonatomic,retain) NSString* identifier;
@property (nonatomic,retain) NSString* source;
-(void)print;
@end

@interface Parallel:MediaOverlayObject {
    NSString* hash;
    int parallelIndex;
    int pageIndex;
    NSString *identifier;
    NSString *type;
    Audio *audio;
    Text *text;
}
@property (nonatomic,retain) NSString* identifier;
@property (nonatomic,retain) NSString* type;
@property (nonatomic,retain) Audio* audio;
@property (nonatomic,retain) Text* text;
@property (nonatomic,retain) NSString* hash;
@property int pageIndex,parallelIndex;
-(void)print;
@end


@class SkyPlayer;
@protocol SkyPlayerDelegate <NSObject>
-(void)didComplete:(SkyPlayer*)skyPlayer;
@end


@class AVPlayer;
@interface SkyPlayer:NSObject {
    AVPlayer* player;
    NSURL* mediaURL;
    NSTimeInterval clipBegin,clipEnd;
    NSTimeInterval currentTime;
    NSTimeInterval oldTime;
    double delta;
    BOOL isPaused;
    NSTimer *timer;
    id <SkyPlayerDelegate>delegate;
}
@property (nonatomic,retain) AVPlayer* player;
@property (nonatomic,retain) NSURL *mediaURL;
@property (nonatomic,retain) id delegate;
@property BOOL isPaused;
-(void)play:(NSURL*)url clipBegin:(NSTimeInterval)begin clipEnd:(NSTimeInterval)end;
-(void)pause;
-(void)stop;
-(void)resume;
@end


@class MediaOverlay;
@protocol MediaOverlayDataSource <NSObject>
-(void)makeParallels:(NSMutableArray*)parallels forMediaOverlay:(MediaOverlay*)mediaOverlay;
-(int)pageIndexForMediaOverlay:(MediaOverlay*)mediaOverlay;
@end

@protocol MediaOverlayDelegate <NSObject>
-(void)mediaOverlay:(MediaOverlay*)mediaOverlay didParallelStart:(Parallel*)parallel;
-(void)mediaOverlay:(MediaOverlay*)mediaOverlay didParallelComplete:(Parallel*)parallel;
-(void)parallelsDidComplete:(MediaOverlay*)mediaOverlay;
@end

@interface MediaOverlay:NSObject <SkyPlayerDelegate> {
    SkyPlayer* player;
    Parallel *currentParallel;
    NSMutableArray* parallels;
    int parallelIndex;
    BOOL isStarted;
    id <MediaOverlayDataSource> dataSource;
    id <MediaOverlayDelegate> delegate;    
}
@property (nonatomic,retain) id delegate;
@property (nonatomic,retain) id dataSource;
@property BOOL isStarted;
-(void)playParallel:(Parallel*)parallel;
-(void)playParallels;
-(void)playParallelByIndex:(int)pi;
-(Parallel*)getParallel:(int)pi;
-(int)parallelCount;
-(void)playNext;
-(void)playPrev;
-(void)play;
-(void)pause;
-(BOOL)isStarted;
-(BOOL)isPaused;
-(void)clear;
-(void)reset;
-(void)stop;
-(void)resume;
@end


@interface Book  : NSObject <NSXMLParserDelegate> {
	/** book code */
	int bookCode;
	/** default font size */
    int fontSize;
	/** default font name */
    NSString *fontName;
	NSString *bookCover;
	/** fileName for epub */
    NSString *fileName;
	NSString *ePubPath;
	NSString *opfPath;
	NSString *opfDir;
	NSString *ncxPath;
	NSString *ncxName;
	NSString *imagePath;
	int parserType;
    int ncxType;
	NSMutableString *currentElementValue;
	
    /** the title of epub */
	NSString *title;
	/** the creator of epub */
    NSString *creator;
	/** the publisher of epub */
    NSString *publisher;
	/** the subject of epub */
    NSString *subject;
	/** the source of epub */
    NSString *source;
	/** the rights of epub */
    NSString *rights;
    /** the identifier of epub */
	NSString *identifier;
	/** the language of epub */
    NSString *language;
	/** the date of epub */
    NSString *date;
	/** the type of epub */
    NSString *type;
    /** the description of epub */
    NSString* description;
	
	NSString* stackNo;
	
	int chapterIndex;
	int readCount;
	double pagePercent;
	BOOL isRent;
	BOOL isSerial;
	BOOL isDeleted;	
	NSDate* dueDate;
	NSString* downloadDate;
	NSString* lastReadDate;
	
	NSMutableArray *Manifest;
	NSMutableArray *Spine;
	NSMutableArray *Guide;
	/** Navigation Map containing NavPoint Objects */
    NSMutableArray *NavMap;
	
	NSString *currentImagePath;
	BOOL isCartoon;
    BOOL isFixedLayout;
    int fixedWidth;
    int fixedHeight;
    float fixedAspectRatio;
	
	int pTagCount;
	int imgTagCount;
	
	NSXMLParser *containerXMLParser;
	NSXMLParser *opfParser;
	NSXMLParser *ncxParser;
	NSXMLParser *chapterParser;	
	NavPoint *currentNavPoint;
	
	NSString *ncxId;
    /** the default lineSpace between text lines */
    int lineSpacing;	
	int depth; // 버그픽스 
    
    DisplayOptions *displayOptions;
    NSString *displayOptionsXMLPath;
    NSString *baseDirectory;
    
    BOOL isRTL;
	BOOL isVerticalWriting;
}

/** parses xml files in epub */
-(BOOL)parseXML:(NSString*)fileName;
-(BOOL)parseChapter:(NSString*)path;
-(BOOL)parseNcx;
-(BOOL)parseOpf;
-(Sequence*)parseMediaOverlay:(ItemRef *)itemRef;
-(BOOL)parseContainerXML;
-(NSString *)getChapterTitle:(int)chapterIndex;
-(BOOL)parseOpfSampleBook;
-(BOOL)parseXMLSampleBook:(NSString *)name;
-(int)getChapterIndexByNCXIndex:(int)ni;
-(NSString*)getOriginalContentByNCXIndex:(int)ni; // 버그픽스 
-(NSString *)getChapterTitle:(int)ci;
-(BOOL)parseDisplayOptions;
-(void)domTest;

@property (nonatomic,copy) NSString *fileName,*fontName;
@property (nonatomic,copy) NSString *ePubPath;
@property (nonatomic,copy) NSString *opfPath,*opfDir,*ncxPath,*ncxName,*ncxId,*imagePath;
@property int parserType;
@property (nonatomic,retain) NSMutableArray *Manifest;
@property (nonatomic,retain) NSMutableArray *Spine;
@property (nonatomic,retain) NSMutableArray *Guide;
@property (nonatomic,retain) NSMutableArray *NavMap;
@property (nonatomic,copy) NSString *currentImagePath;
@property (nonatomic,copy) NSString *title,*creator,*publisher,*subject,*source,*rights,*identifier,*language,*date,*type,*bookCover,*description;
@property BOOL isCartoon,isRent,isSerial;
@property int bookCode,fontSize,chapterIndex,pTagCount,imgTagCount,readCount;
@property double pagePercent;
@property (nonatomic,retain) NSDate *dueDate;
@property (nonatomic,retain) NSString*lastReadDate;
@property (nonatomic,retain) NSString*downloadDate;
@property (nonatomic,copy) NSString* stackNo;
@property BOOL isFixedLayout,isRTL,isVerticalWriting;
@property int fixedWidth;
@property int fixedHeight;
@property float fixedAspectRatio;
@property int lineSpacing;
@property (nonatomic,retain) DisplayOptions* displayOptions;
@property (nonatomic,retain) NSString *displayOptionsXMLPath;
@property (nonatomic,retain) NSString *baseDirectory;

@end
