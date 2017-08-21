//
//  HYDownloaderManager.m
//  DownloaderDemo
//
//  Created by caohongyang on 2017/4/14.
//  Copyright © 2017年 ccoop. All rights reserved.
//

#import "HYDownloaderManager.h"
#import "HYDownloader.h"

@interface HYDownloaderManager ()

/** 下载操作的缓冲池 */
@property (nonatomic, strong) NSMutableDictionary *downloaderCache;
/** 失败的回调属性 */
@property (nonatomic, copy) void (^failedBlock)(NSString*);
@end

@implementation HYDownloaderManager

- (NSMutableDictionary *)downloaderCache {
    if (!_downloaderCache) {
        _downloaderCache = [[NSMutableDictionary alloc] init];
    }
    return _downloaderCache;
}
/**
 
 */
+ (instancetype)shareDownloaderManager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)downloadWithURL:(NSURL *)url progress:(void(^)(float progress))progress completion:(void(^)(NSString *filePath))completion failed:(void(^)(NSString *errorMsg))failed{
    self.failedBlock = failed;
    //判断
    HYDownloader *downloader = self.downloaderCache[url.path];
    if (downloader != nil) {
        NSLog(@"下载操作存在!!");
        return;
    }
    //创建新的下载任务
    downloader = [[HYDownloader alloc] init];
    //保存到缓冲池
    [self.downloaderCache setObject:downloader forKey:url.path];
    //下载完成后清楚下载操作
    [downloader downloadWithURL:url progress:progress completion:^(NSString *filePath) {
        //从下周缓冲池中删除下载操作
        [self.downloaderCache removeObjectForKey:url.path];
        //执行调用方传递的block
        if (completion) {
            completion(filePath);
        }
    } failed:^(NSString *errorMsg) {
        //从下载缓冲池中删除下载操作!
        [self.downloaderCache removeObjectForKey:url.path];
        if (failed) {
            failed(errorMsg);
        }
    }];
}

- (void)pauseWithURL:(NSURL *)url {
    //通过URL获取下载任务
    HYDownloader *downloader = self.downloaderCache[url.path];
    //判断操作是否存在
    if (downloader == nil) {
        if (self.failedBlock) {
            self.failedBlock(@"操作不存在!");
        }
        return;
    }
    
    //暂停
    [downloader pause];
    //从缓存池删除
    [self.downloaderCache removeObjectForKey:url.path];
}
@end
