//
//  WSystemPhotoManager.m
//  install-app-IOS
//
//  Created by pengbingxiang on 2017/8/17.
//  Copyright © 2017年 YWX. All rights reserved.
//

#import "WSystemPhotoManager.h"

@interface WSystemPhotoManager ()

@end

static WSystemPhotoManager *_manager;

@implementation WSystemPhotoManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[WSystemPhotoManager alloc]init];
    });
    return _manager;
}

- (void)systemPhotoWithSourceType:(SourceType)sourceType AuthorizationStatus:(MediaAuthorizationStatusResult)result {
    if (sourceType == Camera) {
        [self camera:result];
    } else {
        [self photoLibrary:result];
    }
}
- (void)camera:(MediaAuthorizationStatusResult)result {
    // 获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        // 判断用户是否授权APP打开摄像机
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        /*
         typedef NS_ENUM(NSInteger, ALAuthorizationStatus) {
         AVAuthorizationStatusNotDetermined = 0, 用户尚未做出了选择这个应用程序的问候
         AVAuthorizationStatusRestricted,        此应用程序没有被授权访问的照片数据。可能是家长控制权限。
         
         AVAuthorizationStatusDenied,            用户已经明确否认了这一照片数据的应用程序访问.
         AVAuthorizationStatusAuthorized         用户已授权应用访问照片数据.
         }
         */
        if(authStatus == AVAuthorizationStatusDenied){
            NSLog(@"用户没授权");
            if (result) {
                result(code_300);
            }
        } else if (authStatus == AVAuthorizationStatusRestricted) {
            NSLog(@"用户没授权");
            if (result) {
                result(code_300);
            }
        }else if (authStatus == AVAuthorizationStatusNotDetermined) {
            NSLog(@"Not Determined -- ");
            // 第一次授权
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        // 做逻辑处理需要在主线程
                        NSLog(@"用户同意 --- ");
                        if (result) {
                            result(code_200);
                        }
                    });
                } else {
                    NSLog(@"用户拒绝 --- ");
                    if (result) {
                        result(code_400);
                    }
                }
            }];
        } else {
            // 调起相机
            NSLog(@"调起相机 -- ");
            if (result) {
                result(code_200);
            }
        }
        
    } else {
        NSLog(@"设备不支持");
        if (result) {
            result(code_500);
        }
    }
}
- (void)photoLibrary:(MediaAuthorizationStatusResult)result {
    // 判断用户是否授权APP打开相册
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    /*
     typedef NS_ENUM(NSInteger, ALAuthorizationStatus) {
     PHAuthorizationStatusNotDetermined = 0, 用户尚未做出了选择这个应用程序的问候
     PHAuthorizationStatusRestricted,        此应用程序没有被授权访问的照片数据。可能是家长控制权限。
     
     PHAuthorizationStatusDenied,            用户已经明确否认了这一照片数据的应用程序访问.
     PHAuthorizationStatusAuthorized         用户已授权应用访问照片数据.
     }
     */
    if(authStatus == PHAuthorizationStatusDenied){
        NSLog(@"用户没授权");
        if (result) {
            result(code_300);
        }
    } else if (authStatus == PHAuthorizationStatusRestricted) {
        NSLog(@"用户没授权");
        if (result) {
            result(code_300);
        }
    }else if (authStatus == PHAuthorizationStatusNotDetermined) {
        NSLog(@"Not Determined -- ");
        // 第一次授权
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                // 允许
                dispatch_sync(dispatch_get_main_queue(), ^{
                    // 做逻辑处理需要在主线程
                    NSLog(@"用户同意 --- ");
                    if (result) {
                        result(code_200);
                    }
                });
            } else {
                // 不允许
                NSLog(@"用户拒绝 --- ");
                if (result) {
                    result(code_400);
                }
            }
        }];
    } else {
        // 调起相机
        NSLog(@"调起相册 -- ");
        if (result) {
            result(code_200);
        }
    }
}
- (void)systemPhotoTorch:(BOOL)model TorchModeStatus:(TorchModeStatus)status {
    /*
     * 如果你要获取的类不存在，则会返回一个nil对象，程序不会崩溃，适用于进行你不确定类的初始化。
     * NSClassFromString的好处是：
     * 1.弱化链接，不会把没有的框架也链接到程序中。
     * 2.不需要使用import,因为类是动态加载的，只要存在就可以加载。因此如果你的类中没有某个头文件定义，而你确信这个类是可以用的，那么可以用这个方法
     */
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        // 判断是否有闪光灯
        if ([device hasTorch]) {
            // 请求独占访问硬件设备
            [device lockForConfiguration:nil];
            if (model) {
                [device setTorchMode:AVCaptureTorchModeOn];
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
            }
            if (status) {
                status(YES);
            }
            // 请求解除独占访问硬件设备
            [device unlockForConfiguration];
        } else {
            NSLog(@"没有闪光设备 --- ");
            if (status) {
                status(NO);
            }
        }
    } else {
        NSLog(@"没有闪光设备 --- ");
        if (status) {
            status(NO);
        }
    }
}

@end
