//
//  WAURLProtocol.m
//  Librelio
//
//  Created by Librelio on 18/08/14.
//  Copyright (c) 2014 WidgetAvenue - Librelio. All rights reserved.
//

#import "WAURLProtocol.h"
#import "NSBundle+WAAdditions.h"
#import "NSString+WAURLString.h"

@implementation WAURLProtocol


+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    
    BOOL ret = [request.URL.host isEqualToString:@"apphost"];
    if (ret) {
        //SLog(@"can init with request %@",request.URL);
        //SLog(@"Headers:%@",request.allHTTPHeaderFields);
    }
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
    
    NSString * urlString = [request.URL.absoluteString stringByReplacingOccurrencesOfString:@"http://apphost" withString:@"http://localhost"];
    NSString *path = [[NSBundle mainBundle] pathOfFileWithUrl:urlString];

    //Mock ajax call


    //If request is for a tsv  file, and does not have a referer, we should redirect to index.html
    if (![request valueForHTTPHeaderField:@"Referer"]&&[[request.URL pathExtension]isEqualToString:@"tsv"] ){
        //SLog(@"TSV!!!!");
        NSString * fileName  = [[urlString noArgsPartOfUrlString] lastPathComponent];
        NSString * indexUrlString = [urlString stringByReplacingOccurrencesOfString:fileName withString:@"index.html"];
        path = [[NSBundle mainBundle] pathOfFileWithUrl:indexUrlString];
        
    }
    
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
