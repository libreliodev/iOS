//
//  BookInformation.h
//  skyepub
//
//  Created by 하늘나무 on 13. 6. 25..
//  Copyright (c) 2013년 SkyTree. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookInformation : NSObject {
    /** the code of book */
    int bookCode;
    /** the filename of epub */
    NSString *fileName;
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
    /** the last reading position */
    double position;
    /** whether book is fixed layout or not. */
    BOOL isFixedLayout;
    /** whether book is downloaded or not */
    BOOL isDownloaded;
    /** the size of epub file */
    int fileSize;
    /** in grid view, the order index that user set */
    int customOrder;
    /** the url of epub where the epub was downloaded */
	NSString* url;
    /** the url of cover image where the epub was downloaded */
	NSString* coverUrl;
    /** the size of donwloaded */
	int downSize;
    /** whether user read or not */
	BOOL isRead;
    /** whether the epub is Right To Left */
	BOOL isRTL;
    /** whether the epub is Vertical writing */
	BOOL isVerticalWriting;
    /** whether the epub is paginated as gloabl */
	BOOL isGlobalPagination;
    /** the date string when the epub last was read */
	NSString* lastRead;
    /** whether the NavMap is paresed */
	BOOL parseNavMap;
    /** reserved */
	int port2;
}

@property (nonatomic,copy) NSString *fileName,*title,*creator,*publisher,*subject,*source,*rights,*identifier,*language,*date,*type;
@property BOOL isFixedLayout;
@property int bookCode;
@property double position;
@property int customOrder,downSize,port2,fileSize;
@property (nonatomic,copy) NSString* url,*coverUrl,*lastRead;
@property BOOL isRead,isRTL,isVerticalWriting,isGlobalPagination,parseNavMap,isDownloaded;

-(id)initWithBookName:(NSString*)bookName baseDirectory:(NSString*)baseDirectory contentProviderClass:(Class)contentProvider;

@end
