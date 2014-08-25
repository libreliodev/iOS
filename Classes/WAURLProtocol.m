//
//  WAURLProtocol.m
//  Librelio
//
//  Created by Librelio on 18/08/14.
//  Copyright (c) 2014 WidgetAvenue - Librelio. All rights reserved.
//

#import "WAURLProtocol.h"
#import "NSBundle+WAAdditions.h"

@implementation WAURLProtocol


+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    BOOL ret = [request.URL.host isEqualToString:@"apphost"];
    if (ret) NSLog(@"can init with request %@",request.URL);
    return ret;
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
    NSString *path = [[NSBundle mainBundle] pathOfFileWithUrl:request.URL.lastPathComponent];
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
