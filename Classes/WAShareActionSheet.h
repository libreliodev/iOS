//
//  ShareActionSheet.h
//  Librelio
//
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WAShareActionSheet : UIActionSheet{
    NSArray *shareItems;
}
@property (nonatomic,retain) NSArray *shareItems;


@end
