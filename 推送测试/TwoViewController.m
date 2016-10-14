//
//  TwoViewController.m
//  推送测试
//
//  Created by imac on 2016/10/14.
//  Copyright © 2016年 imac. All rights reserved.
//

#import "TwoViewController.h"
#import "OneViewController.h"
@interface TwoViewController ()

@end

@implementation TwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"推送的消息控制器";
    self.view.backgroundColor = [UIColor yellowColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(disMissVcMethod)];

}

#warning 控制器消失
-(void)disMissVcMethod{

   [self.navigationController dismissViewControllerAnimated:YES completion:^{
       
   }];

}

@end
