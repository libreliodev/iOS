#import <Foundation/Foundation.h>

@interface UIImage (WAAdditions)
- (UIImage *)imageScaledToSize:(CGSize)newSize;
- (UIImage *)imageScaledToMaxDimension:(CGFloat)maxDimension;
- (UIImage *)squareImageWithSize:(CGSize)newSize;
- (UIImage*)imageByCrop:(CGRect)rect;

@end;
