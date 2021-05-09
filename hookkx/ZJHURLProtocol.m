#import "ZJHURLProtocol.h"
#import "ZJHSessionConfiguration.h"
#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>
#import "SCLAlertView.h"

// 为了避免canInitWithRequest和canonicalRequestForRequest的死循环
static NSString *const kProtocolHandledKey = @"kProtocolHandledKey";

@interface ZJHURLProtocol () <NSURLConnectionDelegate,NSURLConnectionDataDelegate, NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSOperationQueue     *sessionDelegateQueue;
@property (nonatomic, strong) NSURLResponse        *response;

@end

@implementation ZJHURLProtocol

#pragma mark - Public

/// 开始监听
+ (void)load {
    ZJHSessionConfiguration *sessionConfiguration = [ZJHSessionConfiguration defaultConfiguration];
    [NSURLProtocol registerClass:[ZJHURLProtocol class]];
    if (![sessionConfiguration isSwizzle]) {
        [sessionConfiguration load];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addTimerToButtonIndex:0 reverse:YES];
        [alert showInfo:@"温馨提示" subTitle:(@"qq:371851287") closeButtonTitle:@"关闭" duration:10];
        
    });
     
}

/// 停止监听
+ (void)stopMonitor {
    ZJHSessionConfiguration *sessionConfiguration = [ZJHSessionConfiguration defaultConfiguration];
    [NSURLProtocol unregisterClass:[ZJHURLProtocol class]];
    if ([sessionConfiguration isSwizzle]) {
        [sessionConfiguration unload];
    }
}

#pragma mark - Override

/**
 需要控制的请求
 
 @param request 此次请求
 @return 是否需要监控
 */
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    // 如果是已经拦截过的就放行，避免出现死循环
    
    
    // 不是网络请求，不处理
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    
//     指定拦截网络请求，如：www.baidu.com
    if ([request.URL.absoluteString containsString:@"www.baidu.com"]) {
        return YES;
    }else {
        return NO;
    }
    
    // 拦截所有
    return YES;
}

/**
 设置我们自己的自定义请求
 可以在这里统一加上头之类的
 
 @param request 应用的此次请求
 @return 我们自定义的请求
 */
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    // 设置已处理标志
    [NSURLProtocol setProperty:@(YES)
                        forKey:kProtocolHandledKey
                     inRequest:mutableReqeust];
    return [mutableReqeust copy];
}

// 重新父类的开始加载方法
- (void)startLoading {
  //  NSLog(@"***ZJH 监听接口：%@", self.request.URL.absoluteString);
    NSDictionary *chickenjson = @{@"key":@"1393762170",@"expire_at":@"6663465200000325000",@"token":@"01CX2DV780PKBN44JHPWPACT1Z"};
    NSData *redirectData =[NSJSONSerialization dataWithJSONObject:chickenjson options: 0 error:NULL];
    NSURLResponse *redirectresponse = [[NSURLResponse alloc] initWithURL:self.request.URL
                                                                MIMEType:@"application/json"
                                                   expectedContentLength:redirectData.length
                                                        textEncodingName:nil];
    [[self client] URLProtocol:self didReceiveResponse:redirectresponse cacheStoragePolicy:NSURLCacheStorageAllowed];
    [self.client URLProtocol:self didLoadData:redirectData];
    [self.client URLProtocolDidFinishLoading:self];
}
// 结束加载
- (void)stopLoading {
    [self.dataTask cancel];
}
@end
