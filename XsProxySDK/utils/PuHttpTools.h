//
//  PuHttpTools.h
//  PuProxySDK
//
//  Created by saihua lu on 2018/03/31.
//  Copyright © 2018年 suma. All rights reserved.
//

#ifndef PuHttpTools_h
#define PuHttpTools_h

#import <Foundation/Foundation.h>

@protocol PuHttpDelegate <NSObject>

- (void) onResult: (NSString *) tag andCode: (int) code andData: (NSString *) data andDict: dict;

@end

@interface PuHttpTools : NSObject <NSURLSessionDelegate>

- (void)getRequest:(NSString *)tag andUrl:(NSString *)url andDict:(NSMutableDictionary *)dict andDelegate: (id <PuHttpDelegate>) delegate;

- (void)postRequest:(NSString *)tag andUrl:(NSString *)url andDict:(NSMutableDictionary *)dict andDelegate: (id <PuHttpDelegate>) delegate;

- (NSMutableDictionary *) buildParams: (NSMutableDictionary *) dict;

- (NSString *) sortParams: (NSMutableDictionary *) dict;

- (NSMutableDictionary *)dictCommonSet1:(NSMutableDictionary *)mDict;

- (NSMutableDictionary *)dictCommonSet2:(NSMutableDictionary *)mDict serverName:(NSString *)serverName;

@end

#endif /* PuHttpTools_h */
