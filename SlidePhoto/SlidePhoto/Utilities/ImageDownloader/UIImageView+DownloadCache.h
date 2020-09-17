//
//  UIImageView+DownloadCache.h
//  SlidePhoto
//
//  Created by VictorZhang on 2020/9/6.
//  Copyright © 2020 VictorZhang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (DownloadCache)

- (void)sp_showImageWithURL:(NSURL * __nullable)url completion:(void(^ __nullable)(UIImage * __nullable downloadedImage, NSError * __nullable error))downloadingCompletion ;

@end

NS_ASSUME_NONNULL_END
