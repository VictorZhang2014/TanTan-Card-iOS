//
//  SPImageDownloader.h
//  SlidePhoto
//
//  Created by VictorZhang on 2020/9/6.
//  Copyright © 2020 VictorZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class UIImage;
@interface SPImageDownloadItemModel : NSObject

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, assign) NSInteger dataLength;
@property (nonatomic, copy) void(^downloadCompletionHandler)(UIImage * __nullable downloadedImage, NSError * __nullable error);

@end


@interface SPImageDownloader : NSObject

+ (instancetype)shared;

- (void)addImageDownloadTaskWithURL:(NSURL *)imageURL completion:(void(^)(UIImage * __nullable downloadedImage, NSError * __nullable error))completion;

@end

NS_ASSUME_NONNULL_END
