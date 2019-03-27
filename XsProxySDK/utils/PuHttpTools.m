//
//  PuHttpTools.m
//  PuProxySDK
//
//  Created by saihua lu on 2018/03/31.
//  Copyright © 2018年 suma. All rights reserved.
//

#import "PuHttpTools.h"
#import <CommonCrypto/CommonDigest.h>
//#import "../funcs/PuRootSDK.h"
//#import "PuLocTools.h"
//#import "../consts/PuCommonConsts.h"
//#import "PuUsefulTools.h"
//#import "PuPlistTools.h"
//#import "PuDeviceTools.h"
//#import "PuUserDefaultsTools.h"
//
//#import "PuLogTools.h"
//#import "PuMdFiveTools.h"
//
//#import "../consts/PuCommonConsts.h"

@implementation PuHttpTools

int trycount = 1; //初始化尝试次数
const int MAX_TRY_COUNT = 3; //最大尝试次数

- (void)getRequest:(NSString *)tag andUrl:(NSString *)url andDict:(NSMutableDictionary *)dict andDelegate:(id <PuHttpDelegate>)delegate {
}

- (void)postRequest:(NSString *)tag andUrl:(NSString *)url andDict:(NSMutableDictionary *)dict andDelegate:(id <PuHttpDelegate>)delegate {

    if (!url) {
        NSLog(@"Http request failed: url is empty.");
        return;
    }

    static NSString *errmsg;

    if (trycount > MAX_TRY_COUNT) {
        errmsg = [NSString stringWithFormat:@"Http request failed: req reached max try count."];
        NSLog(@"%@",errmsg);
        [delegate onResult:tag andCode:1 andData:errmsg andDict:dict];
        return;
    }
    NSLog(@"Http req %d time for: %@", trycount, url);

    @try {
        if (dict) {
            //签名配置
            NSString *timeStamp = [NSString stringWithFormat:@"%i", (int) [[NSDate date] timeIntervalSince1970]];

            dict[@"service"] = tag;
            dict[@"time"] = timeStamp;

            //地理位置使用old签名方式
            if ([tag isEqualToString:@"gameRoleIpInfoGet"] || [tag isEqualToString:@"gameRoleIpInfoUpdate"]) {
                dict[@"sign"] = [self md5:[tag stringByAppendingString:timeStamp]];
                dict[@"checkSum"] = [[self md5:[self sortParams:dict]] uppercaseString];
            } else {
                dict[@"sign"] = [[self md5:[self sortParams:dict]] uppercaseString];
            }


            dict[@"signType"] = @"md5";
            NSMutableString *mutableString = [NSMutableString string];
            [mutableString appendString:url];
            [mutableString appendString:@"?"];
            for (NSString *key in [dict allKeys]) {
                [mutableString appendString:key];
                [mutableString appendString:@"="];
                [mutableString appendString:dict[key]];
                [mutableString appendString:@"&"];
            }
            url = [mutableString substringToIndex:[mutableString length] - 1];
        }
        // escaped url
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSLog(@"Http request for: %@", url);

        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"GET"];

//        if (dict) {
//            NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
//            NSString *bodyData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//
//            [request setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
//        }
//        [request setHTTPMethod:@"POST"];



        //Configure session，信赖任何的服务端证书
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        if ([tag isEqualToString:@"gameConfGet"]) {
            configuration.timeoutIntervalForRequest = 5;
        }
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];

        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {

                if (trycount < MAX_TRY_COUNT) {
                    trycount++;
                    [self postRequest:tag andUrl:url andDict:dict andDelegate:delegate];
                    return;
                }

                errmsg = [NSString stringWithFormat:@"Http request failed: errmsg = %@", error.localizedDescription];
                NSLog(@"%@",errmsg);
                [delegate onResult:tag andCode:1 andData:errmsg andDict:dict];
                return;
            }

            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            if (httpResponse.statusCode != 200) {

                if (trycount < MAX_TRY_COUNT) {
                    trycount++;
                    [self postRequest:tag andUrl:url andDict:dict andDelegate:delegate];
                    return;
                }

                errmsg = [NSString stringWithFormat:@"Http request failed: errcode = %ld, errmsg = %@", (long) httpResponse.statusCode, error.localizedDescription];

                NSLog(@"%@",errmsg);
                [delegate onResult:tag andCode:1 andData:errmsg andDict:dict];
                return;
            }

            trycount = 1;

            NSString *resultData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Http request succeeced: resultData = %@ tag = %@", resultData,tag);
            
            if ([tag isEqualToString:@"gameRoleIpInfoGet"]) {
                NSLog(@"123");
            }
            
            [delegate onResult:tag andCode:0 andData:resultData andDict:dict];
        }];
        [dataTask resume];
    } @catch (NSException *exception) {
        if (trycount < MAX_TRY_COUNT) {
            trycount++;
            [self postRequest:tag andUrl:url andDict:dict andDelegate:delegate];
            return;
        }

        errmsg = [NSString stringWithFormat:@"Http request failed: errmsg = %@", [exception description]];

        NSLog(@"%@",errmsg);
        [delegate onResult:tag andCode:1 andData:errmsg andDict:dict];
    } @finally {

    }
}
- (NSString *)md5:(NSString *)string {
    NSLog(@"before md5 ->%@",string);
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), digest); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    NSLog(@"after md5 ->%@",output);
    return output;
}
//- (NSMutableDictionary *)buildParams:(NSMutableDictionary *)paramsDict {
//    PuPlistTools *plistUtils = [PuPlistTools sharedInstance];
//    PuDeviceTools *deviceUtils = [PuDeviceTools sharedInstance];
//    PuUsefulTools *commUtils = [PuUsefulTools sharedInstance];
//
//    NSArray *keys = [paramsDict allKeys];
//
//    for (NSString *key in keys) {
//        paramsDict[key] = [NSString stringWithFormat:@"%@", paramsDict[key]];
//    }
//
//
//    @try {
//        NSDictionary *locDict = [PuRootSDK sharedInstance].locDict;
//        NSString *country = @"";
//        NSString *province = @"";
//        NSString *street = @"";
//        NSString *district = @"";
//        NSString *city = @"";
//        NSString *x = @"";
//        NSString *y = @"";
//        if (locDict) {
//            country = locDict[LOC_COUNTRY];
//            if ([[PuUsefulTools sharedInstance] isEmptyStr:country]) country = @"中国";
//            province = locDict[LOC_PROVINCE];
//            if ([[PuUsefulTools sharedInstance] isEmptyStr:province]) province = @"";
//            city = locDict[LOC_CITY];
//            if ([[PuUsefulTools sharedInstance] isEmptyStr:city]) city = @"";
//            street = locDict[LOC_STREET];
//            if ([[PuUsefulTools sharedInstance] isEmptyStr:street]) street = @"";
//            district = locDict[LOC_DISTRICT];
//            if ([[PuUsefulTools sharedInstance] isEmptyStr:district]) district = @"";
//            x = locDict[LOC_X];
//            if (!x) x = @"0";
//            y = locDict[LOC_Y];
//            if (!y) y = @"0";
//        }
//
//        //地理位置
//        paramsDict[PARAM_LOCATION_X] = x;
//        paramsDict[PARAM_LOCATION_Y] = y;
//        paramsDict[PARAM_COUNTRY] = country;
//        paramsDict[PARAM_PROVINCE] = province;
//        paramsDict[PARAM_CITY] = city;
//        paramsDict[PARAM_DISTRICT] = district;
//        paramsDict[PARAM_STREET] = street;
//
//        //基础配置
//        paramsDict[PARAM_GAME_ID] = [NSString stringWithFormat:@"%@", (NSString *) [plistUtils getValueInPlist:PLISTKEY_GAMEID]];
//        paramsDict[PARAM_SOURCE_ID] = [NSString stringWithFormat:@"%@", (NSString *) [plistUtils getValueInPlist:PLISTKEY_SOURCEID]];
//        paramsDict[PARAM_VERSION] = (NSString *) [plistUtils getValueInPlist:@"CFBundleShortVersionString"];
//        paramsDict[PARAM_SERVER_ID] = @"1";
//
//        //硬件配置
//        paramsDict[PARAM_MOBILE_MODE] = [deviceUtils getDeviceModel];
//        paramsDict[PARAM_SDK_VERSION] = [NSString stringWithFormat:@"%@", [deviceUtils getOSVersion]];
//        paramsDict[PARAM_MOBILE_OPERATOR] = [NSString stringWithFormat:@"%d", [deviceUtils getCarrierOperator]];
//        paramsDict[PARAM_NETTYPE] = [NSString stringWithFormat:@"%ld", (long) [deviceUtils getNetType]];
//        paramsDict[PARAM_IMEI] = [commUtils getUUID];
//
//        NSLog(@"buildParams paramsDict->%@", paramsDict);
//    } @catch (NSException *err) {
//        PULog(@"buildParams err->%@", err);
//    }
//    return paramsDict;
//}


//- (NSString *)sortParams:(NSMutableDictionary *)dict {
//    NSLog(@"before sort->%@", dict);
//    NSArray *keys = [dict allKeys];
//    NSArray *sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
//        return [a compare:b];
//    }];
//    NSMutableString *mutableString = [NSMutableString string];
//    for (NSString *key in sortedKeys) {
//        [mutableString appendString:dict[key]];
//    }
//    [mutableString appendString:PRIKEY];
//    NSLog(@"after sort->%@", mutableString);
//    return mutableString;
//}


//- (NSMutableDictionary *)dictCommonSet1:(NSMutableDictionary *)mDict {
//    NSString *country = @"";
//    NSString *province = @"";
//    NSString *street = @"";
//    NSString *district = @"";
//    NSString *city = @"";
//    NSString *x = @"";
//    NSString *y = @"";
//
//    //获取定位信息
//    NSDictionary *locDict = [PuRootSDK sharedInstance].locDict;
//
//    if (locDict) {
//        country = locDict[LOC_COUNTRY];
//        if ([[PuUsefulTools sharedInstance] isEmptyStr:country]) country = @"中国";
//        province = locDict[LOC_PROVINCE];
//        if ([[PuUsefulTools sharedInstance] isEmptyStr:province]) province = @"";
//        city = locDict[LOC_CITY];
//        if ([[PuUsefulTools sharedInstance] isEmptyStr:city]) city = @"";
//        street = locDict[LOC_STREET];
//        if ([[PuUsefulTools sharedInstance] isEmptyStr:street]) street = @"";
//        district = locDict[LOC_DISTRICT];
//        if ([[PuUsefulTools sharedInstance] isEmptyStr:district]) district = @"";
//        x = locDict[LOC_X];
//        if (!x) x = @"0";
//        y = locDict[LOC_Y];
//        if (!y) y = @"0";
//    }
//
//    NSString *uuid = [[PuUsefulTools sharedInstance] getUUID];
//
//    //获取渠道号
//    mDict[PARAM_LOCATION_X] = x;
//    mDict[PARAM_LOCATION_Y] = y;
//    mDict[PARAM_COUNTRY] = country;
//    mDict[PARAM_PROVINCE] = province;
//    mDict[PARAM_CITY] = city;
//    mDict[PARAM_NETTYPE] = [NSString stringWithFormat:@"%li", (long) [[PuDeviceTools sharedInstance] getNetType]];
//
//    mDict[PARAM_VERSION] = (NSString *) [[PuPlistTools sharedInstance] getValueInPlist:@"CFBundleShortVersionString"];
//    mDict[PARAM_MOBILE_MODE] = [[PuDeviceTools sharedInstance] getDeviceModel];
//    mDict[PARAM_IMEI] = uuid;
//    return mDict;
//}

//- (NSMutableDictionary *)dictCommonSet2:(NSMutableDictionary *)mDict serverName:(NSString *)serverName {
//    mDict[PARAM_SERVICE] = serverName;
//    mDict[PARAM_TIME] = [NSString stringWithFormat:@"%i", (int) [[NSDate date] timeIntervalSince1970]]; //当前时间
//    mDict[PARAM_SIGN] = [[[PuMdFiveTools sharedInstance] md5:[self sortParams:mDict]] uppercaseString];
//    mDict[PARAM_SIGN_TYPE] = MD5;
//    return mDict;
//}

/**
 只要请求的地址是HTTPS的, 就会调用这个代理方法
 我们需要在该方法中告诉系统, 是否信任服务器返回的证书
 Challenge: 挑战 质问 (包含了受保护的区域)
 protectionSpace : 受保护区域
 NSURLAuthenticationMethodServerTrust : 证书的类型是 服务器信任
 */
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    @try {
        // 1.判断服务器返回的证书类型, 是否是服务器信任
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            NSURLCredential *credential = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        }
    } @catch (NSException *exception) {
        NSLog(@"URLSession didReceiveChallenge exception: %@", [exception description]);
    }
}

@end
