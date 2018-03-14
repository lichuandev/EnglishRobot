//
//  ERSelectDayViewController.m
//  ERobot
//
//  Created by Mac on 17/2/15.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "ERSelectDayViewController.h"
#import "UIColor+FlatUI.h"
#import "ERDatabaseTool.h"
#import "ERWordsListViewController.h"
#import "ERListenSelectViewController.h"
#import "UIView+Extension.h"
#import "ERWord.h"
@interface ERSelectDayViewController ()
//@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *timeButtonArray;
// 当前月的天数
@property (nonatomic, assign) NSInteger numberOfDaysInMonth;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *selectButtonArray;

- (IBAction)selectButtonClick:(UIButton *)sender;
@property (nonatomic, strong) UIButton *lastButton;
@property (nonatomic, assign) NSInteger currentMouth;
@property (nonatomic, assign) NSInteger currentYear;
@property (nonatomic, assign) NSInteger cuttentDay;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
- (IBAction)lastButtonClick:(id)sender;
- (IBAction)nextButtonClick:(id)sender;
@property (nonatomic, assign) NSInteger month;
@property (nonatomic, assign) int remark;
@end

@implementation ERSelectDayViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    NSLog(@"这个mark：%d",_mark);
    if (_mark == 1 || _mark == 2) {
        if (self.tabBarController.tabBar.hidden == NO) {
            self.tabBarController.tabBar.hidden = YES;
        }
    }else{
        if (self.tabBarController.tabBar.hidden == YES) {
            self.tabBarController.tabBar.hidden = NO;
        }
        
    }
}

-(void)viewDidLoad{
    [super viewDidLoad];
    _remark = 1;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents *components = [calendar components:unitFlags fromDate:[NSDate date]];
    _currentYear = [components year];  //当前的年份
    _currentMouth = [components month];  //当前的月份
    _month = _currentMouth;
    _cuttentDay = [components day]; // 当前的日期
    // 获取当天所在的月的天数
    [self getNumberOfDaysInMonth:_currentMouth];
    // 设置view
    [self setVC];

}
-(void)getNumberOfDaysInMonth:(NSInteger)month{
    if((month == 1) || (month == 3) || (month == 5) || (month == 7) || (month == 8) || (month == 10) || (month == 12))
        _numberOfDaysInMonth = 31 ;
    
    if((month == 4) || (month == 6) || (month == 9) || (month == 11))
        _numberOfDaysInMonth = 30;
    
    if((_currentYear % 400 == 0) && (_currentMouth == 2))
    
        _numberOfDaysInMonth = 29;
    
    
    if((_currentYear % 400 != 0) && (_currentMouth == 2))
    
        _numberOfDaysInMonth = 28;
    
}
-(void)setVC{
    if (_currentMouth < 10) {
        _timeLabel.text = [NSString stringWithFormat:@"%ld-0%ld",(long)_currentYear,(long)_currentMouth];
    }else{
        _timeLabel.text = [NSString stringWithFormat:@"%ld-%ld",(long)_currentYear,(long)_currentMouth];
    }
        int i = 0;
    for (UIButton *button in _selectButtonArray) {
        i += 1;
        if (i<_numberOfDaysInMonth+1) {
            [button setTitle:[NSString stringWithFormat:@"%d",i] forState:UIControlStateNormal];
            button.tag = i;
            button.backgroundColor = [UIColor colorFromHexCode:@"f9f9f9"];
            if (i<10) {
                NSString *dateS = [NSString stringWithFormat:@"%@-0%d",_timeLabel.text,i];
                [self creadLabel:button withDate:dateS i:i];
            }else{
                NSString *dateS = [NSString stringWithFormat:@"%@-%d",_timeLabel.text,i];
                [self creadLabel:button withDate:dateS i:i];
            }

            if (_month == _currentMouth) {
                if (i == _cuttentDay) {
                    [button setTitleColor:[UIColor colorFromHexCode:@"02c7af"] forState:UIControlStateNormal];
                    button.userInteractionEnabled = YES;
                    _lastButton = button;
                }else if (i<_cuttentDay) {
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    button.userInteractionEnabled = YES;
                    }else{
                    [button setTitleColor:[UIColor colorFromHexCode:@"b0b0b0"] forState:UIControlStateNormal];
                    button.userInteractionEnabled = NO;
                }
            }else if(_month < _currentMouth){
                [button setTitleColor:[UIColor colorFromHexCode:@"b0b0b0"] forState:UIControlStateNormal];
                button.userInteractionEnabled = NO;
            }else{
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                
                button.userInteractionEnabled = YES;
            }
            
            
            
            
            
        }else{
            
            [button setTitleColor:[UIColor colorFromHexCode:@"f9f9f9"] forState:UIControlStateNormal];
            button.userInteractionEnabled = NO;

        }
        
    }
    
    
    
}
-(void)creadLabel:(UIButton *)button withDate:(NSString *)dateS i:(int)i{
    UILabel *label = [[UILabel alloc]init];
    if (_remark == 1) {
        label.frame = CGRectMake(button.x, button.y-33, button.width, 20);
    }else{
        label.frame = CGRectMake(button.x, button.y+button.height-8, button.width, 20);
    }
    
    
    NSString *weekS = [self getTheDayOfTheWeekByDateString:dateS];
    weekS = [weekS substringFromIndex:2];
    weekS = [NSString stringWithFormat:@"周%@",weekS];
    label.backgroundColor = [UIColor colorFromHexCode:@"f9f9f9"];
    label.layer.masksToBounds = YES;
    //label.text = [NSString stringWithFormat:@"%lu",(unsigned long)array.count];
    label.text = weekS;
    label.font = [UIFont systemFontOfSize:13];
    if (_month == _currentMouth) {
        if (i > _cuttentDay ) {
            label.textColor = [UIColor colorFromHexCode:@"b0b0b0"];
        }else{
            label.textColor = [UIColor colorFromHexCode:@"333333"];
        }

    }else if (_month < _currentMouth){
       label.textColor = [UIColor colorFromHexCode:@"b0b0b0"];
    }else{
       label.textColor = [UIColor colorFromHexCode:@"333333"];
    }
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    NSString *s = @"select * from allWordsTable where time = ?";
    NSArray *array = [ERDatabaseTool readDb:s para:dateS];
    
    if (array.count >0) {
        UILabel *label = [[UILabel alloc]init];
        if (_remark == 1) {
           label.frame = CGRectMake(button.center.x-5, button.y-13, 10, 10);
        }else{
           label.frame = CGRectMake(button.center.x-5, button.y+button.height+11, 10, 10);
        }
        
        label.backgroundColor = [UIColor colorFromHexCode:@"b0b0b0"];
        label.layer.cornerRadius = 5;
        label.layer.masksToBounds = YES;
        if (_mark == 2) {
            NSMutableArray *mutabelArray = [NSMutableArray array];
            for (ERWord *word in array) {
                if ([word.statue intValue] == 0) {
                    [mutabelArray addObject:word];
                }
            }
            if (mutabelArray.count>0) {
                label.text = [NSString stringWithFormat:@"%lu",(unsigned long)mutabelArray.count];
            }else{
                label.backgroundColor = [UIColor colorFromHexCode:@"f9f9f9"];
            }
            
        }else{
            label.text = [NSString stringWithFormat:@"%lu",(unsigned long)array.count];
        }
        
        label.font = [UIFont systemFontOfSize:7];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
    }
}
// 判断某一天是周几
-(NSString *)getTheDayOfTheWeekByDateString:(NSString *)dateString{
    
    NSDateFormatter *inputFormatter=[[NSDateFormatter alloc]init];
    
    [inputFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *formatterDate=[inputFormatter dateFromString:dateString];
    
    NSDateFormatter *outputFormatter=[[NSDateFormatter alloc]init];
    
    [outputFormatter setDateFormat:@"EEEE-MMMM-d"];
    
    NSString *outputDateStr=[outputFormatter stringFromDate:formatterDate];
    NSArray *weekArray=[outputDateStr componentsSeparatedByString:@"-"];
    return [weekArray objectAtIndex:0];
}
- (IBAction)selectButtonClick:(UIButton *)sender {
    if (sender.tag != _cuttentDay) {
        [sender setTitleColor:[UIColor colorFromHexCode:@"ffa200"] forState:UIControlStateNormal];
    }
    
    if (_lastButton && sender.tag != _lastButton.tag && _lastButton.tag != _cuttentDay) {
        [_lastButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    _lastButton = sender;
    NSString *timeS;
    if (sender.tag <10) {
         timeS = [NSString stringWithFormat:@"%@-0%ld",_timeLabel.text, (long)sender.tag];
    }else{
        timeS = [NSString stringWithFormat:@"%@-%ld",_timeLabel.text, (long)sender.tag];
    }
   
    timeS = [timeS substringToIndex:10];
    if (_mark != 1 && _mark !=2) {
        [self performSegueWithIdentifier:@"listenSelectSegue" sender:timeS];
    }else{
        [self performSegueWithIdentifier:@"wordsListSegue" sender:@{@"timeS":timeS,@"mark":@(_mark)}];
    }
    
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.destinationViewController isKindOfClass:[ERWordsListViewController class]]) {
        NSDictionary *dic = (NSDictionary *)sender;
        ERWordsListViewController *wordsListVC = segue.destinationViewController;
        wordsListVC.titleS = dic[@"timeS"];
        wordsListVC.mark = [dic[@"mark"] intValue];
    }
    if ([segue.destinationViewController isKindOfClass:[ERListenSelectViewController class]]) {
        NSString *title = (NSString *)sender;
        ERListenSelectViewController *lsVC = segue.destinationViewController;
        lsVC.dateS = title;
    }
}
- (IBAction)lastButtonClick:(id)sender {
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UILabel class]] && view.tag != 1) {
            [view removeFromSuperview];
        }
    }
    _remark = 0;
    _currentMouth -= 1;
    if (_currentMouth == 0) {
        _currentYear -= 1;
        _currentMouth = 12;
    }
    
    if (_currentMouth < 10) {
        _timeLabel.text = [NSString stringWithFormat:@"%ld-0%ld",(long)_currentYear,(long)_currentMouth];
    }else{
        _timeLabel.text = [NSString stringWithFormat:@"%ld-%ld",(long)_currentYear,(long)_currentMouth];
    }
    
    [self getNumberOfDaysInMonth:_currentMouth];
    [self setVC];

}

- (IBAction)nextButtonClick:(id)sender {
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UILabel class]] && view.tag != 1) {
            [view removeFromSuperview];
        }
    }
    _remark = 0;
    _currentMouth += 1;
    if (_currentMouth == 13){
        _currentYear += 1;
        _currentMouth = 1;
    }
    if (_currentMouth < 10) {
        _timeLabel.text = [NSString stringWithFormat:@"%ld-0%ld",(long)_currentYear,(long)_currentMouth];
    }else{
        _timeLabel.text = [NSString stringWithFormat:@"%ld-%ld",(long)_currentYear,(long)_currentMouth];
    }
    [self getNumberOfDaysInMonth:_currentMouth];
    [self setVC];
}
-(void)dealloc{
    NSLog(@"");
}
@end
