//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WAMapView.h"
#import "WAUtilities.h"
#import "WAAddressAnnotation.h"
#import <CoreLocation/CoreLocation.h>
#import "WAKMLParser.h"
#import "WAModuleViewController.h"
#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.h"





#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395

@implementation WAMapView

@synthesize currentViewController,parser;

#pragma mark -
#pragma mark Lifecycle
- (void)dealloc {
	[urlString release];
	[parser release];
	
    [super dealloc];
}

- (NSString *) urlString
{
    return urlString;
}

- (void) setUrlString: (NSString *) theString
{
    urlString = [[NSString alloc]initWithString: theString];

	self.delegate = self;
	//self.showsUserLocation = YES;
	
	NSString * extension = [[urlString noArgsPartOfUrlString] pathExtension];
	
	
	if ([extension isEqualToString:@"kml"]){
		parser = [[WAKMLParser alloc]init];
		parser.urlString = urlString;
        
 
		//Set the type of map (satellite or standard, or both)
		NSString * mapType = [urlString valueOfParameterInUrlStringforKey:@"wamaptype"];
		if ([mapType isEqualToString:@"k"]) self.mapType =  MKMapTypeSatellite;
		else if ([mapType isEqualToString:@"h"]) self.mapType =  MKMapTypeHybrid;
		else self.mapType =  MKMapTypeStandard;
		
		//Add annotations, and get min max coords
		CGFloat minLat = 999999;//Higher than any possible real value
		CGFloat minLong = 999999;//Higher than any possible real value
		CGFloat maxLat = -999999;//Smaller than any possible value
		CGFloat maxLong = -999999;//Smaller than any possible value
		
		for(int i = 1; i <= [parser countData]; ++i) {
			NSString * latString = [parser getDataAtRow:i forDataCol:DataColLatitude];
			NSString * longString = [parser getDataAtRow:i forDataCol:DataColLongitude];
			if ((latString)&&(longString)){
				double latitude = [latString doubleValue];
				minLat = MIN(minLat,latitude);
				maxLat = MAX(maxLat,latitude);
				double longitude = [longString doubleValue];
				minLong = MIN(minLong,longitude);
				maxLong = MAX(maxLong,longitude);
				CLLocationCoordinate2D coords = { latitude, longitude };
				
				WAAddressAnnotation * annot = [[WAAddressAnnotation alloc] init];
				[annot setCoordinate:coords];
				annot.parser = parser;
				annot.line = i;
				
				[self addAnnotation:annot];
				[annot release];
					
			}
			
			
		}
		
		//Center the map
		MKCoordinateRegion newRegion;
		newRegion.center.latitude = (minLat+maxLat)/2;
		newRegion.center.longitude = (minLong+maxLong)/2;
		//Get the span
		NSString * mapSpan = [urlString valueOfParameterInUrlStringforKey:@"wamapspan"];//
		if (mapSpan){
			//The mapspan arg should be in the form longitude,latitude
			NSArray *parts = [mapSpan componentsSeparatedByString:@","];
			newRegion.span.longitudeDelta = [[parts objectAtIndex:0]floatValue];
			newRegion.span.latitudeDelta = [[parts objectAtIndex:1]floatValue];
			
			
		}
		else{
			newRegion.span.latitudeDelta = (maxLat-minLat)>0?maxLat-minLat:180;
			newRegion.span.longitudeDelta = (maxLong-minLong)>0?maxLong-minLong:180;
		}
		
		
		[self setRegion:newRegion animated:YES];
		
 		
	}
	else {
		
		//Set the type of map (satellite or standard, or both)
		NSString * mapType = [urlString valueOfParameterInUrlStringforKey:@"t"];
		if ([mapType isEqualToString:@"k"]) self.mapType =  MKMapTypeSatellite;
		else if ([mapType isEqualToString:@"h"]) self.mapType =  MKMapTypeHybrid;
		else self.mapType =  MKMapTypeStandard;
		
		//Set center of map and zoom level
		NSUInteger zoom = [[urlString valueOfParameterInUrlStringforKey:@"z"]intValue];
		NSArray * parts = [[urlString valueOfParameterInUrlStringforKey:@"ll"] componentsSeparatedByString:@","];//The ll argument provides the center of the map, see http://mapki.com/wiki/Google_Map_Parameters
		double latitude = [[parts objectAtIndex:0]doubleValue];
		double longitude = [[parts objectAtIndex:1]doubleValue];
		CLLocationCoordinate2D centerCoord = { latitude, longitude };
		[self setCenterCoordinate:centerCoord zoomLevel:zoom animated:YES];
		[self setDelegate:self];
		
		//Add annotation
		CLLocationCoordinate2D qLoc = [self geocodeAddress:[urlString valueOfParameterInUrlStringforKey:@"q"]];
		WAAddressAnnotation * annot = [[WAAddressAnnotation alloc] init];
        [annot setCoordinate:qLoc];
		[self addAnnotation:annot];
		[annot release];
		
		
	}

	

	
}



#pragma mark -
#pragma mark Map conversion methods

- (double)longitudeToPixelSpaceX:(double)longitude
{
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0);
}

- (double)latitudeToPixelSpaceY:(double)latitude
{
    return round(MERCATOR_OFFSET - MERCATOR_RADIUS * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
}

- (double)pixelSpaceXToLongitude:(double)pixelX
{
    return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI;
}

- (double)pixelSpaceYToLatitude:(double)pixelY
{
    return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI;
}

#pragma mark -
#pragma mark Helper methods

- (MKCoordinateSpan)coordinateSpanWithMapView:(MKMapView *)mapView
							 centerCoordinate:(CLLocationCoordinate2D)centerCoordinate
								 andZoomLevel:(NSUInteger)zoomLevel
{
    // convert center coordiate to pixel space
    double centerPixelX = [self longitudeToPixelSpaceX:centerCoordinate.longitude];
    double centerPixelY = [self latitudeToPixelSpaceY:centerCoordinate.latitude];
    
    // determine the scale value from the zoom level
    NSInteger zoomExponent = 20 - zoomLevel;
    double zoomScale = pow(2, zoomExponent);
    
    // scale the map’s size in pixel space
    CGSize mapSizeInPixels = mapView.bounds.size;
    double scaledMapWidth = mapSizeInPixels.width * zoomScale;
    double scaledMapHeight = mapSizeInPixels.height * zoomScale;
    
    // figure out the position of the top-left pixel
    double topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
    double topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
    
    // find delta between left and right longitudes
    CLLocationDegrees minLng = [self pixelSpaceXToLongitude:topLeftPixelX];
    CLLocationDegrees maxLng = [self pixelSpaceXToLongitude:topLeftPixelX + scaledMapWidth];
    CLLocationDegrees longitudeDelta = maxLng - minLng;
    
    // find delta between top and bottom latitudes
    CLLocationDegrees minLat = [self pixelSpaceYToLatitude:topLeftPixelY];
    CLLocationDegrees maxLat = [self pixelSpaceYToLatitude:topLeftPixelY + scaledMapHeight];
    CLLocationDegrees latitudeDelta = -1 * (maxLat - minLat);
    
    // create and return the lat/lng span
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    return span;
}

#pragma mark -
#pragma mark Public methods

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
				  zoomLevel:(NSUInteger)zoomLevel
				   animated:(BOOL)animated
{
    // clamp large numbers to 28
    zoomLevel = MIN(zoomLevel, 28);
	//SLog(@"Zoom level:%i",zoomLevel);
	
    
    // use the zoom level to compute the region
    MKCoordinateSpan span = [self coordinateSpanWithMapView:self centerCoordinate:centerCoordinate andZoomLevel:zoomLevel];
    MKCoordinateRegion newRegion = MKCoordinateRegionMake(centerCoordinate, span);
    // set the region like normal
    [self setRegion:newRegion animated:animated];
}


-(CLLocationCoordinate2D) geocodeAddress:(NSString*)addressString {
	CLLocationCoordinate2D location;
	NSString *geoCodeUrlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/xml?address=%@&sensor=true", addressString];
	
	NSData * locData = [NSData dataWithContentsOfURL:[NSURL URLWithString:geoCodeUrlString]];
	xmlDocPtr doc = xmlReadMemory([locData bytes], [locData length], "", NULL, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
	xmlXPathContextPtr xpathCtx = xmlXPathNewContext(doc); 
	
	xmlXPathObjectPtr xPathLat = xmlXPathEvalExpression((xmlChar *)"//geometry/location/lat", xpathCtx);
	if(xPathLat->nodesetval->nodeNr) {
		xmlChar * cLatString = xPathLat->nodesetval->nodeTab[0]->children->content;
		NSString *latString = [NSString stringWithCString:(const char *)cLatString encoding:NSUTF8StringEncoding];
		location.latitude = [latString doubleValue];
	}
	xmlXPathFreeObject(xPathLat);
	xmlXPathObjectPtr xPathLng = xmlXPathEvalExpression((xmlChar *)"//geometry/location/lng", xpathCtx);
	if(xPathLng->nodesetval->nodeNr) {
		xmlChar * cLngString = xPathLng->nodesetval->nodeTab[0]->children->content;
		NSString *lngString = [NSString stringWithCString:(const char *)cLngString encoding:NSUTF8StringEncoding];
		location.longitude = [lngString doubleValue];
	}
	xmlXPathFreeObject(xPathLng);
	
	xmlXPathFreeContext(xpathCtx); 
	xmlFreeDoc(doc); 
	
	
	return location;
}


#pragma mark -
#pragma mark ModuleView protocol
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // handle our  custom annotation
    //
    else
    {
        // try to dequeue an existing pin view first
        static NSString* annotationIdentifier = @"annotationIdentifier";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)[self dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier] autorelease];
            //pinView.pinColor = MKPinAnnotationColorPurple;
            pinView.animatesDrop = YES;
            pinView.canShowCallout = YES;
            
            // add a detail disclosure button to the callout which will open a new view controller page
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
             pinView.rightCalloutAccessoryView = rightButton;
			
        }
		
		//Set the tag of pinView to the row of the pin
		WAAddressAnnotation * annot = (WAAddressAnnotation *)annotation;
		pinView.tag = annot.line;
		
		
		//If there is an image, add it
		NSString * imageUrl = [parser getDataAtRow:annot.line forDataCol:DataColImage];
		NSString * imagePath = [[NSBundle mainBundle] pathOfFileWithUrl:imageUrl];
		if (imageUrl && imagePath){
			UIImage * leftImage = [UIImage imageWithContentsOfFile:imagePath];
			UIImageView *leftImageView = [[UIImageView alloc] initWithImage:leftImage];
			CGFloat ratio = leftImage.size.width/leftImage.size.height;
			leftImageView.frame = CGRectMake(0, 0, 30*ratio, 30);
			pinView.leftCalloutAccessoryView = leftImageView;
			[leftImageView release];
			
		}
		else {
			pinView.leftCalloutAccessoryView = nil;
		}

																   
		
		return pinView;
	}
 }


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
	NSString * newUrlString = [parser getDataAtRow:view.tag forDataCol:DataColDetailLink];
	WAModuleViewController * loadingViewController = [[WAModuleViewController alloc]init];
	loadingViewController.moduleUrlString= [WAUtilities absoluteUrlOfRelativeUrl:newUrlString relativeToUrl:urlString] ;
	loadingViewController.initialViewController= self.currentViewController;
	loadingViewController.containingView= mapView;
	loadingViewController.containingRect= CGRectZero;
	[loadingViewController pushViewControllerIfNeededAndLoadModuleView];
	[loadingViewController release];
}

#pragma mark -
#pragma mark ModuleView protocol

- (void)moduleViewWillAppear:(BOOL)animated{
}

- (void) moduleViewDidAppear{
}


- (void) moduleViewWillDisappear:(BOOL)animated{
}



- (void) moduleWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
}

- (void) moduleWillAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
}

- (void) jumpToRow:(int)row{
    
}


@end
