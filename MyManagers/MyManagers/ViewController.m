//
//  ViewController.m
//  MyManagers
//
//  Created by pengbingxiang on 2018/1/19.
//  Copyright © 2018年 yiweixing. All rights reserved.
//

#import "ViewController.h"
#import "WSystemPhotoManager.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIImageView *_photoImageView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUI];
    
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)createUI {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(80, 80, 100, 50);
    [button setTitle:@"选择" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor blackColor];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIImageView *photoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(80, 140, 200, 300)];
    [self.view addSubview:photoImageView];
    _photoImageView = photoImageView;
}
- (void)buttonClick:(UIButton*)sender {
    UIAlertController *al = [UIAlertController alertControllerWithTitle:nil message:@"选择相机相册" preferredStyle:(UIAlertControllerStyleActionSheet)];
    [al addAction:[UIAlertAction actionWithTitle:@"相机" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self photoWithSourceType:Camera];
    }]];
    [al addAction:[UIAlertAction actionWithTitle:@"相册" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self photoWithSourceType:PhotoLibrary];
    }]];
    [al addAction:[UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:al animated:YES completion:nil];
}
#pragma mark - 拍照或相册
- (void)photoWithSourceType:(SourceType)sourceType {
    
    [[WSystemPhotoManager shareManager] systemPhotoWithSourceType:sourceType AuthorizationStatus:^(AVCode code) {
        if (code == code_200) {
            NSLog(@"用户允许 --- ");
            if (sourceType == Camera) {
                [self openPhotoWithSourceType:UIImagePickerControllerSourceTypeCamera];
            } else {
                [self openPhotoWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            }
            
        } else if (code == code_300) {
            NSString *msgStr = (sourceType == Camera) ? [NSString stringWithFormat:@"请在手机“设置-隐私-相机”选项中，允许APP访问您的相机"] : [NSString stringWithFormat:@"请在手机“设置-隐私-照片”选项中，允许APP访问您的相册"];
            [self alertViewControllerWithTitle:@"温馨提示" message:msgStr defaultTitle:@"设置" handler:^(UIAlertAction * _Nullable action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-Prefs:root"]];
            } cancelTitle:@"拒绝" handler:nil];
        } else if (code == code_500) {
            [self alertViewControllerWithTitle:@"温馨提示" message:@"未检测到您的摄像头" defaultTitle:@"确定" handler:nil cancelTitle:nil handler:nil];
        }
    }];
}
#pragma mark - 打开摄像头
- (void)openPhotoWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        // 判断摄像头是否可用
        BOOL isCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
        if (!isCamera) {
            [self alertViewControllerWithTitle:@"温馨提示" message:@"前置摄像头不可用" defaultTitle:@"确定" handler:nil cancelTitle:nil handler:nil];
            return;
        }
    }
    // 初始化图片选择器
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = sourceType;
    // 相机类型
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    imagePicker.allowsEditing = NO;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - 得到图片或者视频后, 调用该代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // 照相界面消失
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    _photoImageView.image = image;
}
#pragma mark - 自定义alertViewController
- (void)alertViewControllerWithTitle:(NSString*)titleStr message:(NSString*)messageStr defaultTitle:(NSString*)defaultTitleStr handler:(void (^ __nullable)(UIAlertAction *action))defaultAction cancelTitle:(NSString*)cancleTitleStr handler:(void (^ __nullable)(UIAlertAction *action))cancelAction {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:titleStr message:messageStr preferredStyle:UIAlertControllerStyleAlert];
    if (defaultTitleStr) {
        [alertVc addAction:[UIAlertAction actionWithTitle:defaultTitleStr style:UIAlertActionStyleDefault handler:defaultAction]];
    }
    if (cancleTitleStr) {
        [alertVc addAction:[UIAlertAction actionWithTitle:cancleTitleStr style:UIAlertActionStyleCancel handler:cancelAction]];
    }
    [self presentViewController:alertVc animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
