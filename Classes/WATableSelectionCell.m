//
//  WATableSelectionCell.m
//  Librelio
//
//  Created by Volodymyr Obrizan on 01.03.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import "WATableSelectionCell.h"
#import "WAPageContainerController.h"

@implementation WATableSelectionCell


////////////////////////////////////////////////////////////////////////////////


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


////////////////////////////////////////////////////////////////////////////////


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


////////////////////////////////////////////////////////////////////////////////


// Source: http://stackoverflow.com/a/4872199/124115
- (float) groupedCellMarginWithTableWidth:(CGFloat)tableViewWidth;
{
    float marginWidth;
    if(tableViewWidth > 20)
    {
        if(tableViewWidth < 400)
        {
            marginWidth = 10;
        }
        else
        {
            marginWidth = MAX(31, MIN(45, tableViewWidth*0.06));
        }
    }
    else
    {
        marginWidth = tableViewWidth - 10;
    }
    return marginWidth;
}


////////////////////////////////////////////////////////////////////////////////


- (void)setFrame:(CGRect)frame 
{
	// Set-up fixed UITableViewCell margins (15 pixels form left & right)
	CGFloat inset = 15.0;
	CGFloat tableWidth = [WAPageContainerController rectForClass:nil].size.width;
    frame.origin.x -= [self groupedCellMarginWithTableWidth:tableWidth] - inset;
	frame.size.width = frame.size.width + 2 * ([self groupedCellMarginWithTableWidth:tableWidth] - inset);
    [super setFrame:frame];
}


////////////////////////////////////////////////////////////////////////////////


@end
