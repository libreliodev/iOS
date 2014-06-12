//
//  ShareActionSheet.m
//  Librelio
//
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import "WAShareActionSheet.h"
#import "NSBundle+WAAdditions.h"


@implementation WAShareActionSheet

- (NSArray *) shareItems
{
    return shareItems;
}


////////////////////////////////////////////////////////////////////////////////


- (void) setShareItems: (NSArray *) theItems{
    
    shareItems = [[NSArray alloc]initWithArray:theItems];
    
    for (NSString *str in theItems)
    {
        [self addButtonWithTitle:str];
        
    }
    
    //Add the cancel button. It will not be displayed on the iPad.
	NSInteger destructiveIndex = [self addButtonWithTitle:NSLocalizedString(@"Cancel",@"" )];
	self.destructiveButtonIndex = destructiveIndex;
    self.cancelButtonIndex = destructiveIndex;
    

}

- (void)dealloc {
    
	[shareItems release];
    [super dealloc];
}

@end
