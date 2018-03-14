//
//  ERWordsListViewController.h
//  ERobot
//
//  Created by Mac on 17/2/16.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ERWordsListViewController : UIViewController
@property (nonatomic, strong) NSArray *wordsArray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wordListConstraint;
@property (nonatomic, copy) NSString *titleS;
@property (nonatomic, assign) int mark;// mark = 1 代表是从听写单词出跳转过来的 2代表是从错误的单词跳转过来的
@end
