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

- (UIImage *)squareImageWithSize:(CGSize)newSize {
    double ratio;
    double delta;
    CGPoint offset;
    
    //make a new square size, that is the resized imaged width
    CGSize sz = CGSizeMake(newSize.width, newSize.width);
    
    //figure out if the picture is landscape or portrait, then
    //calculate scale factor and offset
    if (self.size.width > self.size.height) {
        ratio = newSize.width / self.size.width;
        delta = (ratio*self.size.width - ratio*self.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = newSize.width / self.size.height;
        delta = (ratio*self.size.height - ratio*self.size.width);
        offset = CGPointMake(0, delta/2);
    }
    
    //make the final clipping rect based on the calculated values
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * self.size.width) + delta,
                                 (ratio * self.size.height) + delta);
    
    
    //start a new context, with scale factor 0.0 so retina displays get
    //high quality image
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [self drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage*)imageByCrop:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    return cropped;
}

@end;