//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WARoundedButtonView.h"
#import <QuartzCore/QuartzCore.h>



@implementation WARoundedButtonView


#pragma mark -
#pragma mark Lifecycle

- (void) awakeFromNib{
    [super awakeFromNib];
    //Following code was in layout subviews and removed for iOS5: for some reason, trying to access self.titleLabel here produces unpredictable results
    //Resize the font
    //SLog(@"Label text:%@ and Width:%f",self.titleLabel.text,self.frame.size.width);
	//UIFont * newFont = [self.titleLabel.font fontWithSize:self.frame.size.height/1.5];
	//UIFont * newFont = [UIFont systemFontOfSize:self.frame.size.height/1.5];
	//self.titleLabel.font = newFont;
	//self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    CGFloat cornerRadius = self.frame.size.height/6;
	[[self layer] setCornerRadius:cornerRadius];
	[[self layer] setMasksToBounds:YES];

    
}

- (void)dealloc {
	
    [super dealloc];
}





@end
