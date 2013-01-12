#import <Foundation/Foundation.h>

@interface UIImage (WAAdditions)
- (UIImage *)imageScaledToSize:(CGSize)newSize;
- (UIImage *)imageScaledToMaxDimension:(CGFloat)maxDimension;

@end;
