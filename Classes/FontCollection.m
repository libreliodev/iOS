#import "FontCollection.h"


@implementation FontCollection

/* Applier function for font dictionaries */
void didScanFont(const char *key, CGPDFObjectRef object, void *collection)
{
    //Fix: https://github.com/libreliodev/iOS/issues/175
    //Since ! is applied on CGPDFObjectGetType(object) comparision is perfomred between two incompatible values. Hence the warning.
	if (CGPDFObjectGetType(object) != kCGPDFObjectTypeDictionary) return;
	CGPDFDictionaryRef dict;
	if (!CGPDFObjectGetValue(object, kCGPDFObjectTypeDictionary, &dict)) return;
	Font *font = [Font fontWithDictionary:dict];
	if (!font) return;
	NSString *name = [NSString stringWithUTF8String:key];
	[(NSMutableDictionary *)collection setObject:font forKey:name];
	//SLog(@" %s: %@", key, font);
}

/* Initialize with a font collection dictionary */
- (id)initWithFontDictionary:(CGPDFDictionaryRef)dict
{
	if ((self = [super init]))
	{
		//SLog(@"Font Collection");
		fonts = [[NSMutableDictionary alloc] init];
		// Enumerate the Font resource dictionary
		CGPDFDictionaryApplyFunction(dict, didScanFont, fonts);

		NSMutableArray *namesArray = [NSMutableArray array];
		for (NSString *name in [fonts allKeys])
		{
			[namesArray addObject:name];
		}

		names = [[namesArray sortedArrayUsingSelector:@selector(compare:)] retain];
	}
	return self;
}

/* Returns a copy of the font dictionary */
- (NSDictionary *)fontsByName
{
	return [NSDictionary dictionaryWithDictionary:fonts];
}

/* Return the specified font */
- (Font *)fontNamed:(NSString *)fontName
{
	return [fonts objectForKey:fontName];
}

#pragma mark - Memory Management

- (void)dealloc
{
	[names release];
	[fonts release];
	[super dealloc];
}

@synthesize names;
@end
