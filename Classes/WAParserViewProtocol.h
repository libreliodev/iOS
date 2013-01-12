//
//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import "WAParserProtocol.h"

@protocol WAParserViewProtocol

@required

@property int page;

@property (nonatomic, assign) NSObject <WAParserProtocol> *pdfDocument;

- (void) didBecomeVisible;
- (void) didBecomeInvisible;


@end
