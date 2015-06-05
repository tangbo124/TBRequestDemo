//
//  TBBaseRequest.m
//  TBRequestDemo
//
//  Created by TangBo on 15/2/13.
//  Copyright (c) 2015年 唐波. All rights reserved.
//

#import "TBBaseRequest.h"
#import "AFNetworking.h"
#import "TBNetworkConfig.h"
#import <CommonCrypto/CommonDigest.h>
#import "TBNetWorkAgent.h"

@implementation TBBaseRequest
{
    AFHTTPRequestOperationManager *_manager;
    BOOL ignoreCacheInTime;
    TBNetWorkAgent *networkAgent;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if ([self conformsToProtocol:@protocol(RequestAPIManager) ]) {
            self.child = (id<RequestAPIManager>)self;
            _manager = [AFHTTPRequestOperationManager manager];
            networkAgent = [TBNetWorkAgent shareInstance];
            ignoreCacheInTime = NO;
        } else {
            NSAssert(NO, @"没有继承RequestAPIManager协议");
        }
    }
    return self;
}

- (void)startTaskWithCacheCompletionHandler:(CompletionHandlerWithCacheBlock)completionHandler
{
    ignoreCacheInTime = YES;
    self.completionWithCacheHandler = completionHandler;
    NSString *cachePath = [self p_cacheFilePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        [self p_sendRequest];
        return;
    }
    
    id cacheObject = [NSKeyedUnarchiver unarchiveObjectWithFile:cachePath];
    self.responseObject = cacheObject;
    if (self.completionWithCacheHandler) {
        self.completionWithCacheHandler(self, nil, YES);
    }
    [self p_sendRequest];
}

- (void)startTaskWithCompletionHandler:(CompletionHandlerBlock)completionHandler
{
    self.completionHandler = completionHandler;
    
    NSString *cachePath = [self p_cacheFilePath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        [self p_sendRequest];
        return;
    }
    
    NSInteger duration = [self p_cacheFileDuration:cachePath];
    
    if (duration < 0 || duration > [self cacheTimeInSeconds] || [self cacheTimeInSeconds] <= 0) {
        [self p_sendRequest];
        return;
    }
    
    id responseObject = [NSKeyedUnarchiver unarchiveObjectWithFile:cachePath];
    self.responseObject = responseObject;
    if (self.completionHandler) {
        self.completionHandler(self, nil);
    }
}

- (void)cancelRequest
{
    [networkAgent removeRequest:self];
    self.completionHandler = nil;
    self.completionWithCacheHandler = nil;
}

- (void)p_sendRequest
{
    [networkAgent addRequest:self];
    /*
    TBRequestMethod method = [self requestMethod];
    NSString *requestUrl = [self p_buildRequestUrl];
    id param = [self requestArgument];
    if ([self requestSerializer] == TBHTTPRequestSerializer) {
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    }else if([self requestSerializer] == TBJSONRequestSerializer){
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    if ([self responseSerializer] == TBHTTPResponseSerializer) {
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }else if ([self responseSerializer] == TBJSONRequestSerializer){
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    _manager.requestSerializer.timeoutInterval = [self requestTimeoutInterval];
    if (method == TBRequestMethodGet) {
        self.requestOperation = [_manager GET:requestUrl parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self p_handleRequestOperation:operation error:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self p_handleRequestOperation:operation error:error];
        }];
    }else if(method == TBRequestMethodPost){
        self.requestOperation = [_manager POST:requestUrl parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self p_handleRequestOperation:operation error:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self p_handleRequestOperation:operation error:error];
        }];
    }else if (method == TBRequestMethodPut){
        self.requestOperation = [_manager PUT:requestUrl parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self p_handleRequestOperation:operation error:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self p_handleRequestOperation:operation error:error];
        }];
    }else if (method == TBRequestMethodHead){
        self.requestOperation = [_manager HEAD:requestUrl parameters:param success:^(AFHTTPRequestOperation *operation) {
            [self p_handleRequestOperation:operation error:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self p_handleRequestOperation:operation error:error];
        }];
    }else if (method == TBRequestMethodDelete){
        self.requestOperation = [_manager DELETE:requestUrl parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self p_handleRequestOperation:operation error:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self p_handleRequestOperation:operation error:error];
        }];
    }else if (method == TBRequestMethodPatch){
        self.requestOperation = [_manager PATCH:requestUrl parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self p_handleRequestOperation:operation error:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self p_handleRequestOperation:operation error:error];
        }];
    }
     */
}

- (NSInteger)cacheTimeInSeconds
{
    return -1;
}

- (id)requestArgument
{
    return nil;
}

- (TBRequestMethod)requestMethod
{
    return TBRequestMethodGet;
}

- (NSString *)requestUrl
{
    return nil;
}

- (NSTimeInterval)requestTimeoutInterval
{
    return 60;
}

- (TBRequestSerializer)requestSerializer
{
    return TBHTTPRequestSerializer;
}

- (TBResponseSerializer)responseSerializer
{
    return TBJSONResponseSerializer;
}

- (id)fetchDataWithRequest:(TBBaseRequest *)request
{
    return nil;
}

- (NSString *)p_buildRequestUrl
{
    TBNetworkConfig *config = [TBNetworkConfig defaultConfig];
    NSString *url = [self requestUrl];
    NSString *baseUrl = config.baseUrl;
    if (baseUrl.length > 0) {
        if (url.length > 0) {
            NSString *requestUrl =[NSString stringWithFormat:@"%@/%@", config.baseUrl, url];
            return requestUrl;
        }else
            return baseUrl;
    }
    return nil;
}

- (void)p_handleRequestOperation:(AFHTTPRequestOperation *)operation error:(NSError *)error
{
    self.responseObject = operation.responseObject;
    self.responseString = operation.responseString;
    [self saveResponseToCache:self.responseObject];
    if (self.completionHandler) {
        self.completionHandler(self, error);
    }else if (self.completionWithCacheHandler) {
        self.completionWithCacheHandler(self, error, NO);
    }
}

- (void)saveResponseToCache:(id)responseObject
{
    if (!ignoreCacheInTime && [self cacheTimeInSeconds] <= 0) {
        return;
    }
    
    if (responseObject != nil) {
        [NSKeyedArchiver archiveRootObject:responseObject toFile:[self p_cacheFilePath]];
    }
}

- (void)p_checkDirectory:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self p_createBaseDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self p_createBaseDirectoryAtPath:path];
        }
    }
}

- (void)p_createBaseDirectoryAtPath:(NSString *)path {
    __autoreleasing NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                               attributes:nil error:&error];
    if (error) {
        NSLog(@"create cache directory failed, error = %@", error);
    } else {
        NSURL *url = [NSURL fileURLWithPath:path];
        NSError *error = nil;
        [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
        if (error) {
            NSLog(@"error to set do not backup attribute, error = %@", error);
        }
    }
}

- (NSString *)p_cacheBasePath {
    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [pathOfLibrary stringByAppendingPathComponent:@"LazyRequestCache"];
    
    [self p_checkDirectory:path];
    return path;
}

- (NSString *)p_cacheFileName {
    NSString *requestUrl = [self p_buildRequestUrl];
    id argument = [self requestArgument];
    NSString *requestInfo = [NSString stringWithFormat:@"Method:%ld Url:%@ Argument:%@",
                             (long)[self requestMethod], requestUrl,
                             argument];
    NSString *cacheFileName = [self p_md5StringFromString:requestInfo];
    return cacheFileName;
}

- (NSString *)p_cacheFilePath {
    NSString *cacheFileName = [self p_cacheFileName];
    NSString *path = [self p_cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheFileName];
    return path;
}

- (int)p_cacheFileDuration:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // get file attribute
    NSError *attributesRetrievalError = nil;
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:path
                                                             error:&attributesRetrievalError];
    if (!attributes) {
        NSLog(@"Error get attributes for file at %@: %@", path, attributesRetrievalError);
        return -1;
    }
    int seconds = -[[attributes fileModificationDate] timeIntervalSinceNow];
    return seconds;
}

- (NSString *)p_md5StringFromString:(NSString *)string {
    if(string == nil || [string length] == 0)
        return nil;
    
    const char *value = [string UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}
@end
