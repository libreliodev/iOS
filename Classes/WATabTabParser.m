//
//  TabTabParser.m
//  Librelio
//
//  Copyright 2011 WidgetAvenue - Librelio. All rights reserved.
//

#import "WATabTabParser.h"
#import "NSBundle+WAAdditions.h"


@implementation WATabTabParser

- (void) loadTabFile{
	//Get the template html
	/**NSString * templatePath =[[NSBundle mainBundle] pathOfFileWithUrl:@"HTMLTemplate.html"];
	NSString * templateString = [NSString stringWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:nil];//Tab files are to be  with Windows default encoding
	NSURL *baseURL = [NSURL fileURLWithPath:templatePath];
	//SLog(@"Template:%@",templateString);
	
	//Get the data html
	NSString * filePath = [[NSBundle mainBundle] pathOfFileWithUrl:urlString];
	NSString * fileString = [NSString stringWithContentsOfFile:filePath encoding:NSWindowsCP1252StringEncoding error:nil];
	NSArray * lineArray = [fileString componentsSeparatedByString:@"\n"];
	int index = [[urlString valueOfParameterInUrlStringforKey:@"waline"]intValue];
	NSArray * colArray = [[lineArray objectAtIndex:index]componentsSeparatedByString:@"\t"] ;
	NSArray * titleArray = [[lineArray objectAtIndex:0]componentsSeparatedByString:@"\t"];
	NSMutableString *dataHtmlString = [NSMutableString stringWithString: @""];
	for (int i = 0; i <[colArray count]; i++) {
		[dataHtmlString appendFormat:@"<div class=\"%@\" title=\"%@\">%@</div>",[titleArray objectAtIndex:i],[colArray objectAtIndex:i],[colArray objectAtIndex:i]];
	}
    
	
	//Get the CSS
	NSString * cssPath = [[NSBundle mainBundle] pathOfFileWithUrl:[WAUtilities urlByChangingExtensionOfUrlString:urlString toSuffix:@".css"]];
	NSString *cssString = @"";
	if (cssPath) cssString=[NSString stringWithContentsOfFile:cssPath encoding:NSUTF8StringEncoding error:nil];
	
	//Build the html string
	NSString * htmlString = [NSString stringWithFormat:templateString,cssString,dataHtmlString];
	[self loadHTMLString:htmlString baseURL:baseURL];**/
	
}

- (BOOL) shouldGetExtraInformation{
    
    return NO;
}


@end
