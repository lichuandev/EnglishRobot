//
//  EREditViewController.m
//  ERobot
//
//  Created by Mac on 17/3/21.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "EREditViewController.h"
#import "MBProgressHUD+KR.h"
#import "UIColor+FlatUI.h"
@interface EREditViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
- (IBAction)editButtonClick:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *nickNameView;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (nonatomic, strong) UIImage *bigImage;
@property (nonatomic, strong) UIImage *smallImage;
@end

@implementation EREditViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (self.tabBarController.tabBar.hidden == NO) {
        self.tabBarController.tabBar.hidden = YES;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_mark == 0) {
        _headerImageView.hidden = NO;
        _headerImageView.userInteractionEnabled = YES;
        self.view.backgroundColor = [UIColor blackColor];
        [_editButton setTitle:@"设置"];
        NSString *imageBase64S = [[NSUserDefaults standardUserDefaults] objectForKey:@"bigHeaderImage"];
        if (imageBase64S) {
            NSData *imageData = [[NSData alloc]initWithBase64EncodedString:imageBase64S options:NSDataBase64DecodingIgnoreUnknownCharacters];
            UIImage *image = [UIImage imageWithData:imageData];
            _headerImageView.image = image;
        };
        
        UIPinchGestureRecognizer *pin = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pin:)];
        
        
        [self.headerImageView addGestureRecognizer:pin];
    }else{
        _nickNameView.hidden = NO;
        [_editButton setTitle:@"保存"];
        _nameTF.text = _name;
    }
    
}


-(void)pin:(UIPinchGestureRecognizer *)sender{
    CGFloat scale = sender.scale;
    _headerImageView.transform = CGAffineTransformScale(_headerImageView.transform, scale, scale);
    sender.scale = 1;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)editButtonClick:(id)sender {
    if (_mark == 1){
        [[NSUserDefaults standardUserDefaults] setObject:_nameTF.text forKey:@"name"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self.navigationController popViewControllerAnimated:YES];
    }else if (_mark == 0){
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"设置头像" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelA = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *boyA = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self gotoImagePickerController:UIImagePickerControllerSourceTypeCamera];
            
        }];
        UIAlertAction *girlA = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self gotoImagePickerController:UIImagePickerControllerSourceTypePhotoLibrary];
        }];
        [alertC addAction:cancelA];
        [alertC addAction:boyA];
        [alertC addAction:girlA];
        [self presentViewController:alertC animated:YES completion:nil];
    }else{
        _smallImage = [self cutDownImage:_bigImage withSize:CGSizeMake(160, 160)];
        NSData *bigImageData = UIImageJPEGRepresentation(_bigImage, 1);
        NSString * bigImageS = [bigImageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        NSData *smallImageData = UIImageJPEGRepresentation(_smallImage, 1);
        NSString * smallImageS = [smallImageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        [[NSUserDefaults standardUserDefaults] setObject:bigImageS forKey:@"bigHeaderImage"];
        [[NSUserDefaults standardUserDefaults] setObject:smallImageS forKey:@"headerImage"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)gotoImagePickerController:(UIImagePickerControllerSourceType)sourceType{
    [_editButton setTitle:@"保存"];
    _mark = 2;
    [_editButton setTintColor:[UIColor colorFromHexCode:@"02c7af"]];
    UIImagePickerController *imagePic = [[UIImagePickerController alloc] init];
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            imagePic.sourceType = sourceType;
        }else{
            [MBProgressHUD showError:@"小主，您的手机不支持拍照功能呢~"];
        }
    }else{
       imagePic.sourceType = sourceType;
    }
    
    imagePic.delegate = self;
    imagePic.allowsEditing = YES;
    
    [self presentViewController:imagePic animated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    _bigImage = info[UIImagePickerControllerEditedImage];
    _headerImageView.image = _bigImage;
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(UIImage *)cutDownImage:(UIImage *)image withSize:(CGSize)size{
    UIImage *newImage = nil;
    if (image) {
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newImage;
    
    
}
-(void)dealloc{
    NSLog(@"");
}
@end
