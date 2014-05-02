//
//  FileProvider.h
//  SktreeEPub
//
//  Created by 하늘나무 on 12. 10. 29..
//  Copyright (c) 2012년 Skytree Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentProvider.h"

@interface FileProvider : NSObject <ContentProvider> {
    long long contentLength;
    NSFileHandle *fileHandle;    
}

@end
