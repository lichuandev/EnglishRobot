//
//  ERDataTool.m
//  ERobot
//
//  Created by Mac on 17/3/20.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "ERDataTool.h"

@implementation ERDataTool
 static NSMutableDictionary *mutableDic;
+(void)setWordAccount:(NSMutableDictionary *)accountA{
    mutableDic = accountA;
}
+(NSMutableDictionary *)getWordAccount{
    return mutableDic;
}
@end
