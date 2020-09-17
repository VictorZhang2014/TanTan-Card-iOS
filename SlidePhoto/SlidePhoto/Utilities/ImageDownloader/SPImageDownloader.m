//
//  SPImageDownloader.m
//  SlidePhoto
//
//  Created by VictorZhang on 2020/9/6.
//  Copyright © 2020 VictorZhang. All rights reserved.
//

#import "SPImageDownloader.h"
#import <UIKit/UIKit.h>
#import "NSString+Extension.h"


@implementation SPImageDownloadItemModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _data = [[NSMutableData alloc] init];
        _dataLength = 0;
    }
    return self;
}

@end


@interface SPImageDownloader()<NSURLSessionDataDelegate>

@property (nonatomic, strong) NSMutableDictionary<NSString *, SPImageDownloadItemModel *> *bufferDataDict;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSString *imageDownloaderFolderName;

@end

@implementation SPImageDownloader

- (instancetype)init {
    self = [super init];
    if (self) {
        _bufferDataDict = [[NSMutableDictionary<NSString *, SPImageDownloadItemModel *> alloc] init];
        
        _operationQueue = [[NSOperationQueue alloc] init];
        
        _imageDownloaderFolderName = @"sp.image.cache.downloader";
    }
    return self;
}

+ (instancetype)shared {
    static SPImageDownloader *downloader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloader = [SPImageDownloader new];
    });
    return downloader;
}

- (void)addImageDownloadTaskWithURL:(NSURL *)imageURL completion:(void(^)(UIImage * __nullable downloadedImage, NSError * __nullable error))completion {
    NSString *imageUrlStr = imageURL.absoluteString;

    // 1.如果图片存在则直接返回
    NSString *localFilepath = [self getImageLocalFilePathWithImageUrl:imageUrlStr];
    if (localFilepath) {
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:localFilepath];
        completion(image, nil);
        return;
    }
    
    SPImageDownloadItemModel *itemModel = [[SPImageDownloadItemModel alloc] init];
    itemModel.imageUrl = imageUrlStr;
    itemModel.data = [[NSMutableData alloc] init];
    itemModel.dataLength = 0.0;
    itemModel.downloadCompletionHandler = completion;
    self.bufferDataDict[imageUrlStr] = itemModel;
    
    // 创建一个Operation去下载
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadByOperation:) object:imageURL];
    [self.operationQueue addOperation:operation];
}

- (void)downloadByOperation:(NSURL *)url {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
    [request setHTTPMethod:@"GET"];
    NSURLSessionConfiguration *configure = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configure delegate:self delegateQueue:self.operationQueue];
    NSURLSessionTask *task = [session dataTaskWithRequest:request];
    [task resume];
}
 
#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response
    completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSString *currentUrl = dataTask.currentRequest.URL.absoluteString;
    SPImageDownloadItemModel *itemModel = self.bufferDataDict[currentUrl];
    
    //NSLog(@"图片总长度 = %@", @(response.expectedContentLength));
    itemModel.dataLength = response.expectedContentLength;
    
    if (completionHandler) {
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSString *currentUrl = dataTask.currentRequest.URL.absoluteString;
    SPImageDownloadItemModel *itemModel = self.bufferDataDict[currentUrl];
    [itemModel.data appendData:data];
    //NSLog(@"当前进度：百分之 %@ %%", @(itemModel.data.length * 1.f / itemModel.dataLength * 100));
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSString *currentUrl = task.currentRequest.URL.absoluteString;
    SPImageDownloadItemModel *itemModel = self.bufferDataDict[currentUrl];
    if (!itemModel || !itemModel.data) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        // 下载完，去主线程更新UI
        UIImage *image = [UIImage imageWithData:itemModel.data scale:[UIScreen mainScreen].scale];
        itemModel.downloadCompletionHandler(image, nil);
    });
    
    // 获取图片的后缀格式
    //NSString *imageMimeType = [self getMIMETypeByData:itemModel.data];
    //NSString *imageExt = [[imageMimeType componentsSeparatedByString:@"/"] lastObject];
    
    // 写入图片文件到本地
    NSString *localFilepath = [self getLocalFilePathNameWithName:itemModel.imageUrl];
    NSError *fileerror;
    BOOL isSuccess = [itemModel.data writeToFile:localFilepath options:NSDataWritingAtomic error:&fileerror];
    if (!isSuccess || fileerror) {
        NSLog(@"图片写入文件时发生了错误！错误信息：%@", fileerror.localizedDescription);
        // 重试一遍
        [itemModel.data writeToFile:localFilepath options:NSDataWritingAtomic error:&fileerror];
    }
}

- (NSString *)getLocalFilePathNameWithName:(NSString *)imageUrl {
    NSString *imageFilename = [NSString stringWithFormat:@"%@", [imageUrl MD5]];
    
    NSString *localDocPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    // 如果文件不存在，就创建
    NSString *localFolderPath = [localDocPath stringByAppendingPathComponent:self.imageDownloaderFolderName];
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:localFolderPath isDirectory:&isDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:localFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    NSString *localFilePath = [localFolderPath stringByAppendingPathComponent:imageFilename];
    return localFilePath;
}

// 检查文件是否存在
- (NSString * __nullable)getImageLocalFilePathWithImageUrl:(NSString *)imageUrlStr {
    NSString *localFilepath = [self getLocalFilePathNameWithName:imageUrlStr];
    if ([[NSFileManager defaultManager] fileExistsAtPath:localFilepath]) {
        return localFilepath;
    }
    return nil;
}

- (NSString *)currentDateFolder {
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    return dateString;
}

- (NSString *)getMIMETypeByData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
        default:
            return @"image/jpg";
    }
    return @"image/jpg";
}

@end
