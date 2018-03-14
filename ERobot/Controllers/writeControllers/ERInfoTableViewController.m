//
//  ERInfoTableViewController.m
//  ERobot
//
//  Created by Mac on 17/3/20.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "ERInfoTableViewController.h"
#import "EREditViewController.h"
@interface ERInfoTableViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UITableViewCell *nameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *sexCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *ageCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *birthdayCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *headerCell;

@end

@implementation ERInfoTableViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (self.tabBarController.tabBar.hidden == NO) {
        self.tabBarController.tabBar.hidden = YES;
    }
    NSString *imageBase64S = [[NSUserDefaults standardUserDefaults] objectForKey:@"headerImage"];
    if (imageBase64S) {
        NSData *imageData = [[NSData alloc]initWithBase64EncodedString:imageBase64S options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *image = [UIImage imageWithData:imageData];
        _headerImageView.image = image;
    };
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    if (name) {
        _nameCell.detailTextLabel.text = name;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 1:
            if (indexPath.row == 0) {
                
                return _nameCell;
            }else if (indexPath.row == 1){
                NSString *sex = [[NSUserDefaults standardUserDefaults] objectForKey:@"sex"];
                if (sex) {
                    _sexCell.detailTextLabel.text = sex;
                }else{
                    _sexCell.detailTextLabel.text = @"男";
                }
                return _sexCell;
            }else if (indexPath.row == 2){
                NSInteger age = [[NSUserDefaults standardUserDefaults] integerForKey:@"age"];
                if (age && age >= 5) {
                    age = age / 5;
                    _ageCell.detailTextLabel.text = [NSString stringWithFormat:@"%ld岁",(long)age];
                }else{
                    _ageCell.detailTextLabel.text = @"1岁";
                }
                return  _ageCell;

            }else{
                _birthdayCell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"birthday"];
                return _birthdayCell;
            }
            
            
        default:
            return _headerCell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 1:
            if (indexPath.row == 1) {
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"请选择性别" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                UIAlertAction *cancelA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *boyA = [UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[NSUserDefaults standardUserDefaults] setObject:@"男" forKey:@"sex"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    _sexCell.detailTextLabel.text = @"男";
                }];
                UIAlertAction *girlA = [UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[NSUserDefaults standardUserDefaults] setObject:@"女" forKey:@"sex"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    _sexCell.detailTextLabel.text = @"女";
                }];
                [alertC addAction:cancelA];
                [alertC addAction:boyA];
                [alertC addAction:girlA];
                [self presentViewController:alertC animated:YES completion:nil];
            }else if (indexPath.row == 0){
               [self performSegueWithIdentifier:@"editSegue" sender:@"0"];
            }
            
            break;
        default:
            [self performSegueWithIdentifier:@"editSegue" sender:@"1"];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.destinationViewController isKindOfClass:[EREditViewController class]]) {
        EREditViewController *editVC = segue.destinationViewController;
        if ([sender isEqualToString:@"1"]) {
            editVC.title = @"头像";
            editVC.mark = 0;
        }else{
            editVC.mark = 1;
            editVC.title = @"昵称";
            editVC.name = _nameCell.detailTextLabel.text;
        }
    }
}


-(void)dealloc{
    NSLog(@"");
}

@end
