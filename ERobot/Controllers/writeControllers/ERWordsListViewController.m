//
//  ERWordsListViewController.m
//  ERobot
//
//  Created by Mac on 17/2/16.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "ERWordsListViewController.h"
#import "ERWord.h"
#import "ERWriteViewController.h"
#import "ERDatabaseTool.h"
#import "UIColor+FlatUI.h"
#import "ERDetailViewController.h"
#import "ERListenSelectViewController.h"
@interface ERWordsListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UITableView *wordsListTable;
@property (weak, nonatomic) IBOutlet UIView *emptyView;
- (IBAction)beginButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
- (IBAction)continueButtonClick:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *beginButton;
@property (nonatomic, copy) NSString *currentT;
@end

@implementation ERWordsListViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (self.tabBarController.tabBar.hidden == NO) {
        self.tabBarController.tabBar.hidden = YES;
    }
    NSString *s = @"select * from allWordsTable where time = ?";
   
    _wordsArray = [ERDatabaseTool readDb:s para:_titleS];
    if (_mark == 2) {
        _promptLabel.text = @"小主，今天没有错词哦~";
        _beginButton.hidden = YES;
        NSMutableArray *wrongWordsA = [NSMutableArray array];
        for (ERWord *word in _wordsArray) {
            NSLog(@"状态：%@",word.statue);
            if ([word.statue isEqualToString:@"0"]) {
                [wrongWordsA addObject:word];
            }
        }
        _wordsArray = [wrongWordsA copy];
    }
    
    [self setMyVC];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    _wordsListTable.tableFooterView = [UIView new];
    
}

-(void)setMyVC{
    _wordsListTable.delegate = self;
    _wordsListTable.dataSource = self;
    self.navigationItem.title = _titleS;
    
    if (_wordsArray.count == 0) {
        _emptyView.hidden = NO;
        
        
        _wordsListTable.hidden = YES;
        _continueButton.hidden = YES;
    }
    if (_mark == 2) {
        _continueButton.hidden = YES;
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents *components = [calendar components:unitFlags fromDate:[NSDate date]];
    NSInteger year = [components year];  //当前的年份
    NSInteger month = [components month];  //当前的月份
    NSInteger day = [components day]; // 当前的日期
    
    if (month < 10 && day > 9) {
        _currentT = [NSString stringWithFormat:@"%ld-0%ld-%ld",(long)year,(long)month,(long)day];
    }
    if (day < 10 && month >9) {
        _currentT = [NSString stringWithFormat:@"%ld-%ld-0%ld",(long)year,(long)month,(long)day];
    }
    if (day < 10 && month < 10) {
        _currentT = [NSString stringWithFormat:@"%ld-0%ld-0%ld",(long)year,(long)month,(long)day];
    }
    NSLog(@"_currentT:%@,_titleS:%@",_currentT,_titleS);
    if ([_currentT isEqualToString:_titleS]) {
        if (_mark != 2) {
            _beginButton.hidden = NO;
        }
        
    }else{
        [_continueButton setTitle:@"听写单词" forState:UIControlStateNormal];
    }
   
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _wordsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [UIColor colorFromHexCode:@"02c7af"];
        cell.textLabel.font = [UIFont systemFontOfSize:18];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    }
    ERWord *word = _wordsArray[indexPath.row];
    

    cell.textLabel.text = word.English;
    cell.detailTextLabel.text = word.Chinese;
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ERWord *word = _wordsArray[indexPath.row];
    [self performSegueWithIdentifier:@"detailSegue" sender:word];
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    ERWord *word = _wordsArray[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *a = [NSMutableArray arrayWithArray:_wordsArray];
        [a removeObject:_wordsArray[indexPath.row]];
        _wordsArray = [a copy];
        [self.wordsListTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [ERDatabaseTool cleanDB:@"timeE" content:word.timeE];
    }
    [self.wordsListTable reloadData];}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)beginButtonClick:(id)sender {
    [self performSegueWithIdentifier:@"continueSegue" sender:nil];
}
- (IBAction)continueButtonClick:(id)sender {
    if (![_currentT isEqualToString:_titleS]) {
        if (_mark == 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self performSegueWithIdentifier:@"s2lSegue" sender:nil];
        }
        
    }else{
        [self performSegueWithIdentifier:@"continueSegue" sender:nil];
    }
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.destinationViewController isKindOfClass:[ERWriteViewController class]]) {
        ERWriteViewController *writeVC = (ERWriteViewController *)segue.destinationViewController;
        if (_wordsArray.count != 0) {
            writeVC.lastWordsArray = _wordsArray;
            writeVC.mark = 1;
        }
        
    }
    if ([segue.destinationViewController isKindOfClass:[ERDetailViewController class]]) {
        ERWord *word = (ERWord *)sender;
        ERDetailViewController *detailVC = (ERDetailViewController *)segue.destinationViewController;
        detailVC.word = word;
        detailVC.wordsArray = _wordsArray;
        if (_mark == 2) {
            detailVC.mark = 1;
        }
    }
    if ([segue.destinationViewController isKindOfClass:[ERListenSelectViewController class]]) {
      
        ERListenSelectViewController *lsVC = (ERListenSelectViewController *)segue.destinationViewController;
        lsVC.dateS = _titleS;
        lsVC.mark = 1;
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    self.view = nil;
}

@end
