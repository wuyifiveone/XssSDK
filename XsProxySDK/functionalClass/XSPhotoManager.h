//
//  XSPhotoManager.h
//  XsProxySDK
//
//  Created by 吴怿 on 2019/3/12.
//  Copyright © 2019 吴怿. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XSPhotoManager : UIViewController
+ (instancetype)shareInstance;

- (void)openPhoto:(NSString *)data;
@end

NS_ASSUME_NONNULL_END
