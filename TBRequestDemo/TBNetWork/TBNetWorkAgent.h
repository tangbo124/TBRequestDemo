//
//  TBNetWorkAgent.h
//  TBRequestDemo
//
//  Created by tangbo on 15/5/25.
//  Copyright (c) 2015年 唐波. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBBaseRequest.h"
@interface TBNetWorkAgent : NSObject
+(instancetype)shareInstance;
- (void)addRequest:(TBBaseRequest *)request;
- (void)removeRequest:(TBBaseRequest *)request;
@end
