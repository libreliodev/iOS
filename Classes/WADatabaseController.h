//
//  WADatabaseController.h
//  Librelio
//
//  Created by Volodymyr Obrizan on 31.01.12.
//  Copyright (c) 2012 WidgetAvenue - Librelio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WADatabaseController : NSObject


@property (nonatomic, retain) NSString *pathToDatabase;

// Memcache
@property (nonatomic, retain) NSArray *cachedAdvancedCriteria;
@property (nonatomic, retain) NSArray *cachedLexique;
@property (nonatomic, retain) NSMutableDictionary *cachedValuesForCriterion;
@property (nonatomic, retain) NSMutableDictionary *cachedSettingsForCriterion;

-(id)initWithDatabase:(NSString *)path;
-(void)clearCache;

-(NSArray *)fullDatabase;
-(NSArray *)searchWithPreferences:(NSDictionary *)preferences andKeyword:(NSString *)keyword;
-(NSArray *)advancedCriteria;
-(NSDictionary *)settingsForCriterion:(NSString *)criterion;
-(NSArray *)lexique;
-(NSArray *)valuesForCriterion:(NSString *)criterion;
-(NSString *)prixQuery:(NSDictionary *)preferences;
-(NSArray *)checkForTailles:(NSArray *)result withPreference:(NSDictionary *)preferences;
-(NSString *)selectionDetailForCriterion:(NSString *)tableColumn preferences:(NSDictionary *)searchPreferences;
-(NSMutableArray *)favorisForCriterion:(NSArray *)criterion;

// SQLite low-level
- (NSNumber *)executeSQL:(NSString *)sql withCallback:(void *)callbackFunction context:(id)contextObject;
- (NSString *)selectOneValueSQL:(NSString *)sql;
- (NSArray *)selectManyValuesWithSQL:(NSString *)sql;
- (NSDictionary *)selectOneRowWithSQL:(NSString *)sql;
- (NSArray *)selectManyRowsWithSQL:(NSString *)sql;
- (NSNumber *)insertWithSQL:(NSString *)sql;
- (void)updateWithSQL:(NSString *)sql;
- (void)deleteWithSQL:(NSString *)sql;


@end
