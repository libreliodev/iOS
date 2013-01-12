#import "UIImage+WAAdditions.h"


@implementation UIImage (WAAdditions)

#pragma mark -
#pragma mark Image methods


- (UIImage *)imageScaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)imageScaledToMaxDimension:(CGFloat)maxDimension{
    CGSize size = CGSizeMake(maxDimension*self.size.width/self.size.height, maxDimension);
    if (self.size.width>self.size.height) size = CGSizeMake(maxDimension, maxDimension*self.size.height/self.size.width);
    return [self imageScaledToSize:size];
}


@end;