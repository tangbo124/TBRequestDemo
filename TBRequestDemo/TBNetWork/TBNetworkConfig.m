//
//  TBNetworkConfig.m
//  TBRequestDemo
//
//  Created by TangBo on 15/2/13.
//  Copyright (c) 2015年 唐波. All rights reserved.
//

#import "TBNetworkConfig.h"

@implementation TBNetworkConfig

+(instancetype)defaultConfig
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}
@end
