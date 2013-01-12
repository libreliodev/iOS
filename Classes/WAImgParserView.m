//
//  WAImgParserView.m
//  Librelio
//
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import "WAImgParserView.h"

@implementation WAImgParserView

@synthesize pdfDocument;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		
		self.userInteractionEnabled = YES;//By default, user interactions seem to be disabled in UIImageViews
    }
    return self;
}

- (void) setPage:(int)newPage{
	if (page!=newPage){
        //SLog(@"setpage newPage:%i oldPage:%i,x:%f,width:%f",newPage,page,self.frame.origin.x,self.frame.size.width);
		[self didBecomeInvisible];
        if ((newPage>0)&&(newPage<=[pdfDocument countData])){
            NSString * imgUrl = [pdfDocument getDataAtRow:newPage forDataCol:DataColImage ];
            self.image = [UIImage imageWithContentsOfFile:imgUrl];
            
            
        }
        
		page = newPage;
	}
    
	
}

- (int) page{
	return page;
}

#pragma mark -
#pragma mark ParserView protocol

- (void) didBecomeVisible {
    
}

- (void) didBecomeInvisible {
    
    
    
}



@end
