//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WAGridCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation WAGridCell

@synthesize urlString;

- (id) initWithFrame: (CGRect) frame andNibView:(UIView *)  nibView reuseIdentifier:(NSString *) reuseIdentifier
{
    self = [super initWithFrame: frame reuseIdentifier: reuseIdentifier];
    if ( self == nil )
        return ( nil );
    nibView.frame = frame;
    [self.contentView addSubview:nibView];
    [self.contentView sendSubviewToBack:nibView];

    
    /*_iconView = [[UIImageView alloc] initWithFrame: CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
    _iconView.backgroundColor = [UIColor clearColor];
    _iconView.opaque = NO;
	_iconView.contentMode = UIViewContentModeScaleAspectFit;
	//Add shadow
    _iconView.layer.shadowRadius = 10.0;
    _iconView.layer.shadowOpacity = 0.4;
    _iconView.layer.shadowOffset = CGSizeMake( -20.0, -10.0 );
    _iconView.tag = 3;
    
    [self.contentView addSubview: _iconView];
	
	
	
	_title = [[UILabel alloc] initWithFrame: CGRectZero];
    _title.highlightedTextColor = [UIColor whiteColor];
    _title.textColor = [UIColor whiteColor];
    _title.font = [UIFont boldSystemFontOfSize: 12.0];
    _title.adjustsFontSizeToFitWidth = YES;
    _title.minimumFontSize = 10.0;
	_title.backgroundColor = [UIColor clearColor];
	[self.contentView addSubview: _title];

	_rightBadgeView = [[UIImageView alloc] initWithFrame: CGRectMake(0.0, 0.0, 20.0, 20.0)];
    _rightBadgeView.backgroundColor = [UIColor clearColor];
    _rightBadgeView.opaque = NO;
	_rightBadgeView.contentMode = UIViewContentModeScaleAspectFit;
	[self.contentView addSubview: _rightBadgeView];*/
	
	
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    self.contentView.opaque = NO;
    self.opaque = NO;
    
    self.selectionStyle = AQGridViewCellSelectionStyleGlow;
	
	
    
    return ( self );
}

- (void) dealloc
{
	[urlString release];
	
    [super dealloc];
}





@end
