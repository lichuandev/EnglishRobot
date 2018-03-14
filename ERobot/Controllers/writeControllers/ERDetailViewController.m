//
//  ERDetailViewController.m
//  ERobot
//
//  Created by Mac on 17/2/18.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "ERDetailViewController.h"
#import "UIColor+FlatUI.h"
#import <AVFoundation/AVFoundation.h>
#import "ERDatabaseTool.h"
#import "UIView+Extension.h"
#import "MBProgressHUD+KR.h"
@interface ERDetailViewController ()<UITextViewDelegate,AVSpeechSynthesizerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *EditButton;
- (IBAction)editButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *errorTF;
@property (weak, nonatomic) IBOutlet UILabel *errorCTF;


@property (weak, nonatomic) IBOutlet UITextField *englishTF;
- (IBAction)listenButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *chinesTF;

@property (weak, nonatomic) IBOutlet UITextView *notesTV;
@property (nonatomic, assign) BOOL isEdit;
@property (nonatomic, strong) AVSpeechSynthesizer *spe;
@end

@implementation ERDetailViewController
-(AVSpeechSynthesizer *)spe{
    if (!_spe) {
        _spe = [AVSpeechSynthesizer new];
        _spe.delegate = self;
    }
    return _spe;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (self.tabBarController.tabBar.hidden == NO) {
        self.tabBarController.tabBar.hidden = YES;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"标题：%@",_word.English);
    self.navigationItem.title = _word.English;
    self.notesTV.delegate = self;
    _notesTV.layer.borderColor = [UIColor colorFromHexCode:@"e6e6e6"].CGColor;
    _isEdit = NO;
    [self setMyVC];
}
-(void)setMyVC{
    if (_mark == 2) {
        [_EditButton setTitle:@"加入单词本" forState:UIControlStateNormal];
    }
    if (_mark == 1) {
        if (_word.EEnglish) {
            _errorTF.hidden = NO;
            _errorTF.text = _word.EEnglish;
        }
        if (_word.EChinese) {
            _errorCTF.hidden = NO;
            _errorCTF.text = _word.EChinese;
        }
    }
    _englishTF.text = _word.English;
    _englishTF.font = [UIFont systemFontOfSize:30];
    _chinesTF.text = _word.Chinese;
    _notesTV.text = _word.notes;
    _notesTV.textColor = [UIColor colorFromHexCode:@"666666"];
    if (_notesTV.text.length<1) {
        _notesTV.text = @"这里可以编辑您的笔记...";
        _notesTV.textColor = [UIColor lightGrayColor];
    }
}
-(void)textViewDidBeginEditing:(UITextView *)textView{
    self.view.y -= 1;
    [UIView animateWithDuration:0.5 animations:^{
        self.view.y = -200;
    }];
    
    if ([_notesTV.text isEqualToString:@"这里可以编辑您的笔记..."]) {
        _notesTV.text = @"";
        _notesTV.textColor = [UIColor colorFromHexCode:@"666666"];
    }
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    self.view.y += 1;
    [UIView animateWithDuration:0.5 animations:^{
        self.view.y = 64;
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.spe stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (IBAction)editButtonClick:(id)sender {
    if (_mark == 2) {
        // 获取当前时间
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        NSString *timeS = [dateFormatter stringFromDate:date];
        NSLog(@"日期：%@",timeS);
        for (int i = 0; i < _word.English.length; i ++) {
            NSString *s = [_word.English substringWithRange:NSMakeRange(i, 1)];
            const char *utf8S = [s UTF8String];
            if (strlen(utf8S) == 3) {
                NSString *tempS = _word.English;
                _word.English = _word.Chinese;
                _word.Chinese = tempS;
                _word.time = timeS;
                _word.timeE = [NSString stringWithFormat:@"%@-%@",timeS,_word.English];
            }
        }
        
        [ERDatabaseTool insertOneData:timeS English:_word.English EEnglish:@"" Chinese:_word.Chinese EChinese:@"" notes:_word.notes statue:_word.statue timeE:_word.timeE isFind:_word.isFind];
        [MBProgressHUD showSuccess:@"加入成功~"];
    }else{
        _isEdit = !_isEdit;
        if (_isEdit) {
            [_englishTF becomeFirstResponder];
            _englishTF.userInteractionEnabled = YES;
            _chinesTF.userInteractionEnabled = YES;
            _notesTV.userInteractionEnabled = YES;
            [_EditButton setTitle:@"保存" forState:UIControlStateNormal];
            
        }else{
            _englishTF.userInteractionEnabled = NO;
            _chinesTF.userInteractionEnabled = NO;
            _notesTV.userInteractionEnabled = NO;
            [_EditButton setTitle:@"修改" forState:UIControlStateNormal];
            if (![_englishTF.text isEqualToString:_word.English]) {
                [ERDatabaseTool editWord:_englishTF.text oldPara:_word.English para:@"English"];
                [ERDatabaseTool editWord:[NSString stringWithFormat:@"%@-%@",_word.time,_englishTF.text] oldPara:_word.timeE para:@"timeE"];
            }
            if (![_chinesTF.text isEqualToString:_word.Chinese]) {
                [ERDatabaseTool editWord:_chinesTF.text oldPara:_word.Chinese para:@"Chinese"];
            }
            if (![_notesTV.text isEqualToString:_word.notes]) {
                [ERDatabaseTool editWord:_notesTV.text oldPara:_word.notes para:@"notes"];
            }
        }
 
    }
    
}
- (IBAction)listenButtonClick:(id)sender {
    if (self.spe.speaking) {
        [self.spe stopSpeakingAtBoundary:AVSpeechBoundaryWord];
        return;
    }
    //设置读取的文本
    AVSpeechUtterance *utt = [AVSpeechUtterance speechUtteranceWithString:_englishTF.text];
    //设置使用什么语言
    utt.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-GB"];
    
    [self.spe speakUtterance:utt];
}
-(void)dealloc{
    NSLog(@"");
}
@end
