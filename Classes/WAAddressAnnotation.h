//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.



#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "WAParserProtocol.h"


@interface WAAddressAnnotation : NSObject<MKAnnotation> {
	CLLocationCoordinate2D coordinate;	
	NSObject <WAParserProtocol> * parser;
	int line;
}

@property (nonatomic,assign) NSObject <WAParserProtocol> * parser;
@property int line;

@end