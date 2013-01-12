//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import <Foundation/Foundation.h>
#import "StoreKit/StoreKit.h"


@interface WAPaymentTransactionObserver : NSObject <SKPaymentTransactionObserver> {
	
}

- (NSString *)encode:(const uint8_t *)input length:(NSInteger)length;

@end
