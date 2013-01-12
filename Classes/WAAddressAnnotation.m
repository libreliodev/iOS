//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WAAddressAnnotation.h"



@implementation WAAddressAnnotation

@synthesize parser,line;

- (void) setCoordinate:(CLLocationCoordinate2D)theCoordinate{
	coordinate = theCoordinate;
}

- (CLLocationCoordinate2D)coordinate;
{
     return coordinate; 
}

- (void)dealloc
{
    [super dealloc];
}

- (NSString *)title
{
    return [parser getDataAtRow:line forDataCol:DataColTitle];
}

// optional
- (NSString *)subtitle
{
    return [parser getDataAtRow:line forDataCol:DataColSubTitle];
}
@end
