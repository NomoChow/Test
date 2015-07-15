//
//  Test2_downloadViewController.m
//  NSURLSession_Test
//
//  Created by 周建顺 on 15/7/4.
//  Copyright (c) 2015年 周建顺. All rights reserved.
//

#import "Test2_downloadViewController.h"
#import "AppDelegate.h"

#define kCurrentSession @"zjs_cancelabel_session_description"
#define kBackgroundSessionConfigIdentify @"zjs_background_session_config_identify"
#define kBackgroundSession @"zjs_background_session_description"

@interface Test2_downloadViewController ()<NSURLSessionDownloadDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *porgressView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelabelDownload_item;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *resumableDownload_item;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backgrounDownload_item;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelDownload_item;
@property (weak, nonatomic) IBOutlet UIImageView *downloadImage;


@property (nonatomic,strong) NSURLSession *currentSession;
@property (nonatomic,strong,readonly) NSURLSession *backgroundSession;

@property (nonatomic,strong) NSURLSessionDownloadTask *cancelableDownloadTask;
@property (nonatomic,strong) NSURLSessionDownloadTask *resumeableDownloadTask;
@property (nonatomic,strong) NSURLSessionDownloadTask*backgroundDownloadTask;

@property (nonatomic,strong) NSData *resumeData;
@property (nonatomic,strong) NSData *bgResumeData;

@end

@implementation Test2_downloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)downloadAction:(id)sender {
    
    if (!self.cancelableDownloadTask) {
        
        NSURL *url = [NSURL URLWithString:@"http://b.hiphotos.baidu.com/image/w%3D2048/sign=6be5fc5f718da9774e2f812b8469f919/8b13632762d0f703b0faaab00afa513d2697c515.jpg"];
        
       // NSURL *url = [NSURL URLWithString:@"http://music.baidu.com/cms/mobile/static/apk/BaiduMusic-pcwebdownpagetest.apk"];
        self.cancelableDownloadTask = [self.currentSession downloadTaskWithURL:url];
        self.downloadImage.image = nil;
        [self.cancelableDownloadTask resume];
    }
    
}
- (IBAction)resumDownloadAction:(id)sender {
    if (!self.resumeableDownloadTask) {
        if (self.resumeData) {
            self.resumeableDownloadTask = [self.currentSession downloadTaskWithResumeData:self.resumeData];
        }else{
            
            NSURL *url = [NSURL URLWithString:@"http://p1.pichost.me/i/40/1639665.png"];
            //            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            //            self.resumeableDownloadTask = [self.currentSession downloadTaskWithRequest:request];
            
            self.resumeableDownloadTask = [self.currentSession downloadTaskWithURL:url];;
        }
        [self.resumeableDownloadTask resume];
    }
    
}
- (IBAction)backgroundDownload:(id)sender {
    
    if (!self.backgroundDownloadTask) {
             AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        NSString *caches =  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        self.bgResumeData = [NSData dataWithContentsOfFile:[caches stringByAppendingPathComponent:@"resume.dat"]];
        if (self.bgResumeData) {
            self.backgroundDownloadTask = [self.backgroundSession downloadTaskWithResumeData:self.bgResumeData];
        }else{
            NSURL *url = [NSURL URLWithString:@"http://p1.pichost.me/i/40/1639665.png"];
            self.backgroundDownloadTask = [self.backgroundSession downloadTaskWithURL:url];
        }
        

        
        delegate.backgroundDownloadTask =  self.backgroundDownloadTask;
        [self.backgroundDownloadTask resume];
    }
    
    
}
- (IBAction)cancelDownload:(id)sender {
    if (self.cancelableDownloadTask) {
        [self.cancelableDownloadTask cancel];
        self.cancelableDownloadTask = nil;
        self.progressLabel.text = @"0";
        self.porgressView.progress = 0;
    }else if(self.resumeableDownloadTask){
        [self.resumeableDownloadTask cancelByProducingResumeData:^(NSData *resumeData) {
            self.resumeData = resumeData;
            self.resumeableDownloadTask = nil;
        }];
    }else if(self.backgroundDownloadTask){
        NSError *error;
        NSString *caches =  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        [[NSFileManager defaultManager] removeItemAtPath:[caches stringByAppendingPathComponent:@"resume.dat"] error:&error];
        
        [self.backgroundDownloadTask cancelByProducingResumeData:^(NSData *resumeData) {

            
            [self saveData:resumeData];
            
        }];
        

        
//        [self.backgroundDownloadTask cancel];
//        self.backgroundDownloadTask = nil;
//        self.progressLabel.text = @"0";
//        self.porgressView.progress = 0;
    }
    
}


-(NSURLSession *)currentSession{
    if (!_currentSession) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
       _currentSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
        _currentSession.sessionDescription = kCurrentSession;
    }
    return _currentSession;
}

-(NSURLSession*)backgroundSession{
    static NSURLSession *instance;
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        NSURLSessionConfiguration *backgroundconfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:kBackgroundSessionConfigIdentify];
        instance = [NSURLSession sessionWithConfiguration:backgroundconfig delegate:self delegateQueue:nil];
        instance.sessionDescription = kBackgroundSession;
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    });
    return instance;
}



-(NSString*)getDoucmentsPath{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
    return path;
}

#pragma mark - downloadsesson delegate
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
    if (self.cancelableDownloadTask == downloadTask) {
        NSData *data = [NSData dataWithContentsOfFile:[location path]];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.downloadImage.image = image;
            // self.downloadImage.image = [UIImage imageWithContentsOfFile:[location path]];;
            self.cancelableDownloadTask = nil;
        });
    }else if(self.resumeableDownloadTask == downloadTask){
        
        NSData *data = [NSData dataWithContentsOfFile:[location path]];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.downloadImage.image = image;
            // self.downloadImage.image = [UIImage imageWithContentsOfFile:[location path]];;
            self.resumeData = nil;
            self.resumeableDownloadTask = nil;
        });

    }else if(self.backgroundDownloadTask == downloadTask){
        // 后台下载成功
        // 成功调用
        NSData *data = [NSData dataWithContentsOfFile:[location path]];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.downloadImage.image = image;
       
            self.progressLabel.text =[NSString stringWithFormat:@"%.2f",1.f*100];
            self.porgressView.progress = 1;
            AppDelegate *delegate = [UIApplication sharedApplication].delegate;
           
            void(^handler)(void)  = delegate.backgroundCompleteHandler;
            if (handler) {
                handler();
            }
    
            delegate.backgroundCompleteHandler = nil;
            
            self.backgroundDownloadTask = nil;
            
            NSError *error;
            NSString *caches =  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
            [[NSFileManager defaultManager] removeItemAtPath:[caches stringByAppendingPathComponent:@"resume.dat"] error:&error];
        });
    }


}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    
    if (self.backgroundDownloadTask ==task) {
        if (error) {

            
            NSData *da = [error.userInfo valueForKey:@"NSURLSessionDownloadTaskResumeData"];
            
            if (da) {
                
                NSError *nserror;
                NSString *caches =  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
                [[NSFileManager defaultManager] removeItemAtPath:[caches stringByAppendingPathComponent:@"resume.dat"] error:&nserror];
                
                UIApplication *application = [UIApplication sharedApplication];
                __block UIBackgroundTaskIdentifier bgTask;
                bgTask =  [application beginBackgroundTaskWithExpirationHandler:^{
                    [application endBackgroundTask:bgTask];
                    bgTask = UIBackgroundTaskInvalid;
                }];
                

                NSString *path = [caches stringByAppendingPathComponent:@"resume.dat"];
                BOOL isSuccess = [da writeToFile:path atomically:NO];
                self.backgroundDownloadTask = nil;
                self.downloadImage.image = nil;
                [application endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
            }else{
            
                self.backgroundDownloadTask = nil;
                self.downloadImage.image = nil;
            }
     
            NSLog(@"下载失败：%@", error);

    
        }
    }

}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
   NSLog(@"NSURLSessionDownloadDelegate: Resume download at %lld", fileOffset);
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    NSLog(@"didWriteData");
    float progress = (float)totalBytesWritten/totalBytesExpectedToWrite;
    NSLog(@"%.2f",progress);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressLabel.text =[NSString stringWithFormat:@"%.2f",progress*100];
        self.porgressView.progress =progress;
    });

}

-(void)saveData:(NSData*)resumeData{
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask =  [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    NSString *caches =  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [caches stringByAppendingPathComponent:@"resume.dat"];
    BOOL isSuccess = [resumeData writeToFile:path atomically:NO];
    
    [application endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
}

@end
