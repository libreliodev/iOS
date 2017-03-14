//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.


#import "WAPaymentTransactionObserver.h"
#import "NSString+WAURLString.h"


@implementation WAPaymentTransactionObserver

#pragma mark -
#pragma mark SKPaymentTransactionObserver Protocol


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	//Slog(@"Updated transactions %@",transactions);
    for (SKPaymentTransaction *transaction in transactions)
	{
		NSString * productId = transaction.payment.productIdentifier;
        //Slog(@"product iD %@",productId);
		NSString *shortID = [productId librelioProductIDForAppStoreProductID];
        //Slog(@"short iD %@",shortID);
		NSString *tempKey = [NSString stringWithFormat:@"%@-receipt",shortID];
        //SLog(@"newjson: %@",[self encode:(uint8_t *)receipt.bytes length:receipt.length]);
        
        
        //Begin: Modified for fix #162
        NSData *data = [self transactionReceiptForTransaction:transaction];
        
        switch (transaction.transactionState)
		{
			case SKPaymentTransactionStatePurchased:{
				//Store the receipt
				NSString *jsonObjectString = [self encode:(uint8_t *)data.bytes length:data.length];
				//SLog(@"Transaction Succceded for product id %@ with json receipt %@",transaction.payment.productIdentifier,jsonObjectString);
				[[NSUserDefaults standardUserDefaults] setObject:jsonObjectString forKey:tempKey];
				// Remove the transaction from the payment queue.
				[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
				break;}
			case SKPaymentTransactionStateRestored:{
				//Store the  receipt
				//NSString *jsonObjectString = [self encode:(uint8_t *)transaction.originalTransaction.transactionReceipt.bytes length:transaction.originalTransaction.transactionReceipt.length];  Do not use original receipt, an empty string is returned for some reason
				NSString *jsonObjectString = [self encode:(uint8_t *)data.bytes length:data.length];
				//SLog(@"Transaction restored  and for product id %@ and receipt %@ ",transaction.payment.productIdentifier,jsonObjectString);
				[[NSUserDefaults standardUserDefaults] setObject:jsonObjectString forKey:tempKey];
				// Remove the transaction from the payment queue.
				[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
				break;}
			case SKPaymentTransactionStateFailed:
				//SLog(@"TransactionFailed with error %@", transaction.error);
				// Remove the transaction from the payment queue.
				[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
				break;
			default:
				break;
		}
        //End: Modified for fix #162
 		//Send notification
		[[NSNotificationCenter defaultCenter] postNotificationName:@"transactionStatusDidChange" object:transaction];
        
		
		

		
	}
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
    //SLog(@"Will post restoreCompletedTransactionsFinished notification");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"restoreCompletedTransactionsFinished" object:nil];
    
}


- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"restoreCompletedTransactionsFinished" object:error];
    
}


//Fix: https://github.com/libreliodev/iOS/issues/162
//Added for fix #162
- (NSData *)transactionReceiptForTransaction:(SKPaymentTransaction *)transaction {
    NSData *data = nil;
    if ([[NSBundle mainBundle] respondsToSelector:@selector(appStoreReceiptURL)]) {
        //iOS 7 & above
        data =[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
    }
    if (data != nil) {
        return data;
    }
    ///As per Apple guide lines, we can't completely avoid this call and must be a backup option for the new implementation above.
    return transaction.transactionReceipt;
}


#pragma mark -
#pragma mark Encoding 


- (NSString *)encode:(const uint8_t *)input length:(NSInteger)length {
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
	
    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
	
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
			value <<= 8;
			
			if (j < length) {
				value |= (0xFF & input[j]);
			}
        }
		
        NSInteger index = (i / 3) * 4;
        output[index + 0] =                    table[(value >> 18) & 0x3F];
        output[index + 1] =                    table[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
	
    return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}



-(void)dealloc
{
	[super dealloc];
}
@end
