//
//  ViewController.m
//  DownloaderDemo
//
//  Created by caohongyang on 2017/4/10.
//  Copyright © 2017年 ccoop. All rights reserved.
//

#import "ViewController.h"
#import "HYDownloaderManager.h"

@interface ViewController ()
/** 下载管理器 */
//@property (nonatomic, strong) HYDownloader *downloader;
@property (nonatomic, strong) NSURL *url;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)start:(id)sender {
    //下载
    HYDownloaderManager *downloader = [HYDownloaderManager shareDownloaderManager];
    //self.downloader = downloader;
    NSURL *url = [NSURL URLWithString:@"http://127.0.0.1/002--GCD.mp4"];
    url = [NSURL URLWithString:@"http://119.90.25.36/sw.bos.baidu.com/sw-search-sp/software/447feea06f61e/QQ_mac_5.5.1.dmg"];
    self.url = url;
    [downloader downloadWithURL:url progress:^(float progress) {
        //进度
        NSLog(@"-->%f %@",progress,[NSThread currentThread]);
    } completion:^(NSString *filePath) {
        //下载路径
        
        NSLog(@"-->下载完成:%@ %@",filePath,[NSThread currentThread]);
    } failed:^(NSString *errorMsg) {
        //下载失败
        NSLog(@"-->%@",errorMsg);
    }];
}
- (IBAction)pause:(id)sender {
    [[HYDownloaderManager shareDownloaderManager] pauseWithURL:self.url];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //下载
    HYDownloaderManager *downloader = [HYDownloaderManager shareDownloaderManager];
    //self.downloader = downloader;
    NSURL *url = [NSURL URLWithString:@"http://127.0.0.1/002--GCD.mp4"];
    url = [NSURL URLWithString:@"http://119.90.25.36/sw.bos.baidu.com/sw-search-sp/software/447feea06f61e/QQ_mac_5.5.1.dmg"];
    [downloader downloadWithURL:url progress:^(float progress) {
        //进度
        NSLog(@"-->%f %@",progress,[NSThread currentThread]);
    } completion:^(NSString *filePath) {
        //下载路径
        
        NSLog(@"-->下载完成:%@ %@",filePath,[NSThread currentThread]);
    } failed:^(NSString *errorMsg) {
        //下载失败
        NSLog(@"-->%@",errorMsg);
    }];
}
- (void)demo {
    //指针
    NSString *name = nil;
    int age = 10;
    int userID = [self userIDWithAge:&age title:&name];
    NSLog(@"age:%d userID:%d name:%@",age,userID,name);
}
- (int)userIDWithAge:(int*)age title:(NSString **)title{
    *age = 99;
    *title = [NSString stringWithFormat:@"lisi"];
    return 1;
}
//同步方法
- (void)demosendSynchronousReques {
    NSURL *url = [NSURL URLWithString:@"http://127.0.0.1/demo.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    //反序列化
    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    NSLog(@"%@--%@",result,response);
}


@end
