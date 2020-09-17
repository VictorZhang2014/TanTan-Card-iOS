//
//  ViewController.m
//  TanTan_two
//
//  Created by 彭冲 on 24/12/18.
//  Copyright © 2018年 彭冲. All rights reserved.
//

#import "ViewController.h"
#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height


#define ImageWidth 200
#define ImageHeight 300
#define ImageScale 0.1 //每张图片初始化缩小尺寸
#define ImageSpace 20 //每张图片底部距离



#import "CircleView.h"

@interface ViewController ()



@property (strong ,nonatomic)NSMutableArray * dataArr;

@property (nonatomic, strong) NSMutableArray *cards;


@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *redView;
@property (nonatomic, strong) UIView *topCard; //最上面
@property (nonatomic, strong) UIView *bottomCard; //最底部

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
//    self.bgView.center = CGPointMake(ScreenW/2, ScreenH/2);
//    self.bgView.backgroundColor = [UIColor greenColor];
//    [self.view addSubview:self.bgView];
//    self.bgView.layer.masksToBounds = YES;
//    self.bgView.layer.cornerRadius = 50;
    
//    for (int i = 0; i < 5; i++) {
//        CircleView *circle = [[CircleView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
//        circle.center = CGPointMake(ScreenW/2, ScreenH/2);
//        circle.backgroundColor = [UIColor redColor];
//        circle.layer.masksToBounds = YES;
//        circle.layer.cornerRadius = 50;
//        circle.delayTime = 0.9*i;
//        [self.view addSubview:circle];
//    }
//
//    return;
    
    
    self.cards = [[NSMutableArray alloc] init];
    
    
    for (int i = 0; i < 4; i++) {
        
        UIView *card = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ImageWidth, ImageHeight)];
        card.tag = 100 + i;
        
        int index = i;
        if (index == 3) {
            index = 2;
        }
        
        card.center = CGPointMake(ScreenW/2, ScreenH/2 +(ImageHeight*ImageScale*index/2)+ ImageSpace*index);
        card.transform = CGAffineTransformMakeScale(1-ImageScale*index, 1-ImageScale*index);
        card.backgroundColor = self.dataArr[i];
        
        [self.cards addObject:card];
        
        [self.view addSubview:card];
        [self.view sendSubviewToBack:card];
        
        //添加拖动手势
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panHandle:)];
        [card addGestureRecognizer:pan];
        
        card.userInteractionEnabled = NO;
        if (i == 0) {
            card.userInteractionEnabled = YES;
            self.topCard = card;
        }else if (i == 3){
            self.bottomCard = card;
        }
        
    }
    
    UIButton *likeBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 600, 100, 50)];
    [likeBtn setTitle:@"LIKE" forState:0];
    likeBtn.backgroundColor = [UIColor greenColor];
    [self.view addSubview:likeBtn];
    [likeBtn addTarget:self action:@selector(likeBtnClick:) forControlEvents:64];
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(250, 600, 100, 50)];
    [cancelBtn setTitle:@"反悔" forState:0];
    cancelBtn.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:cancelBtn];
    [cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:64];
    

}

//返回，出现上张图片
- (void)cancelBtnClick:(UIButton *)sender {
    
    sender.userInteractionEnabled = NO;
    self.bottomCard.center = CGPointMake(-ImageWidth, ScreenH/2+50);
    self.bottomCard.transform = CGAffineTransformMakeRotation(-M_PI_4/2);
    [self.view bringSubviewToFront:self.bottomCard];
    
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.bottomCard.center = CGPointMake(ScreenW/2, ScreenH/2);
        self.bottomCard.transform = CGAffineTransformIdentity;
        
        for (UIView *card in self.cards) {

            if (card.tag != 102 && card.tag != 103) {

                NSInteger index = card.tag - 100 + 1;

                card.center = CGPointMake(ScreenW/2, ScreenH/2
                                          + ImageHeight*index*ImageScale/2
                                          + ImageSpace*index );

                CGFloat scale = 1- index*ImageScale;
                card.transform = CGAffineTransformMakeScale(scale, scale);
            }
        }
        
    }completion:^(BOOL finished) {
        
        sender.userInteractionEnabled = YES;
        [self backFinish];
    }];
}

//喜欢
- (void)likeBtnClick:(UIButton *)sender {

    sender.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.1 animations:^{
        
        self.topCard.center = CGPointMake(ScreenW/2 + 5, ScreenH/2);
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.topCard.center = CGPointMake(-ImageWidth, ScreenH/2+50);
            self.topCard.transform = CGAffineTransformMakeRotation(-M_PI_4/2);
            
            for (UIView *card in self.cards) {
                
                if (card.tag != 100 && card.tag != 103) {
                    
                    NSInteger index = card.tag - 100;
                    
                    card.center = CGPointMake(ScreenW/2, ScreenH/2
                                              + ImageHeight*index*ImageScale/2
                                              + ImageSpace*index //原始位置
                                              - ImageSpace
                                              - (ImageHeight*ImageScale*index/2)/index);
                    
                    CGFloat scale = 1-index*ImageScale + ImageScale;
                    card.transform = CGAffineTransformMakeScale(scale, scale);
                }
            }
            
        }completion:^(BOOL finished) {
            
            sender.userInteractionEnabled = YES;
            [self cardRemove];
        }];
    }];
}

-(void)panHandle:(UIPanGestureRecognizer *)pan{
    
    UIView *cardView = pan.view;

    if (pan.state == UIGestureRecognizerStateBegan) { //开始拖动
        
    }else if (pan.state == UIGestureRecognizerStateChanged) { //正在拖动
        
        CGPoint transLcation = [pan translationInView:cardView];
        cardView.center = CGPointMake(cardView.center.x + transLcation.x, cardView.center.y + transLcation.y);
        CGFloat XOffPercent = (cardView.center.x-ScreenW/2.0)/(ScreenW/2.0);
        CGFloat rotation = M_PI_2/4*XOffPercent;
        cardView.transform = CGAffineTransformMakeRotation(rotation);
        [pan setTranslation:CGPointZero inView:cardView];
        
        [self animationBlowViewWithXOffPercent:fabs(XOffPercent)];

        
    }else if (pan.state == UIGestureRecognizerStateEnded) { //松手了，拖动结束
        
        //视图不移除，原路返回
        if (cardView.center.x > 60 && cardView.center.x < ScreenW - 60) {
            [UIView animateWithDuration:0.25 animations:^{
                cardView.center = CGPointMake(ScreenW/2.0, ScreenH/2.0);
                cardView.transform = CGAffineTransformMakeRotation(0);
                [self animationBlowViewWithXOffPercent:0];
            }];
        }else{
            
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
                                      + (ImageHeight*ImageScale*index/2)
                                      + ImageSpace*index  //上面3行是原始位置，下面2行是改变的大小
                                      - XOffPercent*ImageSpace
                                      - (ImageHeight*ImageScale*index/2)*XOffPercent/index);
            
            CGFloat scale = 1-ImageScale*index + XOffPercent*ImageScale;
            card.transform = CGAffineTransformMakeScale(scale, scale);
        }
    }
    
}

-(void)cardRemove{
    
//    滑动结束第一张和放到数组最后
    [self.cards removeObject:self.topCard];
    [self.cards addObject:self.topCard];
    
//    重新设置tag
    for (int i = 0 ; i < 4; i++) {
        UIView *card = self.cards[i];
        card.tag = 100+i;
    }
    
    
//    重置第一张和最后一张（第4）
    self.topCard.userInteractionEnabled = NO;
    self.topCard.center = CGPointMake(ScreenW/2, ScreenH/2 + (ImageHeight*ImageScale*2/2) + ImageSpace*2);
    self.topCard.transform = CGAffineTransformMakeScale(1-ImageScale*2, 1-ImageScale*2);
    [self.view sendSubviewToBack:self.topCard];
    
    self.bottomCard = self.topCard;
    
    UIView *currentCard = self.cards.firstObject;
    currentCard.userInteractionEnabled = YES;
    self.topCard = currentCard;
    
}

- (void)backFinish {
    
    [self.cards removeObject:self.bottomCard];
    [self.cards insertObject:self.bottomCard atIndex:0];
    
    //    重新设置tag
    for (int i = 0 ; i < 4; i++) {
        UIView *card = self.cards[i];
        card.tag = 100+i;
    }
    
    
    //    重置第一张和最后一张（第4）
    self.bottomCard.userInteractionEnabled = YES;
    self.topCard = self.bottomCard;
    
    UIView *currentCard = self.cards.lastObject;
    currentCard.userInteractionEnabled = NO;
    self.bottomCard = currentCard;
    
}


-(NSMutableArray *)dataArr{
    if (!_dataArr) {
        
        _dataArr = [NSMutableArray new];
        [_dataArr addObject:[UIColor redColor]];
        [_dataArr addObject:[UIColor orangeColor]];
        [_dataArr addObject:[UIColor grayColor]];
        [_dataArr addObject:[UIColor brownColor]];
        [_dataArr addObject:[UIColor greenColor]];
        [_dataArr addObject:[UIColor purpleColor]];
        [_dataArr addObject:[UIColor redColor]];
        [_dataArr addObject:[UIColor orangeColor]];
        [_dataArr addObject:[UIColor grayColor]];
        [_dataArr addObject:[UIColor brownColor]];
        [_dataArr addObject:[UIColor greenColor]];
        [_dataArr addObject:[UIColor purpleColor]];
    }
    return _dataArr;
}

@end
