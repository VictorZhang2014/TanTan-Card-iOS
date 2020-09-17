//
//  Extension.h
//  SlidePhoto
//
//  Created by VictorZhang on 2020/9/5.
//  Copyright © 2020 VictorZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Extension)

- (NSString *)urlencode;

- (NSAttributedString *)htmlToPlain;

- (NSString *)MD5;

@end

NS_ASSUME_NONNULL_END
