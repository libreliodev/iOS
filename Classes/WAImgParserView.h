//
//  WAImgParserView.h
//  Librelio
//
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WAParserViewProtocol.h"

@interface WAImgParserView : UIImageView <WAParserViewProtocol>{
	
	NSObject <WAParserProtocol> *pdfDocument;
	int page;
	
	
}


@end
