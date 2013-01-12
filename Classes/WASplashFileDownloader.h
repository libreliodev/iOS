//
//  WAFileDownloader.h
//  Librelio
//
//  Created by Vladimir Obrizan on 09.11.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WASplashFileDownloader : NSObject<NSURLConnectionDelegate>
{
@private
	void (^onSuccess)(NSData *);
	void (^onFailure)(NSError *);
}

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *data;

-(id)initWithURL:(NSURL *)url
		 timeout:(NSTimeInterval)timeout
		 success:(void(^)(NSData *data))success
		 failure:(void(^)(NSError *))failure;

@end
