//
//  ERDetailViewController.h
//  ERobot
//
//  Created by Mac on 17/2/18.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ERWord.h"
@interface ERDetailViewController : UIViewController
@property (nonatomic, strong) NSArray *wordsArray;
@property (nonatomic, strong) ERWord *word;
@property (nonatomic, assign) int mark; //mark 等于1代表是从错题那里跳过来的
@end
