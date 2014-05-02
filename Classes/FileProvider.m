//
//  FileProvider.m
//  SktreeEPub
//
//  Created by SkyTree on 12. 10. 29..
//  Copyright (c) 2012년 Skytree Corporation. All rights reserved.
//

//  !!!!! IMPORTANT !!!!!
//  The Advanced Demo sources are not the part of SkyEpub SDK.
//  These sources are written only to show how to use SkyEpub SDK.
//  The bugs found in this demo do not mean that SkyEpub SDK has the related bugs
//  Developers should change and modify this Advanced Demo sources for their purposes.
//  Any request to add/change/modify the Advanced Demo sources will be refused.


#import "FileProvider.h"

@implementation FileProvider

-(void)setContentPath:(NSString *)path {
    NSLog(@"Path: %@",path);
    fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    contentLength = [fileHandle seekToEndOfFile];
    [fileHandle seekToFileOffset:0];
}

//  you should return the length of content(file)
-(long long)lengthOfContent {
    return contentLength;
}

//  should return the offset of content
-(long long)offsetOfContent {
    return [fileHandle offsetInFile];
}

//  offset will be set by skyepub engine
-(void)setOffsetOfContent:(long long)offset {
    [fileHandle seekToFileOffset:offset];
}

// should return the NSData for the content of given path with the size of given length.
// this can be invoked times depends the size of content and the size of buffer. 
-(NSData*)dataForContent:(long long)length {
    long lengthLeft = contentLength - [fileHandle offsetInFile];
    long lengthToRead = MIN(length,lengthLeft);
    NSData *data = [fileHandle readDataOfLength:lengthToRead];
    if ([data length]==0 || data==nil) {
        return nil;
    }
    else {
        return data;
    }
}

//  should return whether reading content is finished or not.
-(BOOL)isFinished {
    if ([fileHandle offsetInFile]>=contentLength) {
        return YES;
    }else {
        return NO;
    }
}

@end
