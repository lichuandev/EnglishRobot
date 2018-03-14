//
//  TRDatabaseTool.m
//  ERobot
//
//  Created by Mac on 17/2/13.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "ERDatabaseTool.h"
#import "ERWordList.h"
#import "ERWord.h"
#import "ERAnalysisJSONTool.h"

@implementation ERDatabaseTool
+(FMDatabase *)creatAllWordsTable{
    static FMDatabase *db = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"ER.sqlite"];
        db = [FMDatabase databaseWithPath:dbPath];
        if ([db open]) {
            [db executeUpdate:@"create table if not exists allWordsTable (time text, English text, EEnglish text, Chinese text, EChinese text, notes text, statue text, timeE text, isFind text)"];
            [db close];
        }else{
            NSLog(@"数据库打开失败");
        }
        
        
        
        NSLog(@"db=%@",db);
        

    });
    [db close];
    return db;
}


// 读数据库
+(NSArray *)readDb:(NSString *)conten para:(NSString *)para{
     FMDatabase *database = [ERDatabaseTool creatAllWordsTable];
    [database open];
    FMResultSet *resultSet = [database executeQuery:conten,para];
    NSMutableArray *WordsA = [NSMutableArray array];
    while ([resultSet next]) {
        ERWord *word = [ERWord new];
        word.time = [resultSet stringForColumn:@"time"];
        word.English = [resultSet stringForColumn:@"English"];
        word.EEnglish = [resultSet stringForColumn:@"EEnglish"];
        word.Chinese = [resultSet stringForColumn:@"Chinese"];
        word.EChinese = [resultSet stringForColumn:@"EChinese"];
        word.notes = [resultSet stringForColumn:@"notes"];
        word.statue = [resultSet stringForColumn:@"statue"];
        word.timeE = [resultSet stringForColumn:@"timeE"];
        word.isFind = [resultSet stringForColumn:@"isFind"];
        [WordsA addObject:word];
        
    }
    [database close];
    return [WordsA copy];
}

// 清除数据库
+(void)cleanDB:(NSString *)title content:(NSString *)content{
    if ([content containsString:@"'"]) {
        content = [content stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    }
     NSString *s = [NSString stringWithFormat:@"delete from allWordsTable where %@ = '%@'",title,content];
    NSLog(@"删除语句：%@",s);
    FMDatabase *database = [ERDatabaseTool creatAllWordsTable];
    [database open];
    BOOL isSeccess = [database executeUpdate:s];
    if (isSeccess) {
        NSLog(@"删除成功");
    }else{
        NSLog(@"删除失败");
    }
    [database close];
}

+(void)insertOneData:(NSString *)time English:(NSString*)english EEnglish:(NSString *)eEnglish Chinese:(NSString *)chinese EChinese:(NSString *)eChinese notes:(NSString *)notes statue:(NSString *) statue timeE:(NSString *)timeE isFind:(NSString *)isFind{
    FMDatabase *db = [ERDatabaseTool creatAllWordsTable];
    [db open];
    BOOL isInsert = [db executeUpdate:@"insert into allWordsTable (time, English, EEnglish, Chinese, EChinese, notes, statue, timeE, isFind) values (?, ?, ?, ?, ?, ?, ?, ?, ?)",time,english,eEnglish,chinese,eChinese,notes,statue,timeE,isFind];
    if (isInsert) {
        NSLog(@"插入成功");
        }else{
        NSLog(@"插入失败");
        
    }
    [db close];
    

 
}
+(void)editWord:(NSString *)newPara oldPara:(NSString *)oldPara para:(NSString *)para{
    NSString *s = [NSString stringWithFormat:@"UPDATE allWordsTable SET %@='%@' WHERE %@ = '%@'",para,newPara,para,oldPara];
    FMDatabase *db = [ERDatabaseTool creatAllWordsTable];
    [db open];
    [db executeUpdate:s];
    [db close];
}
+(void)editstatue:(NSString *)newPara oldPara:(NSString *)oldPara para1:(NSString *)para1 para2:(NSString *)para2{
    NSString *s = [NSString stringWithFormat:@"UPDATE allWordsTable SET %@='%@' WHERE %@ = '%@'",para1,newPara,para2,oldPara];
    FMDatabase *db = [ERDatabaseTool creatAllWordsTable];
    [db open];
    [db executeUpdate:s];
    [db close];
}








+(FMDatabase *)creatAllFindWordsTable{
    static FMDatabase *db = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"ER.sqlite"];
        db = [FMDatabase databaseWithPath:dbPath];
        if ([db open]) {
            [db executeUpdate:@"create table if not exists allFindWordsTable (time text, English text, EEnglish text, Chinese text, EChinese text, notes text, statue text, timeE text, isFind text)"];
            [db close];
        }else{
            NSLog(@"数据库打开失败");
        }
        
        
        
        NSLog(@"db=%@",db);
        
        
    });
    [db close];
    return db;
}


// 读数据库
+(NSArray *)readFindDb:(NSString *)conten para:(NSString *)para{
    FMDatabase *database = [ERDatabaseTool creatAllFindWordsTable];
    [database open];
    FMResultSet *resultSet = [database executeQuery:conten,para];
    NSMutableArray *WordsA = [NSMutableArray array];
    while ([resultSet next]) {
        ERWord *word = [ERWord new];
        word.time = [resultSet stringForColumn:@"time"];
        word.English = [resultSet stringForColumn:@"English"];
        word.EEnglish = [resultSet stringForColumn:@"EEnglish"];
        word.Chinese = [resultSet stringForColumn:@"Chinese"];
        word.EChinese = [resultSet stringForColumn:@"EChinese"];
        word.notes = [resultSet stringForColumn:@"notes"];
        word.statue = [resultSet stringForColumn:@"statue"];
        word.timeE = [resultSet stringForColumn:@"timeE"];
        word.isFind = [resultSet stringForColumn:@"isFind"];
        [WordsA addObject:word];
        
    }
    [database close];
    return [WordsA copy];
}

// 清除数据库
+(void)cleanFindDB:(NSString *)title content:(NSString *)content{
    NSString *s = [NSString stringWithFormat:@"delete from allFindWordsTable where %@ = '%@'",title,content];
    FMDatabase *database = [ERDatabaseTool creatAllFindWordsTable];
    [database open];
    BOOL isSeccess = [database executeUpdate:s];
    if (isSeccess) {
        NSLog(@"删除成功");
    }else{
        NSLog(@"删除失败");
    }
    [database close];
}

+(void)insertToFindOneData:(NSString *)time English:(NSString*)english EEnglish:(NSString *)eEnglish Chinese:(NSString *)chinese EChinese:(NSString *)eChinese notes:(NSString *)notes statue:(NSString *) statue timeE:(NSString *)timeE isFind:(NSString *)isFind{
    FMDatabase *db = [ERDatabaseTool creatAllFindWordsTable];
    [db open];
    BOOL isInsert = [db executeUpdate:@"insert into allFindWordsTable (time, English, EEnglish, Chinese, EChinese, notes, statue, timeE, isFind) values (?, ?, ?, ?, ?, ?, ?, ?, ?)",time,english,eEnglish,chinese,eChinese,notes,statue,timeE,isFind];
    if (isInsert) {
        NSLog(@"插入成功");
    }else{
        NSLog(@"插入失败");
        
    }
    [db close];
    
    
    
}

@end
