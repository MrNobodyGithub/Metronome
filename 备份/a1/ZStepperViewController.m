//
//  ZStepperViewController.m
//  YYEKT
//
//  Created by 丞相@音乐 on 2017/2/9.
//  Copyright © 2017年 lin. All rights reserved.
//
typedef NS_ENUM(NSInteger,signatureType) {
    signatureType24 = 0,
    signatureType34 ,
    signatureType44 ,
    signatureType38 ,
    signatureType68
};
typedef NS_ENUM(NSInteger , toneProperty) {
    
    tonePropertyStrong  =0  ,   //重拍
    tonePropertyWeak        ,   //弱拍      1
    tonePropertyEleStrong   ,   //电子重拍
    tonePropertyEleWeak     ,   //电子弱拍   3
    tonePropertyDrumStrong  ,   //鼓重拍
    tonePropertyDrumWeak    ,   //鼓弱音     5
    tonePropertyWoodStrong  ,   //木鱼重拍
    tonePropertyWoodWeak    ,   //木鱼弱拍   7
    toneProperty001         ,
    toneProperty002         ,   //         9
    tonePropertyWrong       ,   //错误
    tonePropertyRotation        //旋转音效   11
};
#import "ZStepperViewController.h"
#import "ZStepperView.h"
#import "ZNewSteperView.h"
#import "ZChooseSignatureView.h"
#import <AVFoundation/AVFoundation.h>
#import "ZCustomNumberKeyboardView.h"
#define MAX_RADIAN (M_PI*88/5)
#define MIN_RADIAN (-M_PI*6/5)
#define ZSTEPPERSifnature @"zStepperSifnature"
#define ZSTEPPERSpeed @"zStepperSpeed"
@interface ZStepperViewController ()<AVAudioPlayerDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *midView;
@property (weak, nonatomic) IBOutlet UIButton *btnSignNumber;

@property (weak, nonatomic) IBOutlet UILabel *labSpeed;
@property (weak, nonatomic) IBOutlet UILabel *labSignature;

@property (weak, nonatomic) IBOutlet UIButton *btnImageWheel;
@property (weak, nonatomic) IBOutlet UIButton *btnImageHand;

@property (weak, nonatomic) IBOutlet UIButton *btnBeatSet;
@property (weak, nonatomic) IBOutlet UIButton *btnChangeMusic;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;

@property (weak, nonatomic) IBOutlet UIImageView *imageLeftSquare;
@property (weak, nonatomic) IBOutlet UIImageView *imageMidSquare;
@property (weak, nonatomic) IBOutlet UIImageView *imageRightSquare;

@property (assign ,nonatomic) signatureType signType;
@property (assign ,nonatomic) toneProperty tonePro;
//@property (weak ,nonatomic) ZStepperView * stepperView;
@property (weak ,nonatomic) ZNewSteperView * stepperView;
@property (strong, nonatomic) CADisplayLink *displayLink;
@property(strong, nonatomic)NSTimer * timer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AVAudioPlayer *zaudioPlayer;

@property (nonatomic ,weak) UIView * clickSpeedView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutAddLeft;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutMinusRight;
@property (nonatomic,assign)BOOL isFirstPaly;

@end
static double totalRadian;
static double zflagtotalRadian;

static double preRadian;

@implementation ZStepperViewController{
    int speed;                          //左上角 速度
    int flagSpeed;                      //
    BOOL flagIsPlaying;                 //播放状态
    NSInteger flagPatNumber;            //记录点击中间带尖 图 次数
    NSTimeInterval flagTimeInterval;    //点击中间 时间间隔；
    NSInteger flagSignUp;               //拍号 分子
    NSInteger flagSignDown;             //拍号 分母
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = YES;
    [self.tabBarController.tabBar setHidden:YES];
    [MobClick beginLogPageView:@"节拍器"];
//    self.btnImageHand
    if (iphone5) {
        self.layoutAddLeft.constant = 0;
        self.layoutMinusRight.constant = 0;
    }
 
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    self.navigationController.navigationBar.hidden = NO;
    [MobClick endLogPageView:@"节拍器"];
    [self.displayLink invalidate];
    self.displayLink = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setBaseProperty];
    [self setupStepperView];
}

- (void)setupStepperView{
    if (self.stepperView) {
        [self.stepperView removeFromSuperview];
    }
    CGFloat viewH = 50;
    ZNewSteperView *stepperView = [[ZNewSteperView alloc]init];
    stepperView.frame = CGRectMake(0, CGRectGetHeight(self.topView.frame)-viewH, MLScreenWidth, viewH); 
    stepperView.totalStep = flagSignUp;
    [stepperView setupImageList];
    [self.topView addSubview:stepperView];
    self.stepperView = stepperView;
}
- (void)setBaseProperty{
    [self setupAudioPlayer];
    [self.tabBarController.tabBar setHidden:YES];
    self.view.backgroundColor = MLGlobalBackgroundColor;
    NSString * speedStr = [[NSUserDefaults standardUserDefaults] valueForKey:ZSTEPPERSpeed];
    if (speedStr.length>0) {
        speed = [speedStr intValue];
    }else{
        speed=60;
    }
    self.labSpeed.text = [NSString stringWithFormat:@"%d",speed];
    flagIsPlaying=NO;
//    totalRadian = 0;
    totalRadian=(speed - 60)*M_PI*2/50;
    preRadian=0;
    _signType = signatureType44;
    flagPatNumber = 0;
    NSString * sifnatureStr =[[NSUserDefaults standardUserDefaults] valueForKey:ZSTEPPERSifnature];
    if (sifnatureStr.length>0) {
       NSArray * arr = [sifnatureStr componentsSeparatedByString:@"/"];
        self.labSignature.text = sifnatureStr;
        flagSignUp = [[arr firstObject] integerValue];
        flagSignDown = [[arr lastObject] integerValue];
    }else{
        self.labSignature.text = @"4/4";
        flagSignUp = 4;
        flagSignDown = 4;
    }
    _tonePro = tonePropertyWeak;
    //ui
    _btnBeatSet.layer.cornerRadius = 15;
    _btnBeatSet.layer.shadowOffset = CGSizeMake(0, 5);
    _btnBeatSet.layer.shadowRadius = 5;
    _btnBeatSet.layer.shadowColor = MLGlobalNavItemColor.CGColor;
    _btnBeatSet.layer.shadowOpacity =1;
    _btnChangeMusic.layer.cornerRadius = 15;
    _btnChangeMusic.layer.shadowOffset = CGSizeMake(0, 5);
    _btnChangeMusic.layer.shadowRadius = 5;
    _btnChangeMusic.layer.shadowColor = MLGlobalNavItemColor.CGColor;
    _btnChangeMusic.layer.shadowOpacity =1; 
    [_btnImageWheel setBackgroundImage:[UIImage imageNamed:@"wheel"] forState:UIControlStateHighlighted];
    [_btnImageHand setBackgroundImage:[UIImage imageNamed:@"hand_out"] forState:UIControlStateNormal];
    [_btnImageHand setBackgroundImage:[UIImage imageNamed:@"hand_in"] forState:UIControlStateHighlighted];
    //CADisplaylink
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateStep)]; 

//    self.displayLink.frameInterval = 60;
    [self KDealWithFrameinterval:60];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.displayLink.paused = YES;
    
    //nstime
    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateStep) userInfo:nil repeats:YES];
    [timer setFireDate:[NSDate distantFuture]];
    
}
- (void)updateStep{
    NSLog(@"---%@---",@"a");
    [self.stepperView nextStep];
    if (self.stepperView.step == 1) {
        [self playStepWithTone:_tonePro-1];
    }else{
        [self playStepWithTone:_tonePro];
    }
}
- (void)playStepWithTone:(toneProperty)tonePro{
    NSURL *url = [[NSURL alloc] init];
    NSString * toneName = @"节拍器001";
    switch (tonePro) {
        case toneProperty001:
            toneName = @"节拍器001";
            break;
        case toneProperty002:
            toneName = @"节拍器002";
            break;
        case tonePropertyWrong:
            toneName = @"节拍器错误";
            break;
        case tonePropertyWeak:
            toneName = @"节拍器弱拍";
            break;
        case tonePropertyStrong:
            toneName = @"节拍器重拍";
            break;
        case tonePropertyRotation:
            toneName = @"节拍器旋钮音效";
            break;
        case tonePropertyEleWeak:
            toneName = @"电子弱拍";
            break;
        case tonePropertyEleStrong:
            toneName = @"电子重拍";
            break;
        case tonePropertyDrumWeak:
            toneName = @"鼓弱拍";
            break;
        case tonePropertyDrumStrong:
            toneName = @"鼓重拍";
            break;
        case tonePropertyWoodWeak:
            toneName = @"木鱼弱拍";
            break;
        case tonePropertyWoodStrong:
            toneName = @"木鱼重拍";
            break;
        default:
            break;
    }
    
    url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:toneName ofType:@"wav"]];
    AVAudioPlayer * player =  [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    player.numberOfLoops = 0;//播放次数
    [player prepareToPlay];
    [player play];
    player.delegate = self;
    self.audioPlayer = player;
}
- (void)setupAudioPlayer{
    NSURL * url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"节拍器旋钮音效" ofType:@"wav"]];
    AVAudioPlayer * player =  [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    player.numberOfLoops = 0;//播放次数
    [player prepareToPlay];
    self.zaudioPlayer = player;
}

//- audioPlayerDidFinishPlaying
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [player stop];
    player = nil;
}
//top
- (IBAction)btnActionSpeed:(id)sender {
    [self priRestorePatNumber];
    [self playStepWithTone:toneProperty001];
    UIView * view = [[UIView alloc]initWithFrame:self.view.bounds];
    self.clickSpeedView = view;
    [self.view addSubview:view];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSpeedView)];
    UIView * shadowView = [[UIView alloc]initWithFrame:view.bounds];
    [shadowView addGestureRecognizer:tap];
    [view addSubview:shadowView];
    shadowView.backgroundColor = RGBAColor(0, 0, 0, 0.2);
    
    // w310 h350   left30 right30
    CGFloat keyboardViewX = 30;
    CGFloat keyboardViewW = MLScreenWidth-2*keyboardViewX;
    CGFloat keyboardViewH = keyboardViewW/310.0 * 350.0;
    ZCustomNumberKeyboardView * keyboardView = [[[NSBundle mainBundle]loadNibNamed:@"ZCustomNumberKeyboardView" owner:self options:nil]firstObject];
    keyboardView.frame = CGRectMake(keyboardViewX, MLScreenHeight - keyboardViewH, keyboardViewW, keyboardViewH);
    [view addSubview:keyboardView];
    [keyboardView show];
    keyboardView.callback = ^(NSString * speedStr){
        self.labSpeed.text = speedStr;
//        self.displayLink.frameInterval = 3600/([speedStr integerValue]);
        NSInteger integer = 3600/([speedStr integerValue]);
        
        speed = [speedStr intValue];
        [self KDealWithFrameinterval:integer];
        [view removeFromSuperview];
        
       [[NSUserDefaults standardUserDefaults] setValue:speedStr forKey:ZSTEPPERSpeed];
    };
    keyboardView.callbackForWrong = ^(NSInteger integer){
        if (integer == 0) {
            [self playStepWithTone:tonePropertyWrong];
        }else if (integer == 1){
            [view removeFromSuperview];
        }
    };
    //corner
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:keyboardView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer * shaperLay = [[CAShapeLayer alloc]init];
    shaperLay.frame = keyboardView.bounds;
    shaperLay.path = path.CGPath;
    keyboardView.layer.mask = shaperLay;
    keyboardView.clipsToBounds = YES;
}
- (void)tapSpeedView{
    [self.clickSpeedView removeFromSuperview];
}
- (IBAction)btnActionSignature:(id)sender {
    [self priRestorePatNumber];
    [self playStepWithTone:toneProperty001];
    UIView * view = [[UIView alloc]initWithFrame:self.view.bounds];
    self.clickSpeedView = view;
    [self.view addSubview:view];
         UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSpeedView)];
    UIView * shadowView = [[UIView alloc]initWithFrame:view.bounds];
    [shadowView addGestureRecognizer:tap];
    [view addSubview:shadowView];
    shadowView.backgroundColor = RGBAColor(0, 0, 0, 0.2);
    
    // 60 130
    CGFloat listViewW = 60;
    CGFloat listViewH = 130;
    CGFloat listViewX = CGRectGetMinX(_btnSignNumber.frame)-10;
    CGFloat listViewY = CGRectGetMaxY(_btnSignNumber.frame)+ CGRectGetMinY(_topView.frame);
    UIView * listView = [[UIView alloc]initWithFrame:CGRectMake(listViewX, listViewY, listViewW, listViewH)];
    [view addSubview:listView];
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:listView.bounds];
    [listView  addSubview:imageView];
    imageView.image = [UIImage imageNamed:@"chooseSignature"];
    NSArray * nameArr = @[@"2/4",@"3/4",@"4/4",@"3/8",@"6/8"];
    for (int i =0; i<5; i++) {
        CGFloat btnW = listViewW;
        CGFloat btnH = (listViewH-20)/5;
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 10+i*btnH, btnW, btnH)];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitle:nameArr[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClickForSifnature:) forControlEvents:UIControlEventTouchUpInside];
        [listView addSubview:btn];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    //temp
//    _signType ++;
//    if (_signType == 5) {
//        _signType = 0 ;
//    }
//    [self setupStepperView];
    //temp end
}
- (void)btnClickForSifnature:(UIButton *)btn{
    NSString * str = btn.titleLabel.text;
    [[NSUserDefaults standardUserDefaults] setValue:str forKey:ZSTEPPERSifnature];
    self.labSignature.text = str;
    NSArray * arr = [str componentsSeparatedByString:@"/"];
    flagSignUp = [[arr firstObject] integerValue];
    flagSignDown = [[arr lastObject] integerValue];
    [self setupStepperView];
    [self performSelector:@selector(tapSpeedView)];
}

//mid
- (IBAction)btnActionUpWheel:(UIButton *)sender forEvent:(UIEvent *)event {
    preRadian=0;
    if (totalRadian>MAX_RADIAN) {
        [UIView animateWithDuration:0.5 animations:^{
            self.btnImageWheel.transform = CGAffineTransformRotate(self.btnImageWheel.transform, MAX_RADIAN-totalRadian);
        } completion:^(BOOL finished) {
            totalRadian = MAX_RADIAN;
        }];
    }
    if (totalRadian<MIN_RADIAN) {
        [UIView animateWithDuration:0.5 animations:^{
            self.btnImageWheel.transform = CGAffineTransformRotate(self.btnImageWheel.transform, MIN_RADIAN-totalRadian);
        } completion:^(BOOL finished) {
            totalRadian = MIN_RADIAN;
        }];
    }
}
- (IBAction)btnActionDrayWheel:(UIButton *)sender forEvent:(UIEvent *)event {
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];

//    NSLog(@"--point--%@",NSStringFromCGPoint(point));
    CGPoint center = CGPointMake(sender.center.x, sender.center.y+CGRectGetMinY([sender superview].frame)) ;
    double angle= [self getAngleFromPoint:center toPoint:point];
//    YYEKTLog(@"之前弧度%f，新弧度%f，弧度差%f,总弧度%f",preRadian,angle,angle-preRadian,totalRadian);
    if (preRadian==0) {
    } else {
        //计算 弧度
        if (center.x <= point.x) {
            totalRadian -= angle-preRadian;
        } else {
            totalRadian += angle-preRadian;
        }
        //旋转
        //+- 与wheel 有关系
//        self.btnImageWheel.transform = CGAffineTransformMakeRotation(totalRadian);
          //+- 与wheel 无关系
        if (!zflagtotalRadian) {
            zflagtotalRadian = totalRadian;
        }
        self.btnImageWheel.transform = CGAffineTransformRotate(self.btnImageWheel.transform, (totalRadian-zflagtotalRadian));
        zflagtotalRadian = totalRadian;
        
        
        //展示 速度
        speed = 60 + totalRadian/M_PI*50/2;
        [self setSpeed:speed];
        
        if (speed != flagSpeed) {
//            [self playStepWithTone:tonePropertyRotation]; 
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self.zaudioPlayer play];
                });
            
        }
        flagSpeed = speed;
    }
    preRadian =angle;
}
- (IBAction)btnActionPat:(id)sender {
    if (flagIsPlaying) {
        flagIsPlaying = !flagIsPlaying;
        self.displayLink.paused = YES;
        NSString * imageNamePlay = @"playRed";
        [self.btnPlay setBackgroundImage:[UIImage imageNamed:imageNamePlay] forState:UIControlStateNormal];
    }
 
    flagPatNumber ++;
    //timeDif
    NSTimeInterval timeInterval = [NSDate timeIntervalSinceReferenceDate];
    if (flagPatNumber == 1) {
        flagTimeInterval = timeInterval;
    }else if (flagPatNumber ==4){
        timeInterval -= flagTimeInterval;
        timeInterval/=3;
        
        int abc = (int)(60.0/timeInterval);
        if (abc<30) {
            abc = 30;
        }else if (abc>500){
            abc = 500;
        }
        speed = abc;
        self.labSpeed.text = [NSString stringWithFormat:@"%d",abc];
//        self.displayLink.frameInterval = 3600/abc;
        NSInteger integer  = 3600/abc;
        [self KDealWithFrameinterval:integer];
    }
    
    //UI
    if (flagPatNumber==4) {
        flagPatNumber = 0;
        [self btnActionPlay:nil];
    }
    [self showImageWithTotal:flagPatNumber];
    //func
    
}
- (void)showImageWithTotal:(NSInteger)integer{
    NSString * imageName = @"squareBlue";
    NSString * imageNameFull = @"squareBlueFull";
    if (integer == 1) {
        _imageLeftSquare.image = [UIImage imageNamed:imageNameFull];
        _imageMidSquare.image = [UIImage imageNamed:imageName];
        _imageRightSquare.image = [UIImage imageNamed:imageName];
    }else if(integer == 2){
        _imageLeftSquare.image = [UIImage imageNamed:imageNameFull];
        _imageMidSquare.image = [UIImage imageNamed:imageNameFull];
        _imageRightSquare.image = [UIImage imageNamed:imageName];
    }else if(integer == 3){
        _imageLeftSquare.image = [UIImage imageNamed:imageNameFull];
        _imageMidSquare.image = [UIImage imageNamed:imageNameFull];
        _imageRightSquare.image = [UIImage imageNamed:imageNameFull];
    }else{
        _imageLeftSquare.image = [UIImage imageNamed:imageName];
        _imageMidSquare.image = [UIImage imageNamed:imageName];
        _imageRightSquare.image = [UIImage imageNamed:imageName];
    }
}
- (IBAction)btnActionDecrease:(id)sender {
    [self playStepWithTone:toneProperty001];
    [self setSpeed:--speed];
    totalRadian=(speed - 60)*M_PI*2/50;
//    self.btnImageWheel.transform = CGAffineTransformMakeRotation(totalRadian);
}
- (IBAction)btnActionIncrease:(id)sender {
    [self playStepWithTone:toneProperty001];
    [self setSpeed:++speed];
    totalRadian=(speed - 60)*M_PI*2/50;
//    self.btnImageWheel.transform = CGAffineTransformMakeRotation(totalRadian);
}
//down
- (IBAction)btnActionPlay:(id)sender {
    [self priRestorePatNumber];
    
    if (!self.isFirstPaly) {
        self.isFirstPaly = YES;
        NSString * speedStr = [[NSUserDefaults standardUserDefaults] valueForKey:ZSTEPPERSpeed];
        [self playStepWithTone:toneProperty001];
        [self setSpeed:[speedStr intValue]];
    }
    
    
    
    flagIsPlaying = !flagIsPlaying;
    NSString * imageNamePlay = @"playRed";
    NSString * imageNamePause = @"pauseRed";
    if (flagIsPlaying) {//当前为播放状态
        if (speed >= 30 && speed<60) {
            [self kResetTimer];
        }else{
            self.displayLink.paused = NO;
        }
        [self.btnPlay setBackgroundImage:[UIImage imageNamed:imageNamePause] forState:UIControlStateNormal];
    }else{
        if (speed >= 30 && speed<60) {
            [self kinvalidateTimer];
        }else{
            self.displayLink.paused = YES;
        }
        [self.btnPlay setBackgroundImage:[UIImage imageNamed:imageNamePlay] forState:UIControlStateNormal];
    }
}
- (IBAction)btnActionBeatSet:(UIButton *)sender {
    [self priRestorePatNumber];
    [self playStepWithTone:toneProperty001];
    UIView * view = [[UIView alloc]initWithFrame:self.view.bounds];
    self.clickSpeedView = view;
    [self.view addSubview:view];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSpeedView)];
    UIView * shadowView = [[UIView alloc]initWithFrame:view.bounds];
    [shadowView addGestureRecognizer:tap];
    [view addSubview:shadowView];
    shadowView.backgroundColor = RGBAColor(0, 0, 0, 0.2);
    
    ZChooseSignatureView * chooseView = [[[NSBundle mainBundle]loadNibNamed:@"ZChooseSignatureView" owner:self options:nil]firstObject];
    chooseView.callbackForVideo = ^(){
        [self playStepWithTone:toneProperty001];
    };
    chooseView.callback = ^(NSInteger rowLeft,NSInteger rowRight){
        [self playStepWithTone:toneProperty001];
        if (rowLeft==0 && rowRight==0) {
            
        } else{ 
            flagSignUp = rowLeft+1;
            flagSignDown =rowRight; 
            [self setupStepperView];
            NSString * str = [NSString stringWithFormat:@"%ld/%ld",(long)flagSignUp,(long)flagSignDown];
            self.labSignature.text = str;
             [[NSUserDefaults standardUserDefaults] setValue:str forKey:ZSTEPPERSifnature];
        }
        [view removeFromSuperview];
    };
    chooseView.backgroundColor = [UIColor clearColor];
    CGFloat chooseViewH = 300;
    chooseView.frame = CGRectMake(0, MLScreenHeight-chooseViewH, MLScreenWidth, chooseViewH);
    [view addSubview:chooseView]; 
}
- (IBAction)btnActioChangeMusic:(id)sender {
    [self priRestorePatNumber];
    _tonePro += 2;
    if (_tonePro>7) {
        _tonePro = 0;
    }
    if (_tonePro/2 == 1) {
        _tonePro = tonePropertyEleWeak;
    }else if (_tonePro/2 == 2){
        _tonePro = tonePropertyDrumWeak;
    }else if (_tonePro/2 == 3){
        _tonePro = tonePropertyWoodWeak;
    }else if (_tonePro/2 == 0){
        _tonePro = tonePropertyWeak;
    }else{ 
        _tonePro = tonePropertyWeak;
    }
    [self playStepWithTone:_tonePro];
}

- (IBAction)quit:(id)sender {
//    [self playStepWithTone:toneProperty001];
    [self.displayLink invalidate];
    self.displayLink = nil;
    [self kinvalidateTimer];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)dealloc{
    
    [self.displayLink invalidate];
    self.displayLink = nil;
    [self kinvalidateTimer];
}


#pragma mark- UIPickerViewDataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}
// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 1;
}
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return @"a";
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view {
    return nil;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
}
#pragma mark- --------------------
//展示速度
 
- (void)setSpeed:(int)mySpeed{
     if (mySpeed>500) {
         speed = 500;
    } else if(mySpeed<30) {
        speed = 30;
    }
    _labSpeed.text = [NSString stringWithFormat:@"%d",speed];
//    self.displayLink.frameInterval = 3600/speed;
    NSInteger integer = 3600 / speed;
    [self KDealWithFrameinterval:integer];
     [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",speed] forKey:ZSTEPPERSpeed];
   
//    self.displayLink.preferredFramesPerSecond = 3600/speed;
}
- (double)getAngleFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint{
    //两点的x、y值
    double x = (double)(toPoint.x-fromPoint.x);
    double y = (double)(toPoint.y-fromPoint.y);
    //斜边长度
    double hypotenuse =(double) sqrt(fabs(x*x)+fabs(y*y));
    //求余弦
    double sin =(double)y/(double)hypotenuse;
    //求弧度
    double radian = (double)acos(sin);
    
//    double radian = atan2(x, y);
//    NSLog(@"--radian-- %f",radian);
    return radian;
}
- (void)priRestorePatNumber{
    //还原 三个
    if (flagPatNumber != 0) {
        [self showImageWithTotal:0];
    }
      flagPatNumber = 0;
}
- (void)KDealWithFrameinterval:(NSInteger )integer{
    
    if (integer > 60) {
        self.displayLink.paused = YES;
        [self kResetTimer];
    }else{
        [self kinvalidateTimer];
        if (flagIsPlaying) {
            self.displayLink.paused = NO;
        } else{
            self.displayLink.paused = YES;
        }
    self.displayLink.frameInterval = integer;
    }
}
- (void)kinvalidateTimer{
    if (self.timer) {
        [self.timer invalidate];
        self.timer  = nil;
    }
}
- (void)kResetTimer{
    if (flagIsPlaying) {
        if (self.timer) {
            [self.timer invalidate];
            self.timer  = nil;
        }
        NSTimeInterval interval = 60.0 / (1.0 * speed);
        NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:interval repeats:YES block:^(NSTimer * _Nonnull timer) {
            [self updateStep];
        }];
        self.timer  = timer;
        [timer fire];
    }
    
}

@end
