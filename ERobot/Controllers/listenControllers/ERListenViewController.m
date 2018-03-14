//
//  ERListenViewController.m
//  ERobot
//
//  Created by Mac on 17/2/24.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "ERListenViewController.h"
#import "ERWord.h"
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD+KR.h"
#import "ERDatabaseTool.h"
#import "ERScoreViewController.h"
@interface ERListenViewController ()<AVSpeechSynthesizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *wordLabel;
@property (weak, nonatomic) IBOutlet UITextField *EATF;
@property (weak, nonatomic) IBOutlet UIButton *listenButton;
@property (weak, nonatomic) IBOutlet UIButton *lookButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;

@property (weak, nonatomic) IBOutlet UITextField *CATF;
@property (nonatomic, strong) AVSpeechSynthesizer *spe;
@property (nonatomic, strong) ERWord *word;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSMutableSet *indexSet;
@property (nonatomic, assign) int correctCount;
@end

@implementation ERListenViewController
-(AVSpeechSynthesizer *)spe{
    if (!_spe) {
        _spe = [AVSpeechSynthesizer new];
        _spe.delegate = self;
    }
    return _spe;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _indexSet = [NSMutableSet set];
    _index = 0;
    _correctCount = 0;
    [_indexSet addObject:@(_index)];
    _word = [self getWord:_index];
    [self setMyView:_word];
}
-(ERWord *)getWord:(NSInteger)index{
    ERWord *word = [_wordsArray objectAtIndex:index];
    return word;
}
-(void)setMyView:(ERWord *)word{
    _totalLabel.text = [NSString stringWithFormat:@"%ld/%lu",_index+1,(unsigned long)_wordsArray.count];
    if (_language == 1) {
        _wordLabel.text = word.Chinese;
        _listenButton.enabled = NO;
        _lookButton.enabled = NO;
        _EATF.placeholder = @"请输入英语答案...";
        _CATF.userInteractionEnabled = NO;
        _CATF.placeholder = @"汉译英时无需填写...";
    }else if (_language == 2){
        _wordLabel.text = @"*****";
        _listenButton.userInteractionEnabled = YES;
        _lookButton.enabled = YES;
        _EATF.placeholder = @"请输入英语答案...";
        _CATF.userInteractionEnabled = YES;
        _CATF.placeholder = @"请输入汉语翻译...";
    }
}
- (IBAction)listenButtonClick:(id)sender {
    if (self.spe.speaking) {
        [self.spe stopSpeakingAtBoundary:AVSpeechBoundaryWord];
        return;
    }
    AVSpeechUtterance *utt = [AVSpeechUtterance speechUtteranceWithString:_word.English];
    utt.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-GB"];
    
    [self.spe speakUtterance:utt];
}
- (IBAction)lookButtonClick:(id)sender {
    _lookButton.selected = !_lookButton.selected;
    _wordLabel.text = _lookButton.selected ? _word.English : @"*****";
}
- (IBAction)nextButtonClick:(id)sender {
    
    if (_lookButton.selected) {
        _lookButton.selected = NO;
    }
    if (_order == 1) {
        _index += 1;
        if (_index > _wordsArray.count-1) {
            [MBProgressHUD showSuccess:@"亲，已经听写完喽！"];
            _nextButton.enabled = NO;
            [_nextButton setTitle:@"没有更多单词了" forState:UIControlStateNormal];
            [_nextButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            _nextButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
            return;
        }
    }else if(_order == 2){
        _index = [self getRandomIndex];
        NSLog(@"index:%ld",(long)_index);
        if ([_indexSet containsObject:@(_index)]) {
            [self nextButtonClick:nil];
        }else{
            [_indexSet addObject:@(_index)];
        }
        if (_indexSet.count == _wordsArray.count) {
            [MBProgressHUD showSuccess:@"亲，已经听写完喽！"];
            _nextButton.enabled = NO;
            [_nextButton setTitle:@"没有更多单词了" forState:UIControlStateNormal];
            [_nextButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            _nextButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
            //return;
        }

    }
    // 判断得分
    [self getScore];
    _word = [self getWord:_index];
    [self setMyView:_word];

    
    
    if (_language == 1) {
        _EATF.text = @"";
    }else{
        _EATF.text = @"";
        _CATF.text = @"";
    }
    [self.EATF becomeFirstResponder];
}
-(void)getScore{
    
    NSString *anwser = [_EATF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSLog(@"答案：%@，状态：%@",anwser,_word.statue);
    if (_language == 1) {
        if ([anwser isEqualToString:_word.English]) {
            if ([_word.statue isEqualToString:@"0"]) {
                [ERDatabaseTool editstatue:@"1" oldPara:_word.timeE para1:@"statue" para2:@"timeE"];
            }
            
            _correctCount += 1;
        }else{
            
            [ERDatabaseTool editstatue:_EATF.text oldPara:_word.timeE para1:@"EEnglish" para2:@"timeE"];
            
            if ([_word.statue isEqualToString:@"1"]) {
                [ERDatabaseTool editstatue:@"0" oldPara:_word.timeE para1:@"statue" para2:@"timeE"];
            }
        }
    }else if (_language == 2){
        if ([anwser isEqualToString:_word.English]) {

            [ERDatabaseTool cleanDB:@"timeE" content:_word.timeE];
            [ERDatabaseTool insertOneData:_word.time English:_word.English EEnglish:@"" Chinese:_word.Chinese EChinese:@"" notes:_word.notes statue:@"1" timeE:_word.timeE isFind:@""];
            _correctCount += 1;
        }else{
            [ERDatabaseTool cleanDB:@"timeE" content:_word.timeE];
            

            if (![anwser isEqualToString:_word.English]&&[_CATF.text isEqualToString:_word.Chinese]) {
                [ERDatabaseTool insertOneData:_word.time English:_word.English EEnglish:anwser Chinese:_word.Chinese EChinese:@"" notes:_word.notes statue:@"0" timeE:_word.timeE isFind:@""];
            }
            if (![_CATF.text isEqualToString:_word.Chinese]&&[anwser isEqualToString:_word.English]){
                [ERDatabaseTool insertOneData:_word.time English:_word.English EEnglish:@"" Chinese:_word.Chinese EChinese:_CATF.text notes:_word.notes statue:@"0" timeE:_word.timeE isFind:@""];
            }
            if (![_CATF.text isEqualToString:_word.Chinese]&&![anwser isEqualToString:_word.English]) {
                [ERDatabaseTool insertOneData:_word.time English:_word.English EEnglish:anwser Chinese:_word.Chinese EChinese:_CATF.text notes:_word.notes statue:@"0" timeE:_word.timeE isFind:@""];
            }
            
        }
    }

    
}
-(NSInteger)getRandomIndex{
    NSInteger index = arc4random()%_wordsArray.count;
    return index;
}
- (IBAction)completeButtonClick:(id)sender {
    
    if (_order == 1) {
        if (_index < _wordsArray.count-1) {
            [self presentAlertView];
        }else{
            [self getScore];
            [self gotoNextView];
            NSLog(@"得分：%d",_correctCount);
        }
    }else if (_order == 2){
        if (_indexSet.count < _wordsArray.count) {
            [self presentAlertView];
        }else{
            [self getScore];
            // 处理得分问题
            [self gotoNextView];
            NSLog(@"得分：%d",_correctCount);
        }
    }
}
-(void)presentAlertView{
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:@"小主，单词还没有听写完哦~" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureA = [UIAlertAction actionWithTitle:@"继续提交" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getScore];
        // 处理得分问题
        [self gotoNextView];
        NSLog(@"得分：%d",_correctCount);
    }];
    UIAlertAction *cancelA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // 取消
    }];
    [alertC addAction:sureA];
    [alertC addAction:cancelA];
    [self presentViewController:alertC animated:YES completion:nil];
}
-(void)gotoNextView{
    [self performSegueWithIdentifier:@"completeSegue" sender:nil];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[ERScoreViewController class]]) {
        ERScoreViewController *scoreVC = segue.destinationViewController;
        scoreVC.totalAcount = (int)_wordsArray.count;
        scoreVC.rightAcount = _correctCount;
        scoreVC.dateS = self.navigationItem.title;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
