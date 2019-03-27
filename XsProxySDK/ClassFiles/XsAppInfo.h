//
//  XsAppInfo.h
//  XsProxySDK
//
//  Created by 吴怿 on 2019/3/12.
//  Copyright © 2019 吴怿. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XsAppInfo : NSObject
+ (instancetype)sharedInstance;
- (NSString *)getAppInfo;
- (NSString *)getNotchHeight;
- (NSString *)IsSDKInited;
@end

NS_ASSUME_NONNULL_END
