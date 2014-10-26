#import "WASQLiteParser.h"
#import "NSString+WAURLString.h"
#import "NSBundle+WAAdditions.m"
#import "WADocumentDownloadsManager.h"
#import "WAResourcesDownloader.h"



#import <sqlite3.h> 



@implementation WASQLiteParser

@synthesize intParam,dataArray,currentQueryDic;

- (NSString *) urlString
{
    return urlString;
}

- (void) setUrlString: (NSString *) theString
{
    urlString = [[NSString alloc]initWithString: theString];
    
	dataArray = [[NSMutableArray alloc ]initWithCapacity:1000];
    /*
     //REMOVED, CAUSES CRASH FIRST TIME DATABASE IS USED. KEPT FOR FUTURE REFERENCE
    //If the sqlite file is in the bundle, copy it to the caches directory so that it can be edited
    NSString * sqlitePath = [[NSBundle mainBundle]pathOfFileWithUrl:theString];
    NSString * docPath = [LibrelioUtilities cacheFolderPath];
    if (![sqlitePath hasPrefix:docPath]){
       [LibrelioUtilities storeFileWithUrlString:theString withFileAtPath:sqlitePath];
    }*/
    

 
    
	
	
}

- (void)dealloc
{
	[urlString release];
	[dataArray release];
    [currentQueryDic release];
	
	[super dealloc];
}

- (void) rebuildDataArray{
    sqlite3 *database;
    NSString* databasePath = [[NSBundle mainBundle] pathOfFileWithUrl:[urlString noArgsPartOfUrlString]] ;
    
	// Reset the dataArray
	[dataArray removeAllObjects];
    
    //Create cols array
 

    
	// Open the database from the users filessytem
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        NSString * currentQueryString = [NSString stringWithFormat:@"%@ %@ FROM %@",[currentQueryDic objectForKey:@"Statement"],[currentQueryDic objectForKey:@"Columns"],[currentQueryDic objectForKey:@"From"]];
		// Setup the SQL Statement and compile it for faster access
		const char *sqlStatement = [currentQueryString UTF8String];
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                NSMutableDictionary * colDic = [NSMutableDictionary dictionary];
				// Read the data from the result row
                for (int i = 0;i < sqlite3_column_count(compiledStatement);++i){
                    char* result = (char *)sqlite3_column_text(compiledStatement, i);
                    if (result != NULL) {
                        NSString *aName = [NSString stringWithUTF8String:result]; 
                        NSString *cName = [NSString stringWithUTF8String:(char *)sqlite3_column_name(compiledStatement, i)]; 
                        //SLog(@"col %@: %@",cName, aName);
                        [colDic setObject:aName forKey:cName];
                        
                    }
                }
                [dataArray addObject:colDic];
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
        
	}
	sqlite3_close(database);
    
}

- (NSDictionary*) defaultQueryDic{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"Select", @"Statement", @"*", @"Columns",@"Detail",@"From", nil];
}

- (NSString*) getViewNameFromQueryString:(NSString*)queryString{
    
    return [currentQueryDic objectForKey:@"From"];

}



#pragma mark -
#pragma mark Parser protocol



- (UIImage *) getCoverImage{
	return nil;
}

- (NSString*) getDataAtRow:(int)row forDataCol:(DataCol)dataCol{
    
    return [self getDataAtRow:row forQueryDic:[self defaultQueryDic] forDataCol:dataCol] ;

}
- (int) countData{
 	return [self countSearchResultsForQueryDic:[self defaultQueryDic]];
	
}

- (void) deleteDataAtRow:(int)row{
	
}

- (void) cancelCacheOperations{
    
}

- (NSString*) getHeaderForDataCol:(DataCol)dataCol{
    return nil;	
}

- (int)countSearchResultsForQueryDic:(NSDictionary*)queryDic{
    if (!queryDic) queryDic = [self defaultQueryDic];
    //Check if QueryString is same as CurrentStatement, otherwise rebuild data array
    //SLog(@"queryString: %@",queryString);
    if (![queryDic isEqual:currentQueryDic]){
        if (currentQueryDic) [currentQueryDic release];
        currentQueryDic = [queryDic retain];
        [self rebuildDataArray];
        
    }
 	return (int)[dataArray count];
}

/**
 + (NSString*) colNameOfDataCol:(DataCol)dataCol {
 return colName;
 }**/


-(NSString*) getDataAtRow:(int)row forQueryDic:(NSDictionary*)queryDic forDataCol:(DataCol)dataCol{
    //Check if QueryString is same as CurrentStatement, otherwise rebuild data array
    if (!queryDic) queryDic = [self defaultQueryDic];
    if (![queryDic isEqual:currentQueryDic]){
        if (currentQueryDic) [currentQueryDic release];
        currentQueryDic = [queryDic retain];
        [self rebuildDataArray];
        
    }
	
    //SLog(@"DataArray:%@",dataArray);
    NSString * ret = nil;
    
    if ([dataArray count]>row -1){
        //SLog(@"objectAtIndex in WASQLiteParser");
        NSDictionary * rowDic = (NSDictionary*)[dataArray objectAtIndex:row-1];
        ret = [rowDic objectForKey:[NSString stringWithFormat:@"Col%i",dataCol]];
         
    }
    
    
    
    
	return ret;
}

- (NSArray*) getRessources{
    sqlite3 *database;
    NSString* databasePath = [[NSBundle mainBundle] pathOfFileWithUrl:[urlString noArgsPartOfUrlString]] ;
    // Open the database from the users filessytem
    NSMutableArray * resourcesAr = [NSMutableArray array];
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        NSString * statement = @"Select * FROM Resources LIMIT 1000";
		const char *sqlStatement = [statement UTF8String];
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                    char* result = (char *)sqlite3_column_text(compiledStatement, 0);
                    if (result != NULL) {
                        NSString *aName = [NSString stringWithUTF8String:result];
                        [resourcesAr addObject:aName];

                }
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
        
	}
	sqlite3_close(database);
    
    //Add the cover image
	NSString *noUnderscoreUrlString = [urlString urlByRemovingFinalUnderscoreInUrlString];//Remove the final underscore]
    NSString * imgUrl = [WAUtilities urlByChangingExtensionOfUrlString:noUnderscoreUrlString toSuffix:@".png"];//Change extension to png
    NSString * relativeCoverUrl = [imgUrl lastPathComponent];//Use relative Url
    [resourcesAr addObject:relativeCoverUrl];

    return resourcesAr;
}

- (void) startCacheOperations{
    
}

- (BOOL) shouldCompleteDownloadResources{
    return YES;
}


- (CGFloat) cacheProgress{
    return 1.0 ;
    
}


@end
