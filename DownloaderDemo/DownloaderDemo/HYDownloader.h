//
//  HYDownlod.h
//  DownloaderDemo
//
//  Created by caohongyang on 2017/4/13.
//  Copyright © 2017年 ccoop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HYDownloader : NSObject

/** 下载 */
- (void)downloadWithURL:(NSURL *)url progress:(void(^)(float progress))progress completion:(void(^)(NSString *filePath))completion failed:(void(^)(NSString *errorMsg))failed;
/** 暂停 */
- (void)pause;

@end
