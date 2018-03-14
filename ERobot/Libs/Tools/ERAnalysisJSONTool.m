//
//  TRAnalysisJSONTool.m
//  ERobot
//
//  Created by Mac on 17/2/13.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "ERAnalysisJSONTool.h"
@implementation ERAnalysisJSONTool

+(NSMutableArray *) getModelDataFromArray:(NSArray *)array withClass:(Class)myclass
{
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        NSLog(@"dic:%@",dic);
        id model = [myclass new];
        [model setValuesForKeysWithDictionary:dic];
       
        [mutableArray addObject:model];
    }
    
    return mutableArray;
}
@end
