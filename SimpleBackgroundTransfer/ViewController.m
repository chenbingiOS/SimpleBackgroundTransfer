//
//  ViewController.m
//  SimpleBackgroundTransfer
//
//  Created by 陈冰 on 2017/12/13.
//  Copyright © 2017年 ChenBing. All rights reserved.
//

#import "ViewController.h"
#import "CBAppDelegate.h"

// 测试用图片地址
static NSString *DownloadURLString = @"https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3965435538,609725007&fm=27&gp=0.jpg";

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSURLSessionDownloadTask *downloadTask;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.session = [self backgroundSession];
    
    self.progressView.progress = 0;
    self.progressView.hidden = YES;
    self.imageView.hidden = NO;
}

- (IBAction)actionStart:(id)sender {
    
    if (self.downloadTask) return;
    
    /*
     Create a new download task using the URL session. Tasks start in the “suspended” state; to start a task you need to explicitly call -resume on a task after creating it.
     使用URL会话创建一个新的下载任务。任务从“暂停”状态开始; 要开始一个任务需在创建任务后直接调用 -resume 方法。
     */
    NSURL *downloadURL = [NSURL URLWithString:DownloadURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    self.downloadTask = [self.session downloadTaskWithRequest:request];
    [self.downloadTask resume];
    
    self.imageView.hidden = YES;
    self.progressView.hidden = NO;
}

#pragma mark - NSURLSessionDelegate
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    CBAppDelegate *appDelegate = (CBAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundSessionCompletionHandler) {
        void(^completionHandler)(void) = appDelegate.backgroundSessionCompletionHandler;
        appDelegate.backgroundSessionCompletionHandler = nil;
        completionHandler();
    }
    NSLog(@"All tasks are finished");
}

#pragma mark - NSURLSessionTaskDelegate
// 网络请求任务失败，修改下进度条状态
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    BLog();
    
    if (error == nil) {
        NSLog(@"Task: %@ completed successfully",task);
    } else {
        NSLog(@"Task: %@ completed with error: %@", task, [error localizedDescription]);
    }
    
    CGFloat progress = (CGFloat)task.countOfBytesReceived / (CGFloat)task.countOfBytesExpectedToReceive;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = progress;
    });
    
    self.downloadTask = nil;
}

#pragma mark - NSURLSessionDownloadDelegate
// 下载进度条
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    BLog();
    
    if (downloadTask == self.downloadTask) {
        CGFloat progress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
        BLog(@"DownloadTask: %@ progress %lf", downloadTask, progress);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = progress;
        });
    }
}

// 数据下载完成
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    BLog();
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // Document 目录
    NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = URLs[0];
    // 原始URL 目标URL
    NSURL *originalURL = [[downloadTask originalRequest] URL];
    NSURL *destinationURL = [documentsDirectory URLByAppendingPathComponent:[originalURL lastPathComponent]];
    NSError *errorCopy;
    // 文件移动
    [fileManager removeItemAtURL:destinationURL error:NULL];
    BOOL success = [fileManager copyItemAtURL:location toURL:destinationURL error:&errorCopy];
    
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithContentsOfFile:[destinationURL path]];
            self.imageView.image = image;
            self.imageView.hidden = NO;
            self.progressView.hidden = YES;
        });
    } else {
        BLog(@"Error during the copy: %@", [errorCopy localizedDescription]);
    }
}

// 任务启动
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    BLog();
}

#pragma mark -
// MARK:layz
- (NSURLSession *)backgroundSession {
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.chenbing.exampleCode.SimpleBackgoundTransfer.BackroundSession"];
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    });
    return session;
}

@end
