//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WAPDFParser.h"
#import <QuartzCore/QuartzCore.h>
#import "WAUtilities.h"
#import "WAOperationsManager.h"
#import "WADrawPageOperation.h"
#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.h"
#import "Scanner.h"

@interface WAPDFParser ()

- (int) countElderBrothersDescendants:(CGPDFDictionaryRef)pageDict currentCounter:(size_t)pageCounter;
- (CGRect) getAnnotationRect:(CGPDFDictionaryRef)annotDict inPageRef:(CGPDFPageRef)pageRef;
- (NSString*) getLinkFromActionDictionary:(CGPDFDictionaryRef) actionDict;
- (NSString*) getLinkFromDestArray:(CGPDFArrayRef)destArray;



@end


@implementation WAPDFParser

@synthesize intParam,numberOfPages,outlineArray,currentString;
#pragma mark -
#pragma mark Lifecycle functions


- (NSString *) urlString
{
    return urlString;
}

- (void) setUrlString: (NSString *) theString
{
    urlString = [[NSString alloc]initWithString: theString];
    
    

    //Check if cache exists and is up to date
    //Check if filenumber.txt exists
    NSString * fileNumberUrl = [WAUtilities urlOfCacheFileWithName:@"filenumber.txt" forDocumentWithUrlString:urlString];
    NSString * fileNumberPath = [[NSBundle mainBundle] pathOfFileWithUrl:fileNumberUrl];
    NSString * docPath = [[NSBundle mainBundle] pathOfFileWithUrl:urlString];
    NSNumber * fileNumber = [[[NSFileManager defaultManager] attributesOfItemAtPath:docPath error:NULL]objectForKey:NSFileSystemFileNumber];
    if (!fileNumberPath){
        //Create the filenumber.txt file to store the file number of the file we are caching
        NSData * tempData = [[fileNumber stringValue]dataUsingEncoding:NSUTF8StringEncoding];
        [WAUtilities storeFileWithUrlString:fileNumberUrl withData:tempData];
    }
    else {
        NSString * storedFileNumberString = [NSString stringWithContentsOfFile:fileNumberPath encoding:NSUTF8StringEncoding error:nil];
        if ([storedFileNumberString isEqualToString:[fileNumber stringValue]]){
            //SLog(@"no need to recreate cache");
        }
        else{
            //Delete cache directory, no longer valid
            NSString *dirUrl = [WAUtilities directoryUrlOfUrlString:fileNumberUrl] ;
            NSString * dirPath = [[NSBundle mainBundle] pathOfFileWithUrl:dirUrl];
            [[NSFileManager defaultManager]removeItemAtPath:dirPath error:NULL];
            //Create new filenumber.txt file to store the file number of the file we are caching
            NSData * tempData = [[fileNumber stringValue]dataUsingEncoding:NSUTF8StringEncoding];
            [WAUtilities storeFileWithUrlString:fileNumberUrl withData:tempData];
            
            
        }
    }

    
    
    
    NSString * pdfPath = [NSString stringWithFormat:@"file:%@",[[NSBundle mainBundle] pathOfFileWithUrl:urlString]];
	CFStringRef fileNameEscaped = CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)pdfPath, NULL, NULL,kCFStringEncodingUTF8);
	pdfURL = CFURLCreateWithString(NULL, fileNameEscaped, NULL);
	CFRelease(fileNameEscaped);

	CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL(pdfURL);
	if (!pdf) [self deleteCorruptedFile];
	numberOfPages = CGPDFDocumentGetNumberOfPages(pdf);
	CGPDFDocumentRelease(pdf);
   
    //Create the outlineArray
    outlineArray = [[NSMutableArray alloc]init];
    //[self buildOutlineArray];
    //SLog(@"Outline array built:%@",outlineArray);

    /*
    [self parseText];*/
    
    
    
    
    //Generate cache files if necessary
    [self generateCacheForAllPagesAtSize:PDFPageViewSizeBig];
	
	
	
	
	
}

-(void) deleteCorruptedFile{
	NSString * path = [[NSBundle mainBundle] pathOfFileWithUrl:urlString];
	if (path) [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}


- (void) cancelRelatedOperations{
    //SLog(@"Will cancel ops");
	NSArray * opsArray = [[[WAOperationsManager sharedManager] defaultQueue]operations];
	for (NSOperation * operation in opsArray){
        WADrawPageOperation * dpo = (WADrawPageOperation *) operation;
		WAPDFParser * pdfParser = dpo.pdfDocument;
		if ([pdfParser isEqual:self]){
            //SLog(@"Operation canceled");
			[dpo cancel];
            
		}
		

		
	}

	
}

- (void)dealloc {
	CFRelease(pdfURL);
	[urlString release];
    [currentString release];
    [outlineArray release];
   [super dealloc];
	
}









- (int) getPageNumber:(int)page{
	//Gets the page number from the pdf document, which may be different from the pagination used in this class; for example, page 1 may be the third page of the pdf when it includes a cover
	CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL(pdfURL);
	CGPDFPageRef pageRef = CGPDFDocumentGetPage(pdf, page);
	size_t ret  = CGPDFPageGetPageNumber(pageRef);
	//CGPDFPageRelease(pageRef);Do not release, it crashes the app
	CGPDFDocumentRelease(pdf);
	return ret;
	
	
}
#pragma mark -
#pragma mark PageView generation
- (void) generateCacheForAllPagesAtSize:(PDFPageViewSize)size{
	for (int i = 1; i <=numberOfPages; i++) 
	{
        NSString *fileName = [NSString stringWithFormat:@"page%isize%i.jpg",i,size];
        NSString *cacheUrl = [WAUtilities urlOfCacheFileWithName:fileName forDocumentWithUrlString:urlString]; 
        NSString * cachePath = [[NSBundle mainBundle] pathOfFileWithUrl:cacheUrl];
        if (!cachePath)[self addDrawPageOperationForPage:i atSize:size withPriority:NSOperationQueuePriorityNormal];		
	}
	
}

- (NSString*) getImageUrlStringForPage:(int)page atSize:(PDFPageViewSize)size{
	NSString *fileName = [NSString stringWithFormat:@"page%isize%i.jpg",page,size];
	NSString *cacheUrl = [WAUtilities urlOfCacheFileWithName:fileName forDocumentWithUrlString:urlString]; 
	NSString * cachePath = [[NSBundle mainBundle] pathOfFileWithUrl:cacheUrl];
    if (cachePath){
        return cachePath;
    }
    NSOperationQueuePriority priority = NSOperationQueuePriorityVeryHigh;//Higher priority than in batch
    if(size==PDFPageViewSizeSmall) priority = NSOperationQueuePriorityHigh;//Thumbnails are less important
    [self addDrawPageOperationForPage:page atSize:size withPriority:priority];
	return nil;
    
    
}
- (UIImage*) getImageForPage:(int)page atSize:(PDFPageViewSize)size{
	NSString * cachePath = [self  getImageUrlStringForPage:page atSize:size];
    if (cachePath){
        UIImage *ret = [UIImage imageWithContentsOfFile:cachePath];
        return ret;
    }
    return nil;
    
	
}

- (void) addDrawPageOperationForPage :(int)page atSize:(PDFPageViewSize)size withPriority:(NSOperationQueuePriority)priority{
    
    WADrawPageOperation *dpo = [[WADrawPageOperation alloc] init];
    dpo.drawSize = size;
    dpo.page = page;
    dpo.pdfDocument = self;
	[dpo setQueuePriority:priority];
    [[[WAOperationsManager sharedManager] defaultQueue] addOperation:dpo];
    [dpo release];
  
    
}

-(UIImage*) drawImageForPage:(int)page atSize:(PDFPageViewSize)size{
	CGFloat drawingSize = [UIScreen mainScreen].bounds.size.height;
	//If pagesPerScreenInLandscape (stored in intParam) is equal to 0, it means that we need to display fullwidth; in this case we need a larger drawing size
	if (intParam==0) {
		CGRect rect = [self getRectAtPage:page];
		if (rect.size.width) drawingSize = [UIScreen mainScreen].bounds.size.height*rect.size.height/rect.size.width;
	}
	if (size==PDFPageViewSizeSmall) drawingSize = drawingSize/8;
	CGRect rect = CGRectMake(0, 0, drawingSize, drawingSize);
	UIImage* ret = [self drawTileForPage:page withTileRect:rect withImageRect:rect];
	return ret;

}	


-(UIImage*) drawTileForPage:(int)page withTileRect:(CGRect)tileRect withImageRect:(CGRect)wholeRect{
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL(pdfURL);
	CGPDFPageRef pageRef = CGPDFDocumentGetPage(pdf, page);
	CGRect pageRect = CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox);
	CGFloat xCrop = pageRect.origin.x;
	CGFloat yCrop = pageRect.origin.y;
	CGFloat pdfWidth = pageRect.size.width;
	CGFloat pdfHeight = pageRect.size.height;
	CGFloat hScale = wholeRect.size.width/pdfWidth;
	CGFloat vScale = wholeRect.size.height/pdfHeight;
	CGFloat currentScale = MIN(hScale,vScale);
	wholeRect.size = CGSizeMake(pdfWidth*currentScale, pdfHeight*currentScale);//Adjust the wholeRect size so that it is proportional to the page size
	tileRect = CGRectIntersection(wholeRect, tileRect);//Adjust the tileRect size so it does not go outside the wholeRect

	//UIGraphicsBeginImageContext(rect.size);NOT MULTI THREADABLE
	//CGContextRef	context = UIGraphicsGetCurrentContext()		
	
	//Create Graphic context, based on Quartz 2D programming guide
	CGContextRef    context = NULL;
	CGColorSpaceRef colorSpace;
	void *          bitmapData;
	int             bitmapByteCount;
	int             bitmapBytesPerRow;
	int pixelsWide = tileRect.size.width;
	int pixelsHigh = tileRect.size.height;
	
	bitmapBytesPerRow   = (pixelsWide * 4);// 1
	bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
	colorSpace = CGColorSpaceCreateDeviceRGB();// 2
	bitmapData = malloc( bitmapByteCount );// 3
	context = CGBitmapContextCreate (bitmapData,// 4
									 pixelsWide,
									 pixelsHigh,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedLast);
	CGColorSpaceRelease( colorSpace );// 6
	
	
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextFillRect(context,CGRectMake(0, 0, tileRect.size.width, tileRect.size.height));
	
	CGContextTranslateCTM(context, -xCrop*currentScale-tileRect.origin.x, -yCrop*currentScale-wholeRect.size.height+tileRect.size.height+tileRect.origin.y);//The y coordinate system is inverted on pdf, starts from bottom
	
	//CGContextScaleCTM(context, 1.0, -1.0);
	CGContextScaleCTM(context, currentScale,currentScale);	
	
    //Do not remove the 2 following lines which prevent memory crashes
    //See http://stackoverflow.com/questions/2975240/cgcontextdrawpdfpage-taking-up-large-amounts-of-memory 
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh); 
    CGContextSetRenderingIntent(context, kCGRenderingIntentDefault);

	CGContextDrawPDFPage(context, pageRef);
	CGImageRef newImageRef = CGBitmapContextCreateImage(context);
	//SLog(@"Willl return tile for page %i withTileRect %f %f withImageRect %f %f",page,tileRect.size.width,tileRect.size.height,wholeRect.size.width,wholeRect.size.height);
	
	
	//ret = UIGraphicsGetImageFromCurrentImageContext();
	//UIGraphicsEndImageContext();
	UIImage * ret = [UIImage imageWithCGImage:newImageRef];
	// Clean up
	CGContextRelease(context);
	if (bitmapData) free(bitmapData);
	CGImageRelease(newImageRef);
	CGPDFDocumentRelease(pdf);
	return ret;
}	


#pragma mark -
#pragma mark Links handling

- (NSArray*)getLinksOnPage:(int)page{
	CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL(pdfURL);
	NSMutableArray *tempArray= [NSMutableArray array];
	int min= page;
	int max=page;
	//If page=999999, since there cannot be a page 999999, we consider that links on ALL pages should be returned
	if (page==999999){
		min=1;
		max=numberOfPages;
	}
	for (int j=min;j<=max;j++){
		CGPDFPageRef pageRef = CGPDFDocumentGetPage(pdf, j);
		CGPDFDictionaryRef	pageDict = CGPDFPageGetDictionary(pageRef);
		CGPDFArrayRef		annotsArray;
		if (!CGPDFDictionaryGetArray(pageDict, "Annots", &annotsArray)) continue;
        size_t annotsCount = CGPDFArrayGetCount(annotsArray);
        for (size_t i = 0; i < annotsCount ; i++) 
        {
            NSDictionary * tempDic;
            CGPDFDictionaryRef annotDict;
            if (!CGPDFArrayGetDictionary(annotsArray, i, &annotDict)) continue;
            CGRect linkRect = [self getAnnotationRect:annotDict inPageRef:pageRef];
            NSValue *rectValue = [NSValue valueWithCGRect:linkRect];
            
            
            //Check what type of annotation this is
            const char * subType = nil;
            if (!CGPDFDictionaryGetName(annotDict, "Subtype", &subType )) continue;
            //SLog(@"Annot detected:%s",subType);
            if (!strcmp(subType, "Link"))  //Annotation is a link
            {
                CGPDFDictionaryRef aLink;
                if (CGPDFDictionaryGetDictionary(annotDict, "A", &aLink)) 
                {
                    NSString * tempString = [self getLinkFromActionDictionary:aLink];
                    //SLog(@"Link:%@",tempString);
                    tempDic = [NSDictionary dictionaryWithObjectsAndKeys:rectValue,@"Rect",tempString,@"URL",nil];
                    [tempArray addObject:tempDic];
                    
                }
                else {
                    CGPDFArrayRef anotherArray;
                    if (CGPDFDictionaryGetArray(annotDict, "Dest", &anotherArray))  
                    {
                        NSString * tempString = [self getLinkFromDestArray:anotherArray];
                        tempDic = [NSDictionary dictionaryWithObjectsAndKeys:rectValue,@"Rect",tempString,@"URL",nil];
                        [tempArray addObject:tempDic];
                        
                        
                    }						
                }
                
                
            }
            else if  (!strcmp(subType, "RichMedia")) //Annotation  is a rich media
            {
                
                //SLog(@"Rich media detected");
                CGPDFDictionaryRef contentDic;
                if (CGPDFDictionaryGetDictionary(annotDict, "RichMediaContent", &contentDic)) 
                {
                    //SLog(@"found contentdic");
                    CGPDFDictionaryRef assetsNameTree;
                    if (CGPDFDictionaryGetDictionary(contentDic, "Assets", &assetsNameTree)) 
                    {
                        //SLog(@"found assets name tree");
                        CGPDFArrayRef		namesArray;
                        if (CGPDFDictionaryGetArray(assetsNameTree, "Names", &namesArray))
                        {
                            size_t namesCount = CGPDFArrayGetCount(namesArray);
                            for (size_t i = 0; i < namesCount ; i++) 
                            {
                                //SLog(@"found Names");
                                CGPDFStringRef nameString;
                                if (CGPDFArrayGetString(namesArray, i, &nameString))
                                {
                                    NSString *tempString = (NSString*)CGPDFStringCopyTextString(nameString);
                                    //SLog(@"Found String for %i:%@",i,tempString);
                                    CGPDFDictionaryRef fileSpecDic;
                                    if (CGPDFArrayGetDictionary(namesArray, i+1, &fileSpecDic)) 
                                    {
                                        CGPDFDictionaryRef streamDic;
                                        if (CGPDFDictionaryGetDictionary(fileSpecDic, "EF", &streamDic ) )
                                        {
                                            //SLog(@"Stream dic found for %i",i+1);
                                            CGPDFStreamRef streamData;
                                            if (CGPDFDictionaryGetStream(streamDic, "F", &streamData ) )
                                            {
                                                //SLog(@"Got data stream");
                                                CGPDFDataFormat fmt = CGPDFDataFormatRaw;
                                                NSData * data = (NSData *) CGPDFStreamCopyData( streamData, &fmt );
                                                [WAUtilities storeFileWithUrlString:tempString withData:data];
                                                [data release];
                                                
                                            }
                                            
                                        }
                                        
                                        
                                    }
                                    
                                    [tempString release];
                                    
                                    
                                }
                                
                                
                                
                                
                            }
                        }
                        
                    }
                    
                    
                    
                }
                
            }
    
                
                
                
            
            
            
            
        }
        
    }
		
		
		
	
	//CGPDFPageRelease(pageRef);//This crashes the app
	CGPDFDocumentRelease(pdf);
    
 	
	return tempArray;
	
		
	
	
	
}

- (NSString*) getLinkFromActionDictionary:(CGPDFDictionaryRef) actionDict{
    NSString * ret=nil;
    
    
    const char * sString = nil;
    if (CGPDFDictionaryGetName(actionDict, "S", &sString ) )
    {
         if (!strcmp(sString, "URI"))  //external URL
        {
            CGPDFStringRef uString;
            if (CGPDFDictionaryGetString (actionDict, "URI", &uString)){
                NSString *tempString = (NSString*)CGPDFStringCopyTextString(uString);
                ret = [NSString stringWithString:tempString];
                [tempString release];
             }
        }
        else if (!strcmp(sString, "JavaScript"))  //Javascript, partially supported: only this.getURL
        {
            CGPDFStringRef jString;
            if (CGPDFDictionaryGetString (actionDict, "JS", &jString)){
                NSString *tempString = (NSString*)CGPDFStringCopyTextString(jString);
                NSRange range = [tempString rangeOfString:@"this.getURL"];
                if (range.location != NSNotFound){
                    NSString * tempS = [tempString substringFromIndex:range.location];//extract substring starting with "this.getURL"
                    NSArray *parts = [tempS componentsSeparatedByString:@"'"];//extract argument of this.getURL ASSUMING ' HAS BEEN USED AND NOT "
                    if ([parts count]>1) {
                        NSString * tempUrlString = [parts objectAtIndex:1];
                        if (tempUrlString){
                            ret= tempUrlString;
                        }
                        
                    }									}
                [tempString release];
            }
        }
        else if (!strcmp(sString, "GoTo"))
        {
            
            CGPDFArrayRef anArray;
            //get "D" from aLink and resolve to page = dictionary of page
            if (CGPDFDictionaryGetArray(actionDict, "D", &anArray)) 
            {
                //get Dest Page Number from  anArray
                CGPDFDictionaryRef	aPageDic;
                if (CGPDFArrayGetDictionary(anArray, 0, &aPageDic))
                {
                    int pageCount = [self countElderBrothersDescendants:aPageDic currentCounter:0];
                    int destPage = pageCount + 1;
                    ret = [NSString stringWithFormat:@"goto://%i",destPage];//We use the gotoscheme for internal destinations
                    
                }
            }
        }
    }
    return ret;
    
}

- (NSString*) getLinkFromDestArray:(CGPDFArrayRef)destArray{
    NSString * ret = nil;
    //get Dest Page Number from  destArray
    CGPDFDictionaryRef	anotherPageDic;
    if (CGPDFArrayGetDictionary(destArray, 0, &anotherPageDic))
    {
        int pageCount = [self countElderBrothersDescendants:anotherPageDic currentCounter:0];
        int destPage = pageCount + 1;
        ret = [NSString stringWithFormat:@"goto://%i",destPage];//We use the gotoscheme for internal destinations
        
    }
    return ret;

    
}

- (CGRect) getAnnotationRect:(CGPDFDictionaryRef) annotDict inPageRef:(CGPDFPageRef)pageRef{
	CGFloat linkPoints[4] = {0.0,0.0,0.0,0.0};
	CGPDFArrayRef anArray;
	CGRect linkrect;
	if (CGPDFDictionaryGetArray(annotDict, "Rect", &anArray))
	{
		for (size_t j = 0; j < 4; j++)
		{
			if (CGPDFArrayGetNumber(anArray, j, &linkPoints[j]))
			{
				
			}
			
		}
		
		
		CGRect documentRect = CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox);
		//SLog(@"documentRect: %f, %f, %f, %f", documentRect.origin.x,documentRect.origin.y,documentRect.size.width,documentRect.size.height);
		//We need to make some conversions in order to match coordinate systems.
		linkrect.origin.x = linkPoints[0]- documentRect.origin.x;
		linkrect.origin.y = documentRect.size.height+documentRect.origin.y - linkPoints[3];
		linkrect.size.width = linkPoints[2] - linkPoints[0];
		linkrect.size.height = linkPoints[3] - linkPoints[1];
		//SLog(@"Annot Rect: %f, %f, %f, %f", linkrect.origin.x,linkrect.origin.y,linkrect.size.width,linkrect.size.height);
		
		return linkrect;
	}
	
	
	return  linkrect;
	
	
}


- (void) buildOutlineArray{
	CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL(pdfURL);
    CGPDFDictionaryRef pdfCatalog = CGPDFDocumentGetCatalog(pdf);
    CGPDFDictionaryRef outlines;
    if (CGPDFDictionaryGetDictionary(pdfCatalog, "Outlines", &outlines)){
         //SLog(@"Outlines found");
        [self addOutlineChildrenFromDictionary:outlines atLevel:1];
     }

	CGPDFDocumentRelease(pdf);
	
}


- (void) addOutlineChildrenFromDictionary:(CGPDFDictionaryRef)outlineDict atLevel:(int)level{
    //Get title
    CGPDFStringRef titleString;
    NSString *tempTitle = nil;
    NSString * tempLink = nil;
    if (CGPDFDictionaryGetString(outlineDict, "Title", &titleString))
    {
        tempTitle = [NSString stringWithString:(NSString*)CGPDFStringCopyTextString(titleString)];
        //Add spaces before the title depending on level
        if (level>2){
            NSString *spaces = @"  ";
             // Capacity does not limit the length, it's just an initial capacity
            NSMutableString *repeatedSpaces = [NSMutableString stringWithCapacity:[spaces length] * level]; 
            
            int i;
            for (i = 0; i < level-2; i++)
                [repeatedSpaces appendString:spaces];
            
            tempTitle = [NSString stringWithFormat:@"%@%@",repeatedSpaces,tempTitle];
        }
        [tempTitle release];
     }
    
    //Get link
    CGPDFDictionaryRef aLink;
    if (CGPDFDictionaryGetDictionary(outlineDict, "A", &aLink)) 
    {
        tempLink = [self getLinkFromActionDictionary:aLink];
        
    }
    else {
        CGPDFArrayRef anotherArray;
        if (CGPDFDictionaryGetArray(outlineDict, "Dest", &anotherArray))  
        {
            tempLink = [self getLinkFromDestArray:anotherArray];
            
            
        }						
    }
    NSDictionary * tempDic = [NSDictionary dictionaryWithObjectsAndKeys:tempTitle,@"Title",tempLink,@"Link",nil];

    if (tempTitle) [outlineArray addObject:tempDic];
    //SLog(@"Added outline item %@ at level %i",tempTitle,level);


    
    //Go to next or child
    CGPDFDictionaryRef firstOutline;//Represents the first child
    CGPDFDictionaryRef nextOutline;
    if (CGPDFDictionaryGetDictionary(outlineDict, "First", &firstOutline)){
        [self addOutlineChildrenFromDictionary:firstOutline atLevel:level+1];
    }
    if (CGPDFDictionaryGetDictionary(outlineDict, "Next", &nextOutline)){
        [self addOutlineChildrenFromDictionary:nextOutline atLevel:level];
    }
     
    
}


- (int) countElderBrothersDescendants:(CGPDFDictionaryRef)pageDict currentCounter:(size_t)pageCounter{
	CGPDFDictionaryRef parent;
	
	if (CGPDFDictionaryGetDictionary(pageDict, "Parent", &parent))
	{
		CGPDFArrayRef kids;
		CGPDFDictionaryGetArray(parent, "Kids", &kids);
		
		size_t kidsCount = CGPDFArrayGetCount(kids);
		
		for (size_t i = 0; i < kidsCount; i++) 
		{
			CGPDFDictionaryRef kid;  
			CGPDFArrayGetDictionary(kids, i, &kid);
			if (kid == pageDict)
			{
				break;
			}
			else {
				CGPDFInteger leafCount;
				
				if (CGPDFDictionaryGetInteger(kid, "Count", &leafCount)){
					//kid is a page tree, and has descendants
					pageCounter += leafCount;
					
				}
				else {
					//kid is a page,has only itself as descendant
					pageCounter += 1;
				}
			}
			
			
		}
		pageCounter = [self countElderBrothersDescendants:(CGPDFDictionaryRef)parent currentCounter:pageCounter];
		
		
	}
	return pageCounter;
	
}

- (CGRect) getRectAtPage:(int)page{
	CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL(pdfURL);
	CGPDFPageRef pageRef = CGPDFDocumentGetPage(pdf, page);
	CGRect documentRect = CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox);
	//CGPDFPageRelease(pageRef);Do not release, it crashes the app
	CGPDFDocumentRelease(pdf);
	return documentRect;
	
}

#pragma mark -
#pragma mark Text extraction


- (void) parseText {
    
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL(pdfURL);
    CGPDFPageRef pageRef = CGPDFDocumentGetPage(pdf, 8);
    

	Scanner *scanner = [[Scanner alloc] init];
	[scanner scanPage:pageRef];

}
    


#pragma mark -
#pragma mark Parser protocol



- (UIImage *) getCoverImage{
    if ([self countData]) return  [self drawImageForPage:1 atSize:PDFPageViewSizeSmall];
    else return nil;
}
- (NSString*) getDataAtRow:(int)row forDataCol:(DataCol)dataCol{
	NSString * ret = nil;
    
    
	switch (dataCol) {
		case DataColTitle:
			break;
		case DataColSubTitle:
			break;
		case DataColImage:{
            ret = [self getImageUrlStringForPage:row atSize:PDFPageViewSizeSmall];	
 			break;
        }
		case DataColRect:{
            ret = NSStringFromCGRect( [self getRectAtPage:row] );	
 			break;
        }
		default:
			ret = nil;
	}
	return ret;
}

- (int) countData{
	return numberOfPages;
	
}


- (void) deleteDataAtRow:(int)row{
    
    
}

- (void) startCacheOperations{
    //First, we need to erase the temp cache directory that might still exist due to background operations
    NSString * tempCacheDirUrlString = [WAUtilities urlOfCacheFileWithName:@"" forDocumentWithUrlString:urlString];
    [[NSFileManager defaultManager]removeItemAtPath:[[NSBundle mainBundle] pathOfFileWithUrl:tempCacheDirUrlString] error:nil];//Delete existing cache dir
    //Now, we can start caching
    [self generateCacheForAllPagesAtSize:PDFPageViewSizeBig];

    
}


- (void) cancelCacheOperations{
    [self cancelRelatedOperations];

}

- (BOOL) shouldCompleteDownloadResources{
    return YES;
}



- (NSString*) getHeaderForDataCol:(DataCol)dataCol{
	NSString * ret = nil;
	return ret;
}

- (int)countSearchResultsForQueryDic:(NSDictionary*)queryDic{
    
    return [outlineArray count];
}

- (NSString*) getDataAtRow:(int)row forQueryDic:(NSDictionary*)queryDic forDataCol:(DataCol)dataCol{
	NSString * ret = nil;
    NSDictionary * rowDic = [outlineArray objectAtIndex:row-1];
    //SLog(@"rowdic:%@",rowDic);
    
    
	switch (dataCol) {
		case DataColTitle:
            ret = [rowDic objectForKey:@"Title"];
			break;
		case DataColDetailLink:
            ret = [rowDic objectForKey:@"Link"];
			break;
		case DataColImage:{
            //ret = [self getImageUrlStringForPage:row atSize:PDFPageViewSizeSmall];	
 			break;
        }
		default:
			ret = nil;
	}
	return ret;
}


- (NSArray*) getRessources{
    
    
    NSArray * annotLinksArray = [self getLinksOnPage:999999];//Conventionally, getLinksOnPage:999999 means getLinks on allPages
    NSMutableArray *tempArray= [NSMutableArray array];
    //SLog(@"found %i annotations",[tempArray count]);
    for (NSDictionary *annotDic in annotLinksArray){
        NSString * resourceUrlString = [annotDic objectForKey:@"URL"];
        if ([resourceUrlString isLocalUrl]) {
            //Remove the args
            NSString * noArgsUrl = [resourceUrlString noArgsPartOfUrlString];
            
            NSArray * imagesArray;
            
            if ([resourceUrlString typeOfLinkOfUrlString]==LinkTypeSlideShow){
                //In this case, we need to add all images to the download list
                imagesArray = [WAUtilities arrayOfImageUrlStringsForUrlString:noArgsUrl];
            }
            else{
                //Simply add the url
                
                imagesArray = [NSArray arrayWithObject:noArgsUrl];
                
            }
            [tempArray addObjectsFromArray:imagesArray];
             
        } 
        
        
    }
    //Add the cover image
	NSString *noUnderscoreUrlString = [urlString urlByRemovingFinalUnderscoreInUrlString];//Remove the final underscore]
    NSString * imgUrl = [WAUtilities urlByChangingExtensionOfUrlString:noUnderscoreUrlString toSuffix:@".png"];//Change extension to png
    NSString * relativeCoverUrl = [imgUrl lastPathComponent];//Use relative Url
    [tempArray addObject:relativeCoverUrl];

    return tempArray;

    
    
}

- (CGFloat) cacheProgress{
    //Count the number of generated cache files
    NSString * tempCacheDirUrlString = [WAUtilities urlOfCacheFileWithName:@"" forDocumentWithUrlString:urlString];
    NSString * tempPath = [[NSBundle mainBundle] pathOfFileWithUrl:tempCacheDirUrlString];
    int nFiles = [[[NSFileManager defaultManager]contentsOfDirectoryAtPath:tempPath error:nil] count];
    //SLog(@"nFiles:%i",nFiles);
    
    //If the document has more that 6 pages, we want at least 2x6 files in the cache, otherwise we want all pages
    int neededFiles = 2 * MIN(6,[self countData]);
    neededFiles = MAX(1, neededFiles);//Avoid 0 value
    return (float)nFiles/(float)neededFiles ;

}


@end