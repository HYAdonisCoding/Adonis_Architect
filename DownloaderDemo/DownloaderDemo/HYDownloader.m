//
//  HYDownlod.m
//  DownloaderDemo
//
//  Created by caohongyang on 2017/4/13.
//  Copyright © 2017年 ccoop. All rights reserved.
//

#import "HYDownloader.h"

/** NSURLSession下载
    1.跟踪进度
    2.断点续传
 */
@interface HYDownloader ()<NSURLConnectionDataDelegate>
/** 文件大小 */
@property (nonatomic, assign) long long expectedContentLength;
/** 文件名称 */
@property (nonatomic, copy) NSString *suggestedFilename;
/** 文件路径 */
@property (nonatomic, copy) NSString *filePath;
/** 本地文件大小 */
@property (nonatomic, assign) long long currentLength;

@property (nonatomic, strong) NSURL *downloadURL;
/** 文件输出流 */
@property (nonatomic, strong) NSOutputStream *fileStream;
@property (nonatomic, assign) CFRunLoopRef downloadRunLoop;
//----------block
@property (nonatomic, copy) void(^progressBlock)(float);
@property (nonatomic, copy) void(^completionBlock)(NSString*);
@property (nonatomic, copy) void(^failedBlock)(NSString*);

/** 下载的连接 */
@property (nonatomic, strong) NSURLConnection *downloadConnection;
@end
#define kTimeoutInterval 10

@implementation HYDownloader


- (void)downloadWithURL:(NSURL *)url progress:(void (^)(float))progress completion:(void (^)(NSString *))completion failed:(void (^)(NSString *))failed {
    self.progressBlock = (progress);
    self.completionBlock = (completion);
    self.failedBlock = failed;
    
    self.downloadURL = url;
    //检查服务器上的文件大小
    [self severFileInfoWithURL:url];
    //NSLog(@"%lld -- %@ -- %@",self.expectedContentLength,self.suggestedFilename,self.filePath);
    //检查本地文件的大小
    if (![self checkLocalFileInfo]) {
        //NSLog(@"文件已经下载完毕了");
        if (self.completionBlock) {
            self.completionBlock(self.filePath);
        }

        return;
    }
    //如果需要,从服务器开始下载
    NSLog(@"下载文件从%lld",self.currentLength);
    [self downloadFile];
}
- (void)pause {
    [self.downloadConnection cancel];
}
#pragma mark - <下载文件>
//从self.currentLength处开始下载文件
- (void)downloadFile {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //建立请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.downloadURL cachePolicy:1 timeoutInterval:kTimeoutInterval];
        //设置下载范围
        NSString *rangeStr = [NSString stringWithFormat:@"bytes=%lld-",self.currentLength];
        //设置请求头字段
        [request setValue:rangeStr forHTTPHeaderField:@"Range"];
        //开始网络连接
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
        self.downloadConnection = connection;
        
        [connection start];
        
        self.downloadRunLoop = CFRunLoopGetCurrent();
        CFRunLoopRun();

    });
}

#pragma mark - <私有方法>
- (BOOL)checkLocalFileInfo {
    long long fileSize = 0;
    //文件是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
        //获取文件大小
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:NULL];
        fileSize = [attributes fileSize];
        //NSLog(@"%lld", fileSize);

    }
    //大于服务器的文件
    if (fileSize > self.expectedContentLength) {
        //删除当前文件
        [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:NULL];
        fileSize = 0;
    }
    self.currentLength = fileSize;
    //是否和服务器的文件大小一样
    if (fileSize == self.expectedContentLength) {
        return NO;
    }
    return YES;
}
- (void)severFileInfoWithURL:(NSURL *)url {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:kTimeoutInterval];
    //只返回大小,不下载
    request.HTTPMethod = @"HEAD";
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    //NSLog(@"%@ -- %lld -- %@",response,response.expectedContentLength,response.suggestedFilename);
    //文件长度
    self.expectedContentLength = response.expectedContentLength;
    //文件名,tmp里
    self.filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:response.suggestedFilename];
    self.suggestedFilename = response.suggestedFilename;
}
#pragma mark - NSURLConnectionDataDelegate
//接收到服务器的响应
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.fileStream = [[NSOutputStream alloc] initToFileAtPath:self.filePath append:YES];
    [self.fileStream open];
}
//开始下载
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //追加数据
    [self.fileStream write:data.bytes maxLength:data.length];
    //记录文件的长度
    self.currentLength += data.length;
    
    float progress = (float)self.currentLength / self.expectedContentLength;
    if (self.progressBlock) {
        self.progressBlock(progress);
    }
    //NSLog(@"progress:%f %@", progress, [NSThread currentThread]);
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.fileStream close];
    //NSLog(@"下载完成");
    CFRunLoopStop(self.downloadRunLoop);
    if (self.completionBlock) {
        //主线程回调
        dispatch_async(dispatch_get_main_queue(), ^{self.completionBlock(self.filePath);});
    }
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.fileStream close];
    //NSLog(@"error:%@",error.localizedDescription);
    CFRunLoopStop(self.downloadRunLoop);
    if (self.failedBlock) {
        self.failedBlock(error.localizedDescription);
    }
}
@end
