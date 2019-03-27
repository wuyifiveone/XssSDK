//
//  XsAppInfo.m
//  XsProxySDK
//
//  Created by 吴怿 on 2019/3/12.
//  Copyright © 2019 吴怿. All rights reserved.
//

#import "XsAppInfo.h"
#import <UICKeyChainStore/UICKeyChainStore.h>
#import <sys/utsname.h>
#import <UIKit/UIKit.h>
@interface XsAppInfo() {
    
}

//@property (nonatomic, copy) NSString *safeTop;
//@property (nonatomic, copy) NSString *safeBottom;
//@property (nonatomic, copy) NSString *safeLeft;
@property (nonatomic, copy) NSString *safeRight;
@property (nonatomic, assign) bool isSDKInited;

@end
@implementation XsAppInfo

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static XsAppInfo *instance;
    dispatch_once(&onceToken, ^{
        instance = [[XsAppInfo alloc] init];
        instance.safeRight = @"0";
    });
    return instance;
}
#pragma mark - 读取plist文件
-(id)getValueInPlist:(NSString *)key {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:bundlePath];
    id value = dict[key];
    return value;
}

# pragma mark - 获取应用信息
- (NSString *)getAppInfo {
    
    NSString *version = (NSString *) [self getValueInPlist:@"CFBundleShortVersionString"];
    NSLog(@"version-----%@", version);
    
    NSMutableDictionary *AppinfoDic = [[NSMutableDictionary alloc]init];
    
    //配置信息
    [AppinfoDic setObject:[self getValueInPlist:@"channelId"] forKey:@"channelId"];//账号渠道号 需要提供
    [AppinfoDic setObject:[self getValueInPlist:@"regId"] forKey:@"regId"];//注册渠道号 需要提供
    [AppinfoDic setObject:[self getValueInPlist:@"payId"] forKey:@"payId"];//支付渠道号 需要提供
    [AppinfoDic setObject:version forKey:@"versionName"];//应用版本名
    [AppinfoDic setObject:version forKey:@"versionCode"];//应用版本号
    [AppinfoDic setObject:[self UUID] forKey:@"imei"];//设备唯一标识码
    [AppinfoDic setObject:[self getDevice] forKey:@"mobileMode"];//手机设备型号
    [AppinfoDic setObject:[self getVersion] forKey:@"sdkVersion"];//手机系统版本号
    [AppinfoDic setObject:[self getValueInPlist:@"CFBundleIdentifier"] forKey:@"packageName"];//应用包名
    
    NSLog(@"appinfo == %@", AppinfoDic);
    return [self JSONObjToStr:AppinfoDic];
    
}
# pragma mark - 判断刘海屏幕朝向
- (NSString *)getNotchHeight{
    NSMutableDictionary *NotchHeightDic = [NSMutableDictionary dictionary];
    [NotchHeightDic setObject:[self ScreenDirectionDegree] forKey:@"rotation"];
    [NotchHeightDic setObject:[XsAppInfo sharedInstance].safeRight forKey:@"notchHeight"];
    [NotchHeightDic setObject:[self ScreenDirection] forKey:@"orientation"];
    
    return [self JSONObjToStr:NotchHeightDic];
    
}
- (NSString *)ScreenDirection{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft){
        NSString *XSleft = @"left";
        return XSleft;
    }else {
        NSString *XSRigh = @"Righ";
        return XSRigh;
    }
}

- (NSString *)ScreenDirectionDegree{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft){
        NSString *XSleft = @"90";
        return XSleft;
    }else {
        NSString *XSRigh = @"270";
        return XSRigh;
    }
}


#pragma mark - 获取uuid
- (NSString *)UUID{
    NSString *uuidKey = @"NH983C9DVV.com.wsntcphd.uuid"; //NH983C9DV项目号-com.wsntcphd-uuid
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:uuidKey];
    NSString *uuid = [keychain objectForKeyedSubscript:@"uuid"];
    NSLog(@"[UUID] keychain中的 uuid = %@",uuid);
    NSLog(@"[UUID] keychain是否存在 keychain = %@",keychain);
    if ([self isEmptyStr:uuid]) {
        NSLog(@"[UUID] 获取一次新的uuid");
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        uuid = (NSString *) CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidRef));
        uuid = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSLog(@"[UUID] 未保存的新的 uuid = %@",uuid);
        keychain[@"uuid"] = uuid;
    }
    return uuid;
}
- (NSString *)JSONObjToStr:(NSDictionary *)dict {
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dict options:0 error:nil] encoding:NSUTF8StringEncoding];
}

- (NSString *)getDevice {
    //    return [[UIDevice currentDevice] model];
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone1,1"])     return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])     return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])     return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])     return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])     return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])     return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])     return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])     return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])     return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone5,4"])     return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone6,1"])     return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone6,2"])     return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone7,1"])     return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])     return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])     return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])     return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])     return @"iPhone SE";
    if ([deviceString isEqualToString:@"iPhone9,2"])     return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone9,4"])     return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone9,1"])     return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,3"])     return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone10,1"])    return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,4"])    return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,2"])    return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,5"])    return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,3"])    return @"iPhone X";
    if ([deviceString isEqualToString:@"iPhone10,6"])    return @"iPhone X";
    if ([deviceString isEqualToString:@"iPhone11,8"])    return @"iPhone XR";
    if ([deviceString isEqualToString:@"iPhone11,2"])    return @"iPhone XS";
    if ([deviceString isEqualToString:@"iPhone11,6"])    return @"iPhone XS Max";
    if ([deviceString isEqualToString:@"iPhone11,4"])    return @"iPhone XS Max";
    
    if ([deviceString isEqualToString:@"iPad1,1"])       return @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"])       return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,2"])       return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,3"])       return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad3,1"])       return @"iPad (3rd generation)";
    if ([deviceString isEqualToString:@"iPad3,2"])       return @"iPad (3rd generation)";
    if ([deviceString isEqualToString:@"iPad3,3"])       return @"iPad (3rd generation)";
    if ([deviceString isEqualToString:@"iPad3,4"])       return @"iPad (4th generation)";
    if ([deviceString isEqualToString:@"iPad3,5"])       return @"iPad (4th generation)";
    if ([deviceString isEqualToString:@"iPad3,6"])       return @"iPad (4th generation)";
    if ([deviceString isEqualToString:@"iPad4,1"])       return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad4,2"])       return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad4,3"])       return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad5,3"])       return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])       return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad6,7"])       return @"iPad Pro (12.9-inch)";
    if ([deviceString isEqualToString:@"iPad6,8"])       return @"iPad Pro (12.9-inch)";
    if ([deviceString isEqualToString:@"iPad6,3"])       return @"iPad Pro (9.7-inch)";
    if ([deviceString isEqualToString:@"iPad6,4"])       return @"iPad Pro (9.7-inch)";
    if ([deviceString isEqualToString:@"iPad6,11"])      return @"iPad (5th generation)";
    if ([deviceString isEqualToString:@"iPad6,12"])      return @"iPad (5th generation)";
    if ([deviceString isEqualToString:@"iPad7,1"])       return @"iPad Pro (12.9-inch)(2nd generation)";
    if ([deviceString isEqualToString:@"iPad7,2"])       return @"iPad Pro (12.9-inch)(2nd generation)";
    if ([deviceString isEqualToString:@"iPad7,3"])       return @"iPad Pro (10.5-inch)";
    if ([deviceString isEqualToString:@"iPad7,4"])       return @"iPad Pro (10.5-inch)";
    if ([deviceString isEqualToString:@"iPad7,5"])       return @"iPad (6th generation)";
    if ([deviceString isEqualToString:@"iPad7,6"])       return @"iPad (6th generation)";
    if ([deviceString isEqualToString:@"iPad8,1"])       return @"iPad Pro (11-inch)";
    if ([deviceString isEqualToString:@"iPad8,2"])       return @"iPad Pro (11-inch)";
    if ([deviceString isEqualToString:@"iPad8,3"])       return @"iPad Pro (11-inch)";
    if ([deviceString isEqualToString:@"iPad8,4"])       return @"iPad Pro (11-inch)";
    if ([deviceString isEqualToString:@"iPad8,5"])       return @"iPad Pro (12.9-inch)(3rd generation)";
    if ([deviceString isEqualToString:@"iPad8,6"])       return @"iPad Pro (12.9-inch)(3rd generation)";
    if ([deviceString isEqualToString:@"iPad8,7"])       return @"iPad Pro (12.9-inch)(3rd generation)";
    if ([deviceString isEqualToString:@"iPad8,8"])       return @"iPad Pro (12.9-inch)(3rd generation)";
    if ([deviceString isEqualToString:@"iPad2,5"])       return @"iPad mini";
    if ([deviceString isEqualToString:@"iPad2,6"])       return @"iPad mini";
    if ([deviceString isEqualToString:@"iPad2,7"])       return @"iPad mini";
    if ([deviceString isEqualToString:@"iPad4,4"])       return @"iPad mini 2";
    if ([deviceString isEqualToString:@"iPad4,5"])       return @"iPad mini 2";
    if ([deviceString isEqualToString:@"iPad4,6"])       return @"iPad mini 2";
    if ([deviceString isEqualToString:@"iPad4,7"])       return @"iPad mini 3";
    if ([deviceString isEqualToString:@"iPad4,8"])       return @"iPad mini 3";
    if ([deviceString isEqualToString:@"iPad4,9"])       return @"iPad mini 3";
    if ([deviceString isEqualToString:@"iPad5,1"])       return @"iPad mini 4";
    if ([deviceString isEqualToString:@"iPad5,2"])       return @"iPad mini 4";
    
    
    if ([deviceString isEqualToString:@"x86_64"])    return @"Simulator";
    if ([deviceString isEqualToString:@"i386"]) return @"Simulator";
    
    return deviceString;
}
- (NSString *)getVersion {
    return [[UIDevice currentDevice] systemVersion];
}

- (bool)isEmptyStr:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        return YES;
    }
    return NO;
}
#pragma mark 判断屏幕
- (void)initSDKIndidFinishLaunchingWithOptions:(NSDictionary *)launchOptions window:(UIWindow *)window{
    [[XsAppInfo sharedInstance] addNotification];
}
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SPEACIL_UI_NOTIFICATION" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(safeAreaChange:) name:@"SPEACIL_UI_NOTIFICATION" object:nil];
}

- (void)safeAreaChange:(NSNotification *)noti {
    NSDictionary *dic = noti.object;
    [XsAppInfo sharedInstance].safeRight = dic[@"safeRight"];
}
#pragma mark - sdk初始化
- (NSString *)IsSDKInited {
    //设置sdk已初始化
    self.isSDKInited = true;
    NSString *result = self.isSDKInited ? @"true" : @"false";
    NSLog(@"IsSDKInited = %@", result);
    //    return result;
    return @"true";
}
@end
