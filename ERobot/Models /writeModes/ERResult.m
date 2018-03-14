//
//  ERResult.m
//  ERobot
//
//  Created by Mac on 17/3/22.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "ERResult.h"

@implementation ERResult
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInt:self.totalWords forKey:@"totalWords"];
    [aCoder encodeInt:self.studyDays forKey:@"studyDays"];
    [aCoder encodeInt:self.listenWords forKey:@"listenWords"];
    [aCoder encodeInt:self.correctWords forKey:@"correctWords"];
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.totalWords = [aDecoder decodeIntForKey:@"totalWords"];
        self.studyDays = [aDecoder decodeIntForKey:@"studyDays"];
        self.listenWords = [aDecoder decodeIntForKey:@"listenWords"];
        self.correctWords = [aDecoder decodeIntForKey:@"correctWords"];
    }
    return self;
}
@end
