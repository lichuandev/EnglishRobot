//
//  ERFindViewController.m
//  ERobot
//
//  Created by Mac on 17/3/7.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "ERFindViewController.h"
#import "ERWord.h"
#import "ERDatabaseTool.h"
#import "MBProgressHUD+KR.h"
#import "UIColor+FlatUI.h"
#import "ERDetailViewController.h"
#import "ERTableTootView.h"
#import <AVFoundation/AVFoundation.h>
#import <Speech/Speech.h>
@interface ERFindViewController ()<UITableViewDelegate,UITableViewDataSource,AVSpeechSynthesizerDelegate>
- (IBAction)recordButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UITextField *wordTF;
- (IBAction)findButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *wordListTableView;
@property (weak, nonatomic) IBOutlet UILabel *localTL;
- (IBAction)readWordButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *speechView;
@property (weak, nonatomic) IBOutlet UILabel *wordLabel;
@property (weak, nonatomic) IBOutlet UIButton *ELabel;
@property (weak, nonatomic) IBOutlet UILabel *NLabel;
@property (nonatomic, copy) NSString *labelS;
@property (weak, nonatomic) IBOutlet UILabel *TLabel;
@property (nonatomic, strong) NSArray *findWordsArray;
@property (nonatomic, copy) NSString *dateS;
@property (weak, nonatomic) IBOutlet UIButton *speechButton;
@property (weak, nonatomic) IBOutlet UILabel *headerL;
- (IBAction)addButtonClick:(id)sender;
- (IBAction)speechButtonClick:(id)sender;
@property (nonatomic, strong) AVSpeechSynthesizer *spe;
@property (nonatomic, strong) NSMutableArray *wordsListA;
@property (nonatomic, strong) NSArray * allFindsWordsA;
@property (nonatomic, strong) ERWord *lastWord;
@property (nonatomic, strong) NSString *firstW;
@property (nonatomic, strong) SFSpeechRecognitionTask *task;
@property (nonatomic, strong) AVAudioEngine *engine;
@property (nonatomic, strong) SFSpeechRecognizer *recongizer;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *request;
@end

@implementation ERFindViewController
-(AVSpeechSynthesizer *)spe{
    if (!_spe) {
        _spe = [AVSpeechSynthesizer new];
        _spe.delegate = self;
    }
    return _spe;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (self.tabBarController.tabBar.hidden == YES) {
        self.tabBarController.tabBar.hidden = NO;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // 获取当前时间
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    _dateS = [dateFormatter stringFromDate:date];
    NSString *s = @"select * from allFindWordsTable where isFind = ?";
    _wordsListA = [NSMutableArray array];
    _findWordsArray = [ERDatabaseTool readFindDb:s para:@"yes"];
    _allFindsWordsA = _findWordsArray;
    [self.wordListTableView reloadData];
    self.wordListTableView.delegate = self;
    self.wordListTableView.dataSource = self;
    self.wordListTableView.tableFooterView = [UIView new];
    ERTableTootView *view = [[[NSBundle mainBundle]loadNibNamed:@"ERTableTootView" owner:self options:nil] lastObject];
    [view.cleanAllButton addTarget:self action:@selector(deleteAll:) forControlEvents:UIControlEventTouchUpInside];
    self.wordListTableView.tableFooterView = view;
    if (_allFindsWordsA.count<1) {
        self.wordListTableView.tableFooterView.hidden = YES;
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)findButtonClick:(id)sender {
    if (_wordTF.text.length == 0) {
        [MBProgressHUD showError:@"还没有告诉我你要查找的单词哦~"];
        return;
    }
    [self.view endEditing:YES];
    NSString *word = [_wordTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *s = @"select * from allWordsTable where English = ?";
    
    NSArray *array = [ERDatabaseTool readDb:s para:word];
    if (array.count>0) {
        ERWord *word = array[0];
        _localTL.text = word.Chinese;
        _headerL.text = [NSString stringWithFormat:@"本地翻译（%@）:",word.time];
        _localTL.textColor = [UIColor colorFromHexCode:@"333333"];
    }
    [MBProgressHUD showMessage:@"小E正在努力中，请等两秒~"];
        NSString *urlS = [NSString stringWithFormat:@"http://fanyi.youdao.com/openapi.do?keyfrom=EnglishRobot&key=125224454&type=data&doctype=json&version=1.1&q=%@",word];
        urlS = [urlS stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlS]];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUD];
            });
            
            if (!error) {
                    NSError *JSONerror = nil;
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONerror];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setMyView:dic];
                });
                
            }else{
                [MBProgressHUD showError:@"网络错误，请稍后再试！"];
            }
        }];
        
        [task resume];

    
    
}
- (IBAction)addButtonClick:(id)sender {
   
    ERWord *word = [ERWord new];
    for (int i = 0; i < _wordTF.text.length; i ++) {
        NSString *s = [_wordTF.text substringWithRange:NSMakeRange(i, 1)];
        const char *utf8S = [s UTF8String];
        if (strlen(utf8S) == 3) {
            word.English = _firstW;
            word.Chinese = _wordLabel.text;
        }else if (strlen(utf8S) == 1){
            word.English = _wordLabel.text;
            word.Chinese = _labelS;
        }
    }
    
    word.statue = @"1";
    word.time = _dateS;
    word.isFind = @"yes";
    word.notes = _NLabel.text;
    word.timeE = [NSString stringWithFormat:@"%@-%@",_dateS,_wordLabel.text];
    [ERDatabaseTool insertOneData:word.time English:word.English EEnglish:@"" Chinese:word.Chinese EChinese:@"" notes:word.notes statue:word.statue timeE:word.timeE isFind:word.isFind];
    [MBProgressHUD showSuccess:@"加入成功~"];
}

- (IBAction)speechButtonClick:(id)sender {
    if (self.speechView.hidden == YES) {
        double vertion = [[UIDevice currentDevice].systemVersion doubleValue];
        __weak typeof(self) weakSelf = self;
        if (vertion < 10) {
            [MBProgressHUD showError:@"语音识别系统需要iOS10.0以上才支持！"];
        }else{
            self.speechView.hidden = NO;
            [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
                
                if (status == SFSpeechRecognizerAuthorizationStatusAuthorized) {
                    weakSelf.speechButton.enabled = YES;
                    if (!weakSelf.engine) {
                        weakSelf.engine = [[AVAudioEngine alloc] init];
                        
                    }
                }
            }];
        }

    }
    
}

- (IBAction)editChange:(id)sender {
    if (_wordListTableView.hidden == YES) {
        _wordListTableView.hidden = NO;
        [self updateFindTable];
        [_recordButton setTitle:@"隐藏" forState:UIControlStateNormal];
    }
    if (self.wordListTableView.tableFooterView.hidden == NO) {
        self.wordListTableView.tableFooterView.hidden = YES;
    }
    
    if (_wordsListA.count>0) {
        [_wordsListA removeAllObjects];
    }
    NSString *words = [_wordTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString *s = nil;
    for (ERWord *word in _findWordsArray) {
        if (_wordTF.text.length <= word.English.length) {
            s = [word.English substringToIndex:_wordTF.text.length];
        }else{
            s = word.English;
        }
        
        if ([s isEqualToString:words]) {
            [_wordsListA addObject:word];
            
        }
    }
    _allFindsWordsA = [_wordsListA copy];
    if (_wordTF.text.length == 0) {
        _allFindsWordsA = _findWordsArray;
        self.wordListTableView.tableFooterView.hidden = NO;
        
    }
    [self.wordListTableView reloadData];

}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}
-(void)setMyView:(NSDictionary *)dic{
    _wordLabel.text = dic[@"query"];
    [_ELabel setTitle:dic[@"basic"][@"phonetic"] forState:UIControlStateNormal];
    _labelS = @"";
    for (NSString *s in dic[@"basic"][@"explains"]) {
        
        _labelS = [_labelS stringByAppendingString:s];
        _labelS = [_labelS stringByAppendingString:@"\n"];
    }
    _firstW =[dic[@"basic"][@"explains"] firstObject];
    if (_labelS.length == 0) {
        _TLabel.text = @"在线翻译走丢了~";
        _TLabel.textColor = [UIColor colorFromHexCode:@"ffa200"];
    }else{
        _TLabel.text = _labelS;
    }
    
   NSString *mutableS = @"";
    for (NSDictionary *NDic in dic[@"web"]) {
        mutableS = [mutableS stringByAppendingString:NDic[@"key"]];
        mutableS = [mutableS stringByAppendingString:@"："];
        NSArray *array = (NSArray *)NDic[@"value"];
        for (int i = 0; i < array.count; i ++) {
            
            NSString *s = array[i];
            mutableS = [mutableS stringByAppendingString:s];
            if (i < array.count-1) {
                mutableS = [mutableS stringByAppendingString:@"，"];
            }
            
        }
        mutableS = [mutableS stringByAppendingString:@"\n"];
    }
    if (mutableS.length == 0) {
        _NLabel.text = @"在线拓展走丢了~";
        _NLabel.textColor = [UIColor colorFromHexCode:@"ffa200"];
    }else{
        _NLabel.text = _labelS;
    }
    
    //_wordTF.text = @"";
    NSLog(@"当前线程：%@",[NSThread currentThread]);
    _wordListTableView.hidden = YES;
    [_recordButton setTitle:@"查找记录" forState:UIControlStateNormal];
    self.recordButton.hidden = NO;
    if (_labelS.length>0) {
        [ERDatabaseTool insertToFindOneData:_dateS English:_wordLabel.text EEnglish:@"" Chinese:_labelS EChinese:@"" notes:mutableS statue:@"1" timeE:[NSString stringWithFormat:@"%@-%@",_dateS,_wordLabel.text] isFind:@"yes"];
    }
    
    
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _allFindsWordsA.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ERWord *word = _allFindsWordsA[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //cell.textLabel.textColor = [UIColor colorFromHexCode:@"02c7af"];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.textLabel.textColor = [UIColor colorFromHexCode:@"333333"];
        cell.detailTextLabel.textColor = [UIColor colorFromHexCode:@"a6a6a6"];
        cell.backgroundColor = [UIColor colorFromHexCode:@"f9f9f9"];
        cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    }
    cell.textLabel.text = word.English;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"  %@",word.Chinese];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ERWord *word = _allFindsWordsA[indexPath.row];
    [self performSegueWithIdentifier:@"findWordSegue" sender:word];
}
- (IBAction)recordButtonClick:(id)sender {
    _wordListTableView.hidden = !_wordListTableView.hidden;
    NSString *titleS = _wordListTableView.hidden ? @"查找记录" : @"隐藏";
    [_recordButton setTitle:titleS forState:UIControlStateNormal];
    if (_wordListTableView.hidden == NO) {
        [self updateFindTable];
        
    }
}
-(void)updateFindTable{
    NSString *s = @"select * from allFindWordsTable where isFind = ?";
    _findWordsArray = [ERDatabaseTool readFindDb:s para:@"yes"];
    _allFindsWordsA = _findWordsArray;
    if (_allFindsWordsA.count>0) {
        self.wordListTableView.tableFooterView.hidden = NO;
    }
    [self.wordListTableView reloadData];
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    ERWord *word = self.allFindsWordsA[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *a = [NSMutableArray arrayWithArray:_allFindsWordsA];
        [a removeObject:word];
        _allFindsWordsA = [a copy];
        if (_allFindsWordsA.count<1) {
            self.wordListTableView.tableFooterView.hidden = YES;
        }
        [self.wordListTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [ERDatabaseTool cleanFindDB:@"timeE" content:word.timeE];
    }
    //[self.wordListTableView reloadData];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 38;
}
-(void)deleteAll:(UIButton *)sender{
    self.wordListTableView.tableFooterView.hidden = YES;
    NSMutableArray *mutableA = [NSMutableArray arrayWithArray:_allFindsWordsA];
    [mutableA removeAllObjects];
    _allFindsWordsA = [mutableA copy];
    [ERDatabaseTool cleanFindDB:@"isFind" content:@"yes"];
    [self.wordListTableView reloadData];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    ERWord *word = (ERWord *)sender;
    if ([segue.destinationViewController isKindOfClass:[ERDetailViewController class]]) {
        ERDetailViewController *dVC = segue.destinationViewController;
        dVC.word = word;
        dVC.mark = 2;
    }
}
- (IBAction)readWordButtonClick:(id)sender {
    if (self.spe.speaking) {
        [self.spe stopSpeakingAtBoundary:AVSpeechBoundaryWord];
        return;
    }
    //设置读取的文本
    AVSpeechUtterance *utt = [AVSpeechUtterance speechUtteranceWithString:_wordLabel.text];
    //设置使用什么语言
    utt.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-GB"];
    
    [self.spe speakUtterance:utt];

}
-(void)dealloc{
    NSLog(@"");
}
- (IBAction)speech:(id)sender {
    [_speechButton setImage:[UIImage imageNamed:@"话筒_S"] forState:UIControlStateNormal];
    _speechButton.enabled = NO;
    CABasicAnimation *anim = [CABasicAnimation animation];
    anim.keyPath = @"transform.rotation";
    anim.toValue = @(M_PI * 2);
    
    anim.duration = 2;
    
    anim.repeatCount = MAXFLOAT;
    
    /*** 固定动画结束时 视图的位置 *****/
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    
    [self.speechButton.layer addAnimation:anim forKey:nil];
    __weak typeof(self) weakSelf = self;
    if (!_recongizer) {
        _recongizer = [[SFSpeechRecognizer alloc] init];
    }
    if (!_request) {
        _request = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
        _request.shouldReportPartialResults = true;
    }
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryRecord error:&error];
    if (error) {
        self.wordTF.text = error.description;
        self.speechView.hidden = YES;
        return;
    }
    [session setMode:AVAudioSessionModeMeasurement error:&error];
    if (error) {
        self.wordTF.text = error.description;
        self.speechView.hidden = YES;
        return;
    }
    [session setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    if (error) {
        self.wordTF.text = error.description;
        self.speechView.hidden = YES;
        return;
    }
    
    if (!_engine.inputNode) {
        self.wordTF.text = @"无输入节点";
        self.speechView.hidden = YES;
        return;
        
    }
    
    
    [_engine.inputNode installTapOnBus:0 bufferSize:1024 format:[_engine.inputNode outputFormatForBus:0] block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        if (buffer) {
            [_request appendAudioPCMBuffer:buffer];
            
        }
    }];
    if (_task != nil) {
        [_task cancel];
        _task = nil;
    }
    
      _task = [_recongizer recognitionTaskWithRequest:_request resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        if (result) {
            weakSelf.wordTF.text = result.bestTranscription.formattedString;
            [_engine pause];
//            [_task cancel];
//            _task = nil;
            weakSelf.speechView.hidden = YES;
            [weakSelf.speechButton setImage:[UIImage imageNamed:@"话筒"] forState:UIControlStateNormal];
            [self.speechButton.layer removeAllAnimations];
        }
        if (error) {
            self.wordTF.text = error.description;
//            [_engine pause];
//            [_task cancel];
//            _task = nil;
            [self.speechButton.layer removeAllAnimations];
            weakSelf.speechView.hidden = YES;
            [weakSelf.speechButton setImage:[UIImage imageNamed:@"话筒"] forState:UIControlStateNormal];
        }
    }];
    
    [_engine prepare];
    [_engine startAndReturnError:&error];
}


@end
