//
//  XsProxySDK.h
//  XsProxySDK
//
//  Created by 吴怿 on 2019/3/12.
//  Copyright © 2019 吴怿. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  FYSDKDelegate
 */
@protocol XSProxySDKDelegate <NSObject>
@optional
#pragma mark - 传值方法 code : 错误码  data : JSON字符串格式
- (void)nativeTransmissionJs:(NSString *)tag andCode:(int)code withData:(id)data;
- (void)NavbarVisible:(BOOL)visible;

@end
@interface XsProxySDK : NSObject
@property(nonatomic, assign) id <XSProxySDKDelegate> delegate;
+ (instancetype)sharedInstance;

#pragma mark - game调用native方法 *tag : tag  *data : JSON字符串格式
- (NSString *)gameCallNative:(NSString *)tag andData:(NSString *)data;
@end
