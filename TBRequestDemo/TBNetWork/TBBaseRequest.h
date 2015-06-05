//
//  TBBaseRequest.h
//  TBRequestDemo
//
//  Created by TangBo on 15/2/13.
//  Copyright (c) 2015年 唐波. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AFHTTPRequestOperation;
@class TBBaseRequest;

typedef void(^CompletionHandlerBlock)(TBBaseRequest *request, NSError *error);

typedef void(^CompletionHandlerWithCacheBlock)(TBBaseRequest *request, NSError *error, BOOL isInCache);

/**
 *  请求类型
 */
typedef NS_ENUM(NSInteger, TBRequestMethod){
    /**
     *  get请求, 默认
     */
    TBRequestMethodGet = 0,
    /**
     *  post请求
     */
    TBRequestMethodPost,
    /**
     *  put请求
     */
    TBRequestMethodPut,
    /**
     *  delete请求
     */
    TBRequestMethodDelete,
    /**
     *  head请求
     */
    TBRequestMethodHead,
    /**
     *  patch请求
     */
    TBRequestMethodPatch
};

typedef NS_ENUM(NSInteger, TBRequestSerializer){
    TBHTTPRequestSerializer = 0,
    TBJSONRequestSerializer
};

typedef NS_ENUM(NSInteger, TBResponseSerializer){
    TBHTTPResponseSerializer = 0,
    TBJSONResponseSerializer
};

@protocol RequestAPIManager <NSObject>

@optional
/**
 *取消请求
 */

- (void)cancelRequest;

/**
 *  请求类型, 子类需继承
 *
 *  @return 请求类型
 */
- (TBRequestMethod)requestMethod;

/**
 *  网络请求参数, 子类需继承
 *
 *  @return 请求参数, 返回类型一般是字典
 */
- (id)requestArgument;

/**
 *  网络请求的url
 *
 *  @return 网络请求的url
 */
- (NSString *)requestUrl;

/**
 *  缓存过期时间, 要想实现缓存功能, 子类需继承
 *
 *  @return 缓存过期时间
 */
- (NSInteger)cacheTimeInSeconds;

/**
 *  请求超时时间, 默认60秒, 子类可选继承
 *
 *  @return 请求超时时间
 */
- (NSTimeInterval)requestTimeoutInterval;

- (TBRequestSerializer)requestSerializer;

- (TBResponseSerializer)responseSerializer;

@end

@interface TBBaseRequest : NSObject

@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;

@property (nonatomic, copy) CompletionHandlerBlock completionHandler;

@property (nonatomic, copy) CompletionHandlerWithCacheBlock completionWithCacheHandler;

@property (nonatomic, copy) NSString *responseString;

@property (nonatomic, strong) id responseObject;

@property(nonatomic, weak) id<RequestAPIManager> child;
/**
 *  普通的数据请求
 *
 *  @param completionHandler 请求成功的回调
 */
- (void)startTaskWithCompletionHandler:(CompletionHandlerBlock)completionHandler;

/**
 *  带缓存的请求, 这个缓存没有过期时间, 用来实现在网络请求还没有返回时, 先加载缓存的功能
 *
 *  @param completionHandler 请求成功的回调, 通过isInCache参数判断当前的数据是来自缓存还是网络请求
 */
- (void)startTaskWithCacheCompletionHandler:(CompletionHandlerWithCacheBlock)completionHandler;

- (void)saveResponseToCache:(id)obj;
/**
 *解析返回的json数据, 子类需要继承
 */
- (id)fetchDataWithRequest:(TBBaseRequest *)request;

@end
