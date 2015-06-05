//
//  GetUserInfo.m
//  TBRequestDemo
//
//  Created by TangBo on 15/2/13.
//  Copyright (c) 2015年 唐波. All rights reserved.
//

#import "GetUserInfo.h"

@implementation GetUserInfo

- (id)requestArgument
{
    return @{@"rd": @(214),
             @"ptd":@(1114)
             };
}

- (TBRequestMethod)requestMethod
{
    return TBRequestMethodPost;
}

//- (NSInteger)cacheTimeInSeconds
//{
//    return 60 * 3;//3分钟
//}

- (TBResponseSerializer)responseSerializer
{
    return TBHTTPResponseSerializer;
}

- (id)fetchDataWithRequest:(TBBaseRequest *)request
{
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:request.responseObject options:NSJSONReadingMutableContainers error:nil];
    return dic;
}

- (void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}
@end
