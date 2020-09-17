//
//  UIImageView+DownloadCache.m
//  SlidePhoto
//
//  Created by VictorZhang on 2020/9/6.
//  Copyright © 2020 VictorZhang. All rights reserved.
//

#import "UIImageView+DownloadCache.h"
#import "SPImageDownloader.h"


@implementation UIImageView (DownloadCache)

- (void)sp_showImageWithURL:(NSURL * __nullable)url completion:(void(^ __nullable)(UIImage * __nullable downloadedImage, NSError * __nullable error))downloadingCompletion {
    // 先显示加载框
    UIActivityIndicatorView *indicatorView = [self createIndicatorView];
    
    SPImageDownloader *downloader = [SPImageDownloader shared];
    [downloader addImageDownloadTaskWithURL:url completion:^(UIImage * __nullable downloadedImage, NSError * __nullable error) {
        [indicatorView stopAnimating];
        [indicatorView removeFromSuperview];
        if (error) {
            // 下载失败，重试
        } else {
            self.image = downloadedImage;
            if (downloadingCompletion) {
                downloadingCompletion(downloadedImage, error);
            }
        }
    }];
}

- (UIActivityIndicatorView *)createIndicatorView {
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:indicatorView];
    [indicatorView startAnimating];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(indicatorView);
    NSDictionary *metrics = @{};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[indicatorView]-|" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[indicatorView]-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
    
    return indicatorView;
}

@end
