//
//  ERViewController.m
//  ERobot
//
//  Created by Mac on 17/2/13.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "ERViewController.h"
#import "ERSelectDayViewController.h"
#import "ERWordsListViewController.h"
#import "ERInfoTableViewController.h"
#import "EREditViewController.h"

@interface ERViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *noticeImageView;
@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;

- (IBAction)setButtonClick:(id)sender;
- (IBAction)reportButtonClick:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *noticeButton;
@end

@implementation ERViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (self.tabBarController.tabBar.hidden == YES) {
        self.tabBarController.tabBar.hidden = NO;
    }

    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstUse"]){
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        NSString *dateS = [dateFormatter stringFromDate:date];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstUse"];
        [[NSUserDefaults standardUserDefaults] setObject:dateS forKey:@"birthday"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
   
    NSString *imageBase64S = [[NSUserDefaults standardUserDefaults] objectForKey:@"headerImage"];
    if (imageBase64S) {
        NSData *imageData = [[NSData alloc]initWithBase64EncodedString:imageBase64S options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *image = [UIImage imageWithData:imageData];
        _headerImageView.image = image;
    };
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    if (name) {
        _nameLabel.text = name;
    }
    NSInteger age = [[NSUserDefaults standardUserDefaults] integerForKey:@"age"];
    if (age && age >= 5) {
        age = age / 5;
        _ageLabel.text = [NSString stringWithFormat:@"%ld岁",(long)age];
    }else{
        _ageLabel.text = @"1岁";
    }

}
- (void)viewDidLoad {
    [super viewDidLoad];
     self.noticeLabel.text = @"每天至少学习20个单词，每5天成长一岁，快来跟我一起学习吧~";
}
- (IBAction)tap:(id)sender {
    [self performSegueWithIdentifier:@"maineditSegue" sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)allWordsButtonClick:(id)sender {
    [self performSegueWithIdentifier:@"selectSegue" sender:@(1)];
}

- (IBAction)errorWordsButtonClick:(id)sender {
    [self performSegueWithIdentifier:@"selectSegue" sender:@(2)];
}
- (IBAction)todayWordsButtonClick:(id)sender {
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateS = [formatter stringFromDate:date];
    [self performSegueWithIdentifier:@"todySegue" sender:dateS];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    int mark = [sender intValue];
    NSLog(@"mark:%d",mark);
    if ([segue.destinationViewController isKindOfClass:[ERSelectDayViewController class]]) {
        ERSelectDayViewController *selectVC = segue.destinationViewController;
        selectVC.mark = mark;
    }
    if ([segue.destinationViewController isKindOfClass:[ERWordsListViewController class]]) {
        NSString *dS = (NSString *)sender;
        ERWordsListViewController *listVC = segue.destinationViewController;
        listVC.titleS = dS;
    }
    if ([segue.destinationViewController isKindOfClass:[EREditViewController class]]) {
        EREditViewController *editVC = segue.destinationViewController;
        
        editVC.title = @"头像";
        editVC.mark = 0;
    }
}
- (IBAction)noticeButtonClick:(id)sender {
    
    if (!_noticeButton.selected) {
        self.noticeImageView.alpha += 0.01;
        [UIView animateWithDuration:1 animations:^{
            self.noticeImageView.alpha = 1;
        } completion:^(BOOL finished) {
            
            [self setNoticeL:0];
        }];
    }else{
        self.noticeLabel.alpha -= 0.01;
        [UIView animateWithDuration:1 animations:^{
            self.noticeLabel.alpha = 0;
        } completion:^(BOOL finished) {
            [self setNoticeL:1];
        }];
        
    }
    
}
-(void)setNoticeL:(int)mark{
    if (mark == 0) {
        self.noticeLabel.alpha += 0.01;
        [UIView animateWithDuration:1 animations:^{
            self.noticeLabel.alpha = 1;
        } completion:^(BOOL finished) {
            _noticeButton.selected = YES;
        }];
    }else{
        self.noticeImageView.alpha -= 0.01;
        [UIView animateWithDuration:1 animations:^{
            self.noticeImageView.alpha = 0;
        } completion:^(BOOL finished) {
            _noticeButton.selected = NO;
        }];
    }
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)setButtonClick:(id)sender {
    [self performSegueWithIdentifier:@"infoSegue" sender:nil];
}

- (IBAction)reportButtonClick:(id)sender {
    [self performSegueWithIdentifier:@"reportSegue" sender:nil];
}
-(void)dealloc{
    NSLog(@"");
}

@end
