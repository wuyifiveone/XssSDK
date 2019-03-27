//
//  XsProxySDK.m
//  XsProxySDK
//
//  Created by 吴怿 on 2019/3/12.
//  Copyright © 2019 吴怿. All rights reserved.
//

#import "XsProxySDK.h"
#import "ClassFiles/XsAppInfo.h"
#import "ClassFiles/XsRoot.h"
@implementation XsProxySDK
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static XsProxySDK *instance;
    dispatch_once(&onceToken, ^{
        instance = [[XsProxySDK alloc] init];
    });
    return instance;
}


- (NSString *)gameCallNative:(NSString *)tag andData:(NSString *)data{
    
    NSString *XSTAG_APPINFO = @"getAppInfo";// 获取app信息
    NSString *XSTAG_GETNOTCHHEIGHT = @"getNotchHeight"; //获取刘海高度
    NSString *XSTAG_ISSDKINITED = @"isSdkInited";//是否初始化
    NSString *XSTAG_GETPHOTO = @"getPhoto";//拍照
    if ([XSTAG_APPINFO isEqualToString:tag]) {
        //获取appinfo 内容没配置
        return [[XsAppInfo sharedInstance] getAppInfo];
    }
    else if([XSTAG_GETNOTCHHEIGHT isEqualToString:tag]){
        //获取刘海屏幕数据 是不是刘海屏需要在游戏中写判断
        return [[XsAppInfo sharedInstance] getNotchHeight];
    }else if ([XSTAG_ISSDKINITED isEqualToString:tag]){
        //获取sdk是否初始化
        return [[XsAppInfo sharedInstance] IsSDKInited];
    }else if ([XSTAG_GETPHOTO isEqualToString:tag]){
        //调用拍照
        [[XsRoot sharedInstance] getPhoto:data];
    }
    else {
        NSLog(@"Unsupport tag : %@", tag);
    }
    return @"";
}
@end
