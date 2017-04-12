//
//  ZCustomNumberKeyboardView.m
//  YYEKT
//
//  Created by 丞相@音乐 on 2017/2/10.
//  Copyright © 2017年 lin. All rights reserved.
//

#import "ZCustomNumberKeyboardView.h"
@interface ZCustomNumberKeyboardView ()
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *topLab;
@property (weak, nonatomic) IBOutlet UIView *downView;
@property (weak, nonatomic) IBOutlet UIView *shaView;
@property (weak, nonatomic) IBOutlet UIImageView *shaImage;

@property (strong ,nonatomic)NSArray * numberArr;

@end
@implementation ZCustomNumberKeyboardView{
    NSInteger totalInteger;
    NSInteger totalIntegerNumber;
    NSInteger flagNumber;
}
- (void)awakeFromNib{
    [super awakeFromNib]; 
//    [self setupNumberKeyboard];
    totalIntegerNumber = 0;
    totalInteger =0;
    flagNumber = 0;
    
    _shaImage.layer.cornerRadius = 5; 
    
    _downView.backgroundColor = [UIColor clearColor];
    _topView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"keyShow"]];
}
- (void)show{
    [self setupNumberKeyboard];
}
- (void)setupNumberKeyboard{
    // left right 6 up down 6  interval 3
    CGFloat interval = 3;
    CGFloat width =  self.frame.size.width - 40 - 12;
    CGFloat height = self.frame.size.height - 55 - 12;
//    CGFloat width = CGRectGetWidth(self.downView.frame);
//    CGFloat height = CGRectGetHeight(self.downView.frame);
    for (int i =0; i<12; i++) {
        CGFloat btnW = (width -2* interval)/3;
        CGFloat btnH = (height - 3* interval)/4;
        CGFloat btnX = i%3 * (btnW+interval);
        CGFloat btnY = i/3 * (btnH+interval);
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(btnX, btnY, btnW, btnH)];
        [self.downView addSubview:btn];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:[self.numberArr objectAtIndex:i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"keyboard_out"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"keyboard_in"] forState:UIControlStateHighlighted];
    }
}
- (void)btnClick:(UIButton *)btn{
    NSString * str = btn.titleLabel.text;
    if ([str isEqualToString:@"C"]) {
        totalIntegerNumber = 0;
        totalInteger = 0;
        self.topLab.text = @"0";
        flagNumber = 0;
    }else if ([str isEqualToString:@"确定"]){
        if (totalInteger>500) {
//            totalInteger =500;
        }else if (totalInteger<30&&totalInteger>0){
            self.callbackForWrong(0);
            return;
        }else if (totalInteger ==0){
            self.callbackForWrong(1);
        }else{
            NSString * strForZ =[NSString stringWithFormat:@"%lu",totalInteger];
            self.callback(strForZ);
        }
    }else{
        NSInteger integer = [str integerValue];
        totalIntegerNumber++;
        [self calculateWith:totalIntegerNumber and:integer];
    }
}
- (void)calculateWith:(NSInteger)count and:(NSInteger)number{
    //    NSLog(@"--ldexp--%lf",ldexp(10, number));
//    totalInteger = pow(10, (count-1))*number + flagNumber;
    totalInteger =  number + flagNumber *10;
    if (totalInteger>500) {
        self.topLab.text = [NSString stringWithFormat:@"%ld",(long)flagNumber];
        return;
    }else{
        self.topLab.text = [NSString stringWithFormat:@"%ld",(long)totalInteger];
    }
    flagNumber = totalInteger;
}
-(NSArray *)numberArr{
    if (!_numberArr) {
        _numberArr = [NSArray arrayWithObjects:@"7",@"8",@"9",@"4",@"5",@"6",@"1",@"2",@"3",@"C",@"0",@"确定", nil];
    }
    return _numberArr;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
