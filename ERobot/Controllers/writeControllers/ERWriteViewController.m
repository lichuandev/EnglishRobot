//
//  ERWriteViewController.m
//  ERobot
//
//  Created by Mac on 17/2/13.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "ERWriteViewController.h"
#import "ERWord.h"
#import "ERWordList.h"
#import "ERWordsListViewController.h"
#import "ERDatabaseTool.h"
#import "UIColor+FlatUI.h"
@interface ERWriteViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *ETF;
@property (weak, nonatomic) IBOutlet UITextField *CTF;
@property (weak, nonatomic) IBOutlet UITextView *notesTV;
- (IBAction)E2CButtonClick:(id)sender;
- (IBAction)C2EButtonClick:(id)sender;
@property (nonatomic, strong) NSMutableArray *wordsArray;
@property (nonatomic, strong) NSMutableArray *wordListArray;
@property (nonatomic, copy) NSString *dateStr;
@end

@implementation ERWriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _notesTV.delegate = self;
    _wordsArray = [NSMutableArray array];
    _wordListArray = [NSMutableArray array];
    if (_lastWordsArray) {
        [_wordsArray addObjectsFromArray:_lastWordsArray];
    }
    _notesTV.text = @"这里可以编辑您的笔记...";
    _notesTV.textColor = [UIColor lightGrayColor];
    _notesTV.layer.borderColor = [UIColor colorFromHexCode:@"e6e6e6"].CGColor;
   
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    // 获取当前时间
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    _dateStr = [dateFormatter stringFromDate:date];
}
// textView的代理方法
-(void)textViewDidBeginEditing:(UITextView *)textView{
    _notesTV.text = @"";
    _notesTV.textColor = [UIColor blackColor];
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
- (IBAction)nextButtonClick:(id)sender {
    [self saveData];
}
-(void)saveData{
    ERWord *word = [ERWord new];
    word.time = _dateStr;
    word.English = [_ETF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    word.EEnglish = @"";
    word.Chinese = _CTF.text;
    word.EChinese = @"";
    word.notes = _notesTV.text;
    word.statue = @"1";
    word.timeE = [NSString stringWithFormat:@"%@-%@",_dateStr,_ETF.text];
    [_wordsArray addObject:word];
    _CTF.text = @"";
    _ETF.text = @"";
    _notesTV.text = @"这里可以编辑您的笔记...";
    _notesTV.textColor = [UIColor lightGrayColor];
    [_ETF becomeFirstResponder];
}
- (IBAction)completeButtonClick:(id)sender {
    if (_ETF.text.length != 0) {
        [self saveData];
    }
    
    
   


    if (_mark == 1) {
        [ERDatabaseTool cleanDB:@"time" content:_dateStr];
    }
    
    for (ERWord *word in _wordsArray) {
        [ERDatabaseTool insertOneData:word.time English:word.English EEnglish:word.EEnglish Chinese:word.Chinese EChinese:word.EChinese notes:word.notes statue:word.statue timeE:word.timeE isFind:@""];
    }
    [self.navigationController popViewControllerAnimated:YES];
    

   
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"willBack" object:nil];
}
- (IBAction)E2CButtonClick:(id)sender {
    if (_ETF.text.length == 0) {
        return;
    }
    NSString *urlS = [NSString stringWithFormat:@"http://fanyi.youdao.com/openapi.do?keyfrom=EnglishRobot&key=125224454&type=data&doctype=json&version=1.1&q=%@",_ETF.text];
    urlS = [urlS stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlS]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"返回的数据：%@",data);
            NSError *JSONerror = nil;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONerror];
            NSLog(@"字典：%@",dic);
            dispatch_async(dispatch_get_main_queue(), ^{
                _CTF.text = [dic[@"translation"] firstObject];
            });
        }
        
        
    }];
    [task resume];
}

- (IBAction)C2EButtonClick:(id)sender {
    if (_CTF.text.length == 0) {
        return;
    }
    NSString *urlS = [NSString stringWithFormat:@"http://fanyi.youdao.com/openapi.do?keyfrom=EnglishRobot&key=125224454&type=data&doctype=json&version=1.1&q=%@",_CTF.text];
    urlS = [urlS stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlS]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"返回的数据：%@",data);
            NSError *JSONerror = nil;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONerror];
            NSLog(@"字典：%@",dic);
            dispatch_async(dispatch_get_main_queue(), ^{
                _ETF.text = [dic[@"translation"] firstObject];
            });
        }else{
            NSLog(@"错误：%@",error);
        }
        
        
    }];
    [task resume];

}
@end
