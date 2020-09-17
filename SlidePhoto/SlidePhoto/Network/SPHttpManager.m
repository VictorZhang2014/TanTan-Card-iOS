//
//  SPHttpManager.m
//  SlidePhoto
//
//  Created by VictorZhang on 2020/9/5.
//  Copyright © 2020 VictorZhang. All rights reserved.
//

#import "SPHttpManager.h"


@interface SPHttpManager ()

@property (nonatomic, strong) NSString *apidomain;

@end

@implementation SPHttpManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _apidomain = @"https://image.so.com";
    }
    return self;
}

- (NSString *)getAPIUrlPath:(SPAPIUrlType)apiUrlType {
    return [self getAPIUrlPath:apiUrlType suffixParam:nil];
}

- (NSString *)getAPIUrlPath:(SPAPIUrlType)apiUrlType suffixParam:(NSString * __nullable)param {
    if (param == nil) {
        param = @"";
    }
    switch (apiUrlType) {
        case SPAPIUrlTypeSignUp:
            return [NSString stringWithFormat:@"%@/signup", self.apidomain]; // 假设接口存在
        case SPAPIUrlTypeSignIn:
            return [NSString stringWithFormat:@"%@/signin", self.apidomain]; // 假设接口存在
        case SPAPIUrlTypeSearchItemsByKeyword:
            return [NSString stringWithFormat:@"%@/j%@", self.apidomain, param];
        default:
            return @"";
    }
}


- (void)requestWithUrl:(NSString *)apiUrlStr
                              parameters:(NSDictionary * _Nullable)parameters
                                  method:(SPAPIHTTPMethod)method
                      completionHandler:(nullable void (^)(BOOL isSuccess, NSDictionary * _Nullable responseDict,  NSError * _Nullable error))completionHandler {
    NSURL *url = [[NSURL alloc] initWithString:apiUrlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:[self getHttpMethod:method]];
    if (parameters) {
        NSError *serializedError;
        NSData *parameterData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&serializedError];
        [request setHTTPBody:parameterData];
    }
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!completionHandler) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                completionHandler(NO, nil, error);
            } else if (data) {
                NSDictionary *_respDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                completionHandler(YES, _respDict, nil);
            } else {
                NSError *tmpError = [[NSError alloc] init];
                [tmpError setValue:@"Unknown Error!" forKey:@"localizedDescription"];
                completionHandler(NO, nil, tmpError);
            }
        });
    }];
    [task resume];
}

- (NSString *)getHttpMethod:(SPAPIHTTPMethod)method {
    switch (method) {
        case SPAPIHTTPMethodGet:
            return @"GET";
        case SPAPIHTTPMethodPost:
            return @"POST";
        case SPAPIHTTPMethodPut:
            return @"PUT";
        case SPAPIHTTPMethodDelete:
            return @"DELETE";
        case SPAPIHTTPMethodHead:
            return @"HEAD";
        case SPAPIHTTPMethodPatch:
            return @"PATCH";
        default:
            return @"GET";
    }
}

@end
