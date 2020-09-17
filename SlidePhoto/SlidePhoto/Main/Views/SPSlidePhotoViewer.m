//
//  SPSlidePhotoViewer.m
//  SlidePhoto
//
//  Created by VictorZhang on 2020/9/6.
//  Copyright © 2020 VictorZhang. All rights reserved.
//

#import "SPSlidePhotoViewer.h"
#import "SlidePhoto-Swift.h"

#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height

#define ImageScale 0.1 //每张图片初始化缩小尺寸
#define ImageSpace 20 //每张图片底部距离

@interface SPSlidePhotoViewer ()

@property (strong, nonatomic) UIView *rootView;

@property (nonatomic, strong) NSMutableArray<SPImageCardDataModel *> *cardDataModels;
@property (nonatomic, strong) NSMutableArray *cards;


@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *redView;
@property (nonatomic, strong) UIView *topCard; //最上面
@property (nonatomic, strong) UIView *bottomCard; //最底部


@property (nonatomic, assign) CGFloat photoViewWidth;
@property (nonatomic, assign) CGFloat photoViewHeight;
           
@end

@implementation SPSlidePhotoViewer

- (instancetype)initWithFrame:(CGRect)frame dataList:(NSArray *)dataList {
    self = [super initWithFrame:frame];
    if (self) {
        _cardDataModels = [NSMutableArray arrayWithArray:dataList];
        
        [self setupCardSubviews];
    }
    return self;
}

- (void)setupCardSubviews {
    CGSize viewSize = self.bounds.size;
    CGFloat margin = 30;
    _photoViewWidth = viewSize.width - margin * 2;
    _photoViewHeight = _photoViewWidth * 1.3;
    
    self.rootView = [[UIView alloc] init];
    self.rootView.frame = self.bounds;
    [self addSubview:self.rootView];
    
    self.cards = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 4; i++) {
        if (i >= self.cardDataModels.count) {
            break;
        }
        SPImageCardDataModel *model = self.cardDataModels[i];
        SPSlidePhotoItemView *card = [[SPSlidePhotoItemView alloc] initWithFrame:CGRectMake(0, 0, _photoViewWidth, _photoViewHeight)];
        [card updateDataWith:model];
        card.tag = 100 + i;
       
       int index = i;
       if (index == 3) {
           index = 2;
       }
       
       card.center = CGPointMake(ScreenW/2, ScreenH/2 +(_photoViewHeight*ImageScale*index/2)+ ImageSpace*index);
       card.transform = CGAffineTransformMakeScale(1-ImageScale*index, 1-ImageScale*index);
       
       [self.cards addObject:card];
       
       [self.rootView addSubview:card];
       [self.rootView sendSubviewToBack:card];
       
       // 添加拖动手势
       UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandle:)];
       [card addGestureRecognizer:pan];
       
       // 设置首尾卡片
       card.userInteractionEnabled = NO;
       if (i == 0) {
           card.userInteractionEnabled = YES;
           self.topCard = card;
       } else if (i == 3) {
           self.bottomCard = card;
       }
    }
}

- (void)panHandle:(UIPanGestureRecognizer *)pan {
    UIView *cardView = pan.view;

    if (pan.state == UIGestureRecognizerStateBegan) { //开始拖动
        
    } else if (pan.state == UIGestureRecognizerStateChanged) { //正在拖动
        
        CGPoint transLcation = [pan translationInView:cardView];
        cardView.center = CGPointMake(cardView.center.x + transLcation.x, cardView.center.y + transLcation.y);
        CGFloat XOffPercent = (cardView.center.x-ScreenW/2.0)/(ScreenW/2.0);
        CGFloat rotation = M_PI_2/4*XOffPercent;
        cardView.transform = CGAffineTransformMakeRotation(rotation);
        [pan setTranslation:CGPointZero inView:cardView];
        
        [self animationBlowViewWithXOffPercent:fabs(XOffPercent)];

        
    } else if (pan.state == UIGestureRecognizerStateEnded) { //松手了，拖动结束
        
        //视图不移除，原路返回
        if (cardView.center.x > 60 && cardView.center.x < ScreenW - 60) {
            [UIView animateWithDuration:0.25 animations:^{
                cardView.center = CGPointMake(ScreenW/2.0, ScreenH/2.0);
                cardView.transform = CGAffineTransformMakeRotation(0);
                [self animationBlowViewWithXOffPercent:0];
            }];
        } else {
            
            //视图在屏幕左侧移除
            if (cardView.center.x < 60) {
                [UIView animateWithDuration:0.25 animations:^{
                    cardView.center = CGPointMake(-200, cardView.center.y);
                }];
                
            } else{//视图在屏幕右侧移除
                [UIView animateWithDuration:0.25 animations:^{
                    cardView.center = CGPointMake(ScreenW+200, cardView.center.y);
                }];
            }
            
            [self animationBlowViewWithXOffPercent:1];
            [self performSelector:@selector(cardRemove) withObject:cardView afterDelay:0.25];
        }
    }
}

- (void)animationBlowViewWithXOffPercent:(CGFloat)XOffPercent {
    for (UIView *card in self.cards) {
        if (card != self.topCard && card.tag != 103) {
            NSInteger index = card.tag-100;
            card.center = CGPointMake(ScreenW/2,ScreenH/2
                                      + (_photoViewHeight*ImageScale*index/2)
                                      + ImageSpace*index  //上面3行是原始位置，下面2行是改变的大小
                                      - XOffPercent*ImageSpace
                                      - (_photoViewHeight*ImageScale*index/2)*XOffPercent/index);
            
            CGFloat scale = 1-ImageScale*index + XOffPercent*ImageScale;
            card.transform = CGAffineTransformMakeScale(scale, scale);
        }
    }
}

- (void)cardRemove {
    // 滑动结束时的顶部PhotoView先移除，再把顶部的PhotoView添加到尾部
    [self.cards removeObject:self.topCard];
    [self.cards addObject:self.topCard];
    
    // 删除此数据模型
    if ((self.topCard.tag-100) < self.cardDataModels.count) {
        [self.cardDataModels removeObjectAtIndex:self.topCard.tag-100];
    }
    
    // 重新设置tag
    for (int i = 0 ; i < 4; i++) {
        if (i >= self.cards.count) {
            break;
        }
        SPSlidePhotoItemView *card = self.cards[i];
        card.tag = 100+i;
        
        if (i < self.cardDataModels.count) {
            SPImageCardDataModel *model = self.cardDataModels[i];
            [card updateDataWith:model];
        } else {
            // 重新请求下一页资源
            if ([self.photoViewerDelegate respondsToSelector:@selector(slidePhotoViewer:requestNextPage:)]) {
                [self.photoViewerDelegate slidePhotoViewer:self requestNextPage:YES];
            }
        }
    }
    
    // 重置第一张和最后一张（第4）
    self.topCard.userInteractionEnabled = NO;
    self.topCard.center = CGPointMake(ScreenW/2, ScreenH/2 + (_photoViewHeight*ImageScale*2/2) + ImageSpace*2);
    self.topCard.transform = CGAffineTransformMakeScale(1-ImageScale*2, 1-ImageScale*2);
    [self.rootView sendSubviewToBack:self.topCard];
    
    self.bottomCard = self.topCard;
    
    UIView *currentCard = self.cards.firstObject;
    currentCard.userInteractionEnabled = YES;
    self.topCard = currentCard;
    
}

- (void)updateDataModelList:(NSArray *)dataList {
    [_cardDataModels addObjectsFromArray:dataList];
}

@end
