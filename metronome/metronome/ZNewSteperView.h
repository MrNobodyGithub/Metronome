//
//  ZNewSteperView.h
//  YYEKT
//
//  Created by 丞相@音乐 on 2017/2/14.
//  Copyright © 2017年 lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZNewSteperView : UIView

@property (assign, nonatomic) NSInteger step;
@property (assign, nonatomic) NSInteger totalStep;
- (void)setupImageList;
- (void)nextStep;
@end
