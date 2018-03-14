//
//  ERResult.h
//  ERobot
//
//  Created by Mac on 17/3/22.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ERResult : NSObject<NSCoding>
@property (nonatomic, assign) int studyDays;
@property (nonatomic, assign) int totalWords;
@property (nonatomic, assign) int listenWords;
@property (nonatomic, assign) int correctWords;
@end
