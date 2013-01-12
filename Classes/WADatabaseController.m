//
//  WADatabaseController.m
//  Librelio
//
//  Created by Volodymyr Obrizan on 31.01.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import "WADatabaseController.h"

#import <sqlite3.h>

@implementation WADatabaseController

@synthesize pathToDatabase              = _pathToDatabase;
@synthesize cachedAdvancedCriteria      = _cachedAdvancedCriteria;
@synthesize cachedLexique               = _cachedLexique;
@synthesize cachedValuesForCriterion    = _cachedValuesForCriterion;
@synthesize cachedSettingsForCriterion  = _cachedSettingsForCriterion;


////////////////////////////////////////////////////////////////////////////////


-(id)initWithDatabase:(NSString *)path
{
    self = [super init];
    if (self)
    {
        self.pathToDatabase = path;
        self.cachedValuesForCriterion = [NSMutableDictionary dictionary];
    }
    return self;
}


////////////////////////////////////////////////////////////////////////////////


-(void)dealloc
{
    [self clearCache];
    
    self.pathToDatabase = nil;
    
    [super dealloc];
}


////////////////////////////////////////////////////////////////////////////////


-(void)clearCache
{
    self.cachedAdvancedCriteria = nil;
    self.cachedLexique = nil;
    self.cachedValuesForCriterion = nil;
    self.cachedSettingsForCriterion = nil;  
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark - High-level queries


-(NSArray *)fullDatabase
{
    return [self selectManyRowsWithSQL:@"SELECT * FROM Detail"];
}


////////////////////////////////////////////////////////////////////////////////


-(NSArray *)searchWithPreferences:(NSDictionary *)preferences andKeyword:(NSString *)keyword
{
    NSString *percent = @"%";//Avoid problems when trying to escape the % sign

    //SLog(@"starting searchWithPreferences");
    NSMutableString *query = [NSMutableString stringWithString:@"SELECT * FROM Detail"];

    // We will store here the separate query specifiers 
    NSMutableArray *querySpecifiers = [NSMutableArray array];
    
    // Iterate through all search parameters
    for (NSString *key in preferences.allKeys) 
    {
        NSDictionary *settings = [self settingsForCriterion:key];
        NSString *joinOperator = [settings objectForKey:@"Type"];
        
        // Only 'Prix' is processed here. Taille is another special case
        if ([joinOperator isEqualToString:@"Numeric"])
        {
            // Special case: Price (Prix)
            if ([key isEqualToString:@"Prix_de_reference"])
            {
                NSString *result = [self prixQuery:[preferences objectForKey:key]];
                if (result)
                    [querySpecifiers addObject:result];
            }

            // Skip for the next parameter
            continue;
        }
        
        NSIndexSet *indexSet = [preferences objectForKey:key];
        
        // Iterate through all selected indices
        if (indexSet.count > 0)
        {
            NSArray *valuesForCriterion = [self valuesForCriterion:key];
            NSMutableString *tmpQuery = [NSMutableString string];
            
            // Must specify that it is a block variable
            // Source: http://stackoverflow.com/questions/6727179/objective-c-read-only-int-what
            __block NSUInteger paramCount = 0;
            [tmpQuery appendString:@"("];
            [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
            {
                 NSString *criterionValue = [valuesForCriterion objectAtIndex:idx];
				
				// Ecapse a single quote with a double quote
				// Source: http://www.sqlite.org/lang_expr.html
				criterionValue = [criterionValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                [tmpQuery appendFormat:@"%@ LIKE '%@%@%@'", key,percent, criterionValue,percent];
                
                // Append join operator (OR, AND) if it isn't the last value
                if (++paramCount != indexSet.count)
                    [tmpQuery appendFormat:@" %@ ", joinOperator];
                
            }];
            [tmpQuery appendString:@")"];
            
            [querySpecifiers addObject:tmpQuery];
        }
    }

    // Append keyword search if present
    if (keyword && keyword.length)
        [querySpecifiers addObject:[NSString stringWithFormat:@"(Description_Test LIKE '%@%@%@')", percent,keyword,percent]];
    
    // Build final query
    NSUInteger querySpecifiersCounter = 0;
    if (querySpecifiers.count)
    {
        [query appendString:@" WHERE "];
        for (NSString *str in querySpecifiers)
        {
            if (querySpecifiersCounter)
                [query appendString:@" AND "];
            [query appendString:str];
            querySpecifiersCounter++;
        }
    }
    
    //SLog(@"Executing search query: %@", query);
    NSArray *result = [self selectManyRowsWithSQL:query];
    //SLog(@"Search results: %d rows.", result.count);
    if ([preferences objectForKey:@"Tailles"])
		result = [self checkForTailles:result withPreference:[preferences objectForKey:@"Tailles"]];
    //SLog(@"Processed results: %d rows.", result.count);
    
    return result;
}


////////////////////////////////////////////////////////////////////////////////


-(NSString *)prixQuery:(NSDictionary *)preferences
{
    NSString *result = @"(";
    NSString *mini = [preferences objectForKey:@"mini"];
    NSString *maxi = [preferences objectForKey:@"maxi"];
	NSString *miniQuery = nil;
	NSString *maxiQuery = nil;
    
    if (mini)
        miniQuery = [NSString stringWithFormat:@"Prix_de_reference >= %@", mini];
    if (maxi)
        maxiQuery = [NSString stringWithFormat:@"Prix_de_reference <= %@", maxi];
	
	if (miniQuery)
		result = [result stringByAppendingString:miniQuery];
	if (miniQuery && maxiQuery)
		result = [result stringByAppendingString:@" AND "];
	if (maxiQuery)
		result = [result stringByAppendingString:maxiQuery];
	
	result = [result stringByAppendingString:@")"];
    
	// Return the part of the query only if we have at least one parameter
	if (miniQuery || maxiQuery)
		return result;
	else
		return nil;
}


////////////////////////////////////////////////////////////////////////////////


-(NSArray *)checkForTailles:(NSArray *)result withPreference:(NSDictionary *)preferences
{
    NSMutableArray *processedResults = [NSMutableArray arrayWithArray:result];
    
    NSString *miniStr = [preferences objectForKey:@"mini"];
    NSInteger mini = 0;
    if (miniStr)
        mini = miniStr.integerValue;
    
    NSString *maxiStr = [preferences objectForKey:@"maxi"];
    NSInteger maxi = 99999999;
    if (maxiStr)
        maxi = maxiStr.integerValue;

    // Iterate through all models in results set
    for (NSDictionary *dic in result)
    {
        NSString *tailles = [dic objectForKey:@"Tailles"];
        NSArray *taillesNum = [tailles componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@","]];
        
        BOOL match = NO;
        
        // Iterate through all tailles
        for (NSString *height in taillesNum) 
        {
            if (height.integerValue >= mini && height.integerValue <= maxi)
            {
                match = YES;
                break;
            }
        }
        
        // Remove if height is not matched
        if (!match)
            [processedResults removeObject:dic];
    }
    
    return processedResults;
}


////////////////////////////////////////////////////////////////////////////////


-(NSString *)selectionDetailForCriterion:(NSString *)tableColumn preferences:(NSDictionary *)searchPreferences
{
    //SLog(@"Starting selectionDetailForCriterion");
    NSMutableString *result = [NSMutableString string];
    
    id preference = [searchPreferences objectForKey:tableColumn];
    
    if ([tableColumn isEqualToString:@"Prix_de_reference"])
    {
        NSString *mini = [(NSDictionary *)preference objectForKey:@"mini"];
        NSString *maxi = [(NSDictionary *)preference objectForKey:@"maxi"];
        
        if (mini)
            [result appendFormat:@"superieur à %@ €", mini];
        if (mini && maxi)
            [result appendString:@", "];
        if (maxi)
            [result appendFormat:@"inférieur à %@ €", maxi];
    } 
    else
        if ([tableColumn isEqualToString:@"Tailles"])
        {
            NSString *mini = [(NSDictionary *)preference objectForKey:@"mini"];
            NSString *maxi = [(NSDictionary *)preference objectForKey:@"maxi"];
            
            if (mini)
                [result appendFormat:@"superieur à %@ cm", mini];
            if (mini && maxi)
                [result appendString:@", "];
            if (maxi)
                [result appendFormat:@"inférieur à %@ cm", maxi];
        }
        else 
        {
            NSIndexSet *indexSet = (NSIndexSet *)preference;
            
            // Iterate through all selected indices
            if (indexSet.count)
            {
                NSArray *valuesForCriterion = [self valuesForCriterion:tableColumn];
                
                // Must specify that it is a block variable
                // Source: http://stackoverflow.com/questions/6727179/objective-c-read-only-int-what
                __block NSUInteger paramCount = 0;
                [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
                 {
                     NSString *criterionValue = [valuesForCriterion objectAtIndex:idx]; 
                     [result appendFormat:@"%@", criterionValue];
                     
                     if (++paramCount != indexSet.count)
                         [result appendString:@", "];
                     
                 }];
            }
        }
    
    return result;
}


////////////////////////////////////////////////////////////////////////////////


-(NSArray *)advancedCriteria
{
    if (!self.cachedAdvancedCriteria)
        self.cachedAdvancedCriteria = [self selectManyRowsWithSQL:@"SELECT * FROM AdvancedCriteria"];
    
    return self.cachedAdvancedCriteria;
}


////////////////////////////////////////////////////////////////////////////////


-(NSDictionary *)settingsForCriterion:(NSString *)criterion
{
    //SLog(@"Starting settingsForCriterion");
    // Memcache
    if (!self.cachedSettingsForCriterion)
        self.cachedSettingsForCriterion = [NSMutableDictionary dictionary];
    
    if (![self.cachedSettingsForCriterion objectForKey:criterion])
    {
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM AdvancedCriteria WHERE ColName LIKE '%@'", criterion];
       
        NSDictionary *res = [[self selectManyRowsWithSQL:query]  objectAtIndex:0];
        
        [self.cachedSettingsForCriterion setObject:res forKey:criterion];
    }
    
    return [self.cachedSettingsForCriterion objectForKey:criterion];
}


////////////////////////////////////////////////////////////////////////////////


-(NSArray *)lexique
{
    if (!self.cachedLexique)
        self.cachedLexique = [self selectManyRowsWithSQL:@"SELECT * FROM Lexique ORDER BY Gamme ASC"];
    
    return self.cachedLexique;
}


////////////////////////////////////////////////////////////////////////////////


-(NSMutableArray *)favorisForCriterion:(NSArray *)criterion
{       
    NSEnumerator *enumerator = [criterion objectEnumerator];
    id element;
    NSMutableArray *favorisObjects = [NSMutableArray array];
    while ((element = [enumerator nextObject]))
    {
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM Detail WHERE id_modele LIKE '%@'", element];
        NSDictionary *res = [[self selectManyRowsWithSQL:query]  objectAtIndex:0];
        [favorisObjects addObject:res];        
    }    
    return favorisObjects;
}

            
////////////////////////////////////////////////////////////////////////////////


-(NSArray *)valuesForCriterion:(NSString *)criterion
{
    // Memcache
    if (!self.cachedValuesForCriterion)
        self.cachedValuesForCriterion = [NSMutableDictionary dictionary];
    
    if (![self.cachedValuesForCriterion objectForKey:criterion])
    {
        // First, try to get from the specific table
        NSMutableArray *a = [NSMutableArray arrayWithArray:[self selectManyValuesWithSQL:[NSString stringWithFormat:@"SELECT * FROM Advanced_%@", criterion]]];
        if (!a.count)
        {
            // If not found or zero, try to populate from the appropriate column of the 'Modele' table
            NSString *query = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM Detail ORDER BY %@ ASC", criterion, criterion];
            a = [NSMutableArray arrayWithArray:[self selectManyValuesWithSQL:query]];
        }
        
        // Remove NULL or empty objects
        [a removeObjectIdenticalTo:[NSNull null]];
        [a removeObjectIdenticalTo:@""];
        
        [self.cachedValuesForCriterion setObject:a forKey:criterion];
    }
    
    return [self.cachedValuesForCriterion objectForKey:criterion];
}


////////////////////////////////////////////////////////////////////////////////

#pragma mark - SQLite operation


static int singleRowCallback(void *queryValuesVP, int columnCount, char **values, char **columnNames) 
{
    NSMutableDictionary *queryValues = (NSMutableDictionary *)queryValuesVP;
    int i;
    for(i=0; i<columnCount; i++) 
    {
        [queryValues setObject:values[i] ? [NSString stringWithUTF8String:values[i]] : [NSNull null] 
                        forKey:[NSString stringWithUTF8String:columnNames[i]]];
    }
    return 0;
}


////////////////////////////////////////////////////////////////////////////////


static int multipleRowCallback(void *queryValuesVP, int columnCount, char **values, char **columnNames) 
{
    NSMutableArray *queryValues = (NSMutableArray *)queryValuesVP;
    NSMutableDictionary *individualQueryValues = [NSMutableDictionary dictionary];
    int i;
    for(i=0; i<columnCount; i++) {
        [individualQueryValues setObject:values[i] ? [NSString stringWithUTF8String:values[i]] : [NSNull null] 
                                  forKey:[NSString stringWithUTF8String:columnNames[i]]];
    }
    [queryValues addObject:[NSDictionary dictionaryWithDictionary:individualQueryValues]];
    return 0;
}


////////////////////////////////////////////////////////////////////////////////


- (NSNumber *)executeSQL:(NSString *)sql withCallback:(void *)callbackFunction context:(id)contextObject {
    sqlite3 *db = NULL;
    int rc = SQLITE_OK;
    NSInteger lastRowId = 0;
    rc = sqlite3_open([self.pathToDatabase UTF8String], &db);
    if(SQLITE_OK != rc) {
        //SLog(@"Can't open database: %s\n", sqlite3_errmsg(db));
        sqlite3_close(db);
        return nil;
    } else {
        char *zErrMsg = NULL;
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        rc = sqlite3_exec(db, [sql UTF8String], callbackFunction, (void*)contextObject, &zErrMsg);
        if(SQLITE_OK != rc) {
            //SLog(@"Can't run query '%@' error message: %s\n", sql, sqlite3_errmsg(db));
            sqlite3_free(zErrMsg);
        }
        lastRowId = sqlite3_last_insert_rowid(db);
        sqlite3_close(db);
        [pool release];
    }
    NSNumber *lastInsertRowId = nil;
    if(0 != lastRowId) {
        lastInsertRowId = [NSNumber numberWithInteger:lastRowId];
    }
    return lastInsertRowId;
}


////////////////////////////////////////////////////////////////////////////////


- (NSString *)selectOneValueSQL:(NSString *)sql {
    NSMutableDictionary *queryValues = [NSMutableDictionary dictionary];
    [self executeSQL:sql withCallback:singleRowCallback context:queryValues];
    NSString *value = nil;
    if([queryValues count] == 1) {
        value = [[queryValues objectEnumerator] nextObject];
    }
    return value;
}


////////////////////////////////////////////////////////////////////////////////


- (NSArray *)selectManyValuesWithSQL:(NSString *)sql {
    NSMutableArray *queryValues = [NSMutableArray array];
    [self executeSQL:sql withCallback:multipleRowCallback context:queryValues];
    NSMutableArray *values = [NSMutableArray array];
    for(NSDictionary *dict in queryValues) {
        [values addObject:[[dict objectEnumerator] nextObject]];
    }
    return values;
}


////////////////////////////////////////////////////////////////////////////////


- (NSDictionary *)selectOneRowWithSQL:(NSString *)sql {
    NSMutableDictionary *queryValues = [NSMutableDictionary dictionary];
    [self executeSQL:sql withCallback:singleRowCallback context:queryValues];
    return [NSDictionary dictionaryWithDictionary:queryValues];    
}


////////////////////////////////////////////////////////////////////////////////


- (NSArray *)selectManyRowsWithSQL:(NSString *)sql {
    NSMutableArray *queryValues = [NSMutableArray array];
    [self executeSQL:sql withCallback:multipleRowCallback context:queryValues];
    //SLog(@"selectManyRowsWithSQL %@ will return %@",sql,queryValues);
    return [NSArray arrayWithArray:queryValues];
}


////////////////////////////////////////////////////////////////////////////////


- (NSNumber *)insertWithSQL:(NSString *)sql {
    sql = [NSString stringWithFormat:@"BEGIN TRANSACTION; %@; COMMIT TRANSACTION;", sql];
    return [self executeSQL:sql withCallback:NULL context:NULL];
}


////////////////////////////////////////////////////////////////////////////////


- (void)updateWithSQL:(NSString *)sql {
    sql = [NSString stringWithFormat:@"BEGIN TRANSACTION; %@; COMMIT TRANSACTION;", sql];
    [self executeSQL:sql withCallback:NULL context:nil];
}


////////////////////////////////////////////////////////////////////////////////


- (void)deleteWithSQL:(NSString *)sql {
    sql = [NSString stringWithFormat:@"BEGIN TRANSACTION; %@; COMMIT TRANSACTION;", sql];
    [self executeSQL:sql withCallback:NULL context:nil];
}


////////////////////////////////////////////////////////////////////////////////
@end
