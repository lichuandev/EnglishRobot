//
//  ERDateMagementTool.m
//  ERobot
//
//  Created by Mac on 17/2/24.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "ERDateMagementTool.h"

@implementation ERDateMagementTool
+(NSString *)getDateString:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateS = [dateFormatter stringFromDate:date];
    return dateS;
}
@end
