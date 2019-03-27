//
//  XsRoot.h
//  XsProxySDK
//
//  Created by 吴怿 on 2019/3/12.
//  Copyright © 2019 吴怿. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../XsProxySDK.h"
NS_ASSUME_NONNULL_BEGIN

@interface XsRoot : NSObject
+ (instancetype)sharedInstance;
- (void)getPhoto:(NSString *)data;
- (NSDictionary *)parseJSONStrToObj:(NSString *)json;
@end

NS_ASSUME_NONNULL_END
