//
//  SPSlidePhotoViewer.h
//  SlidePhoto
//
//  Created by VictorZhang on 2020/9/6.
//  Copyright © 2020 VictorZhang. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN


@class SPSlidePhotoViewer;
@protocol SPSlidePhotoViewerDelegate <NSObject>

- (void)slidePhotoViewer:(SPSlidePhotoViewer *)photoViewer requestNextPage:(BOOL)nextPage;

@end



@interface SPSlidePhotoViewer : UIView

@property (nonatomic, weak) id<SPSlidePhotoViewerDelegate> photoViewerDelegate;

- (instancetype)initWithFrame:(CGRect)frame dataList:(NSArray *)dataList;

- (void)updateDataModelList:(NSArray *)dataList;

@end

NS_ASSUME_NONNULL_END
