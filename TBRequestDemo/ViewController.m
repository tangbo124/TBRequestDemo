//
//  ViewController.m
//  TBRequestDemo
//
//  Created by TangBo on 15/2/13.
//  Copyright (c) 2015年 唐波. All rights reserved.
//

#import "ViewController.h"
#import "GetUserInfo.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GetUserInfo *userInfo = [[GetUserInfo alloc] init];
    [userInfo startTaskWithCompletionHandler:^(TBBaseRequest *request, NSError *error) {
        if (!error) {
            NSDictionary *dic = [request fetchDataWithRequest:request];
            NSLog(@"dic : %@", dic);
        }
    }];
}

- (void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
