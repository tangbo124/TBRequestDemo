//
//  TBNetworkConfig.h
//  TBRequestDemo
//
//  Created by TangBo on 15/2/13.
//  Copyright (c) 2015年 唐波. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBNetworkConfig : NSObject

@property (nonatomic, copy) NSString *baseUrl;

+(instancetype)defaultConfig;

@end
