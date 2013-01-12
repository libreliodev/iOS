//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "WAModuleProtocol.h"
#import "WAParserProtocol.h"


#import <libxml/xmlmemory.h>
#import <libxml/debugXML.h>
#import <libxml/HTMLtree.h>
#import <libxml/xmlIO.h>
#import <libxml/xinclude.h>
#import <libxml/catalog.h>
#import <libxml/xpathInternals.h>



@interface WAMapView : MKMapView  <MKMapViewDelegate,WAModuleProtocol> {
	MKCoordinateRegion region;
	NSString *urlString;
	UIViewController* currentViewController;
	NSObject <WAParserProtocol> * parser;

	
}

@property (nonatomic,retain) NSObject <WAParserProtocol> * parser;


-(CLLocationCoordinate2D) geocodeAddress:(NSString*)addressString;
- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate zoomLevel:(NSUInteger)zoomLevel  animated:(BOOL)animated;
-(CLLocationCoordinate2D) geocodeAddress:(NSString*)addressString;


@end
