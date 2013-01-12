//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.

#import <UIKit/UIKit.h>
#import "AQGridViewCell.h"

@interface WAGridCell : AQGridViewCell
{
	NSString * urlString;

}
@property (nonatomic, retain) NSString * urlString;

- (id) initWithFrame: (CGRect) frame andNibView:(UIView *)  nibView reuseIdentifier:(NSString *) reuseIdentifier;

@end
