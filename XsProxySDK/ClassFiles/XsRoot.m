//
//  XsRoot.m
//  XsProxySDK
//
//  Created by 吴怿 on 2019/3/12.
//  Copyright © 2019 吴怿. All rights reserved.
//

#import "XsRoot.h"

@implementation XsRoot
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static XsRoot *instance;
    dispatch_once(&onceToken, ^{
        instance = [[XsRoot alloc] init];
    });
    return instance;
}
#pragma mark - 拍照
//拍照
- (void)getPhoto:(NSString *)data {
    if (![XsProxySDK sharedInstance].delegate) {
        NSLog(@"Photo failed: PuProxySDKDelegate is nil.");
        return;
    }
//    [[PUPhotoManager shareInstance] openPhoto:data];
}
- (NSDictionary *)parseJSONStrToObj:(NSString *)json {
    return [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
}
@end
