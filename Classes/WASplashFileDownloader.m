//
//  WAFileDownloader.m
//  Librelio
//
//  Created by Vladimir Obrizan on 09.11.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import "WASplashFileDownloader.h"

@implementation WASplashFileDownloader


////////////////////////////////////////////////////////////////////////////////


#pragma mark - Initialalizations 

-(id)initWithURL:(NSURL *)url
		 timeout:(NSTimeInterval)timeout
		 success:(void(^)(NSData *data))success
		 failure:(void(^)(NSError *))failure
{
	self = super.init;
	if (self)
	{
		onSuccess = Block_copy(success);
		onFailure = Block_copy(failure);
		
		NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeout] autorelease];
		self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
	}
	return self;
}


////////////////////////////////////////////////////////////////////////////////


-(void)dealloc
{
	[_connection release];
	[_data release];
	Block_release(onSuccess);
	Block_release(onFailure);
	
	[super dealloc];
}


////////////////////////////////////////////////////////////////////////////////


#pragma mark - NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
	
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
	
    // receivedData is an instance variable declared elsewhere.
	self.data = [NSMutableData data];
	self.data.length = 0;
}


////////////////////////////////////////////////////////////////////////////////


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [self.data appendData:data];
}


////////////////////////////////////////////////////////////////////////////////



- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    self.connection = nil;
	self.data = nil;
	
	if (onFailure)
		onFailure(error);
}


////////////////////////////////////////////////////////////////////////////////


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // release the connection, and the data object
    self.connection = nil;
	if (onSuccess)
		onSuccess(self.data);
	
    self.data = nil;
}


////////////////////////////////////////////////////////////////////////////////

@end
