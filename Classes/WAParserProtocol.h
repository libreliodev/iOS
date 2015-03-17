//
//  WAParserProtocol.h
//  Librelio
//
//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.
//

typedef enum {
	ParserTypeSelf=0,
	ParserTypePDF=1,
	ParserTypeEPub=2,
    ParserTypeHTML=3,
    ParserTypePList=4,
    ParserTypeKML=5,
    ParserTypeSQLite=6,
    ParserTypeRSS=7,
    ParserTypeAtom=8,
    ParserTypeLocal=9,
    ParserTypeOAM=10,
    ParserTypeZip=11,
    ParserTypeFolio=12,


    
    
} ParserType;




typedef enum {
	DataColZero=0,
	DataColTitle=1,
	DataColSubTitle=2,
	DataColImage=3,
	DataColDetailLink=4,
	DataColIcon=5,
	DataColHTML=6,
	DataColLongitude=7,
	DataColLatitude=8,
	DataColDownload=9,
	DataColSample=10,
	DataColRead=11,
	DataColDelete=12,
	DataColDate=13,
    DataColRect=14,
    DataColSearch=15,
    DataColShare=16,
    DataColClass=17,
    DataColNib=18,
    DataColLogin =19,
    DataColAd=24,
    DataColDetail=25,
    DataColDismiss=26,
    DataColUnitPrice = 30,
    DataColMonthlySubscriptionPrice=31,
    DataColQuarterlySubscriptionPrice=32,
    DataColHalfYearlySubscriptionPrice=33,
    DataColYearlySubscriptionPrice=34,
    DataColNothing=999,
} DataCol;


typedef enum {
	PDFPageViewSizeSmall,
	PDFPageViewSizeBig
} PDFPageViewSize;



@protocol WAParserProtocol

@required

@property (nonatomic, retain) NSString *urlString;
@property int intParam;



- (UIImage *) getCoverImage;
- (NSString*) getDataAtRow:(int)row forDataCol:(DataCol)dataCol;
- (void) deleteDataAtRow:(int)row;
- (int) countData;
- (NSString*) getHeaderForDataCol:(DataCol)dataCol;
- (int)countSearchResultsForQueryDic:(NSDictionary*)queryDic;
- (NSString*) getDataAtRow:(int)row forQueryDic:(NSDictionary*)queryDic forDataCol:(DataCol)dataCol;

/*!
 Gets a list of all resources required to display the document. 
 For example, the html partser should return a list of images needed to display the page
 */
- (NSArray*) getRessources;

/*!
 Starts cache operations
 */
- (void) startCacheOperations;

/*!
 Get the progress of the minimal caching operations required for the document to display smoothly.
 For example, if 6 pages should be cached, and 2 pages have been cached, will return 2/6
 */
- (CGFloat) cacheProgress;

/*!
 Cancels pending cache operations
 */
- (void) cancelCacheOperations;

/*!
 @return: YES if download of resources should be completed before displaying the file
 */
- (BOOL) shouldCompleteDownloadResources;

- (BOOL) shouldGetExtraInformation;


@end
