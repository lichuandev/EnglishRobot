//
//  EREditViewController.h
//  ERobot
//
//  Created by Mac on 17/3/21.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EREditViewController : UIViewController
@property (nonatomic, assign) int mark; // 0代表是头像，1代表是姓名
@property (nonatomic, copy) NSString *name;
@end
