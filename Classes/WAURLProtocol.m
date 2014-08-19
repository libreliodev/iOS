//
//  WAURLProtocol.m
//  Librelio
//
//  Created by Librelio on 18/08/14.
//  Copyright (c) 2014 WidgetAvenue - Librelio. All rights reserved.
//

#import "WAURLProtocol.h"

@implementation WAURLProtocol


+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSLog(@"can init with request");
    return [request.URL.host isEqualToString:@"localhost"];
}

+ (NSURLRequest *) canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (void) startLoading
{
    id <NSURLProtocolClient> client = self.client;
    NSURLRequest *request = [self request];
    
    //Mock ajax call
    NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:@"ajax_info" ofType:@"txt"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *headers = @{@"Access-Control-Allow-Origin" : @"*", @"Access-Control-Allow-Headers" : @"Content-Type"};
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"1.1" headerFields:headers];
    
    [client URLProtocol:self didReceiveResponse:response
     cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [client URLProtocol:self didLoadData:data];
    [client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading
{
}

@end
