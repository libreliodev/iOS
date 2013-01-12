//
//  WAPopoverViewController.h
//  Librelio
//
//  Created by Volodymyr Obrizan on 11.02.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WAPopoverViewController : UIViewController<NSURLConnectionDelegate>
{
@private
    NSURLConnection *connection;
    NSMutableData *data;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, retain) NSString *lowResImgFileName;
@property (nonatomic, retain) NSString *highResImgURL;

@end
