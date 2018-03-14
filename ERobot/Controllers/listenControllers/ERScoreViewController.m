//
//  ERScoreViewController.m
//  ERobot
//
//  Created by Mac on 17/2/28.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "ERScoreViewController.h"
#import "ERWordsListViewController.h"
#import "ERResult.h"
#import "ERSelectDayViewController.h"
#import <UShareUI/UShareUI.h>
@interface ERScoreViewController ()
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
- (IBAction)lookAnwserButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *lookAnswerButton;
- (IBAction)letSomebodyKnow:(id)sender;

- (IBAction)backButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@end

@implementation ERScoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateData];
    if (_rightAcount == _totalAcount) {
        _lookAnswerButton.enabled = NO;
    }
    self.rightLabel.text = [NSString stringWithFormat:@"%d道题",_rightAcount];
    self.errorLabel.text = [NSString stringWithFormat:@"%d道题",_totalAcount-_rightAcount];
    self.scoreLabel.text = [NSString stringWithFormat:@"%.0f分",_rightAcount*0.1/_totalAcount*1000];
}
-(void)updateData{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"result"];
    
    if (data) {
        ERResult *result = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSLog(@"听写单词：%d,正确单词：%d",result.listenWords,result.correctWords);
        result.listenWords = result.listenWords + _totalAcount;
        result.correctWords = result.correctWords + _rightAcount;
         NSData *resultData = [NSKeyedArchiver archivedDataWithRootObject:result];
        [[NSUserDefaults standardUserDefaults] setObject:resultData forKey:@"result"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        ERResult *result = [[ERResult alloc]init];
        result.studyDays = 0;
        result.totalWords = 0;
        result.listenWords = _totalAcount;
        result.correctWords = _rightAcount;
        NSData *resultData = [NSKeyedArchiver archivedDataWithRootObject:result];
        [[NSUserDefaults standardUserDefaults] setObject:resultData forKey:@"result"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)navigationShouldPopOnBackButton{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)lookAnwserButtonClick:(id)sender {
    [self performSegueWithIdentifier:@"wrongWordListSegue" sender:nil];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.destinationViewController isKindOfClass:[ERWordsListViewController class]]) {
        ERWordsListViewController *WLVC = segue.destinationViewController;
        WLVC.titleS = _dateS;
        WLVC.mark = 2;
    }
}

- (IBAction)letSomebodyKnow:(id)sender {
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        // 根据获取的platformType确定所选平台进行下一步操作
        [self shareImageToPlatformType:platformType];
    }];
}
// 分享图片
- (void)shareImageToPlatformType:(UMSocialPlatformType)platformType
{
    UIImage *image = [self getImage];
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    NSString *descr = [NSString stringWithFormat:@"我在 J单词 得分：%@，你也快来试试吧~",self.scoreLabel.text];
    NSLog(@"%@",descr);
    //NSString* thumbURL =  @"https://mobile.umeng.com/images/pic/home/social/img-1.png";
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:@"J单词" descr:descr thumImage:image];
    //设置网页地址
    shareObject.webpageUrl = @"http://mobile.umeng.com/social";
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            NSLog(@"************Share fail with error %@*********",error);
        }else{
            NSLog(@"response data is %@",data);
        }
    }];
}
-(UIImage *)getImage{
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, [[UIScreen mainScreen] scale]);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return image;
}
- (IBAction)backButtonClick:(id)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
