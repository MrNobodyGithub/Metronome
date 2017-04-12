//
//  ViewController.m
//  metronome
//
//  Created by shmily on 2017/4/12.
//  Copyright © 2017年 zlz. All rights reserved.
//

#import "ViewController.h"
#import "ZStepperViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)btnAction:(id)sender {
    ZStepperViewController * vc = [[ZStepperViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
