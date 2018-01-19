//
//  WSystemPhotoManager.h
//  install-app-IOS
//
//  Created by pengbingxiang on 2017/8/17.
//  Copyright © 2017年 YWX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

// 返回的code嘛
typedef NS_ENUM(NSInteger, AVCode) {
    code_200,  // 能正常调用系统相机
    code_300,  // 用户没授权调用系统相机（之前不允许/还没授权）
    code_400,  // 用户不允许调用系统相机（在弹框授权时拒绝）
    code_500   // 相机设备不支持
};

// 资源类型
typedef NS_ENUM(NSInteger, SourceType) {
    Camera,
    PhotoLibrary
};

typedef void(^MediaAuthorizationStatusResult)(AVCode code);

typedef void(^TorchModeStatus)(BOOL status);

@interface WSystemPhotoManager : NSObject

+ (instancetype)shareManager;

/*!
 * 判断摄像头是否授权可用
 * @param  sourceType   资源类型
 * @param  result       结果回调
 */
- (void)systemPhotoWithSourceType:(SourceType)sourceType AuthorizationStatus:(MediaAuthorizationStatusResult)result;

/*!
 * 手电筒的开关
 * @param  model   是否打开手电筒
 * @param  status  手电筒是否能正常使用
 */
- (void)systemPhotoTorch:(BOOL)model TorchModeStatus:(TorchModeStatus)status;

@end
