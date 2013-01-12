//
//  WAMissingResourcesDownloader.h
//  Librelio
//
//  Copyright (c) 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import "WADocumentDownloader.h"

/**!
 Downloads missing resources, for a document already downloaded
 */

@interface WAMissingResourcesDownloader : WADocumentDownloader <NSURLConnectionDelegate>

@end
