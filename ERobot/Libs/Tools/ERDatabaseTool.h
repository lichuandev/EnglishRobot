//
//  TRDatabaseTool.h
//  ERobot
//
//  Created by Mac on 17/2/13.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
@interface ERDatabaseTool : NSObject

// 建立数据库
+(FMDatabase *)creatAllWordsTable;
// 读数据库
+(NSArray *)readDb:(NSString *)conten para:(NSString *)para;
// 向数据库插入消息
+(void)insertOneData:(NSString *)time English:(NSString*)english EEnglish:(NSString *)eEnglish Chinese:(NSString *)chinese EChinese:(NSString *)eChinese notes:(NSString *)notes statue:(NSString *) statue timeE:(NSString *)timeE isFind:(NSString *)isFind;
// 清除数据库
+(void)cleanDB:(NSString *)title content:(NSString *)content;
// 修改
+(void)editWord:(NSString *)newPara oldPara:(NSString *)oldPara para:(NSString *)para;
+(void)editstatue:(NSString *)newPara oldPara:(NSString *)oldPara para1:(NSString *)para1 para2:(NSString *)para2;



+(FMDatabase *)creatAllFindWordsTable;
// 读数据库
+(NSArray *)readFindDb:(NSString *)conten para:(NSString *)para;
// 清除数据库
+(void)cleanFindDB:(NSString *)title content:(NSString *)content;
+(void)insertToFindOneData:(NSString *)time English:(NSString*)english EEnglish:(NSString *)eEnglish Chinese:(NSString *)chinese EChinese:(NSString *)eChinese notes:(NSString *)notes statue:(NSString *) statue timeE:(NSString *)timeE isFind:(NSString *)isFind;
@end
