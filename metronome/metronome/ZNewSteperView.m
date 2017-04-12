//
//  ZNewSteperView.m
//  YYEKT
//
//  Created by 丞相@音乐 on 2017/2/14.
//  Copyright © 2017年 lin. All rights reserved.
//

#import "ZNewSteperView.h"
static NSString * blueImageName = @"blueKey";
static NSString * redImageName  = @"redKey";

#define MLScreenWidth         [UIScreen mainScreen].bounds.size.width
@implementation ZNewSteperView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)setupImageList{
    if (!self.step) {
        self.step = 0;
    }
    if (!self.totalStep) {
        self.totalStep = 4;
    }
    CGFloat leftInteger = 20;
    CGFloat Width = MLScreenWidth - leftInteger *2;
    CGFloat viewH = self.frame.size.height;//50;
    //间隙 占比0.15；
    CGFloat customRatio = 0.15;
    CGFloat imgW = Width/(_totalStep * (1+customRatio) - customRatio);
    CGFloat inteval = imgW * customRatio;
    for (int i =0; i<self.totalStep; i++) {
        UIImageView * imageView = [[UIImageView alloc]init];
        imageView.frame = CGRectMake(leftInteger+ 0+i*(imgW+inteval), 0, imgW, viewH);
        [self addSubview:imageView];
        imageView.image = [UIImage imageNamed:redImageName];
        if (i == 0) {
//            imageView.image = [UIImage imageNamed:blueImageName];
        }
        imageView.tag = 100+i;
    }
}
- (void)nextStep{
    if (!self.step) {
        self.step = 0;
    }
    if (!self.totalStep) {
        self.totalStep = 4;
    }
    _step++;
    if (_step > _totalStep) {
        _step = 1;
    }
    
    //100 101 ..
    for (int i =0; i<_totalStep; i++) {
        UIImageView * imageV = (UIImageView *)[self viewWithTag:(100+i)];
        imageV.image = [UIImage imageNamed:redImageName];
    }
    
    UIImageView * imageV = (UIImageView *)[self viewWithTag:(100+_step-1)];
    imageV.image = [UIImage imageNamed:blueImageName];
}
@end
