//
//  CircleView.m
//  TanTan_two
//
//  Created by 彭冲 on 25/12/18.
//  Copyright © 2018年 彭冲. All rights reserved.
//

#import "CircleView.h"

@implementation CircleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)setDelayTime:(int)delayTime {
    
    _delayTime = delayTime;
    
    CAKeyframeAnimation *animation_scale = [CAKeyframeAnimation animation];
    animation_scale.keyPath = @"transform.scale";
    NSValue *value0 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
    NSValue *value1 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 1.5, 1)];
    NSValue *value2 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2, 2, 1)];
    NSValue *value3 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2.5, 2.5, 1)];
    NSValue *value4 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(3, 3, 1)];
    animation_scale.values = @[value0, value1, value2, value3, value4];
    
    
    CAKeyframeAnimation *animation_opacity = [CAKeyframeAnimation animation];
    animation_opacity.keyPath = @"opacity";
    NSValue *value0_0 = @(1.0);
    NSValue *value1_1 = @(0.8);
    NSValue *value2_2 = @(0.5);
    NSValue *value3_3 = @(0.3);
    NSValue *value4_4 = @(0.0);
    animation_opacity.values = @[value0_0, value1_1, value2_2, value3_3, value4_4];
    
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[animation_scale, animation_opacity];
    group.duration = 4.5;
    group.removedOnCompletion = NO;
    group.beginTime = CACurrentMediaTime() + delayTime;
    group.repeatCount = MAXFLOAT;
    group.fillMode = kCAFillModeForwards;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    
    [self.layer addAnimation:group forKey:nil];
    
}

@end
