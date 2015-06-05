//
//  TBNetWorkAgent.m
//  TBRequestDemo
//
//  Created by tangbo on 15/5/25.
//  Copyright (c) 2015年 唐波. All rights reserved.
//

#import "TBNetWorkAgent.h"
#import "TBBaseRequest.h"
#import "AFNetworking.h"
#import "TBNetworkConfig.h"

@implementation TBNetWorkAgent
{
    AFHTTPRequestOperationManager *_manager;
    NSMutableDictionary *_requestsRecord;
}
+(instancetype)shareInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _manager = [AFHTTPRequestOperationManager manager];
        _requestsRecord = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSMutableURLRequest *)generateRequestWithRequestMethod:(TBBaseRequest *)request
{
    TBRequestMethod method = [request.child requestMethod];
    NSString *requestUrl = [self p_buildRequestUrl:request];
    id param = [request.child requestArgument];
    NSString *methodStr = @"GET";
    switch (method) {
        case TBRequestMethodGet:
            methodStr = @"GET";
            break;
        case TBRequestMethodPost:
            methodStr = @"POST";
            break;
        case TBRequestMethodPut:
            methodStr = @"PUT";
            break;
        case TBRequestMethodDelete:
            methodStr = @"DELETE";
            break;
        case TBRequestMethodHead:
            methodStr = @"HEAD";
            break;
        case TBRequestMethodPatch:
            methodStr = @"PATCH";
            break;
        default:
            break;
    }
    
    NSError *error = nil;
    
    NSMutableURLRequest *methodRequest = [_manager.requestSerializer requestWithMethod:methodStr URLString:requestUrl parameters:param error:&error];
    if (error) {
        NSLog(@"创建reqeust失败");
        return nil;
    }
    return methodRequest;
}

- (void)addRequest:(TBBaseRequest *)request
{
    if ([request.child requestSerializer] == TBHTTPRequestSerializer) {
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    }else if([request.child requestSerializer] == TBJSONRequestSerializer){
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    if ([request.child responseSerializer] == TBHTTPResponseSerializer) {
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }else if ([request.child responseSerializer] == TBJSONRequestSerializer){
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    _manager.requestSerializer.timeoutInterval = [request.child requestTimeoutInterval];
    
    NSMutableURLRequest *methodRequst = [self generateRequestWithRequestMethod:request];
    
    AFHTTPRequestOperation *operation = [_manager HTTPRequestOperationWithRequest:methodRequst success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self p_handleRequestOperation:operation error:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self p_handleRequestOperation:operation error:error];
    }];
    
    request.requestOperation = operation;
    
    [_manager.operationQueue addOperation:operation];
    
    [self addOperation:request];
}
/*
- (void)addRequest:(TBBaseRequest *)request {
    TBRequestMethod method = [request requestMethod];
    NSString *requestUrl = [self p_buildRequestUrl:request];
    id param = [request requestArgument];
    if ([request requestSerializer] == TBHTTPRequestSerializer) {
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    }else if([request requestSerializer] == TBJSONRequestSerializer){
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    if ([request responseSerializer] == TBHTTPResponseSerializer) {
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }else if ([request responseSerializer] == TBJSONRequestSerializer){
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    _manager.requestSerializer.timeoutInterval = [request requestTimeoutInterval];
    if (method == TBRequestMethodGet) {
        request.requestOperation = [_manager GET:requestUrl parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self p_handleRequestOperation:operation error:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self p_handleRequestOperation:operation error:error];
        }];
    }else if(method == TBRequestMethodPost){
        request.requestOperation = [_manager POST:requestUrl parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self p_handleRequestOperation:operation error:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self p_handleRequestOperation:operation error:error];
        }];
    }else if (method == TBRequestMethodPut){
        request.requestOperation = [_manager PUT:requestUrl parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self p_handleRequestOperation:operation error:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self p_handleRequestOperation:operation error:error];
        }];
    }else if (method == TBRequestMethodHead){
        request.requestOperation = [_manager HEAD:requestUrl parameters:param success:^(AFHTTPRequestOperation *operation) {
            [self p_handleRequestOperation:operation error:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self p_handleRequestOperation:operation error:error];
        }];
    }else if (method == TBRequestMethodDelete){
        request.requestOperation = [_manager DELETE:requestUrl parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self p_handleRequestOperation:operation error:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self p_handleRequestOperation:operation error:error];
        }];
    }else if (method == TBRequestMethodPatch){
        request.requestOperation = [_manager PATCH:requestUrl parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self p_handleRequestOperation:operation error:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self p_handleRequestOperation:operation error:error];
        }];
    }
    [self addOperation:request];
}
*/
- (void)removeRequest:(TBBaseRequest *)request
{
    [request.requestOperation cancel];
    [self removeOperation:request.requestOperation];
}

- (NSString *)p_buildRequestUrl:(TBBaseRequest *)request
{
    TBNetworkConfig *config = [TBNetworkConfig defaultConfig];
    NSString *url = [request.child requestUrl];
    NSString *baseUrl = config.baseUrl;
    if (baseUrl.length > 0) {
        if (url.length > 0) {
            NSString *requestUrl =[NSString stringWithFormat:@"%@/%@", baseUrl, url];
            return requestUrl;
        }else
            return baseUrl;
    }
    return nil;
}

- (void)p_handleRequestOperation:(AFHTTPRequestOperation *)operation error:(NSError *)error
{
    NSString *key = [self requestHashKey:operation];
    TBBaseRequest *request = _requestsRecord[key];
    request.responseObject = operation.responseObject;
    request.responseString = operation.responseString;
    [request saveResponseToCache:operation.responseObject];
    if (request.completionHandler) {
        request.completionHandler(request, error);
    }else if (request.completionWithCacheHandler) {
        request.completionWithCacheHandler(request, error, NO);
    }
    
    [self removeOperation:operation];
}

- (NSString *)requestHashKey:(AFHTTPRequestOperation *)operation {
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)[operation hash]];
    return key;
}

- (void)addOperation:(TBBaseRequest *)request {
    if (request.requestOperation != nil) {
        NSString *key = [self requestHashKey:request.requestOperation];
        _requestsRecord[key] = request;
    }
}

- (void)removeOperation:(AFHTTPRequestOperation *)operation {
    NSString *key = [self requestHashKey:operation];
    [_requestsRecord removeObjectForKey:key];
}
@end
