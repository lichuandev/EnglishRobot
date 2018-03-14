//
//  ERListenSelectViewController.m
//  ERobot
//
//  Created by Mac on 17/2/22.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "ERListenSelectViewController.h"
#import "UIColor+FlatUI.h"
#import "ERDatabaseTool.h"
#import "ERListenViewController.h"
#import "ERDateMagementTool.h"
#import "ERWordsListViewController.h"
@interface ERListenSelectViewController ()

@property (weak, nonatomic) IBOutlet UIView *emptyView;
- (IBAction)seqButtonClcik:(UIButton *)sender;
- (IBAction)noSeq:(UIButton *)sender;
- (IBAction)C2E:(UIButton *)sender;
- (IBAction)E2C:(UIButton *)sender;
- (IBAction)sureButtonClick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *seq;
@property (weak, nonatomic) IBOutlet UIButton *noSeqButton;
@property (weak, nonatomic) IBOutlet UIButton *E2CButton;
@property (weak, nonatomic) IBOutlet UIButton *C2EButton;
@property (nonatomic, assign) int order;
@property (nonatomic, assign) int language;
@property (weak, nonatomic) IBOutlet UIButton *studyButton;
@property (nonatomic, strong) NSArray *wordsArray;
- (IBAction)studyButtonClick:(id)sender;
@end

@implementation ERListenSelectViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (self.tabBarController.tabBar.hidden == NO) {
        self.tabBarController.tabBar.hidden = YES;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //__weak typeof(self)weakSelf = self;
    _order = 1;
    _language = 1;
    NSString *s = @"select * from allWordsTable where time = ?";
    _wordsArray = [ERDatabaseTool readDb:s para:_dateS];
     [self setMyVC];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setMyVC{
    
    if (_wordsArray.count == 0) {
        _emptyView.hidden = NO;
    }
    NSString *dateString = [ERDateMagementTool getDateString:[NSDate date]];
    if (![dateString isEqualToString:_dateS]) {
        [_studyButton setTitle:@"单词本" forState:UIControlStateNormal];
        if (_wordsArray.count == 0) {
            _studyButton.hidden = YES;
        }
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
// order 等于 1 代表顺序   等于2 代表乱序  language 等于1代表 汉译英  等于2 代表英译汉
- (IBAction)seqButtonClcik:(UIButton *)sender {
    _order = 1;
    [sender setBackgroundColor:[UIColor colorFromHexCode:@"02c7af"]];
    [sender setTintColor:[UIColor whiteColor]];
    [_noSeqButton setBackgroundColor:[UIColor clearColor]];
    [_noSeqButton setTintColor:[UIColor colorFromHexCode:@"333333"]];
}

- (IBAction)noSeq:(UIButton *)sender {
    _order = 2;
    [sender setBackgroundColor:[UIColor colorFromHexCode:@"02c7af"]];
    [sender setTintColor:[UIColor whiteColor]];
    [_seq setBackgroundColor:[UIColor clearColor]];
    [_seq setTintColor:[UIColor colorFromHexCode:@"333333"]];
}

- (IBAction)C2E:(UIButton *)sender {
    _language = 1;
    [sender setBackgroundColor:[UIColor colorFromHexCode:@"02c7af"]];
    [sender setTintColor:[UIColor whiteColor]];
    [_E2CButton setBackgroundColor:[UIColor clearColor]];
    [_E2CButton setTintColor:[UIColor colorFromHexCode:@"333333"]];

}

- (IBAction)E2C:(UIButton *)sender {
    _language = 2;
    [sender setBackgroundColor:[UIColor colorFromHexCode:@"02c7af"]];
    [sender setTintColor:[UIColor whiteColor]];
    [_C2EButton setBackgroundColor:[UIColor clearColor]];
    [_C2EButton setTintColor:[UIColor colorFromHexCode:@"333333"]];

}

- (IBAction)sureButtonClick:(UIButton *)sender {
    NSLog(@"order=%d,language=%d",_order,_language);
    [self performSegueWithIdentifier:@"listenSegue" sender:nil];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.destinationViewController isKindOfClass:[ERListenViewController class]]) {
        ERListenViewController *lVC = segue.destinationViewController;
        lVC.wordsArray = _wordsArray;
        lVC.title = _dateS;
        lVC.order = _order;
        lVC.language = _language;
    }
    if ([segue.destinationViewController isKindOfClass:[ERWordsListViewController class]]) {
        ERWordsListViewController *listVC = segue.destinationViewController;
        listVC.titleS = _dateS;
        listVC.mark = 1;
    }
}
- (IBAction)studyButtonClick:(id)sender {
    if (_mark == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self performSegueWithIdentifier:@"todyWordSegue" sender:nil];
    }
    
}
-(void)dealloc{
    NSLog(@"");
}
@end
