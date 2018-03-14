//
//  ERReportCartViewController.m
//  ERobot
//
//  Created by Mac on 17/3/24.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "ERReportCartViewController.h"
#import "ERResult.h"
#import "MBProgressHUD+KR.h"
#import "UIColor+FlatUI.h"
#import <UShareUI/UShareUI.h>

@interface ERReportCartViewController ()
@property (weak, nonatomic) IBOutlet UILabel *totalDaysLabel;
@property (weak, nonatomic) IBOutlet UILabel *studyDays;
@property (weak, nonatomic) IBOutlet UILabel *totalWordsLabel;
@property (weak, nonatomic) IBOutlet UILabel *listenWordsLabel;
@property (weak, nonatomic) IBOutlet UILabel *hardworkingLabel;
@property (weak, nonatomic) IBOutlet UILabel *studingLabel;
@property (weak, nonatomic) IBOutlet UILabel *correctLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodDays;
@property (weak, nonatomic) IBOutlet UILabel *correctlabel;

@end

@implementation ERReportCartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setMyVC];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.tabBarController.tabBar.hidden == NO) {
        self.tabBarController.tabBar.hidden = YES;
    }
}
-(void)setMyVC{
    NSString *birth = [[NSUserDefaults standardUserDefaults]objectForKey:@"birthday"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSDate *birthDate = [dateFormatter dateFromString:birth];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:birthDate];
    double days = timeInterval/86400;
    NSLog(@"days:%lf",days);
    NSData *resultData = [[NSUserDefaults standardUserDefaults] objectForKey:@"result"];
    if (resultData) {
        ERResult *result = [NSKeyedUnarchiver unarchiveObjectWithData:resultData];
        _totalDaysLabel.text = [NSString stringWithFormat:@"%.0lf天",days];
        if (result.studyDays) {
            _studyDays.text = [NSString stringWithFormat:@"%d天",result.studyDays];
        }
        if (result.totalWords) {
            _totalWordsLabel.text = [NSString stringWithFormat:@"%d个",result.totalWords];
        }
        if (result.listenWords) {
            _listenWordsLabel.text = [NSString stringWithFormat:@"%d个",result.listenWords];
        }
        if (result.correctWords) {
            _correctlabel.text = [NSString stringWithFormat:@"%d个",result.correctWords];
        }
        CGFloat hardWorking = result.studyDays*0.1/days*1000;
        _hardworkingLabel.text = [NSString stringWithFormat:@"%.0f%%",hardWorking];
        [self setColor:hardWorking label:_hardworkingLabel];
         NSInteger age = [[NSUserDefaults standardUserDefaults] integerForKey:@"age"];
        _goodDays.text = [NSString stringWithFormat:@"%ld天",(long)age];
        CGFloat studing = age*0.1/result.studyDays*1000;
        _studingLabel.text = [NSString stringWithFormat:@"%.0f%%",studing];
        [self setColor:studing label:_studingLabel];
        CGFloat correct = result.correctWords*0.1/result.listenWords*1000;
        _correctLabel.text = [NSString stringWithFormat:@"%.0f%%",correct];
        [self setColor:correct label:_correctLabel];
        
    }else{
        [MBProgressHUD showError:@"小主还未开始学习哦~"];
    }
    
    
}
-(void)setColor:(NSInteger)value label:(UILabel *)label{
    switch (value) {
        case 70 ... 100:
            label.textColor = [UIColor colorFromHexCode:@"02c7af"];
            break;
        case 40 ... 69:
            label.textColor = [UIColor colorFromHexCode:@"ffa200"];
            break;
        case 0 ... 39:
            label.textColor = [UIColor redColor];
            break;
        default:
            break;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)shareButtonClick:(id)sender {
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
    
    //创建图片内容对象
    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
    //如果有缩略图，则设置缩略图
    //shareObject.thumbImage = [UIImage imageNamed:@"icon"];
    [shareObject setShareImage:image];
    
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
