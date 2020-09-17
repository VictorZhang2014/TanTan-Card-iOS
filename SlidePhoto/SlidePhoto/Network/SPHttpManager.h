//
//  SPHttpManager.h
//  SlidePhoto
//
//  Created by VictorZhang on 2020/9/5.
//  Copyright © 2020 VictorZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SPAPIUrlType) {
    SPAPIUrlTypeSignUp, // 注册  ”假设接口存在“
    SPAPIUrlTypeSignIn, // 登录  “假设接口存在”
    SPAPIUrlTypeSearchItemsByKeyword, // 通过关键字搜索item列表
};



typedef NS_ENUM(NSInteger, SPAPIHTTPMethod) {
    SPAPIHTTPMethodGet,
    SPAPIHTTPMethodPost,
    SPAPIHTTPMethodPut,
    SPAPIHTTPMethodDelete,
    SPAPIHTTPMethodHead,
    SPAPIHTTPMethodPatch,
};



@interface SPHttpManager : NSObject

- (NSString *)getAPIUrlPath:(SPAPIUrlType)apiUrlType;
- (NSString *)getAPIUrlPath:(SPAPIUrlType)apiUrlType suffixParam:(NSString * __nullable)param;


- (void)requestWithUrl:(NSString *)apiUrlStr
            parameters:(NSDictionary * _Nullable)parameters
                method:(SPAPIHTTPMethod)method
     completionHandler:(nullable void (^)(BOOL isSuccess, NSDictionary * _Nullable responseDict,  NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
