//
//  ZChooseSignatureView.m
//  YYEKT
//
//  Created by 丞相@音乐 on 2017/2/13.
//  Copyright © 2017年 lin. All rights reserved.
//

#import "ZChooseSignatureView.h"
@interface ZChooseSignatureView ()<UIPickerViewDataSource,UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageBack;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (nonatomic , strong)NSArray * arrComponent;

@property (nonatomic,copy) NSString * ztest;

@end
@implementation ZChooseSignatureView
{
    NSInteger flagRowLeft;
    NSInteger flagRowRight;
}
-(NSArray *)arrComponent{
    if (!_arrComponent) {
//        NSArray * arr = @[@"2",@"4",@"8",@"16"];
//        _arrComponent = [NSArray arrayWithArray:arr];
        _arrComponent = @[@"2",@"4",@"8",@"16"];
     }
    return _arrComponent;
}
- (void)awakeFromNib{
    [super awakeFromNib];
    [self setDefaultValue];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBackImage)];
    self.imageBack.userInteractionEnabled = YES;
    
    [self.imageBack addGestureRecognizer:tap];
    self.pickerView.showsSelectionIndicator = YES;
    self.pickerView.delegate = self;
    self.pickerView.dataSource =self;
    self.pickerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"signaturePicker"]];
}
- (void)setDefaultValue{
    flagRowLeft = 0;
    flagRowRight =[self.arrComponent[0] integerValue];
}
- (IBAction)btnActionArrowDown:(UIButton *)sender forEvent:(UIEvent *)event {
    self.callback(flagRowLeft,flagRowRight);
}
- (void)tapBackImage{
    
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 0) {
        return 16;
    }else if (component ==1){
        return 4;
    }
    return 16;
}
//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
//    return 20;
//}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40;
}
//- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
//    NSString * str = [NSString stringWithFormat:@"%ld",row+1];
//    return str;
//}
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component == 0) {
        NSString * str = [NSString stringWithFormat:@"%ld",row+1];
        NSDictionary *attributeDict = [NSDictionary dictionaryWithObjectsAndKeys: [UIFont systemFontOfSize:15.0],NSFontAttributeName,nil];
        NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:str attributes:attributeDict];
        return  AttributedStr;
    }else if (component ==1){
//        NSString * str = [NSString stringWithFormat:@"%ld",row+1];
        NSString * str = self.arrComponent[row];
        NSDictionary *attributeDict = [NSDictionary dictionaryWithObjectsAndKeys: [UIFont systemFontOfSize:15.0],NSFontAttributeName,nil];
        NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:str attributes:attributeDict];
        return  AttributedStr;
    }else{
        
        NSString * str = [NSString stringWithFormat:@"%ld",row+1];
        NSDictionary *attributeDict = [NSDictionary dictionaryWithObjectsAndKeys: [UIFont systemFontOfSize:15.0],NSFontAttributeName,nil];
        NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:str attributes:attributeDict];
        return  AttributedStr;
    }
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (component ==0) {
        flagRowLeft = row;
    }else if (component == 1){
//        flagRowRight = row;
        flagRowRight = [self.arrComponent[row] integerValue];
    }
}
@end
