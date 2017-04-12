//
//  ZCustomNumberKeyboardView.h
//  YYEKT
//
//  Created by 丞相@音乐 on 2017/2/10.
//  Copyright © 2017年 lin. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ZCustomNumberKeyboardView : UIView
@property(nonatomic,copy) void(^callback)(NSString * str);
@property(nonatomic,copy) void(^callbackForWrong)(NSInteger integer);
- (void)show;
@end
