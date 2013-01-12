//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WAPDFParserView.h"
#import "WAUtilities.h"
#import "WAButtonWithLink.h"
#import "WAOperationsManager.h"

#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.h"
#import "UIImage+WAAdditions.h"

#import "GANTracker.h"


@implementation WAPDFParserView

@synthesize pdfDocument,activityIndicator,audioPlayer;




- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		
		self.userInteractionEnabled = YES;//By default, user interactions seem to be disabled in UIImageViews
 
		//Add UIActivityIndicatorView
		activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[self addSubview:activityIndicator];
		activityIndicator.tag = 998;
		
		
		
		//Add observers
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndDrawPageOperationWithNotification:) name:@"didEndDrawPageOperation" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeVisiblePageViewsWithNotification:) name:@"didChangeVisiblePageViews" object:nil];


		

    }
    return self;
}

- (void) setPage:(int)newPage{
	if (page!=newPage){
        //SLog(@"setpage newPage:%i oldPage:%i,x:%f,width:%f",newPage,page,self.frame.origin.x,self.frame.size.width);
		[self didBecomeInvisible];
        if ((newPage>0)&&(newPage<=[pdfDocument countData])){
            UIImage * img = [(WAPDFParser*) pdfDocument getImageForPage:newPage atSize:PDFPageViewSizeBig];
            if (img) {
                //SLog(@"Image for page %i already available",newPage);
                self.image = img;
                [activityIndicator stopAnimating];
                
            }
            else {
                //Add a white page and animate activityIndicator
                self.image = [UIImage imageNamed:@"Placeholder.png"];
                activityIndicator.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
                activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin);
                [activityIndicator startAnimating];
                 
            }
            
            
        }

		page = newPage;
	}
		
	
}

- (int) page{
	return page;
}

/**- (void)layoutSubviews 
{
	[super layoutSubviews];
	
	
}**/		

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	//Stop movie in case it is playing
	[audioPlayer release];
	[activityIndicator release];

	[super dealloc];
}




#pragma mark -
#pragma mark Notifications
- (void) didChangeVisiblePageViewsWithNotification:(NSNotification *) notification
{
	
	NSArray *pageViewsArray = notification.object;
	if ([pageViewsArray containsObject:self]) [self didBecomeVisible];
	else [self didBecomeInvisible];
}



- (void) didEndDrawPageOperationWithNotification:(NSNotification *) notification
{
	NSString *returnedCacheUrl = notification.object;

	
	NSRange pageRange = [returnedCacheUrl rangeOfString:@"page"];
	NSRange sizeRange = [returnedCacheUrl rangeOfString:@"size"];
	NSRange pageNumberRange = NSMakeRange(pageRange.location+4, sizeRange.location-(pageRange.location+4));
	int returnedPage = [[returnedCacheUrl substringWithRange:pageNumberRange]intValue];
	NSRange sizeNumberRange = NSMakeRange(sizeRange.location+4,[returnedCacheUrl length]-(sizeRange.location+4));
	int drawSize = [[returnedCacheUrl substringWithRange:sizeNumberRange]intValue];
	
	
	NSString * returnedPdfUrl = [[WAUtilities directoryUrlOfUrlString:returnedCacheUrl]stringByReplacingOccurrencesOfString:@"_cache" withString:@".pdf"] ;
    
    NSString * neededPdfUrl = [pdfDocument.urlString noArgsPartOfUrlString];
    neededPdfUrl = [WAUtilities absoluteUrlOfRelativeUrl:neededPdfUrl relativeToUrl:@""];
    
   //SLog(@"returnedPage:%i , neededPage:%i, returnedSize:%i ",returnedPage,self.page,drawSize);
    //SLog(@"returnedCacheUrl:%@",returnedCacheUrl);
    //SLog(@"returnedPDF:%@ neededPDF:%@",returnedPdfUrl,neededPdfUrl);

	
	//Test if the document of the notification is our current document; this might not be the case if antoher document was opened before
	 if ([returnedPdfUrl isEqualToString:neededPdfUrl]){
		//Test if this is the page and size we need
		if ((self.page==returnedPage)&&(drawSize==PDFPageViewSizeBig)){
            //SLog(@"Received new image for page %i",self.page);
            UIImage * img = [(WAPDFParser*) pdfDocument getImageForPage:returnedPage atSize:PDFPageViewSizeBig];
            self.image = img;
            [activityIndicator stopAnimating];
            [self increaseTiledViewDetail];


		}
	}
}




#pragma mark -
#pragma mark Visibility 

- (void) didBecomeVisible {
    //Check if the TiledView exists; if it does, it means that the page was already visible
    if (![self viewWithTag:999]){
        //There is a lot of work, stop the NSOperations to save memory
        [[[WAOperationsManager sharedManager] defaultQueue] setSuspended:YES];
        
        //Add buttons for all links
        NSArray * tempArray = [(WAPDFParser*) pdfDocument getLinksOnPage:self.page];
        CGRect pageRect = CGRectFromString([pdfDocument getDataAtRow:self.page forDataCol:DataColRect]);
        CGFloat scale = (pageRect.size.width>0)?self.frame.size.width/pageRect.size.width:0;
        for (NSDictionary * tempDic in tempArray){
            NSValue *rectValue = [tempDic objectForKey:@"Rect"];
            CGRect rect = [rectValue CGRectValue];
            CGRect scaledRect = CGRectMake(rect.origin.x*scale, rect.origin.y*scale, rect.size.width*scale, rect.size.height*scale);
            [self addButtonInRect:scaledRect withLink:[tempDic objectForKey:@"URL"] atScale:scale];		
        }
        [self addTiledView];
        [[[WAOperationsManager sharedManager] defaultQueue] setSuspended:NO];
        
        //Register page View with Google Analytics, only if page>0 (which sometimes happen erroneously)
        if (page>0){
            NSString * pageString = [pdfDocument.urlString gaVirtualUrlForModuleWithName:@"documents" withPage:[NSString stringWithFormat:@"page%i",page]];
            
            NSError *error;
            if (![[GANTracker sharedTracker] trackPageview:pageString
                                                 withError:&error]) {
                NSLog(@"error in trackPageview");
            }
            
        }


        
    }
    else{
        //Remove the tileview, and create it again, otherwise, for some reason, it does not reize properly when the orientaiton is changed
        [[self viewWithTag:999]removeFromSuperview];
        //SLog(@"Removed from superview in didBecomeVisible");
        [self addTiledView];
       
        
        
    }

	//SLog(@"did become visible:page %i with %i subviews",self.page, [[self subviews]count]);

}

- (void) didBecomeInvisible {

	//Stop movie
	
	//Stop sound
	[audioPlayer stop];

	//Remove all subviews
	for (UIView * view in [self subviews]){
		if (view.tag !=998) {//998 is the tag number of activityIndicator
			[view removeFromSuperview];
		}
		
	}
	
	//Set audioPlayer to nil so that another music can potentially be loaded
	audioPlayer = nil;


}



#pragma mark -
#pragma mark Buttons
- (void) addButtonInRect:(CGRect)rect withLink:(NSString*)urlString atScale:(CGFloat)scale{
    //SLog(@"Will add button at scale %f",scale);
	WAButtonWithLink *button =  [WAButtonWithLink buttonWithType:UIButtonTypeCustom];
	button.frame = rect;
	button.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin);
	button.backgroundColor = [UIColor clearColor];
	button.showsTouchWhenHighlighted = YES;

	//Put the URL of the link (without hash) in the title, and make it invisible
	NSString *noHash = [urlString noHashPartOfUrlString];
	button.link = noHash;

	//If there is a hash with autoplay, or a wabutton or waplay arg there is some more work
	NSString *hash = [WAUtilities hashPartOfUrlString:urlString];//the autoplay after the hash is deprecated (now we use waplay=auto), but we keep it here for back compatibility reasons
	if ([hash isEqualToString:@"autoplay"]||[[urlString valueOfParameterInUrlStringforKey:@"waplay"] isEqualToString:@"auto"]){
		[self.superview.superview  performSelector:@selector(performLinkAction:) withObject:button afterDelay:0];//The action is handled by the ScreenView instance, which is parent of containerView which is parent of self
	}
	else{
		NSString * buttonPath= [urlString valueOfParameterInUrlStringforKey:@"wabutton"];
		if (buttonPath){
			NSString * buttonUrl =  [WAUtilities absoluteUrlOfRelativeUrl:buttonPath relativeToUrl:pdfDocument.urlString];
			NSString *imPath = [[NSBundle mainBundle] pathOfFileWithUrl:buttonUrl];
			UIImage * originalImage = [UIImage imageWithContentsOfFile:imPath];
			CGSize scaledSize = CGSizeMake(originalImage.size.width*scale, originalImage.size.height*scale);
			UIImage * scaledImage = [originalImage imageScaledToSize:scaledSize];
			
			[button setImage:scaledImage forState:UIControlStateNormal];
			
		}
		
	}
	
	
	[button addTarget:self.superview.superview action:@selector(performLinkAction:) forControlEvents:UIControlEventTouchUpInside];//The action is handled by the ScreenView instance, which is parent of containerView which is parent of self
	[self addSubview:button];
	
}

#pragma mark -
#pragma mark Tiling

-  (void) addTiledView{
	if (![self viewWithTag:999]){
		WATilingView * tilingView = [[WATilingView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        //SLog(@"Adding tiledview %@ for view %@",tilingView,self);
		[self addSubview:tilingView];
		[self sendSubviewToBack:tilingView];
		tilingView.tag = 999;
		tilingView.pdfDocument = (WAPDFParser*) pdfDocument;
		tilingView.page = page;
        [self increaseTiledViewDetail];

		[tilingView release];

	}

}
/** 
 *  @brief Increases the levelsOfDetailBias of the TilingView's CATileLayer, only if activityIndicator is not animating (otherwise, it is quicker to display TIlingView with a lower resolution
 **/
- (void) increaseTiledViewDetail{
    //SLog(@"Increasing tiledview detail");
    if ([self viewWithTag:999]&& ![activityIndicator isAnimating]){
        CATiledLayer *tiledLayer = (CATiledLayer *)[[self viewWithTag:999] layer];
        //Settings should be different for retina and non retina displays
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00) {
            // RETINA DISPLAY
            tiledLayer.levelsOfDetail = 4;
            tiledLayer.levelsOfDetailBias = 3;
        }
        else {
            tiledLayer.levelsOfDetail = 3;
            tiledLayer.levelsOfDetailBias = 2;
        }
     }

}



@end
