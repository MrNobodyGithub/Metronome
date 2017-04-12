//
//  ZChooseSignatureView.h
//  YYEKT
//
//  Created by 丞相@音乐 on 2017/2/13.
//  Copyright © 2017年 lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZChooseSignatureView : UIView

@property(nonatomic,copy) void ((^callback)(NSInteger integer,NSInteger zinteger));

@end
